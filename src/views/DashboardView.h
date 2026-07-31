#pragma once
#include <QWidget>
#include <QLabel>
#include <QPushButton>
class QChartView;
class QTableWidget;
namespace mms {
class DashboardView : public QWidget {
    Q_OBJECT
public:
    explicit DashboardView(QWidget* parent = nullptr);
public slots:
    void refresh();
signals:
    void navigateToView(int index);
private:
    void setupUi();
    void loadStats();
    void loadCharts();
    void loadRecentActivity();
    QWidget* makeStatCard(int index, QLabel*& valueLabel);
    QWidget* makeChartCard(const QString& title, const QString& subtitle, const QString& borderColor, QWidget* chart);
    QLabel* lblFamilies_=nullptr, *lblMembers_=nullptr, *lblActive_=nullptr, *lblCollection_=nullptr, *lblPending_=nullptr;
    QLabel* lblDonations_=nullptr, *lblWelfare_=nullptr, *lblMarriages_=nullptr, *lblDeaths_=nullptr, *lblBalance_=nullptr;
    QPushButton* qaAddFamily_=nullptr, *qaAddMember_=nullptr, *qaPayment_=nullptr, *qaDonation_=nullptr, *qaReport_=nullptr, *refreshBtn_=nullptr;
    QTableWidget* recentTable_ = nullptr;
};
} // namespace mms
