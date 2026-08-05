/*
 * QmlServices.cpp — Implementation
 */
#include "QmlServices.h"
#include "FamilyService.h"
#include "MemberService.h"
#include "../models/Family.h"
#include "../models/Member.h"
#include <QDateTime>

using namespace mms;

static QVariantMap familyToMap(const Family& f) {
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

static Family mapToFamily(const QVariantMap& d) {
    Family f;
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

QmlServices::QmlServices(QObject* parent) : QObject(parent), familySvc_(new FamilyService()) {}
QmlServices::~QmlServices() { delete familySvc_; }

QStringList QmlServices::wards() const {
    return const_cast<FamilyService*>(familySvc_)->wards();
}

int QmlServices::totalFamilies() const {
    return const_cast<FamilyService*>(familySvc_)->totalFamilies();
}

QVariantList QmlServices::searchFamilies(const QString& term, int page, int pageSize,
                                          const QString& statusFilter, const QString& wardFilter) {
    QVariantList out;
    try {
        auto families = familySvc_->searchFamilies(term, page, pageSize, statusFilter, wardFilter);
        for (const auto& f : families) out.append(familyToMap(f));
    } catch (const std::exception& e) {
        lastError_ = e.what();
        emit lastErrorChanged();
    }
    return out;
}

QVariantMap QmlServices::getFamily(qint64 id) {
    try { return familyToMap(familySvc_->getFamily(id)); }
    catch (const std::exception& e) {
        lastError_ = e.what();
        emit lastErrorChanged();
    }
    return {};
}

QVariantList QmlServices::getFamilyMembers(qint64 familyId) {
    QVariantList out;
    try {
        MemberService svc;
        auto members = svc.familyMembers(familyId);
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

qint64 QmlServices::createFamily(const QVariantMap& data) {
    Family f = mapToFamily(data);
    QString err;
    qint64 id = familySvc_->createFamily(f, &err);
    if (id > 0) { emit dataChanged(); return id; }
    lastError_ = err;
    emit lastErrorChanged();
    return 0;
}

bool QmlServices::updateFamily(qint64 id, const QVariantMap& data) {
    Family f = mapToFamily(data);
    f.id = id;
    QString err;
    if (familySvc_->updateFamily(f, &err)) { emit dataChanged(); return true; }
    lastError_ = err;
    emit lastErrorChanged();
    return false;
}

bool QmlServices::deleteFamily(qint64 id) {
    QString err;
    if (familySvc_->deleteFamily(id, &err)) { emit dataChanged(); return true; }
    lastError_ = err;
    emit lastErrorChanged();
    return false;
}

bool QmlServices::archiveFamily(qint64 id) {
    if (familySvc_->archiveFamily(id)) { emit dataChanged(); return true; }
    return false;
}

bool QmlServices::restoreFamily(qint64 id) {
    if (familySvc_->restoreFamily(id)) { emit dataChanged(); return true; }
    return false;
}
