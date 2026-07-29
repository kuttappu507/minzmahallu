/*
 * DashboardService.h - Aggregated dashboard statistics & chart data
 */
#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>

namespace mms {

struct DashboardStats {
    int totalFamilies = 0;
    int totalMembers = 0;
    int activeMembers = 0;
    int maleMembers = 0;
    int femaleMembers = 0;
    double monthlyCollection = 0;
    double pendingDues = 0;
    double monthlyDonations = 0;
    int welfareBeneficiaries = 0;
    int marriagesThisYear = 0;
    int deathsThisYear = 0;
    double incomeThisMonth = 0;
    double expenseThisMonth = 0;
    double balanceThisMonth = 0;
};

class DashboardService {
public:
    DashboardStats load();

    // Chart data
    QVariantList monthlyCollections(int months = 6);   // [{month, amount}]
    QVariantList monthlyDonations(int months = 6);
    QVariantList monthlyExpenses(int months = 6);
    QVariantList membershipGrowth(int months = 12);     // [{month, total_members}]
    QVariantList donationsByCategory(const QString& dateFrom, const QString& dateTo);
    QVariantList familiesByWard();
    QVariantList membersByAgeGroup();
    QVariantList incomeVsExpense(int months = 6);
};

} // namespace mms
