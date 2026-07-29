/*
 * Subscription.h - Subscription/collection model
 */
#pragma once

#include <QString>
#include <QDateTime>
#include <QVariantMap>
#include <QSqlQuery>
#include <QSqlRecord>

namespace mms {

struct SubscriptionPlan {
    qint64 id = 0;
    QString name;
    QString frequency;   // Monthly, Yearly, OneTime
    double defaultAmount = 0;
    bool isActive = true;
    QString description;
};

struct Subscription {
    qint64 id = 0;
    qint64 familyId = 0;
    qint64 memberId = 0;
    qint64 planId = 0;
    QString periodStart;
    QString periodEnd;
    double amount = 0;
    double amountPaid = 0;
    QString paymentDate;
    QString receiptNumber;
    QString paymentMethod;
    QString transactionRef;
    QString status = "Pending";   // Paid, Pending, Overdue, Partial
    qint64 collectedBy = 0;
    QString remarks;
    QDateTime createdAt;
    QDateTime updatedAt;

    // Joined
    QString familyNumber;
    QString memberName;
    QString planName;

    static Subscription fromQuery(const QSqlQuery& q) {
        Subscription s;
        s.id = q.value("id").toLongLong();
        s.familyId = q.value("family_id").toLongLong();
        s.memberId = q.value("member_id").toLongLong();
        s.planId = q.value("plan_id").toLongLong();
        s.periodStart = q.value("period_start").toString();
        s.periodEnd = q.value("period_end").toString();
        s.amount = q.value("amount").toDouble();
        s.amountPaid = q.value("amount_paid").toDouble();
        s.paymentDate = q.value("payment_date").toString();
        s.receiptNumber = q.value("receipt_number").toString();
        s.paymentMethod = q.value("payment_method").toString();
        s.transactionRef = q.value("transaction_ref").toString();
        s.status = q.value("status").toString();
        s.collectedBy = q.value("collected_by").toLongLong();
        s.remarks = q.value("remarks").toString();
        s.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);
        s.updatedAt = QDateTime::fromString(q.value("updated_at").toString(), Qt::ISODate);

        int idx = q.record().indexOf("family_number");
        if (idx >= 0) s.familyNumber = q.value(idx).toString();
        idx = q.record().indexOf("member_name");
        if (idx >= 0) s.memberName = q.value(idx).toString();
        idx = q.record().indexOf("plan_name");
        if (idx >= 0) s.planName = q.value(idx).toString();
        return s;
    }
};

} // namespace mms
