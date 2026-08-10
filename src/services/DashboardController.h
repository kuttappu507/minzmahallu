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

    // Called from app_main.cpp to connect to other controllers' dataChanged signals
    // so the dashboard auto-refreshes when any CRUD operation happens
    void connectToSignals(QObject* familyCtrl, QObject* memberCtrl,
                          QObject* subscriptionCtrl, QObject* donationCtrl,
                          QObject* accountingCtrl, QObject* marriageCtrl,
                          QObject* deathCtrl, QObject* welfareCtrl) {
        if (familyCtrl) connect(familyCtrl, SIGNAL(created(qint64)), this, SLOT(onDataChanged()));
        if (familyCtrl) connect(familyCtrl, SIGNAL(updated(qint64)), this, SLOT(onDataChanged()));
        if (familyCtrl) connect(familyCtrl, SIGNAL(removed(qint64)), this, SLOT(onDataChanged()));
        if (memberCtrl) connect(memberCtrl, SIGNAL(created(qint64)), this, SLOT(onDataChanged()));
        if (memberCtrl) connect(memberCtrl, SIGNAL(updated(qint64)), this, SLOT(onDataChanged()));
        if (memberCtrl) connect(memberCtrl, SIGNAL(removed(qint64)), this, SLOT(onDataChanged()));
        if (subscriptionCtrl) connect(subscriptionCtrl, SIGNAL(created(qint64)), this, SLOT(onDataChanged()));
        if (subscriptionCtrl) connect(subscriptionCtrl, SIGNAL(updated(qint64)), this, SLOT(onDataChanged()));
        if (subscriptionCtrl) connect(subscriptionCtrl, SIGNAL(removed(qint64)), this, SLOT(onDataChanged()));
        if (donationCtrl) connect(donationCtrl, SIGNAL(created(qint64)), this, SLOT(onDataChanged()));
        if (donationCtrl) connect(donationCtrl, SIGNAL(updated(qint64)), this, SLOT(onDataChanged()));
        if (donationCtrl) connect(donationCtrl, SIGNAL(removed(qint64)), this, SLOT(onDataChanged()));
        if (accountingCtrl) connect(accountingCtrl, SIGNAL(created(qint64)), this, SLOT(onDataChanged()));
        if (accountingCtrl) connect(accountingCtrl, SIGNAL(updated(qint64)), this, SLOT(onDataChanged()));
        if (accountingCtrl) connect(accountingCtrl, SIGNAL(removed(qint64)), this, SLOT(onDataChanged()));
        if (marriageCtrl) connect(marriageCtrl, SIGNAL(created(qint64)), this, SLOT(onDataChanged()));
        if (marriageCtrl) connect(marriageCtrl, SIGNAL(updated(qint64)), this, SLOT(onDataChanged()));
        if (marriageCtrl) connect(marriageCtrl, SIGNAL(removed(qint64)), this, SLOT(onDataChanged()));
        if (deathCtrl) connect(deathCtrl, SIGNAL(created(qint64)), this, SLOT(onDataChanged()));
        if (deathCtrl) connect(deathCtrl, SIGNAL(updated(qint64)), this, SLOT(onDataChanged()));
        if (deathCtrl) connect(deathCtrl, SIGNAL(removed(qint64)), this, SLOT(onDataChanged()));
        if (welfareCtrl) connect(welfareCtrl, SIGNAL(created(qint64)), this, SLOT(onDataChanged()));
        if (welfareCtrl) connect(welfareCtrl, SIGNAL(updated(qint64)), this, SLOT(onDataChanged()));
        if (welfareCtrl) connect(welfareCtrl, SIGNAL(removed(qint64)), this, SLOT(onDataChanged()));
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

private slots:
    void onDataChanged() { refresh(); }

signals:
    void dataChanged();

private:
    mms::DashboardService svc_;
    mms::DashboardStats stats_;
    int revision_ = 0;
};
