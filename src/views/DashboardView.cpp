#include "DashboardView.h"
#include "../services/DashboardService.h"
#include "../services/SettingsService.h"
#include "../services/AuthSession.h"
#include "../core/Database.h"
#include "../core/I18N.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGridLayout>
#include <QScrollArea>
#include <QLabel>
#include <QPushButton>
#include "FlowLayout.h"
#include <QFrame>
#include <QTableWidget>
#include <QHeaderView>
#include <QDateTime>
#include <QPainter>
#include <QImage>
#include <QSvgRenderer>
#include <QGraphicsDropShadowEffect>
#include <QPalette>
#include <QApplication>
#include <QBrush>
#include <QSizePolicy>
#include <QtCharts/QChart>
#include <QtCharts/QChartView>
#include <QtCharts/QLineSeries>
#include <QtCharts/QBarSeries>
#include <QtCharts/QBarSet>
#include <QtCharts/QBarCategoryAxis>
#include <QtCharts/QValueAxis>
#include <QtCharts/QPieSeries>
#include <QtCharts/QPieSlice>

namespace mms {

DashboardView::DashboardView(QWidget* parent) : QWidget(parent) { setupUi(); refresh(); }

static QLabel* makeIcon(QWidget* parent, const QString& svgPath, const QString& pastelBg, const QString& iconColor) {
    auto* lbl = new QLabel(parent);
    lbl->setFixedSize(48, 48);
    const int S = 96;
    QPixmap pix(S, S);
    pix.fill(Qt::transparent);
    QPainter p(&pix);
    p.setRenderHint(QPainter::Antialiasing);
    p.setRenderHint(QPainter::SmoothPixmapTransform);
    p.setBrush(QColor(pastelBg));
    p.setPen(Qt::NoPen);
    p.drawEllipse(0, 0, S, S);
    QSvgRenderer svg(svgPath);
    if (svg.isValid()) {
        const int IS = 48;
        QPixmap iconPix(IS, IS);
        iconPix.fill(Qt::transparent);
        QPainter ip(&iconPix);
        ip.setRenderHint(QPainter::Antialiasing);
        ip.setRenderHint(QPainter::SmoothPixmapTransform);
        svg.render(&ip, QRectF(0, 0, IS, IS));
        ip.end();
        QImage img = iconPix.toImage();
        QColor col(iconColor);
        for (int y = 0; y < img.height(); y++)
            for (int x = 0; x < img.width(); x++) {
                int a = qAlpha(img.pixel(x, y));
                if (a > 0) img.setPixel(x, y, qRgba(col.red(), col.green(), col.blue(), a));
            }
        p.drawPixmap((S-IS)/2, (S-IS)/2, QPixmap::fromImage(img));
    }
    p.end();
    lbl->setPixmap(pix.scaled(48, 48, Qt::KeepAspectRatio, Qt::SmoothTransformation));
    return lbl;
}

static QPushButton* makeColorBtn(QWidget* parent, const QString& text, const QString& svgPath, const QString& iconColor, const QString& objName = "") {
    auto* btn = new QPushButton(text, parent);
    if (!objName.isEmpty()) btn->setObjectName(objName);
    btn->setCursor(Qt::PointingHandCursor);
    btn->setMinimumHeight(40);
    QPixmap iconPix(36, 36);
    iconPix.fill(Qt::transparent);
    QSvgRenderer svg(svgPath);
    if (svg.isValid()) {
        QPainter hp(&iconPix);
        hp.setRenderHint(QPainter::Antialiasing);
        svg.render(&hp, QRectF(0, 0, 36, 36));
        hp.end();
        QImage img = iconPix.toImage();
        QColor col(iconColor);
        for (int y = 0; y < img.height(); y++)
            for (int x = 0; x < img.width(); x++) {
                int a = qAlpha(img.pixel(x, y));
                if (a > 0) img.setPixel(x, y, qRgba(col.red(), col.green(), col.blue(), a));
            }
        btn->setIcon(QIcon(QPixmap::fromImage(img)));
        btn->setIconSize(QSize(18, 18));
    }
    return btn;
}

QWidget* DashboardView::makeStatCard(const QString& title, QLabel*& valueLabel,
                                     const QString&, const QString& iconBg,
                                     const QString& iconColor, const QString& iconPath,
                                     const QString& sub) {
    auto* card = new QFrame(this);
    card->setObjectName("statCard");
    card->setMinimumHeight(140);
    card->setMinimumWidth(220);
    card->setMaximumWidth(300);
    card->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Preferred);
    auto* shadow = new QGraphicsDropShadowEffect(card);
    shadow->setBlurRadius(8);
    shadow->setOffset(0, 1);
    shadow->setColor(QColor(0, 0, 0, 10));
    card->setGraphicsEffect(shadow);
    auto* h = new QHBoxLayout(card);
    h->setSpacing(14);
    h->setContentsMargins(20, 20, 20, 20);
    h->addWidget(makeIcon(card, iconPath, iconBg, iconColor));
    auto* v = new QVBoxLayout();
    v->setSpacing(2);
    auto* lbl = new QLabel(title, card);
    lbl->setObjectName("chartCardTitle");
    v->addWidget(lbl);
    valueLabel = new QLabel(QString::fromUtf8("\xe2\x80\x94"), card);
    valueLabel->setObjectName("statCardValue");
    //old:—", card);
    v->addWidget(valueLabel);
    if (!sub.isEmpty()) {
        auto* subLbl = new QLabel(sub, card);
        subLbl->setObjectName("statCardSub");
        v->addWidget(subLbl);
    }
    v->addStretch();
    h->addLayout(v, 1);
    return card;
}

