/*
 * Transaction.h - Accounting transaction model
 */
#pragma once

#include <QString>
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlRecord>

namespace mms {

struct LedgerAccount {
    qint64 id = 0;
    QString code;
    QString name;
    QString type;        // Income, Expense, Asset, Liability
    QString category;
    bool isActive = true;
};

struct Transaction {
    qint64 id = 0;
    QString txnDate;
    qint64 accountId = 0;
    QString type;         // Income, Expense
    double amount = 0;
    QString paymentMethod;
    QString reference;
    QString description;
    QString linkedModule;
    qint64 linkedId = 0;
    QString receiptNumber;
    qint64 createdBy = 0;
    QDateTime createdAt;

    // Joined
    QString accountName;
    QString accountCode;

    static Transaction fromQuery(const QSqlQuery& q) {
        Transaction t;
        t.id = q.value("id").toLongLong();
        t.txnDate = q.value("txn_date").toString();
        t.accountId = q.value("account_id").toLongLong();
        t.type = q.value("type").toString();
        t.amount = q.value("amount").toDouble();
        t.paymentMethod = q.value("payment_method").toString();
        t.reference = q.value("reference").toString();
        t.description = q.value("description").toString();
        t.linkedModule = q.value("linked_module").toString();
        t.linkedId = q.value("linked_id").toLongLong();
        t.receiptNumber = q.value("receipt_number").toString();
        t.createdBy = q.value("created_by").toLongLong();
        t.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);

        int idx = q.record().indexOf("account_name");
        if (idx >= 0) t.accountName = q.value(idx).toString();
        idx = q.record().indexOf("account_code");
        if (idx >= 0) t.accountCode = q.value(idx).toString();
        return t;
    }
};

} // namespace mms
