/*
 * SubscriptionRepository.cpp
 */
#include "SubscriptionRepository.h"
#include "../core/Database.h"
#include "../core/Security.h"

namespace mms {

std::optional<Subscription> SubscriptionRepository::findById(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM subscriptions WHERE id = ?", { id });
    if (q.next()) return Subscription::fromQuery(q);
    return std::nullopt;
}

std::optional<Subscription> SubscriptionRepository::findByReceiptNumber(const QString& receipt) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM subscriptions WHERE receipt_number = ?", { receipt });
    if (q.next()) return Subscription::fromQuery(q);
    return std::nullopt;
}

std::vector<SubscriptionPlan> SubscriptionRepository::listPlans() {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM subscription_plans WHERE is_active = 1 ORDER BY id");
    std::vector<SubscriptionPlan> result;
    while (q.next()) {
        SubscriptionPlan p;
        p.id = q.value("id").toLongLong();
        p.name = q.value("name").toString();
        p.frequency = q.value("frequency").toString();
        p.defaultAmount = q.value("default_amount").toDouble();
        p.isActive = q.value("is_active").toInt() == 1;
        p.description = q.value("description").toString();
        result.push_back(p);
    }
    return result;
}

std::optional<SubscriptionPlan> SubscriptionRepository::findPlan(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM subscription_plans WHERE id = ?", { id });
    if (!q.next()) return std::nullopt;
    SubscriptionPlan p;
    p.id = q.value("id").toLongLong();
    p.name = q.value("name").toString();
    p.frequency = q.value("frequency").toString();
    p.defaultAmount = q.value("default_amount").toDouble();
    p.isActive = q.value("is_active").toInt() == 1;
    p.description = q.value("description").toString();
    return p;
}

std::vector<Subscription> SubscriptionRepository::list(int page, int pageSize,
                                                       const QString& statusFilter,
                                                       const QString& dateFrom,
                                                       const QString& dateTo,
                                                       qint64 familyId,
                                                       int* totalOut) {
    QStringList where;
    QVariantList params;

    if (!statusFilter.isEmpty()) {
        where << "s.status = ?";
        params << statusFilter;
    }
    if (!dateFrom.isEmpty()) {
        where << "s.payment_date >= ?";
        params << dateFrom;
    }
    if (!dateTo.isEmpty()) {
        where << "s.payment_date <= ?";
        params << dateTo;
    }
    if (familyId > 0) {
        where << "s.family_id = ?";
        params << familyId;
    }
    QString whereSql = where.isEmpty() ? QString() : ("WHERE " + where.join(" AND "));

    if (totalOut) {
        QVariant c = Database::instance().scalar(
            "SELECT COUNT(*) FROM subscriptions s " + whereSql, params);
        *totalOut = c.toInt();
    }

    QString sql = QString(
        "SELECT s.*, f.family_number, m.name AS member_name, p.name AS plan_name "
        "FROM subscriptions s "
        "LEFT JOIN families f ON f.id = s.family_id "
        "LEFT JOIN members m ON m.id = s.member_id "
        "LEFT JOIN subscription_plans p ON p.id = s.plan_id "
        "%1 ORDER BY s.payment_date DESC, s.id DESC LIMIT ? OFFSET ?")
        .arg(whereSql);

    int offset = (page - 1) * pageSize;
    params << pageSize << offset;

    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<Subscription> result;
    while (q.next()) result.push_back(Subscription::fromQuery(q));
    return result;
}

QString SubscriptionRepository::generateNextReceiptNumber(const QString& prefix) {
    return Security::generateReference(prefix, 6);
}