QWidget* DashboardView::makeChartCard(const QString& title, QWidget* chart) {
    auto* card = new QFrame(this);
    card->setObjectName("card");
    auto* shadow = new QGraphicsDropShadowEffect(card);
    shadow->setBlurRadius(8);
    shadow->setOffset(0, 1);
    shadow->setColor(QColor(0, 0, 0, 8));
    card->setGraphicsEffect(shadow);
    auto* v = new QVBoxLayout(card);
    v->setContentsMargins(24, 24, 24, 24);
    v->setSpacing(12);
    auto* lbl = new QLabel(title, card);
    lbl->setObjectName("statCardTitle");
    v->addWidget(lbl);
    v->addWidget(chart, 1);
    return card;
}

void DashboardView::setupUi() {
    auto* scroll = new QScrollArea(this);
    scroll->setWidgetResizable(true);
    scroll->setFrameShape(QFrame::NoFrame);
    auto* content = new QWidget(scroll);
    auto* layout = new QVBoxLayout(content);
    layout->setSpacing(24);
    layout->setContentsMargins(24, 24, 24, 24);
    auto* header = new QHBoxLayout();
    auto* titleCol = new QVBoxLayout();
    titleCol->setSpacing(4);
    auto* title = new QLabel(TR("dash_title"), content);
    title->setObjectName("dashTitle");
    titleCol->addWidget(title);
    auto* welcome = new QLabel("Welcome back, " + AuthSession::instance().user().fullName + "!", content);
    welcome->setObjectName("dashWelcome");
    titleCol->addWidget(welcome);
    header->addLayout(titleCol);
    header->addStretch();
    refreshBtn_ = new QPushButton(TR("action_refresh"), content);
    refreshBtn_->setObjectName("action_refresh");
    refreshBtn_->setCursor(Qt::PointingHandCursor);
    refreshBtn_->setMinimumHeight(38);
    header->addWidget(refreshBtn_);
    connect(refreshBtn_, &QPushButton::clicked, this, &DashboardView::refresh);
    layout->addLayout(header);
    auto* qaLayout = new QHBoxLayout();
    qaLayout->setSpacing(12);
    qaAddFamily_ = makeColorBtn(content, TR("dash_quick_add_family"), ":/icons/families.svg", "#3b82f6", "dash_qa_blue");
    qaAddMember_ = makeColorBtn(content, TR("dash_quick_add_member"), ":/icons/members.svg", "#8b5cf6", "dash_qa_purple");
    qaPayment_ = makeColorBtn(content, TR("dash_quick_record_payment"), ":/icons/subscriptions.svg", "#10b981", "dash_qa_green");
    qaDonation_ = makeColorBtn(content, TR("dash_quick_add_donation"), ":/icons/donations.svg", "#f59e0b", "dash_qa_orange");
    qaReport_ = makeColorBtn(content, TR("dash_quick_generate_report"), ":/icons/reports.svg", "#6366f1", "dash_qa_indigo");
    for (auto* b : {qaAddFamily_, qaAddMember_, qaPayment_, qaDonation_, qaReport_}) qaLayout->addWidget(b);
    qaLayout->addStretch();
    layout->addLayout(qaLayout);
    connect(qaAddFamily_, &QPushButton::clicked, this, [this](){ emit navigateToView(1); });
    connect(qaAddMember_, &QPushButton::clicked, this, [this](){ emit navigateToView(2); });
    connect(qaPayment_, &QPushButton::clicked, this, [this](){ emit navigateToView(3); });
    connect(qaDonation_, &QPushButton::clicked, this, [this](){ emit navigateToView(4); });
    connect(qaReport_, &QPushButton::clicked, this, [this](){ emit navigateToView(10); });
    auto* sg = new FlowLayout(0, 16, 16);
    
    sg->addWidget(makeStatCard(TR("dash_total_families"), lblFamilies_, "", "#dbeafe", "#3b82f6", ":/icons/families.svg", "View all"));
    sg->addWidget(makeStatCard(TR("dash_total_members"), lblMembers_, "", "#dcfce7", "#22c55e", ":/icons/members.svg", "View all"));
    sg->addWidget(makeStatCard(TR("dash_active_members"), lblActive_, "", "#ccfbf1", "#14b8a6", ":/icons/check.svg", "100% of total"));
    sg->addWidget(makeStatCard(TR("dash_monthly_collection"), lblCollection_, "", "#ffedd5", "#f97316", ":/icons/dollar.svg", "This month"));
    sg->addWidget(makeStatCard(TR("dash_pending_dues"), lblPending_, "", "#fee2e2", "#ef4444", ":/icons/alert.svg", "Pending"));
    sg->addWidget(makeStatCard(TR("dash_donations_month"), lblDonations_, "", "#f3e8ff", "#a855f7", ":/icons/donations.svg", "This month"));
    sg->addWidget(makeStatCard(TR("dash_welfare_disbursed"), lblWelfare_, "", "#fef3c7", "#f59e0b", ":/icons/welfare.svg", "This month"));
    sg->addWidget(makeStatCard(TR("dash_marriages_year"), lblMarriages_, "", "#cffafe", "#06b6d4", ":/icons/marriage.svg", "This year"));
    sg->addWidget(makeStatCard(TR("dash_deaths_year"), lblDeaths_, "", "#f3f4f6", "#6b7280", ":/icons/death.svg", "This year"));
    sg->addWidget(makeStatCard(TR("dash_balance_month"), lblBalance_, "", "#dbeafe", "#3b82f6", ":/icons/reports.svg", "Current"));
    layout->addLayout(sg);
    auto* cl = new FlowLayout(0, 16, 16);
    auto* cc = new QChart(); auto* cv = new QChartView(cc); cv->setMinimumHeight(250); cv->setRenderHint(QPainter::Antialiasing);
    cl->addWidget(makeChartCard(TR("dash_chart_collections"), cv));
    auto* dc = new QChart(); auto* dv = new QChartView(dc); dv->setMinimumHeight(250); dv->setRenderHint(QPainter::Antialiasing);
    cl->addWidget(makeChartCard(TR("dash_chart_donations"), dv));
    layout->addLayout(cl);
    
    auto* ic = new QChart(); auto* iv = new QChartView(ic); iv->setMinimumHeight(250); iv->setRenderHint(QPainter::Antialiasing);
    cl->addWidget(makeChartCard(TR("dash_chart_income_expense"), iv));
    auto* mc = new QChart(); auto* mv = new QChartView(mc); mv->setMinimumHeight(250); mv->setRenderHint(QPainter::Antialiasing);
    cl->addWidget(makeChartCard(TR("dash_chart_membership_growth"), mv));
    
    auto* rg = new QFrame(this); rg->setObjectName("card");
    auto* rshadow = new QGraphicsDropShadowEffect(rg); rshadow->setBlurRadius(8); rshadow->setOffset(0, 1); rshadow->setColor(QColor(0,0,0,8));
    rg->setGraphicsEffect(rshadow);
    auto* rl = new QVBoxLayout(rg); rl->setContentsMargins(24, 24, 24, 24); rl->setSpacing(12);
    auto* rTitle = new QLabel(TR("dash_recent_activity"), rg);
    rl->addWidget(rTitle);
    recentTable_ = new QTableWidget(rg);
    recentTable_->setColumnCount(4);
    recentTable_->setHorizontalHeaderLabels({TR("audit_time"), TR("audit_user"), TR("audit_action"), TR("audit_description")});
    recentTable_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    recentTable_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    recentTable_->setAlternatingRowColors(true);
    recentTable_->setMaximumHeight(200);
    rl->addWidget(recentTable_);
    layout->addWidget(rg);
    layout->addStretch();
    scroll->setWidget(content);
    auto* ol = new QVBoxLayout(this); ol->setContentsMargins(0, 0, 0, 0); ol->addWidget(scroll);
}

