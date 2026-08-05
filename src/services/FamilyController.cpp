/*
 * FamilyController.cpp — Implementation
 *
 * Wraps the existing FamilyService. Does NOT duplicate validation, audit
 * logging, or SQL — all of that stays in FamilyService/FamilyRepository.
 */
#include "FamilyController.h"
#include "MemberService.h"
#include "../models/Family.h"
#include "../models/Member.h"
#include "../core/Database.h"
#include <QRegularExpression>
#include <QSqlError>

FamilyController::FamilyController(QObject* parent)
    : QObject(parent)
{
    // Check if the database is initialized (families table exists + query works)
    setDatabaseReady(mms::Database::instance().isInitialized());
}

// ============================================================================
// CRUD
// ============================================================================

QVariantMap FamilyController::create(const QVariantMap& data) {
    QVariantMap result;
    mms::Family f = mapToFamily(data);

    QString err;
    qint64 id = svc_.createFamily(f, &err);

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

QVariantMap FamilyController::update(qint64 id, const QVariantMap& data) {
    QVariantMap result;
    mms::Family f = mapToFamily(data);
    f.id = id;

    QString err;
    bool ok = svc_.updateFamily(f, &err);

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

QVariantMap FamilyController::remove(qint64 id) {
    QVariantMap result;
    QString err;
    bool ok = svc_.deleteFamily(id, &err);

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

QVariantMap FamilyController::archive(qint64 id) {
    QVariantMap result;
    bool ok = svc_.archiveFamily(id);
    if (ok) {
        result["success"] = true;
        setLastError(QString());
        emit archived(id);
    } else {
        result["success"] = false;
        result["error"] = lastError();
        emit errorOccurred(lastError());
    }
    return result;
}

QVariantMap FamilyController::restore(qint64 id) {
    QVariantMap result;
    bool ok = svc_.restoreFamily(id);
    if (ok) {
        result["success"] = true;
        setLastError(QString());
        emit restored(id);
    } else {
        result["success"] = false;
        result["error"] = lastError();
        emit errorOccurred(lastError());
    }
    return result;
}

// ============================================================================
// Read helpers
// ============================================================================

QVariantMap FamilyController::get(qint64 id) {
    try {
        mms::Family f = svc_.getFamily(id);
        return familyToMap(f);
    } catch (const std::exception& e) {
        setLastError(e.what());
        emit errorOccurred(e.what());
        return {};
    }
}

QVariantList FamilyController::getMembers(qint64 familyId) {
    QVariantList out;
    try {
        mms::MemberService memberSvc;
        auto members = memberSvc.familyMembers(familyId);
        for (const auto& m : members) {
            QVariantMap v;
            v["id"] = m.id;
            v["name"] = m.name;
            v["gender"] = m.gender;
            v["age"] = m.age;
            v["relationship"] = m.relationship;
            v["mobile"] = m.mobile;
            v["status"] = m.status;
            v["isHead"] = m.isHead;
            out.append(v);
        }
    } catch (...) {}
    return out;
}

QStringList FamilyController::wards() {
    return svc_.wards();
}

QString FamilyController::nextFamilyNumber() {
    return svc_.totalFamilies() > 0
        ? QString("FAM-%1").arg(svc_.totalFamilies() + 1, 4, 10, QChar('0'))
        : "FAM-0001";
}

// ============================================================================
// Private helpers
// ============================================================================

void FamilyController::setLastError(const QString& err) {
    if (lastError_ != err) {
        lastError_ = err;
        emit lastErrorChanged();
    }
}

void FamilyController::setDatabaseReady(bool ready) {
    if (databaseReady_ != ready) {
        databaseReady_ = ready;
        emit databaseReadyChanged();
    }
}

mms::Family FamilyController::mapToFamily(const QVariantMap& d) {
    mms::Family f;
    f.id = d.value("id").toLongLong();
    f.familyNumber = d.value("familyNumber").toString();
    f.houseName = d.value("houseName").toString();
    f.houseNumber = d.value("houseNumber").toString();
    f.ward = d.value("ward").toString();
    f.area = d.value("area").toString();
    f.address = d.value("address").toString();
    f.pincode = d.value("pincode").toString();
    f.phone = d.value("phone").toString();
    f.alternativePhone = d.value("alternativePhone").toString();
    f.status = d.value("status", "Active").toString();
    f.notes = d.value("notes").toString();
    return f;
}

QVariantMap FamilyController::familyToMap(const mms::Family& f) {
    QVariantMap m;
    m["id"] = f.id;
    m["familyNumber"] = f.familyNumber;
    m["houseName"] = f.houseName;
    m["houseNumber"] = f.houseNumber;
    m["ward"] = f.ward;
    m["area"] = f.area;
    m["address"] = f.address;
    m["pincode"] = f.pincode;
    m["phone"] = f.phone;
    m["alternativePhone"] = f.alternativePhone;
    m["status"] = f.status;
    m["notes"] = f.notes;
    m["memberCount"] = f.memberCount;
    m["headName"] = f.headName;
    return m;
}

QString FamilyController::guessField(const QString& error) {
    // Map service error messages to form field names for QML highlighting.
    QString lower = error.toLower();
    if (lower.contains("house name") || lower.contains("address")) return "houseName";
    if (lower.contains("phone")) return "phone";
    if (lower.contains("pincode")) return "pincode";
    if (lower.contains("family number")) return "familyNumber";
    return QString();
}
