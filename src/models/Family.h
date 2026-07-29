/*
 * Family.h - Family domain model
 */
#pragma once

#include <QString>
#include <QDateTime>
#include <QVariantMap>
#include <QSqlQuery>
#include <QSqlRecord>

namespace mms {

struct Family {
    qint64 id = 0;
    QString familyNumber;
    QString houseName;
    QString houseNumber;
    QString ward;
    QString area;
    QString address;
    QString pincode;
    QString phone;
    QString alternativePhone;
    QString status = "Active";   // Active, Inactive, Archived
    QString notes;
    QDateTime createdAt;
    QDateTime updatedAt;

    // Joined display fields (read-only)
    int memberCount = 0;
    QString headName;

    static Family fromQuery(const QSqlQuery& q) {
        Family f;
        f.id = q.value("id").toLongLong();
        f.familyNumber = q.value("family_number").toString();
        f.houseName = q.value("house_name").toString();
        f.houseNumber = q.value("house_number").toString();
        f.ward = q.value("ward").toString();
        f.area = q.value("area").toString();
        f.address = q.value("address").toString();
        f.pincode = q.value("pincode").toString();
        f.phone = q.value("phone").toString();
        f.alternativePhone = q.value("alternative_phone").toString();
        f.status = q.value("status").toString();
        f.notes = q.value("notes").toString();
        f.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);
        f.updatedAt = QDateTime::fromString(q.value("updated_at").toString(), Qt::ISODate);

        // Optional joined columns
        int mcIdx = q.record().indexOf("member_count");
        if (mcIdx >= 0) f.memberCount = q.value(mcIdx).toInt();
        int hnIdx = q.record().indexOf("head_name");
        if (hnIdx >= 0) f.headName = q.value(hnIdx).toString();
        return f;
    }

    QVariantMap toMap() const {
        QVariantMap m;
        m["family_number"] = familyNumber;
        m["house_name"] = houseName;
        m["house_number"] = houseNumber;
        m["ward"] = ward;
        m["area"] = area;
        m["address"] = address;
        m["pincode"] = pincode;
        m["phone"] = phone;
        m["alternative_phone"] = alternativePhone;
        m["status"] = status;
        m["notes"] = notes;
        return m;
    }
};

} // namespace mms