qint64 SubscriptionRepository::create(const Subscription& s) {
    qint64 id = Database::instance().insert(
        R"(INSERT INTO subscriptions
           (family_id, member_id, plan_id, period_start, period_end, amount, amount_paid,
            payment_date, receipt_number, payment_method, transaction_ref, status,
            collected_by, remarks)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?))",
        { s.familyId, s.memberId > 0 ? QVariant(s.memberId) : QVariant(),
          s.planId, s.periodStart, s.periodEnd, s.amount, s.amountPaid,
          s.paymentDate, s.receiptNumber, s.paymentMethod, s.transactionRef,
          s.status, s.collectedBy > 0 ? QVariant(s.collectedBy) : QVariant(), s.remarks });

    // If paid, also create an accounting transaction linked to subscription income
    if (id > 0 && s.amountPaid > 0 && s.status == "Paid") {
        Database::instance().insert(
            R"(INSERT INTO transactions
               (txn_date, account_id, type, amount, payment_method, description,
                linked_module, linked_id, receipt_number, created_by)
               VALUES (?, (SELECT id FROM ledger_accounts WHERE code='INC-SUB'),
                       'Income', ?, ?, ?, 'subscription', ?, ?, ?))",
            { s.paymentDate, s.amountPaid, s.paymentMethod,
              QString("Subscription collection - %1").arg(s.receiptNumber),
              id, s.receiptNumber,
              s.collectedBy > 0 ? QVariant(s.collectedBy) : QVariant() });
    }
    return id;
}

bool SubscriptionRepository::update(const Subscription& s) {
    int n = Database::instance().update(
        R"(UPDATE subscriptions SET
           family_id = ?, member_id = ?, plan_id = ?, period_start = ?, period_end = ?,
           amount = ?, amount_paid = ?, payment_date = ?, receipt_number = ?,
           payment_method = ?, transaction_ref = ?, status = ?, collected_by = ?, remarks = ?
           WHERE id = ?)",
        { s.familyId, s.memberId > 0 ? QVariant(s.memberId) : QVariant(),
          s.planId, s.periodStart, s.periodEnd, s.amount, s.amountPaid,
          s.paymentDate, s.receiptNumber, s.paymentMethod, s.transactionRef,
          s.status, s.collectedBy > 0 ? QVariant(s.collectedBy) : QVariant(),
          s.remarks, s.id });
    return n > 0;
}

bool SubscriptionRepository::remove(qint64 id) {
    int n = Database::instance().remove(
        "DELETE FROM subscriptions WHERE id = ?", { id });
    return n > 0;
}

int SubscriptionRepository::markOverdue() {
    int n = Database::instance().update(
        "UPDATE subscriptions SET status = 'Overdue' "
        "WHERE status = 'Pending' AND period_end < date('now')");
    return n;
}

std::vector<SubscriptionRepository::DefaulterRow> SubscriptionRepository::defaulters() {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM v_defaulters ORDER BY due_amount DESC");
    std::vector<DefaulterRow> result;
    while (q.next()) {
        DefaulterRow r;
        r.familyId = q.value("family_id").toLongLong();
        r.familyNumber = q.value("family_number").toString();
        r.houseName = q.value("house_name").toString();
        r.phone = q.value("phone").toString();
        r.pendingCount = q.value("pending_count").toInt();
        r.dueAmount = q.value("due_amount").toDouble();
        result.push_back(r);
    }
    return result;
}

double SubscriptionRepository::totalCollected(const QString& dateFrom, const QString& dateTo) {
    QVariant v = Database::instance().scalar(
        "SELECT COALESCE(SUM(amount_paid),0) FROM subscriptions "
        "WHERE status = 'Paid' AND payment_date >= ? AND payment_date <= ?",
        { dateFrom, dateTo });
    return v.toDouble();
}

double SubscriptionRepository::totalPending() {
    QVariant v = Database::instance().scalar(
        "SELECT COALESCE(SUM(amount - amount_paid),0) FROM subscriptions "
        "WHERE status IN ('Pending','Overdue','Partial')");
    return v.toDouble();
}

double SubscriptionRepository::totalCollectedThisMonth() {
    QVariant v = Database::instance().scalar(
        "SELECT COALESCE(SUM(amount_paid),0) FROM subscriptions "
        "WHERE strftime('%Y-%m', payment_date) = strftime('%Y-%m','now')");
    return v.toDouble();
}

} // namespace mms
