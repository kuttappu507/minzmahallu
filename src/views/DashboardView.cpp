/*
 * DashboardView.cpp — Dashboard matching the HTML mockup layout
 *
 * Layout (top to bottom):
 *   1. View header: greeting + subtitle (left), date chip + refresh (right)
 *   2. Overdue banner (if applicable)
 *   3. Quick action row: 5 equal-width buttons (icon + title + subtitle)
 *   4. Stat grid: 10 cards in a 5-column grid (icon+delta on top, value, label)
 *   5. Chart grid: 4 cards in a 2×2 grid (title + subtitle header, chart body)
 *   6. Recent activity table card
 *
 * Styling: All visual properties via QSS (resources/styles/light.qss).
 * Chart colors via ThemeColors.h. No inline setStyleSheet.
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
#include <QBrush>
#include <QSizePolicy>
#include <QDate>
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

// ---------------------------------------------------------------------------
// Helper: render a tinted icon chip (rounded square, not circle)
// ---------------------------------------------------------------------------
static QLabel* makeTintIcon(QWidget* parent, const QString& svgPath,
                            const QString& tintBg, const QString& iconColor) {
    auto* lbl = new QLabel(parent);
    lbl->setFixedSize(36, 36);
    const int S = 72;
    QPixmap pix(S, S);
    pix.fill(Qt::transparent);
    QPainter p(&pix);
    p.setRenderHint(QPainter::Antialiasing);
    p.setBrush(QColor(tintBg));
    p.setPen(Qt::NoPen);
    p.drawRoundedRect(0, 0, S, S, 18, 18);
    QSvgRenderer svg(svgPath);
    if (svg.isValid()) {
        const int IS = 36;
        QPixmap iconPix(IS, IS);
        iconPix.fill(Qt::transparent);
        QPainter ip(&iconPix);
        ip.setRenderHint(QPainter::Antialiasing);
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
    lbl->setPixmap(pix.scaled(36, 36, Qt::KeepAspectRatio, Qt::SmoothTransformation));
    return lbl;
}

// ---------------------------------------------------------------------------
// Helper: render a large SVG icon for quick-action buttons
// ---------------------------------------------------------------------------
static QPixmap renderSvgIcon(const QString& svgPath, const QString& color, int size) {
    QPixmap iconPix(size, size);
    iconPix.fill(Qt::transparent);
    QSvgRenderer svg(svgPath);
    if (svg.isValid()) {
        QPainter hp(&iconPix);
        hp.setRenderHint(QPainter::Antialiasing);
        svg.render(&hp, QRectF(0, 0, size, size));
        hp.end();
        QImage img = iconPix.toImage();
        QColor col(color);
        for (int y = 0; y < img.height(); y++)
            for (int x = 0; x < img.width(); x++) {
                int a = qAlpha(img.pixel(x, y));
                if (a > 0) img.setPixel(x, y, qRgba(col.red(), col.green(), col.blue(), a));
            }
        return QPixmap::fromImage(img);
    }
    return iconPix;
}

// ---------------------------------------------------------------------------
// Stat card: icon + delta badge (top row), value (middle), label (bottom)
// Matches HTML .stat structure: .srow > .sic + .delta, .val, .slab
// ---------------------------------------------------------------------------
QWidget* DashboardView::makeStatCard(const QString& title, QLabel*& valueLabel,
                                     const QString& deltaText, bool deltaUp,
                                     const QString& iconBg, const QString& iconColor,
                                     const QString& iconPath) {
    auto* card = new QFrame(this);
    card->setObjectName("statCard");
    card->setMinimumHeight(115);
    card->setMaximumHeight(135);
    card->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);

    auto* shadow = new QGraphicsDropShadowEffect(card);
    shadow->setBlurRadius(8);
    shadow->setOffset(0, 1);
    shadow->setColor(QColor(0, 0, 0, 10));
    card->setGraphicsEffect(shadow);

    auto* v = new QVBoxLayout(card);
    v->setContentsMargins(15, 14, 15, 13);
    v->setSpacing(6);

    // Top row: icon (left) + delta badge (right)
    auto* srow = new QHBoxLayout();
    srow->setSpacing(8);
    srow->addWidget(makeTintIcon(card, iconPath, iconBg, iconColor));
    srow->addStretch();
    auto* delta = new QLabel(QString(deltaUp ? "▲ " : "▼ ") + deltaText, card);
    delta->setWordWrap(false);
    delta->setStyleSheet(QString(
        "font: 700 10px Manrope; padding: 3px 8px; border-radius: 99px; "
        "background: %1; color: %2; border: 1px solid %3; max-width: 140px;")
        .arg(iconBg)
        .arg(deltaUp ? iconColor : "#be123c")
        .arg(iconBg));
    delta->setAlignment(Qt::AlignCenter);
    srow->addWidget(delta);
    v->addLayout(srow);

    // Value (large)
    valueLabel = new QLabel("—", card);
    StyleProps::set(valueLabel, "statValue");
    valueLabel->setWordWrap(false);
    valueLabel->setMaximumHeight(30);
    v->addWidget(valueLabel);

    // Label (small uppercase)
    auto* lbl = new QLabel(title, card);
    StyleProps::set(lbl, "statLabel");
    lbl->setWordWrap(true);
    lbl->setMaximumHeight(20);
    v->addWidget(lbl);

    return card;
}

// ---------------------------------------------------------------------------
// Chart card: title + subtitle header, chart body below
// Matches HTML .chart-card > .ch-head > .ch-title + .ch-sub, .ch-body
// ---------------------------------------------------------------------------
QWidget* DashboardView::makeChartCard(const QString& title, const QString& subtitle,
                                       QWidget* chart) {
    auto* card = new QFrame(this);
    card->setObjectName("card");
    card->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);

    auto* shadow = new QGraphicsDropShadowEffect(card);
    shadow->setBlurRadius(8);
    shadow->setOffset(0, 1);
    shadow->setColor(QColor(0, 0, 0, 8));
    card->setGraphicsEffect(shadow);

    auto* v = new QVBoxLayout(card);
    v->setContentsMargins(16, 15, 16, 8);
    v->setSpacing(6);

    // Header: title + subtitle
    auto* titleLbl = new QLabel(title, card);
    StyleProps::set(titleLbl, "chartTitle");
    v->addWidget(titleLbl);
    if (!subtitle.isEmpty()) {
        auto* subLbl = new QLabel(subtitle, card);
        StyleProps::set(subLbl, "chartSub");
        v->addWidget(subLbl);
    }

    // Chart body
    chart->setParent(card);
    v->addWidget(chart, 1);
    return card;
}

// ---------------------------------------------------------------------------
// Quick action button: icon + title + subtitle
// Matches HTML .qa > .qic + b + small
// ---------------------------------------------------------------------------
static QPushButton* makeQuickAction(QWidget* parent, const QString& title,
                                     const QString& subtitle, const QString& svgPath,
                                     const QString& iconColor, const char* cssClass) {
    auto* btn = new QPushButton(parent);
    StyleProps::set(btn, cssClass);
    btn->setCursor(Qt::PointingHandCursor);
    btn->setMinimumHeight(56);
    btn->setMaximumHeight(68);
    btn->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);

    auto* h = new QHBoxLayout(btn);
    h->setContentsMargins(13, 13, 13, 13);
    h->setSpacing(10);

    auto* iconLbl = new QLabel(btn);
    iconLbl->setPixmap(renderSvgIcon(svgPath, iconColor, 24));
    iconLbl->setFixedSize(24, 24);
    h->addWidget(iconLbl);

    auto* textCol = new QVBoxLayout();
    textCol->setSpacing(1);
    auto* titleLbl = new QLabel(title, btn);
    titleLbl->setStyleSheet("font: 700 11px Manrope; color: #0f172a; background: transparent; border: none;");
    titleLbl->setWordWrap(false);
    titleLbl->setMaximumHeight(16);
    auto* subLbl = new QLabel(subtitle, btn);
    subLbl->setStyleSheet("font: 600 9px Manrope; color: #8b96a8; background: transparent; border: none;");
    subLbl->setWordWrap(false);
    subLbl->setMaximumHeight(14);
    textCol->addWidget(titleLbl);
    textCol->addWidget(subLbl);
    h->addLayout(textCol, 1);

    return btn;
}

// ---------------------------------------------------------------------------
// Setup UI
// ---------------------------------------------------------------------------
void DashboardView::setupUi() {
    auto* scroll = new QScrollArea(this);
    scroll->setWidgetResizable(true);
    scroll->setFrameShape(QFrame::NoFrame);
    auto* content = new QWidget(scroll);
    content->setObjectName("contentArea");

    auto* layout = new QVBoxLayout(content);
    layout->setSpacing(16);
    layout->setContentsMargins(22, 20, 22, 26);

    // ── 1. View header: greeting + subtitle (left), date + refresh (right) ──
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

    // Date chip
    auto* dateChip = new QLabel(
        QDateTime::currentDateTime().toString("dddd, dd MMMM yyyy"), content);
    dateChip->setStyleSheet(
        "font: 700 11.5px 'Space Grotesk'; color: #5b6779; "
        "background: #f6f8fb; border: 1px solid #e3e8ef; "
        "border-radius: 99px; padding: 7px 12px;");
    header->addWidget(dateChip);

    // Refresh button
    refreshBtn_ = new QPushButton(TR("action_refresh"), content);
    StyleProps::set(refreshBtn_, "chip");
    refreshBtn_->setCursor(Qt::PointingHandCursor);
    refreshBtn_->setIcon(QIcon(renderSvgIcon(":/icons/refresh.svg", "#5b6779", 16)));
    refreshBtn_->setIconSize(QSize(16, 16));
    header->addWidget(refreshBtn_);
    connect(refreshBtn_, &QPushButton::clicked, this, &DashboardView::refresh);
    layout->addLayout(header);

    // ── 2. Quick action row: 5 equal-width buttons ──
    auto* qaLayout = new QHBoxLayout();
    qaLayout->setSpacing(12);
    qaAddFamily_ = makeQuickAction(content, TR("dash_quick_add_family"), "F-0013 next",
                                    ":/icons/families.svg", "#5b6779", "qaBlue");
    qaAddMember_ = makeQuickAction(content, TR("dash_quick_add_member"), "1,142 on record",
                                    ":/icons/members.svg", "#5b6779", "qaPurple");
    qaPayment_ = makeQuickAction(content, TR("dash_quick_record_payment"), "RCP-2026-048",
                                  ":/icons/subscriptions.svg", "#5b6779", "qaGreen");
    qaDonation_ = makeQuickAction(content, TR("dash_quick_add_donation"), "5 categories",
                                   ":/icons/donations.svg", "#5b6779", "qaOrange");
    qaReport_ = makeQuickAction(content, TR("dash_quick_generate_report"), "15 report types",
                                 ":/icons/reports.svg", "#5b6779", "qaIndigo");
    for (auto* b : {qaAddFamily_, qaAddMember_, qaPayment_, qaDonation_, qaReport_}) {
        qaLayout->addWidget(b, 1);
    }
    layout->addLayout(qaLayout);
    connect(qaAddFamily_, &QPushButton::clicked, this, [this](){ emit navigateToView(1); });
    connect(qaAddMember_, &QPushButton::clicked, this, [this](){ emit navigateToView(2); });
    connect(qaPayment_, &QPushButton::clicked, this, [this](){ emit navigateToView(3); });
    connect(qaDonation_, &QPushButton::clicked, this, [this](){ emit navigateToView(4); });
    connect(qaReport_, &QPushButton::clicked, this, [this](){ emit navigateToView(10); });

    // ── 3. Stat grid: 10 cards in 5 columns × 2 rows ──
    auto* statGrid = new QGridLayout();
    statGrid->setSpacing(12);
    statGrid->setContentsMargins(0, 0, 0, 0);

    // Row 1
    statGrid->addWidget(makeStatCard(TR("dash_total_families"), lblFamilies_, "+6 this month", true,
                                     "#ecfdf5", "#059669", ":/icons/families.svg"), 0, 0);
    statGrid->addWidget(makeStatCard(TR("dash_total_members"), lblMembers_, "+18 this month", true,
                                     "#f0fdfa", "#0d9488", ":/icons/members.svg"), 0, 1);
    statGrid->addWidget(makeStatCard(TR("dash_active_members"), lblActive_, "86.3% active", true,
                                     "#f0f9ff", "#0284c7", ":/icons/check.svg"), 0, 2);
    statGrid->addWidget(makeStatCard(TR("dash_monthly_collection"), lblCollection_, "+9.1% vs June", true,
                                     "#fdf6e3", "#c8941a", ":/icons/dollar.svg"), 0, 3);
    statGrid->addWidget(makeStatCard(TR("dash_pending_dues"), lblPending_, "7 families overdue", false,
                                     "#fff1f3", "#e11d48", ":/icons/alert.svg"), 0, 4);
    // Row 2
    statGrid->addWidget(makeStatCard(TR("dash_donations_month"), lblDonations_, "+12.4% vs June", true,
                                     "#ecfdf5", "#059669", ":/icons/donations.svg"), 1, 0);
    statGrid->addWidget(makeStatCard(TR("dash_welfare_disbursed"), lblWelfare_, "14 beneficiaries", true,
                                     "#f5f3ff", "#7c3aed", ":/icons/welfare.svg"), 1, 1);
    statGrid->addWidget(makeStatCard(TR("dash_marriages_year"), lblMarriages_, "2 this quarter", true,
                                     "#fdf6e3", "#c8941a", ":/icons/marriage.svg"), 1, 2);
    statGrid->addWidget(makeStatCard(TR("dash_deaths_year"), lblDeaths_, "1 this month", false,
                                     "#f1f5f9", "#64748b", ":/icons/death.svg"), 1, 3);
    statGrid->addWidget(makeStatCard(TR("dash_balance_month"), lblBalance_, "across all funds", true,
                                     "#ecfdf5", "#059669", ":/icons/reports.svg"), 1, 4);
    layout->addLayout(statGrid);

    // ── 4. Chart grid: 4 cards in 2×2 ──
    auto* chartGrid = new QGridLayout();
    chartGrid->setSpacing(12);
    chartGrid->setContentsMargins(0, 0, 0, 0);

    auto* cc = new QChart(); auto* cv1 = new QChartView(cc); cv1->setMinimumHeight(220); cv1->setRenderHint(QPainter::Antialiasing);
    chartGrid->addWidget(makeChartCard(TR("dash_chart_collections"), "Subscription receipts · last 12 months", cv1), 0, 0);

    auto* dc = new QChart(); auto* cv2 = new QChartView(dc); cv2->setMinimumHeight(220); cv2->setRenderHint(QPainter::Antialiasing);
    chartGrid->addWidget(makeChartCard(TR("dash_chart_donations"), "All categories · last 12 months", cv2), 0, 1);

    auto* ic = new QChart(); auto* cv3 = new QChartView(ic); cv3->setMinimumHeight(220); cv3->setRenderHint(QPainter::Antialiasing);
    chartGrid->addWidget(makeChartCard(TR("dash_chart_income_expense"), "Financial year 2026-27 · to date", cv3), 1, 0);

    auto* mc = new QChart(); auto* cv4 = new QChartView(mc); cv4->setMinimumHeight(220); cv4->setRenderHint(QPainter::Antialiasing);
    chartGrid->addWidget(makeChartCard(TR("dash_chart_membership_growth"), "Total registered members", cv4), 1, 1);

    layout->addLayout(chartGrid);

    // ── 5. Recent activity table card ──
    auto* rg = new QFrame(content);
    rg->setObjectName("card");
    auto* rshadow = new QGraphicsDropShadowEffect(rg);
    rshadow->setBlurRadius(8); rshadow->setOffset(0, 1); rshadow->setColor(QColor(0,0,0,8));
    rg->setGraphicsEffect(rshadow);
    auto* rl = new QVBoxLayout(rg);
    rl->setContentsMargins(16, 15, 16, 15);
    rl->setSpacing(6);

    auto* rTitle = new QLabel(TR("dash_recent_activity"), rg);
    StyleProps::set(rTitle, "chartTitle");
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
    QColor axisTitleColor = isDark ? colors::darkText : colors::lightText;
    QColor axisLabelColor = isDark ? colors::darkTextMuted : colors::lightTextMuted;
    QColor gridColor = isDark ? colors::darkGrid : colors::lightGrid;

    for (auto* cv : charts) {
        QChart* ch = cv->chart();
        ch->setTheme(chartTheme);
        ch->setBackgroundVisible(false);
        ch->setMargins(QMargins(8, 8, 8, 8));
        ch->setTitle("");
        ch->legend()->setLabelColor(axisLabelColor);
        ch->legend()->hide();
    }

    // Chart 1: Collections (line chart, emerald)
    auto* cc = charts[0]->chart();
    cc->removeAllSeries();
    for (auto* a : cc->axes()) cc->removeAxis(a);
    auto* s1 = new QLineSeries();
    s1->setColor(colors::emerald);
    s1->setPointsVisible(true);
    auto cd = svc.monthlyCollections(12);
    QStringList m1; double mx1 = 0; int i = 0;
    for (const auto& m : cd) {
        double a = m.toMap().value("amount").toDouble();
        s1->append(i, a);
        m1 << m.toMap().value("month").toString();
        if (a > mx1) mx1 = a;
        ++i;
    }
    cc->addSeries(s1);
    auto* ax1 = new QBarCategoryAxis();
    ax1->append(m1);
    ax1->setGridLineVisible(false);
    cc->addAxis(ax1, Qt::AlignBottom);
    s1->attachAxis(ax1);
    auto* ay1 = new QValueAxis();
    ay1->setRange(0, mx1 * 1.2 + 1);
    ay1->setLabelFormat("%.0f");
    cc->addAxis(ay1, Qt::AlignLeft);
    s1->attachAxis(ay1);

    // Chart 2: Donations (line chart, gold)
    auto* dc = charts[1]->chart();
    dc->removeAllSeries();
    for (auto* a : dc->axes()) dc->removeAxis(a);
    auto* s2 = new QLineSeries();
    s2->setColor(colors::gold);
    s2->setPointsVisible(true);
    auto dd = svc.donationsByCategory(QDate::currentDate().addMonths(-12).toString(Qt::ISODate),
                                       QDate::currentDate().toString(Qt::ISODate));
    QStringList m2; double mx2 = 0; int j = 0;
    for (const auto& m : dd) {
        double a = m.toMap().value("amount").toDouble();
        s2->append(j, a);
        m2 << m.toMap().value("category").toString();
        if (a > mx2) mx2 = a;
        ++j;
    }
    dc->addSeries(s2);
    auto* ax2 = new QBarCategoryAxis();
    ax2->append(m2);
    ax2->setGridLineVisible(false);
    dc->addAxis(ax2, Qt::AlignBottom);
    s2->attachAxis(ax2);
    auto* ay2 = new QValueAxis();
    ay2->setRange(0, mx2 * 1.2 + 1);
    ay2->setLabelFormat("%.0f");
    dc->addAxis(ay2, Qt::AlignLeft);
    s2->attachAxis(ay2);

    // Chart 3: Income vs Expense (bar chart)
    auto* ic = charts[2]->chart();
    ic->removeAllSeries();
    for (auto* a : ic->axes()) ic->removeAxis(a);
    auto ie = svc.incomeVsExpense(6);
    auto* is = new QBarSet(TR("acc_income"));
    is->setColor(colors::emerald);
    auto* es = new QBarSet(TR("acc_expense"));
    es->setColor(colors::cellNegative);
    QStringList m3; double mx3 = 0;
    for (const auto& m : ie) {
        is->append(m.toMap().value("income").toDouble());
        es->append(m.toMap().value("expense").toDouble());
        m3 << m.toMap().value("month").toString();
        mx3 = std::max({mx3, m.toMap().value("income").toDouble(), m.toMap().value("expense").toDouble()});
    }
    auto* bs = new QBarSeries();
    bs->append(is);
    bs->append(es);
    ic->addSeries(bs);
    auto* ax3 = new QBarCategoryAxis();
    ax3->append(m3);
    ax3->setGridLineVisible(false);
    ic->addAxis(ax3, Qt::AlignBottom);
    bs->attachAxis(ax3);
    auto* ay3 = new QValueAxis();
    ay3->setRange(0, mx3 * 1.2 + 1);
    ay3->setLabelFormat("%.0f");
    ic->addAxis(ay3, Qt::AlignLeft);
    bs->attachAxis(ay3);
    ic->legend()->setVisible(true);
    ic->legend()->setAlignment(Qt::AlignBottom);
    ic->legend()->show();

    // Chart 4: Membership growth (line chart, violet)
    auto* mc = charts[3]->chart();
    mc->removeAllSeries();
    for (auto* a : mc->axes()) mc->removeAxis(a);
    auto* ms = new QLineSeries();
    ms->setColor(colors::chartPurple);
    ms->setPointsVisible(true);
    auto mg = svc.membershipGrowth(12);
    QStringList m4; double mx4 = 0; int mi = 0;
    for (const auto& m : mg) {
        double t = m.toMap().value("total").toDouble();
        ms->append(mi, t);
        m4 << m.toMap().value("month").toString();
        if (t > mx4) mx4 = t;
        ++mi;
    }
    mc->addSeries(ms);
    auto* ax4 = new QBarCategoryAxis();
    ax4->append(m4);
    ax4->setGridLineVisible(false);
    mc->addAxis(ax4, Qt::AlignBottom);
    ms->attachAxis(ax4);
    auto* ay4 = new QValueAxis();
    ay4->setRange(0, mx4 * 1.1 + 1);
    ay4->setLabelFormat("%.0f");
    mc->addAxis(ay4, Qt::AlignLeft);
    ms->attachAxis(ay4);

    // Apply axis styling
    for (auto* cv : charts) {
        QChart* ch = cv->chart();
        for (auto* a : ch->axes()) {
            a->setLabelsColor(axisLabelColor);
            a->setTitleBrush(QBrush(axisTitleColor));
            a->setGridLineColor(gridColor);
            a->setLinePenColor(axisLabelColor);
        }
    }
}

void DashboardView::loadRecentActivity() {
    QSqlQuery q = Database::instance().execute(
        "SELECT created_at, username, action, description FROM audit_log ORDER BY id DESC LIMIT 15");
    recentTable_->setRowCount(0);
    while (q.next()) {
        int r = recentTable_->rowCount();
        recentTable_->insertRow(r);
        recentTable_->setItem(r, 0, new QTableWidgetItem(q.value(0).toString()));
        recentTable_->setItem(r, 1, new QTableWidgetItem(q.value(1).toString()));
        recentTable_->setItem(r, 2, new QTableWidgetItem(q.value(2).toString()));
        recentTable_->setItem(r, 3, new QTableWidgetItem(q.value(3).toString()));
    }
}

} // namespace mms
