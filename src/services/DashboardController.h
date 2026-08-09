/*
 * DashboardController.h — QML-facing controller for Dashboard stats.
 * Wraps existing DashboardService to provide real KPI data.
 * Caches stats on refresh() to avoid repeated DB queries.
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include <QVariantList>
#include "DashboardService.h"

class DashboardController : public QObject {
    Q_OBJECT
    Q_PROPERTY(int totalFamilies READ totalFamilies NOTIFY dataChanged)
    Q_PROPERTY(int totalMembers READ totalMembers NOTIFY dataChanged)
    Q_PROPERTY(int activeMembers READ activeMembers NOTIFY dataChanged)
    Q_PROPERTY(double monthlyCollection READ monthlyCollection NOTIFY dataChanged)
    Q_PROPERTY(double pendingDues READ pendingDues NOTIFY dataChanged)
    Q_PROPERTY(double monthlyDonations READ monthlyDonations NOTIFY dataChanged)
    Q_PROPERTY(int marriagesThisYear READ marriagesThisYear NOTIFY dataChanged)
    Q_PROPERTY(int deathsThisYear READ deathsThisYear NOTIFY dataChanged)
    Q_PROPERTY(double incomeThisMonth READ incomeThisMonth NOTIFY dataChanged)
    Q_PROPERTY(double expenseThisMonth READ expenseThisMonth NOTIFY dataChanged)
    Q_PROPERTY(double balance READ balance NOTIFY dataChanged)
    Q_PROPERTY(int summaryRevision READ summaryRevision NOTIFY dataChanged)

public:
    explicit DashboardController(QObject* parent = nullptr) : QObject(parent) {
        // Load initial data — wrapped in try/catch in case DB isn't ready yet
        try { stats_ = svc_.load(); } catch (...) {}
    }

    int totalFamilies() const { return stats_.totalFamilies; }
    int totalMembers() const { return stats_.totalMembers; }
    int activeMembers() const { return stats_.activeMembers; }
    double monthlyCollection() const { return stats_.monthlyCollection; }
    double pendingDues() const { return stats_.pendingDues; }
    double monthlyDonations() const { return stats_.monthlyDonations; }
    int marriagesThisYear() const { return stats_.marriagesThisYear; }
    int deathsThisYear() const { return stats_.deathsThisYear; }
    double incomeThisMonth() const { return stats_.incomeThisMonth; }
    double expenseThisMonth() const { return stats_.expenseThisMonth; }
    double balance() const { return stats_.balanceThisMonth; }
    int summaryRevision() const { return revision_; }

    Q_INVOKABLE void refresh() {
        try { stats_ = svc_.load(); } catch (...) {}
        ++revision_;
        emit dataChanged();
    }

signals:
    void dataChanged();

private:
    mms::DashboardService svc_;
    mms::DashboardStats stats_;
    int revision_ = 0;
};
