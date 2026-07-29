/*
 * Death.h - Death register model
 */
#pragma once

#include <QString>
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlRecord>

namespace mms {

struct Death {
    qint64 id = 0;
    QString deathNumber;
    QString deceasedName;
    QString fatherName;
    qint64 familyId = 0;
    QString gender;
    QString dateOfDeath;
    QString burialDate;
    QString causeOfDeath;
    QString burialPlace;
    int age = 0;
    QString remarks;
    QDateTime createdAt;

    // Joined
    QString familyNumber;
    QString houseName;

    static Death fromQuery(const QSqlQuery& q) {
        Death d;
        d.id = q.value("id").toLongLong();
        d.deathNumber = q.value("death_number").toString();
        d.deceasedName = q.value("deceased_name").toString();
        d.fatherName = q.value("father_name").toString();
        d.familyId = q.value("family_id").toLongLong();
        d.gender = q.value("gender").toString();
        d.dateOfDeath = q.value("date_of_death").toString();
        d.burialDate = q.value("burial_date").toString();
        d.causeOfDeath = q.value("cause_of_death").toString();
        d.burialPlace = q.value("burial_place").toString();
        d.age = q.value("age").toInt();
        d.remarks = q.value("remarks").toString();
        d.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);

        int idx = q.record().indexOf("family_number");
        if (idx >= 0) d.familyNumber = q.value(idx).toString();
        idx = q.record().indexOf("house_name");
        if (idx >= 0) d.houseName = q.value(idx).toString();
        return d;
    }
};

} // namespace mms
