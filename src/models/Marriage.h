/*
 * Marriage.h - Marriage register model
 */
#pragma once

#include <QString>
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlRecord>

namespace mms {

struct Marriage {
    qint64 id = 0;
    QString marriageNumber;
    QString brideName;
    QString brideFather;
    QString brideAddress;
    QString groomName;
    QString groomFather;
    QString groomAddress;
    QString witness1;
    QString witness2;
    QString witness3;
    QString witness4;
    QString mahar;
    QString nikahDate;
    QString registrationDate;
    qint64 imamId = 0;
    QString place;
    QString remarks;
    QDateTime createdAt;

    // Joined
    QString imamName;

    static Marriage fromQuery(const QSqlQuery& q) {
        Marriage m;
        m.id = q.value("id").toLongLong();
        m.marriageNumber = q.value("marriage_number").toString();
        m.brideName = q.value("bride_name").toString();
        m.brideFather = q.value("bride_father").toString();
        m.brideAddress = q.value("bride_address").toString();
        m.groomName = q.value("groom_name").toString();
        m.groomFather = q.value("groom_father").toString();
        m.groomAddress = q.value("groom_address").toString();
        m.witness1 = q.value("witness1").toString();
        m.witness2 = q.value("witness2").toString();
        m.witness3 = q.value("witness3").toString();
        m.witness4 = q.value("witness4").toString();
        m.mahar = q.value("mahar").toString();
        m.nikahDate = q.value("nikah_date").toString();
        m.registrationDate = q.value("registration_date").toString();
        m.imamId = q.value("imam_id").toLongLong();
        m.place = q.value("place").toString();
        m.remarks = q.value("remarks").toString();
        m.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);

        int idx = q.record().indexOf("imam_name");
        if (idx >= 0) m.imamName = q.value(idx).toString();
        return m;
    }
};

} // namespace mms
