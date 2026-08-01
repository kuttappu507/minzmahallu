/*
 * DashboardView.cpp — Flat emerald dashboard
 * ZERO inline setStyleSheet() — all styling via QSS cssClass properties.
 * Fonts: Poppins (English) + Gayathri (Malayalam)
 */
#include "DashboardView.h"
#include "../services/DashboardService.h"
#include "../services/SettingsService.h"
#include "../services/AuthSession.h"
#include "../core/Database.h"
#include "../core/I18N.h"
#include "../core/StyleProps.h"
#include "../core/ThemeColors.h"
#include "../core/IconUtils.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGridLayout>
#include <QScrollArea>
#include <QLabel>
#include <QPushButton>
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
#include <QSizePolicy>
#include <QDate>
#include <QtCharts/QChart>
#include <QtCharts/QChartView>
#include <QtCharts/QLineSeries>
#include <QtCharts/QBarSeries>
#include <QtCharts/QBarSet>
#include <QtCharts/QBarCategoryAxis>
#include <QtCharts/QValueAxis>

namespace mms {

DashboardView::DashboardView(QWidget* parent) : QWidget(parent) { setupUi(); refresh(); }

// Render SVG icon as QPixmap with specified color
static QPixmap renderSvg(const QString& svgPath, const QString& color, int size) {
    QPixmap pix(size, size);
    pix.fill(Qt::transparent);
    QSvgRenderer svg(svgPath);
    if (svg.isValid()) {
        QPainter p(&pix);
        p.setRenderHint(QPainter::Antialiasing);
        svg.render(&p, QRectF(0, 0, size, size));
        p.end();
        QImage img = pix.toImage();
        QColor col(color);
        for (int y = 0; y < img.height(); y++)
            for (int x = 0; x < img.width(); x++) {
                int a = qAlpha(img.pixel(x, y));
                if (a > 0) img.setPixel(x, y, qRgba(col.red(), col.green(), col.blue(), a));
            }
        return QPixmap::fromImage(img);
    }
    return pix;
}

// Solid color icon square (flat design — colored bg, white icon)
static QLabel* makeSolidIcon(QWidget* parent, const QString& svgPath,
                             const QString& bgColor, int size = 37) {
    auto* lbl = new QLabel(parent);
    lbl->setFixedSize(size, size);
    const int S = size * 2;
    QPixmap pix(S, S);
    pix.fill(Qt::transparent);
    QPainter p(&pix);
    p.setRenderHint(QPainter::Antialiasing);
    p.setBrush(QColor(bgColor));
    p.setPen(Qt::NoPen);
    p.drawRoundedRect(0, 0, S, S, S*0.25, S*0.25);
    QSvgRenderer svg(svgPath);
    if (svg.isValid()) {
        int is = size;
        QPixmap iconPix(is, is);
        iconPix.fill(Qt::transparent);
        QPainter ip(&iconPix);
        ip.setRenderHint(QPainter::Antialiasing);
        svg.render(&ip, QRectF(0, 0, is, is));
        ip.end();
        QImage img = iconPix.toImage();
        for (int y = 0; y < img.height(); y++)
            for (int x = 0; x < img.width(); x++) {
                int a = qAlpha(img.pixel(x, y));
                if (a > 0) img.setPixel(x, y, qRgba(255, 255, 255, a));
            }
        p.drawPixmap((S-is)/2, (S-is)/2, QPixmap::fromImage(img));
    }
    p.end();
    lbl->setPixmap(pix.scaled(size, size, Qt::KeepAspectRatio, Qt::SmoothTransformation));
    return lbl;
}

// Stat card definitions with tint names
struct StatDef {
    const char* i18nKey;
    const char* iconPath;
    const char* solidColor;  // for icon bg
    const char* deltaText;
    bool deltaUp;
    const char* tintName;   // "em", "teal", etc.
};

static const StatDef STAT_DEFS[] = {
    {"dash_total_families",     ":/icons/families.svg",      "#059669", "+6 this month",      true,  "em"},
    {"dash_total_members",      ":/icons/members.svg",       "#0d9488", "+18 this month",     true,  "teal"},
    {"dash_active_members",     ":/icons/check.svg",         "#0284c7", "86.3% active",       true,  "sky"},
    {"dash_monthly_collection", ":/icons/dollar.svg",        "#d97706", "+9.1% vs June",      true,  "gold"},
    {"dash_pending_dues",       ":/icons/alert.svg",         "#e11d48", "7 families overdue", false, "rose"},
    {"dash_donations_month",    ":/icons/donations.svg",     "#db2777", "+12.4% vs June",     true,  "pink"},
    {"dash_welfare_disbursed",  ":/icons/welfare.svg",       "#7c3aed", "14 beneficiaries",   true,  "violet"},
    {"dash_marriages_year",     ":/icons/marriage.svg",      "#ea580c", "2 this quarter",     true,  "orange"},
    {"dash_deaths_year",        ":/icons/death.svg",         "#64748b", "1 this month",       false, "slate"},
    {"dash_balance_month",      ":/icons/reports.svg",       "#2563eb", "across all funds",   true,  "blue"},
};

QWidget* DashboardView::makeStatCard(int index, QLabel*& valueLabel) {
    const auto& s = STAT_DEFS[index];
    auto* card = new QFrame(this);
    // Use cssClass for tint background+border — NO inline setStyleSheet
    QString tintClass = QString("statTint-%1").arg(s.tintName);
    StyleProps::set(card, tintClass.toUtf8().constData());
    card->setMinimumHeight(115);
    card->setMaximumHeight(135);
    card->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);

