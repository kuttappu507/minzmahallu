/*
 * Member.h - Member domain model
 */
#pragma once

#include <QString>
#include <QDateTime>
#include <QVariantMap>
#include <QSqlQuery>
#include <QSqlRecord>

namespace mms {

struct Member {
    qint64 id = 0;
    qint64 familyId = 0;
    QString memberCode;
    QString photoPath;
    QString name;
    QString arabicName;
    QString gender;          // Male, Female, Other
    QString dateOfBirth;
    int age = 0;
    QString bloodGroup;
    QString occupation;
    QString education;
    QString maritalStatus;   // Single, Married, Divorced, Widowed
    QString mobile;
    QString email;
    QString nationality = "Indian";
    QString address;
    QString emergencyContact;
    QString relationship;    // Head, Spouse, Son, Daughter, Parent, Other
    bool isHead = false;
    QString status = "Active";
    QDateTime createdAt;
    QDateTime updatedAt;

    // Joined display fields
    QString familyNumber;
    QString houseName;

    static Member fromQuery(const QSqlQuery& q) {
        Member m;
        m.id = q.value("id").toLongLong();
        m.familyId = q.value("family_id").toLongLong();
        m.memberCode = q.value("member_code").toString();
        m.photoPath = q.value("photo_path").toString();
        m.name = q.value("name").toString();
        m.arabicName = q.value("arabic_name").toString();
        m.gender = q.value("gender").toString();
        m.dateOfBirth = q.value("date_of_birth").toString();
        m.age = q.value("age").toInt();
        m.bloodGroup = q.value("blood_group").toString();
        m.occupation = q.value("occupation").toString();
        m.education = q.value("education").toString();
        m.maritalStatus = q.value("marital_status").toString();
        m.mobile = q.value("mobile").toString();
        m.email = q.value("email").toString();
        m.nationality = q.value("nationality").toString();
        m.address = q.value("address").toString();
        m.emergencyContact = q.value("emergency_contact").toString();
        m.relationship = q.value("relationship").toString();
        m.isHead = q.value("is_head").toInt() == 1;
        m.status = q.value("status").toString();
        m.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);
        m.updatedAt = QDateTime::fromString(q.value("updated_at").toString(), Qt::ISODate);

        int fnIdx = q.record().indexOf("family_number");
        if (fnIdx >= 0) m.familyNumber = q.value(fnIdx).toString();
        int hnIdx = q.record().indexOf("house_name");
        if (hnIdx >= 0) m.houseName = q.value(hnIdx).toString();
        return m;
    }

    QVariantMap toMap() const {
        QVariantMap m;
        m["family_id"] = familyId;
        m["member_code"] = memberCode;
        m["photo_path"] = photoPath;
        m["name"] = name;
        m["arabic_name"] = arabicName;
        m["gender"] = gender;
        m["date_of_birth"] = dateOfBirth;
        m["age"] = age;
        m["blood_group"] = bloodGroup;
        m["occupation"] = occupation;
        m["education"] = education;
        m["marital_status"] = maritalStatus;
        m["mobile"] = mobile;
        m["email"] = email;
        m["nationality"] = nationality;
        m["address"] = address;
        m["emergency_contact"] = emergencyContact;
        m["relationship"] = relationship;
        m["is_head"] = isHead ? 1 : 0;
        m["status"] = status;
        return m;
    }
};

} // namespace mms
