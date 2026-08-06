/*
 * MemberController.cpp — Implementation
 */
#include "MemberController.h"
#include "FamilyService.h"
#include "../models/Member.h"
#include "../core/Database.h"
#include <QDate>

MemberController::MemberController(QObject* parent)
    : QObject(parent)
{
}

QVariantMap MemberController::create(const QVariantMap& data) {
    QVariantMap result;
    mms::Member m = mapToMember(data);

    QString err;
    qint64 id = svc_.createMember(m, &err);

    if (id > 0) {
        result["success"] = true;
        result["id"] = id;
        setLastError(QString());
        emit created(id);
    } else {
        result["success"] = false;
        result["id"] = 0;
        result["error"] = err;
        result["field"] = guessField(err);
        setLastError(err);
        emit errorOccurred(err);
    }
    return result;
}

QVariantMap MemberController::update(qint64 id, const QVariantMap& data) {
    QVariantMap result;
    mms::Member m = mapToMember(data);
    m.id = id;

    QString err;
    bool ok = svc_.updateMember(m, &err);

    if (ok) {
        result["success"] = true;
        setLastError(QString());
        emit updated(id);
    } else {
        result["success"] = false;
        result["error"] = err;
        result["field"] = guessField(err);
        setLastError(err);
        emit errorOccurred(err);
    }
    return result;
}

QVariantMap MemberController::remove(qint64 id) {
    QVariantMap result;
    QString err;
    bool ok = svc_.deleteMember(id, &err);

    if (ok) {
        result["success"] = true;
        setLastError(QString());
        emit removed(id);
    } else {
        result["success"] = false;
        result["error"] = err;
        setLastError(err);
        emit errorOccurred(err);
    }
    return result;
}

QVariantMap MemberController::get(qint64 id) {
    try {
        mms::Member m = svc_.getMember(id);
        return memberToMap(m);
    } catch (const std::exception& e) {
        setLastError(e.what());
        emit errorOccurred(e.what());
        return {};
    }
}

QVariantList MemberController::getFamilyMembers(qint64 familyId) {
    QVariantList out;
    try {
        auto members = svc_.familyMembers(familyId);
        for (const auto& m : members) {
            out.append(memberToMap(m));
        }
    } catch (...) {}
    return out;
}

QStringList MemberController::relationships() const {
    return {"Head", "Spouse", "Son", "Daughter", "Parent", "Sibling", "Other"};
}

QString MemberController::nextMemberCode() {
    return svc_.totalMembers() > 0
        ? QString("MBR-%1").arg(svc_.totalMembers() + 1, 4, 10, QChar('0'))
        : "MBR-0001";
}

QVariantList MemberController::activeFamilies() {
    QVariantList out;
    mms::FamilyService famSvc;
    auto families = famSvc.searchFamilies("", 1, 10000, "Active", "");
    for (const auto& f : families) {
        QVariantMap m;
        m["id"] = f.id;
        m["familyNumber"] = f.familyNumber;
        m["houseName"] = f.houseName;
        m["ward"] = f.ward;
        out.append(m);
    }
    return out;
}

// ===== Private =====

void MemberController::setLastError(const QString& err) {
    if (lastError_ != err) {
        lastError_ = err;
        emit lastErrorChanged();
    }
}

mms::Member MemberController::mapToMember(const QVariantMap& d) {
    mms::Member m;
    m.id = d.value("id").toLongLong();
    m.familyId = d.value("familyId").toLongLong();
    m.memberCode = d.value("memberCode").toString();
    m.photoPath = d.value("photoPath").toString();
    m.name = d.value("name").toString();
    m.arabicName = d.value("arabicName").toString();
    m.gender = d.value("gender").toString();
    m.dateOfBirth = d.value("dateOfBirth").toString();
    m.age = d.value("age").toInt();
    m.bloodGroup = d.value("bloodGroup").toString();
    m.occupation = d.value("occupation").toString();
    m.education = d.value("education").toString();
    m.maritalStatus = d.value("maritalStatus").toString();
    m.mobile = d.value("mobile").toString();
    m.email = d.value("email").toString();
    m.nationality = d.value("nationality", "Indian").toString();
    m.address = d.value("address").toString();
    m.emergencyContact = d.value("emergencyContact").toString();
    m.relationship = d.value("relationship").toString();
    m.isHead = d.value("isHead", false).toBool();
    m.status = d.value("status", "Active").toString();
    return m;
}

QVariantMap MemberController::memberToMap(const mms::Member& m) {
    QVariantMap map;
    map["id"] = m.id;
    map["familyId"] = m.familyId;
    map["memberCode"] = m.memberCode;
    map["photoPath"] = m.photoPath;
    map["name"] = m.name;
    map["arabicName"] = m.arabicName;
    map["gender"] = m.gender;
    map["dateOfBirth"] = m.dateOfBirth;
    map["age"] = m.age;
    map["bloodGroup"] = m.bloodGroup;
    map["occupation"] = m.occupation;
    map["education"] = m.education;
    map["maritalStatus"] = m.maritalStatus;
    map["mobile"] = m.mobile;
    map["email"] = m.email;
    map["nationality"] = m.nationality;
    map["address"] = m.address;
    map["emergencyContact"] = m.emergencyContact;
    map["relationship"] = m.relationship;
    map["isHead"] = m.isHead;
    map["status"] = m.status;
    map["familyNumber"] = m.familyNumber;
    map["houseName"] = m.houseName;
    return map;
}

QString MemberController::guessField(const QString& error) {
    QString lower = error.toLower();
    if (lower.contains("name")) return "name";
    if (lower.contains("family")) return "familyId";
    if (lower.contains("gender")) return "gender";
    if (lower.contains("mobile")) return "mobile";
    if (lower.contains("email")) return "email";
    return QString();
}
