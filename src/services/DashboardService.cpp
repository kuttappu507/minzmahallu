/*
 * DashboardService.cpp
 */
#include "DashboardService.h"
#include "../core/Database.h"
#include <QDate>

namespace mms {

DashboardStats DashboardService::load() {
    DashboardStats s;
    QSqlQuery q = Database::instance().execute("SELECT * FROM v_dashboard_summary");
    if (q.next()) {
        s.totalFamilies        = q.value("total_families").toInt();
        s.totalMembers         = q.value("total_members").toInt();
        s.activeMembers        = q.value("active_members").toInt();
        s.monthlyCollection    = q.value("monthly_collection").toDouble();
        s.pendingDues          = q.value("pending_dues").toDouble();
        s.monthlyDonations     = q.value("monthly_donations").toDouble();
        s.welfareBeneficiaries = q.value("welfare_beneficiaries").toInt();
        s.marriagesThisYear    = q.value("marriages_this_year").toInt();
        s.deathsThisYear       = q.value("deaths_this_year").toInt();
    }

    QVariant m = Database::instance().scalar(
        "SELECT COUNT(*) FROM members WHERE gender='Male' AND status='Active'");
    s.maleMembers = m.toInt();
    QVariant f = Database::instance().scalar(
        "SELECT COUNT(*) FROM members WHERE gender='Female' AND status='Active'");
    s.femaleMembers = f.toInt();

    QDate now = QDate::currentDate();
    QString monthStart = now.toString("yyyy-MM-01");
    QString monthEnd   = now.toString("yyyy-MM-") + QString::number(now.daysInMonth());

    QVariant inc = Database::instance().scalar(
        "SELECT COALESCE(SUM(amount),0) FROM transactions WHERE type='Income' "
        "AND strftime('%Y-%m', txn_date) = strftime('%Y-%m','now')");
    s.incomeThisMonth = inc.toDouble();

    QVariant exp = Database::instance().scalar(
        "SELECT COALESCE(SUM(amount),0) FROM transactions WHERE type='Expense' "
        "AND strftime('%Y-%m', txn_date) = strftime('%Y-%m','now')");
    s.expenseThisMonth = exp.toDouble();
    s.balanceThisMonth = s.incomeThisMonth - s.expenseThisMonth;
    return s;
}

QVariantList DashboardService::monthlyCollections(int months) {
    QVariantList result;
    QSqlQuery q = Database::instance().execute(
        QString("SELECT strftime('%Y-%m', payment_date) AS month, "
                "COALESCE(SUM(amount_paid),0) AS amount "
                "FROM subscriptions WHERE payment_date >= date('now','-%1 months') "
                "GROUP BY month ORDER BY month").arg(months));
    while (q.next()) {
        QVariantMap m;
        m["month"] = q.value(0);
        m["amount"] = q.value(1);
        result << m;
    }
    return result;
}

QVariantList DashboardService::monthlyDonations(int months) {
    QVariantList result;
    QSqlQuery q = Database::instance().execute(
        QString("SELECT strftime('%Y-%m', donation_date) AS month, "
                "COALESCE(SUM(amount),0) AS amount "
                "FROM donations WHERE donation_date >= date('now','-%1 months') "
                "GROUP BY month ORDER BY month").arg(months));
    while (q.next()) {
        QVariantMap m;
        m["month"] = q.value(0);
        m["amount"] = q.value(1);
        result << m;
    }
    return result;
}

QVariantList DashboardService::monthlyExpenses(int months) {
    QVariantList result;
    QSqlQuery q = Database::instance().execute(
        QString("SELECT strftime('%Y-%m', txn_date) AS month, "
                "COALESCE(SUM(amount),0) AS amount "
                "FROM transactions WHERE type='Expense' "
                "AND txn_date >= date('now','-%1 months') "
                "GROUP BY month ORDER BY month").arg(months));
    while (q.next()) {
        QVariantMap m;
        m["month"] = q.value(0);
        m["amount"] = q.value(1);
        result << m;
    }
    return result;
}

QVariantList DashboardService::membershipGrowth(int months) {
    QVariantList result;
    QSqlQuery q = Database::instance().execute(
        QString("SELECT strftime('%Y-%m', created_at) AS month, COUNT(*) AS added "
                "FROM members WHERE created_at >= date('now','-%1 months') "
                "GROUP BY month ORDER BY month").arg(months));
    int cumulative = 0;
    // Get initial count before the period
    QVariant initial = Database::instance().scalar(
        QString("SELECT COUNT(*) FROM members WHERE created_at < date('now','-%1 months')").arg(months));
    cumulative = initial.toInt();
    while (q.next()) {
        cumulative += q.value(1).toInt();
        QVariantMap m;
        m["month"] = q.value(0);
        m["total"] = cumulative;
        result << m;
    }
    return result;
}

QVariantList DashboardService::donationsByCategory(const QString& dateFrom, const QString& dateTo) {
    QVariantList result;
    QSqlQuery q = Database::instance().execute(
        "SELECT c.name, COALESCE(SUM(d.amount),0) FROM donation_categories c "
        "LEFT JOIN donations d ON d.category_id = c.id "
        "AND d.donation_date >= ? AND d.donation_date <= ? "
        "GROUP BY c.id ORDER BY 2 DESC",
        { dateFrom, dateTo });
    while (q.next()) {
        QVariantMap m;
        m["category"] = q.value(0);
        m["amount"] = q.value(1);
        result << m;
    }
    return result;
}

QVariantList DashboardService::familiesByWard() {
    QVariantList result;
    QSqlQuery q = Database::instance().execute(
        "SELECT ward, COUNT(*) FROM families WHERE status='Active' AND ward != '' "
        "GROUP BY ward ORDER BY ward");
    while (q.next()) {
        QVariantMap m;
        m["ward"] = q.value(0);
        m["count"] = q.value(1);
        result << m;
    }
    return result;
}

QVariantList DashboardService::membersByAgeGroup() {
    QVariantList result;
    struct { QString label; int min; int max; } groups[] = {
        {"0-17", 0, 17},
        {"18-30", 18, 30},
        {"31-50", 31, 50},
        {"51-70", 51, 70},
        {"70+", 71, 200}
    };
    for (auto& g : groups) {
        QVariant v = Database::instance().scalar(
            "SELECT COUNT(*) FROM members WHERE age BETWEEN ? AND ? AND status='Active'",
            { g.min, g.max });
        QVariantMap m;
        m["label"] = g.label;
        m["count"] = v.toInt();
        result << m;
    }
    return result;
}

QVariantList DashboardService::incomeVsExpense(int months) {
    QVariantList result;
    QSqlQuery q = Database::instance().execute(
        QString("SELECT strftime('%Y-%m', txn_date) AS month, "
                "SUM(CASE WHEN type='Income' THEN amount ELSE 0 END) AS income, "
                "SUM(CASE WHEN type='Expense' THEN amount ELSE 0 END) AS expense "
                "FROM transactions WHERE txn_date >= date('now','-%1 months') "
                "GROUP BY month ORDER BY month").arg(months));
    while (q.next()) {
        QVariantMap m;
        m["month"]   = q.value(0);
        m["income"]  = q.value(1);
        m["expense"] = q.value(2);
        result << m;
    }
    return result;
}

} // namespace mms