void DashboardView::refresh() { loadStats(); loadCharts(); loadRecentActivity(); }

void DashboardView::loadStats() {
    DashboardService svc; auto s = svc.load();
    QString cur = SettingsService::instance().currencySymbol();
    lblFamilies_->setText(QString::number(s.totalFamilies));
    lblMembers_->setText(QString::number(s.totalMembers));
    lblActive_->setText(QString::number(s.activeMembers));
    lblCollection_->setText(cur + QString::number(s.monthlyCollection, 'f', 0));
    lblPending_->setText(cur + QString::number(s.pendingDues, 'f', 0));
    lblDonations_->setText(cur + QString::number(s.monthlyDonations, 'f', 0));
    lblWelfare_->setText(QString::number(s.welfareBeneficiaries));
    lblMarriages_->setText(QString::number(s.marriagesThisYear));
    lblDeaths_->setText(QString::number(s.deathsThisYear));
    lblBalance_->setText(cur + QString::number(s.balanceThisMonth, 'f', 0));
}

void DashboardView::loadCharts() {
    DashboardService svc;
    auto charts = findChildren<QChartView*>(); if (charts.size() < 4) return;
    bool isDark = qApp->palette().color(QPalette::Window).lightness() < 128;
    QChart::ChartTheme chartTheme = isDark ? QChart::ChartThemeDark : QChart::ChartThemeLight;
    QColor axisTitleColor = isDark ? QColor("#e2e8f0") : QColor("#1e293b");
    QColor axisLabelColor = isDark ? QColor("#94a3b8") : QColor("#64748b");
    QColor gridColor = isDark ? QColor("#334155") : QColor("#f1f5f9");
    for (auto* cv : charts) { QChart* ch = cv->chart(); ch->setTheme(chartTheme); ch->setBackgroundVisible(false); ch->setMargins(QMargins(8,8,8,8)); ch->setTitle(""); ch->legend()->setLabelColor(axisLabelColor); }
    auto* cc = charts[0]->chart(); cc->removeAllSeries(); for (auto* a : cc->axes()) cc->removeAxis(a);
    auto* s1 = new QLineSeries(); s1->setColor(QColor("#3b82f6")); s1->setPointsVisible(true);
    auto cd = svc.monthlyCollections(6); QStringList m1; double mx1 = 0; int i = 0;
    for (const auto& m : cd) { double a = m.toMap().value("amount").toDouble(); s1->append(i, a); m1 << m.toMap().value("month").toString(); if (a > mx1) mx1 = a; ++i; }
    cc->addSeries(s1);
    auto* ax1 = new QBarCategoryAxis(); ax1->append(m1); ax1->setGridLineVisible(false); cc->addAxis(ax1, Qt::AlignBottom); s1->attachAxis(ax1);
    auto* ay1 = new QValueAxis(); ay1->setRange(0, mx1 * 1.2 + 1); ay1->setLabelFormat("%.0f"); cc->addAxis(ay1, Qt::AlignLeft); s1->attachAxis(ay1);
    auto* dc = charts[1]->chart(); dc->removeAllSeries();
    auto dd = svc.donationsByCategory(QDate::currentDate().addMonths(-6).toString(Qt::ISODate), QDate::currentDate().toString(Qt::ISODate));
    auto* pie = new QPieSeries(); QStringList cols = {"#3b82f6","#22c55e","#a855f7","#f59e0b","#14b8a6"}; int ci = 0;
    for (const auto& m : dd) { auto* sl = pie->append(m.toMap().value("category").toString(), m.toMap().value("amount").toDouble()); sl->setColor(QColor(cols[ci % cols.size()])); sl->setLabelVisible(true); ++ci; }
    dc->addSeries(pie); dc->legend()->setAlignment(Qt::AlignBottom);
    auto* ic = charts[2]->chart(); ic->removeAllSeries(); for (auto* a : ic->axes()) ic->removeAxis(a);
    auto ie = svc.incomeVsExpense(6);
    auto* is = new QBarSet(TR("acc_income")); is->setColor(QColor("#22c55e"));
    auto* es = new QBarSet(TR("acc_expense")); es->setColor(QColor("#ef4444"));
    QStringList m2; double mx2 = 0;
    for (const auto& m : ie) { is->append(m.toMap().value("income").toDouble()); es->append(m.toMap().value("expense").toDouble()); m2 << m.toMap().value("month").toString(); mx2 = std::max({mx2, m.toMap().value("income").toDouble(), m.toMap().value("expense").toDouble()}); }
    auto* bs = new QBarSeries(); bs->append(is); bs->append(es); ic->addSeries(bs);
    auto* ax2 = new QBarCategoryAxis(); ax2->append(m2); ax2->setGridLineVisible(false); ic->addAxis(ax2, Qt::AlignBottom); bs->attachAxis(ax2);
    auto* ay2 = new QValueAxis(); ay2->setRange(0, mx2 * 1.2 + 1); ay2->setLabelFormat("%.0f"); ic->addAxis(ay2, Qt::AlignLeft); bs->attachAxis(ay2);
    ic->legend()->setVisible(true); ic->legend()->setAlignment(Qt::AlignBottom);
    auto* mc = charts[3]->chart(); mc->removeAllSeries(); for (auto* a : mc->axes()) mc->removeAxis(a);
    auto* ms = new QLineSeries(); ms->setColor(QColor("#a855f7"));
    auto mg = svc.membershipGrowth(12); QStringList m3; double mx3 = 0; int mi = 0;
    for (const auto& m : mg) { double t = m.toMap().value("total").toDouble(); ms->append(mi, t); m3 << m.toMap().value("month").toString(); if (t > mx3) mx3 = t; ++mi; }
    mc->addSeries(ms);
    auto* ax3 = new QBarCategoryAxis(); ax3->append(m3); ax3->setGridLineVisible(false); mc->addAxis(ax3, Qt::AlignBottom); ms->attachAxis(ax3);
    auto* ay3 = new QValueAxis(); ay3->setRange(0, mx3 * 1.1 + 1); ay3->setLabelFormat("%.0f"); mc->addAxis(ay3, Qt::AlignLeft); ms->attachAxis(ay3);
    for (auto* cv : charts) { QChart* ch = cv->chart(); for (auto* a : ch->axes()) { a->setLabelsColor(axisLabelColor); a->setTitleBrush(QBrush(axisTitleColor)); a->setGridLineColor(gridColor); a->setLinePenColor(axisLabelColor); } }
}

void DashboardView::loadRecentActivity() {
    QSqlQuery q = Database::instance().execute("SELECT created_at, username, action, description FROM audit_log ORDER BY id DESC LIMIT 15");
    recentTable_->setRowCount(0);
    while (q.next()) { int r = recentTable_->rowCount(); recentTable_->insertRow(r);
        recentTable_->setItem(r, 0, new QTableWidgetItem(q.value(0).toString()));
        recentTable_->setItem(r, 1, new QTableWidgetItem(q.value(1).toString()));
        recentTable_->setItem(r, 2, new QTableWidgetItem(q.value(2).toString()));
        recentTable_->setItem(r, 3, new QTableWidgetItem(q.value(3).toString())); }
}

} // namespace mms