    auto* v = new QVBoxLayout(card);
    v->setContentsMargins(14, 13, 14, 12);
    v->setSpacing(6);

    // Top row: solid icon (left) + delta badge (right)
    auto* srow = new QHBoxLayout();
    srow->setSpacing(8);
    srow->addWidget(makeSolidIcon(card, s.iconPath, s.solidColor, 37));
    srow->addStretch();
    auto* delta = new QLabel(QString(s.deltaUp ? "▲ " : "▼ ") + s.deltaText, card);
    StyleProps::set(delta, s.deltaUp ? "deltaUp" : "deltaDown");
    delta->setWordWrap(false);
    srow->addWidget(delta);
    v->addLayout(srow);

    // Value (large, colored) — cssClass drives the color
    valueLabel = new QLabel("—", card);
    QString valClass = QString("statVal-%1").arg(s.tintName);
    StyleProps::set(valueLabel, valClass.toUtf8().constData());
    valueLabel->setWordWrap(false);
    v->addWidget(valueLabel);

    // Label (small uppercase) — cssClass drives the color
    auto* lbl = new QLabel(TR(s.i18nKey), card);
    QString labClass = QString("statLab-%1").arg(s.tintName);
    StyleProps::set(lbl, labClass.toUtf8().constData());
    lbl->setWordWrap(true);
    v->addWidget(lbl);

    return card;
}

QWidget* DashboardView::makeChartCard(const QString& title, const QString& subtitle,
                                       const QString& tintName, QWidget* chart) {
    auto* card = new QFrame(this);
    card->setObjectName("card");
    card->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);

    auto* v = new QVBoxLayout(card);
    v->setContentsMargins(16, 15, 16, 8);
    v->setSpacing(6);

    // Title with colored left border — via cssClass
    auto* titleLbl = new QLabel(title, card);
    QString titleClass = QString("chartTitle-%1").arg(tintName);
    StyleProps::set(titleLbl, titleClass.toUtf8().constData());
    v->addWidget(titleLbl);

    if (!subtitle.isEmpty()) {
        auto* subLbl = new QLabel(subtitle, card);
        StyleProps::set(subLbl, "chartSub");
        v->addWidget(subLbl);
    }

    chart->setParent(card);
    v->addWidget(chart, 1);
    return card;
}

// Quick action button definitions
struct QADef {
    const char* i18nKey;
    const char* iconPath;
    const char* iconColor;
    const char* subtitle;
    const char* cssClass;
    int navIndex;
};

static const QADef QA_DEFS[] = {
    {"dash_quick_add_family",       ":/icons/families.svg",      "#059669", "F-0013 next",        "qaGreen",  1},
    {"dash_quick_add_member",       ":/icons/members.svg",       "#0d9488", "1,142 on record",    "qaBlue",   2},
    {"dash_quick_record_payment",   ":/icons/subscriptions.svg", "#d97706", "RCP-2026-048",       "qaOrange", 3},
    {"dash_quick_add_donation",     ":/icons/donations.svg",     "#db2777", "5 categories",       "qaIndigo", 4},
    {"dash_quick_generate_report",  ":/icons/reports.svg",       "#7c3aed", "15 report types",    "qaPurple", 10},
};

