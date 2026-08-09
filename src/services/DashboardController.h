/*
 * DashboardController.h — QML-facing controller for Dashboard stats.
 * Wraps existing DashboardService to provide real KPI data.
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
    explicit DashboardController(QObject* parent = nullptr) : QObject(parent) { refresh(); }

    int totalFamilies() { auto s = svc_.load(); return s.totalFamilies; }
    int totalMembers() { auto s = svc_.load(); return s.totalMembers; }
    int activeMembers() { auto s = svc_.load(); return s.activeMembers; }
    double monthlyCollection() { auto s = svc_.load(); return s.monthlyCollection; }
    double pendingDues() { auto s = svc_.load(); return s.pendingDues; }
    double monthlyDonations() { auto s = svc_.load(); return s.monthlyDonations; }
    int marriagesThisYear() { auto s = svc_.load(); return s.marriagesThisYear; }
    int deathsThisYear() { auto s = svc_.load(); return s.deathsThisYear; }
    double incomeThisMonth() { auto s = svc_.load(); return s.incomeThisMonth; }
    double expenseThisMonth() { auto s = svc_.load(); return s.expenseThisMonth; }
    double balance() { auto s = svc_.load(); return s.balanceThisMonth; }
    int summaryRevision() const { return revision_; }

    Q_INVOKABLE QVariantList monthlyCollections(int months = 6) { return svc_.monthlyCollections(months); }
    Q_INVOKABLE QVariantList monthlyDonationsChart(int months = 6) { return svc_.monthlyDonations(months); }
    Q_INVOKABLE QVariantList incomeVsExpense(int months = 6) { return svc_.incomeVsExpense(months); }
    Q_INVOKABLE QVariantList membershipGrowth(int months = 12) { return svc_.membershipGrowth(months); }

    Q_INVOKABLE void refresh() { ++revision_; emit dataChanged(); }

signals:
    void dataChanged();

private:
    mms::DashboardService svc_;
    int revision_ = 0;
};
