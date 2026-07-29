/*
 * Donation.h - Donation model
 */
#pragma once

#include <QString>
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlRecord>

namespace mms {

struct DonationCategory {
    qint64 id = 0;
    QString name;
    QString description;
    bool isActive = true;
};

struct Donation {
    qint64 id = 0;
    QString donorName;
    QString donorPhone;
    QString donorAddress;
    qint64 familyId = 0;
    qint64 memberId = 0;
    qint64 categoryId = 0;
    double amount = 0;
    QString donationDate;
    QString receiptNumber;
    QString purpose;
    QString remarks;
    QString paymentMethod;
    qint64 receivedBy = 0;
    QDateTime createdAt;

    // Joined
    QString categoryName;
    QString familyNumber;

    static Donation fromQuery(const QSqlQuery& q) {
        Donation d;
        d.id = q.value("id").toLongLong();
        d.donorName = q.value("donor_name").toString();
        d.donorPhone = q.value("donor_phone").toString();
        d.donorAddress = q.value("donor_address").toString();
        d.familyId = q.value("family_id").toLongLong();
        d.memberId = q.value("member_id").toLongLong();
        d.categoryId = q.value("category_id").toLongLong();
        d.amount = q.value("amount").toDouble();
        d.donationDate = q.value("donation_date").toString();
        d.receiptNumber = q.value("receipt_number").toString();
        d.purpose = q.value("purpose").toString();
        d.remarks = q.value("remarks").toString();
        d.paymentMethod = q.value("payment_method").toString();
        d.receivedBy = q.value("received_by").toLongLong();
        d.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);

        int idx = q.record().indexOf("category_name");
        if (idx >= 0) d.categoryName = q.value(idx).toString();
        idx = q.record().indexOf("family_number");
        if (idx >= 0) d.familyNumber = q.value(idx).toString();
        return d;
    }
};

} // namespace mms