static QPushButton* makeQuickAction(QWidget* parent, const QADef& qa) {
    auto* btn = new QPushButton(parent);
    StyleProps::set(btn, qa.cssClass);
    btn->setCursor(Qt::PointingHandCursor);
    btn->setMinimumHeight(56);
    btn->setMaximumHeight(68);
    btn->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);

    auto* h = new QHBoxLayout(btn);
    h->setContentsMargins(12, 12, 12, 12);
    h->setSpacing(10);

    auto* iconLbl = makeSolidIcon(btn, qa.iconPath, qa.iconColor, 42);
    h->addWidget(iconLbl);

    auto* textCol = new QVBoxLayout();
    textCol->setSpacing(1);
    auto* titleLbl = new QLabel(TR(qa.i18nKey), btn);
    StyleProps::set(titleLbl, "qaTitle");
    titleLbl->setWordWrap(false);
    auto* subLbl = new QLabel(qa.subtitle, btn);
    StyleProps::set(subLbl, "qaSub");
    subLbl->setWordWrap(false);
    textCol->addWidget(titleLbl);
    textCol->addWidget(subLbl);
    h->addLayout(textCol, 1);

    return btn;
}

void DashboardView::setupUi() {
    auto* scroll = new QScrollArea(this);
    scroll->setWidgetResizable(true);
    scroll->setFrameShape(QFrame::NoFrame);
    auto* content = new QWidget(scroll);
    content->setObjectName("contentArea");

    auto* layout = new QVBoxLayout(content);
    layout->setSpacing(16);
    layout->setContentsMargins(22, 20, 22, 26);

    // 1. View header
    auto* header = new QHBoxLayout();
    header->setSpacing(14);
    auto* titleCol = new QVBoxLayout();
    titleCol->setSpacing(3);
    auto* title = new QLabel(TR("dash_greeting") + " " + AuthSession::instance().user().fullName, content);
    StyleProps::set(title, "h1");
    titleCol->addWidget(title);
    auto* welcome = new QLabel(TR("dash_subtitle"), content);
    StyleProps::set(welcome, "viewSub");
    titleCol->addWidget(welcome);
    header->addLayout(titleCol);
    header->addStretch();

    auto* dateChip = new QLabel(QDateTime::currentDateTime().toString("dddd, dd MMMM yyyy"), content);
    StyleProps::set(dateChip, "dateChip");
    header->addWidget(dateChip);

    refreshBtn_ = new QPushButton(TR("action_refresh"), content);
    StyleProps::set(refreshBtn_, "chip");
    refreshBtn_->setCursor(Qt::PointingHandCursor);
    refreshBtn_->setIcon(QIcon(renderSvg(":/icons/refresh.svg", "#4f6b5c", 16)));
    refreshBtn_->setIconSize(QSize(16, 16));
    header->addWidget(refreshBtn_);
    connect(refreshBtn_, &QPushButton::clicked, this, &DashboardView::refresh);
    layout->addLayout(header);

    // 2. Quick action row
    auto* qaLayout = new QHBoxLayout();
    qaLayout->setSpacing(12);
    QPushButton* qaBtns[5];
    for (int i = 0; i < 5; i++) {
        qaBtns[i] = makeQuickAction(content, QA_DEFS[i]);
        qaLayout->addWidget(qaBtns[i], 1);
        int navIdx = QA_DEFS[i].navIndex;
        connect(qaBtns[i], &QPushButton::clicked, this, [this, navIdx](){ emit navigateToView(navIdx); });
    }
    qaAddFamily_ = qaBtns[0]; qaAddMember_ = qaBtns[1]; qaPayment_ = qaBtns[2];
    qaDonation_ = qaBtns[3]; qaReport_ = qaBtns[4];
    layout->addLayout(qaLayout);

    // 3. Stat grid 5×2
    auto* statGrid = new QGridLayout();
    statGrid->setSpacing(12);
    statGrid->setContentsMargins(0, 0, 0, 0);
    QLabel* statLabels[10];
    for (int i = 0; i < 10; i++) {
        int row = i / 5, col = i % 5;
        statGrid->addWidget(makeStatCard(i, statLabels[i]), row, col);
    }
    lblFamilies_ = statLabels[0]; lblMembers_ = statLabels[1]; lblActive_ = statLabels[2];
    lblCollection_ = statLabels[3]; lblPending_ = statLabels[4]; lblDonations_ = statLabels[5];
    lblWelfare_ = statLabels[6]; lblMarriages_ = statLabels[7]; lblDeaths_ = statLabels[8];
    lblBalance_ = statLabels[9];
    layout->addLayout(statGrid);

    // 4. Chart grid 2×2
    auto* chartGrid = new QGridLayout();
    chartGrid->setSpacing(12);
    chartGrid->setContentsMargins(0, 0, 0, 0);

    auto* cc = new QChart(); auto* cv1 = new QChartView(cc); cv1->setMinimumHeight(220); cv1->setRenderHint(QPainter::Antialiasing);
    chartGrid->addWidget(makeChartCard(TR("dash_chart_collections"), "Subscription receipts · last 12 months", "em", cv1), 0, 0);
    auto* dc = new QChart(); auto* cv2 = new QChartView(dc); cv2->setMinimumHeight(220); cv2->setRenderHint(QPainter::Antialiasing);
    chartGrid->addWidget(makeChartCard(TR("dash_chart_donations"), "All categories · last 12 months", "gold", cv2), 0, 1);
    auto* ic = new QChart(); auto* cv3 = new QChartView(ic); cv3->setMinimumHeight(220); cv3->setRenderHint(QPainter::Antialiasing);
    chartGrid->addWidget(makeChartCard(TR("dash_chart_income_expense"), "Financial year 2026-27 · to date", "violet", cv3), 1, 0);
    auto* mc = new QChart(); auto* cv4 = new QChartView(mc); cv4->setMinimumHeight(220); cv4->setRenderHint(QPainter::Antialiasing);
    chartGrid->addWidget(makeChartCard(TR("dash_chart_membership_growth"), "Total registered members", "sky", cv4), 1, 1);
    layout->addLayout(chartGrid);

    // 5. Recent activity table
    auto* rg = new QFrame(content);
    rg->setObjectName("card");
    auto* rl = new QVBoxLayout(rg);
    rl->setContentsMargins(16, 15, 16, 15);
    rl->setSpacing(6);
    auto* rTitle = new QLabel(TR("dash_recent_activity"), rg);
    StyleProps::set(rTitle, "chartTitle-em");
    auto* rSub = new QLabel(TR("dash_recent_activity_sub"), rg);
    StyleProps::set(rSub, "chartSub");
    rl->addWidget(rTitle);
    rl->addWidget(rSub);
    recentTable_ = new QTableWidget(rg);
    recentTable_->setColumnCount(4);
    recentTable_->setHorizontalHeaderLabels({TR("audit_time"), TR("audit_user"), TR("audit_action"), TR("audit_description")});
    recentTable_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    recentTable_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    recentTable_->setAlternatingRowColors(true);
    recentTable_->setMaximumHeight(220);
    recentTable_->verticalHeader()->setVisible(false);
    rl->addWidget(recentTable_);
    layout->addWidget(rg);

    layout->addStretch();
    scroll->setWidget(content);
    auto* ol = new QVBoxLayout(this);
    ol->setContentsMargins(0, 0, 0, 0);
    ol->addWidget(scroll);
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
    auto charts = findChildren<QChartView*>();
    if (charts.size() < 4) return;
    bool isDark = qApp->palette().color(QPalette::Window).lightness() < 128;
    QChart::ChartTheme chartTheme = isDark ? QChart::ChartThemeDark : QChart::ChartThemeLight;
    QColor axisLabelColor = isDark ? QColor("#9fb8aa") : QColor("#7e968a");
    QColor gridColor = isDark ? QColor("#23402f") : QColor("#d2e5d8");

    for (auto* cv : charts) {
        QChart* ch = cv->chart();
        ch->setTheme(chartTheme); ch->setBackgroundVisible(false);
        ch->setMargins(QMargins(8,8,8,8)); ch->setTitle(""); ch->legend()->hide();
    }

    // Chart 1: Collections (emerald)
    auto* cc = charts[0]->chart(); cc->removeAllSeries(); for (auto* a : cc->axes()) cc->removeAxis(a);
    auto* s1 = new QLineSeries(); s1->setColor(QColor("#059669")); s1->setPointsVisible(true);
    auto cd = svc.monthlyCollections(12); QStringList m1; double mx1 = 0; int i = 0;
    for (const auto& m : cd) { double a = m.toMap().value("amount").toDouble(); s1->append(i, a); m1 << m.toMap().value("month").toString(); if (a > mx1) mx1 = a; ++i; }
    cc->addSeries(s1);
    auto* ax1 = new QBarCategoryAxis(); ax1->append(m1); ax1->setGridLineVisible(false); cc->addAxis(ax1, Qt::AlignBottom); s1->attachAxis(ax1);
    auto* ay1 = new QValueAxis(); ay1->setRange(0, mx1 * 1.2 + 1); ay1->setLabelFormat("%.0f"); cc->addAxis(ay1, Qt::AlignLeft); s1->attachAxis(ay1);

    // Chart 2: Donations (gold)
    auto* dc = charts[1]->chart(); dc->removeAllSeries(); for (auto* a : dc->axes()) dc->removeAxis(a);
    auto* s2 = new QLineSeries(); s2->setColor(QColor("#d97706")); s2->setPointsVisible(true);
    auto dd = svc.donationsByCategory(QDate::currentDate().addMonths(-12).toString(Qt::ISODate), QDate::currentDate().toString(Qt::ISODate));
    QStringList m2; double mx2 = 0; int j = 0;
    for (const auto& m : dd) { double a = m.toMap().value("amount").toDouble(); s2->append(j, a); m2 << m.toMap().value("category").toString(); if (a > mx2) mx2 = a; ++j; }
    dc->addSeries(s2);
    auto* ax2 = new QBarCategoryAxis(); ax2->append(m2); ax2->setGridLineVisible(false); dc->addAxis(ax2, Qt::AlignBottom); s2->attachAxis(ax2);
    auto* ay2 = new QValueAxis(); ay2->setRange(0, mx2 * 1.2 + 1); ay2->setLabelFormat("%.0f"); dc->addAxis(ay2, Qt::AlignLeft); s2->attachAxis(ay2);

    // Chart 3: Income vs Expense (bar)
    auto* ic = charts[2]->chart(); ic->removeAllSeries(); for (auto* a : ic->axes()) ic->removeAxis(a);
    auto ie = svc.incomeVsExpense(6);
    auto* is = new QBarSet(TR("acc_income")); is->setColor(QColor("#059669"));
    auto* es = new QBarSet(TR("acc_expense")); es->setColor(QColor("#e11d48"));
    QStringList m3; double mx3 = 0;
    for (const auto& m : ie) { is->append(m.toMap().value("income").toDouble()); es->append(m.toMap().value("expense").toDouble()); m3 << m.toMap().value("month").toString(); mx3 = std::max({mx3, m.toMap().value("income").toDouble(), m.toMap().value("expense").toDouble()}); }
    auto* bs = new QBarSeries(); bs->append(is); bs->append(es); ic->addSeries(bs);
    auto* ax3 = new QBarCategoryAxis(); ax3->append(m3); ax3->setGridLineVisible(false); ic->addAxis(ax3, Qt::AlignBottom); bs->attachAxis(ax3);
    auto* ay3 = new QValueAxis(); ay3->setRange(0, mx3 * 1.2 + 1); ay3->setLabelFormat("%.0f"); ic->addAxis(ay3, Qt::AlignLeft); bs->attachAxis(ay3);
    ic->legend()->setVisible(true); ic->legend()->setAlignment(Qt::AlignBottom); ic->legend()->show();

    // Chart 4: Membership growth (sky)
    auto* mc = charts[3]->chart(); mc->removeAllSeries(); for (auto* a : mc->axes()) mc->removeAxis(a);
    auto* ms = new QLineSeries(); ms->setColor(QColor("#0284c7")); ms->setPointsVisible(true);
    auto mg = svc.membershipGrowth(12); QStringList m4; double mx4 = 0; int mi = 0;
    for (const auto& m : mg) { double t = m.toMap().value("total").toDouble(); ms->append(mi, t); m4 << m.toMap().value("month").toString(); if (t > mx4) mx4 = t; ++mi; }
    mc->addSeries(ms);
    auto* ax4 = new QBarCategoryAxis(); ax4->append(m4); ax4->setGridLineVisible(false); mc->addAxis(ax4, Qt::AlignBottom); ms->attachAxis(ax4);
    auto* ay4 = new QValueAxis(); ay4->setRange(0, mx4 * 1.1 + 1); ay4->setLabelFormat("%.0f"); mc->addAxis(ay4, Qt::AlignLeft); ms->attachAxis(ay4);

    for (auto* cv : charts) { QChart* ch = cv->chart(); for (auto* a : ch->axes()) { a->setLabelsColor(axisLabelColor); a->setGridLineColor(gridColor); a->setLinePenColor(axisLabelColor); } }
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
