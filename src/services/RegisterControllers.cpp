/*
 * RegisterControllers.cpp — Implementation for Marriage/Death/Welfare controllers
 */
#include "RegisterControllers.h"
#include "../repositories/MarriageRepository.h"
#include "../repositories/DeathRepository.h"
#include "../repositories/WelfareRepository.h"
#include <QDate>

// ============================================================================
// MarriageController
// ============================================================================

QVariantMap MarriageController::create(const QVariantMap& data) {
    QVariantMap result;
    mms::Marriage m = mapToMarriage(data);
    QString err;
    qint64 id = svc_.createMarriage(m, &err);
    if (id > 0) { result["success"] = true; result["id"] = id; setLastError(QString()); emit created(id); }
    else { result["success"] = false; result["error"] = err; setLastError(err); emit errorOccurred(err); }
    return result;
}

QVariantMap MarriageController::update(qint64 id, const QVariantMap& data) {
    QVariantMap result;
    mms::Marriage m = mapToMarriage(data);
    m.id = id;
    QString err;
    bool ok = svc_.updateMarriage(m, &err);
    if (ok) { result["success"] = true; setLastError(QString()); emit updated(id); }
    else { result["success"] = false; result["error"] = err; setLastError(err); emit errorOccurred(err); }
    return result;
}

QVariantMap MarriageController::remove(qint64 id) {
    QVariantMap result;
    bool ok = svc_.deleteMarriage(id);
    if (ok) { result["success"] = true; setLastError(QString()); emit removed(id); }
    else { result["success"] = false; result["error"] = lastError(); emit errorOccurred(lastError()); }
    return result;
}

QVariantMap MarriageController::get(qint64 id) {
    try { return marriageToMap(svc_.getMarriage(id)); }
    catch (const std::exception& e) { setLastError(e.what()); return {}; }
}

QString MarriageController::nextNumber() { return svc_.nextMarriageNumber(); }

mms::Marriage MarriageController::mapToMarriage(const QVariantMap& d) {
    mms::Marriage m;
    m.id = d.value("id").toLongLong();
    m.marriageNumber = d.value("marriageNumber").toString();
    m.brideName = d.value("brideName").toString();
    m.brideFather = d.value("brideFather").toString();
    m.brideAddress = d.value("brideAddress").toString();
    m.groomName = d.value("groomName").toString();
    m.groomFather = d.value("groomFather").toString();
    m.groomAddress = d.value("groomAddress").toString();
    m.witness1 = d.value("witness1").toString();
    m.witness2 = d.value("witness2").toString();
    m.witness3 = d.value("witness3").toString();
    m.witness4 = d.value("witness4").toString();
    m.mahar = d.value("mahar").toString();
    m.nikahDate = d.value("nikahDate").toString();
    m.registrationDate = d.value("registrationDate").toString();
    m.imamId = d.value("imamId").toLongLong();
    m.place = d.value("place").toString();
    m.remarks = d.value("remarks").toString();
    return m;
}

QVariantMap MarriageController::marriageToMap(const mms::Marriage& m) {
    QVariantMap r;
    r["id"] = m.id; r["marriageNumber"] = m.marriageNumber;
    r["brideName"] = m.brideName; r["brideFather"] = m.brideFather; r["brideAddress"] = m.brideAddress;
    r["groomName"] = m.groomName; r["groomFather"] = m.groomFather; r["groomAddress"] = m.groomAddress;
    r["witness1"] = m.witness1; r["witness2"] = m.witness2; r["witness3"] = m.witness3; r["witness4"] = m.witness4;
    r["mahar"] = m.mahar; r["nikahDate"] = m.nikahDate; r["registrationDate"] = m.registrationDate;
    r["imamId"] = m.imamId; r["place"] = m.place; r["remarks"] = m.remarks; r["imamName"] = m.imamName;
    return r;
}

// ============================================================================
// DeathController
// ============================================================================

QVariantMap DeathController::create(const QVariantMap& data) {
    QVariantMap result;
    mms::Death d = mapToDeath(data);
    QString err;
    qint64 id = svc_.createDeath(d, &err);
    if (id > 0) { result["success"] = true; result["id"] = id; setLastError(QString()); emit created(id); }
    else { result["success"] = false; result["error"] = err; setLastError(err); emit errorOccurred(err); }
    return result;
}

QVariantMap DeathController::update(qint64 id, const QVariantMap& data) {
    QVariantMap result;
    mms::Death d = mapToDeath(data);
    d.id = id;
    QString err;
    bool ok = svc_.updateDeath(d, &err);
    if (ok) { result["success"] = true; setLastError(QString()); emit updated(id); }
    else { result["success"] = false; result["error"] = err; setLastError(err); emit errorOccurred(err); }
    return result;
}

QVariantMap DeathController::remove(qint64 id) {
    QVariantMap result;
    bool ok = svc_.deleteDeath(id);
    if (ok) { result["success"] = true; setLastError(QString()); emit removed(id); }
    else { result["success"] = false; result["error"] = lastError(); emit errorOccurred(lastError()); }
    return result;
}

QVariantMap DeathController::get(qint64 id) {
    try { return deathToMap(svc_.getDeath(id)); }
    catch (const std::exception& e) { setLastError(e.what()); return {}; }
}

QString DeathController::nextNumber() { return svc_.nextDeathNumber(); }

mms::Death DeathController::mapToDeath(const QVariantMap& d) {
    mms::Death de;
    de.id = d.value("id").toLongLong();
    de.deathNumber = d.value("deathNumber").toString();
    de.deceasedName = d.value("deceasedName").toString();
    de.fatherName = d.value("fatherName").toString();
    de.familyId = d.value("familyId").toLongLong();
    de.gender = d.value("gender").toString();
    de.dateOfDeath = d.value("dateOfDeath").toString();
    de.burialDate = d.value("burialDate").toString();
    de.causeOfDeath = d.value("causeOfDeath").toString();
    de.burialPlace = d.value("burialPlace").toString();
    de.age = d.value("age").toInt();
    de.remarks = d.value("remarks").toString();
    return de;
}

QVariantMap DeathController::deathToMap(const mms::Death& d) {
    QVariantMap r;
    r["id"] = d.id; r["deathNumber"] = d.deathNumber; r["deceasedName"] = d.deceasedName;
    r["fatherName"] = d.fatherName; r["familyId"] = d.familyId; r["gender"] = d.gender;
    r["dateOfDeath"] = d.dateOfDeath; r["burialDate"] = d.burialDate; r["causeOfDeath"] = d.causeOfDeath;
    r["burialPlace"] = d.burialPlace; r["age"] = d.age; r["remarks"] = d.remarks;
    r["familyNumber"] = d.familyNumber; r["houseName"] = d.houseName;
    return r;
}

// ============================================================================
// WelfareController
// ============================================================================

QVariantMap WelfareController::create(const QVariantMap& data) {
    QVariantMap result;
    mms::WelfareRequest w = mapToWelfare(data);
    QString err;
    qint64 id = svc_.createRequest(w, &err);
    if (id > 0) { result["success"] = true; result["id"] = id; setLastError(QString()); emit created(id); }
    else { result["success"] = false; result["error"] = err; setLastError(err); emit errorOccurred(err); }
    return result;
}

QVariantMap WelfareController::update(qint64 id, const QVariantMap& data) {
    QVariantMap result;
    mms::WelfareRequest w = mapToWelfare(data);
    w.id = id;
    QString err;
    bool ok = svc_.updateRequest(w, &err);
    if (ok) { result["success"] = true; setLastError(QString()); emit updated(id); }
    else { result["success"] = false; result["error"] = err; setLastError(err); emit errorOccurred(err); }
    return result;
}

QVariantMap WelfareController::remove(qint64 id) {
    QVariantMap result;
    bool ok = svc_.deleteRequest(id);
    if (ok) { result["success"] = true; setLastError(QString()); emit removed(id); }
    else { result["success"] = false; result["error"] = lastError(); emit errorOccurred(lastError()); }
    return result;
}

QVariantMap WelfareController::approve(qint64 id, double amount, const QString& remarks) {
    QVariantMap result;
    bool ok = svc_.approveRequest(id, amount, remarks);
    if (ok) { result["success"] = true; setLastError(QString()); emit updated(id); }
    else { result["success"] = false; result["error"] = lastError(); emit errorOccurred(lastError()); }
    return result;
}

QVariantMap WelfareController::reject(qint64 id, const QString& remarks) {
    QVariantMap result;
    bool ok = svc_.rejectRequest(id, remarks);
    if (ok) { result["success"] = true; setLastError(QString()); emit updated(id); }
    else { result["success"] = false; result["error"] = lastError(); emit errorOccurred(lastError()); }
    return result;
}

QVariantMap WelfareController::disburse(qint64 id, const QString& date) {
    QVariantMap result;
    bool ok = svc_.disburseRequest(id, date);
    if (ok) { result["success"] = true; setLastError(QString()); emit updated(id); }
    else { result["success"] = false; result["error"] = lastError(); emit errorOccurred(lastError()); }
    return result;
}

QVariantMap WelfareController::get(qint64 id) {
    try { return welfareToMap(svc_.getRequest(id)); }
    catch (const std::exception& e) { setLastError(e.what()); return {}; }
}

QString WelfareController::nextNumber() { return svc_.nextRequestNumber(); }

QStringList WelfareController::categories() const {
    return {"Medical Aid", "Education Aid", "Marriage Assistance", "Financial Assistance"};
}

mms::WelfareRequest WelfareController::mapToWelfare(const QVariantMap& d) {
    mms::WelfareRequest w;
    w.id = d.value("id").toLongLong();
    w.requestNumber = d.value("requestNumber").toString();
    w.applicantName = d.value("applicantName").toString();
    w.familyId = d.value("familyId").toLongLong();
    w.category = d.value("category").toString();
    w.amountRequested = d.value("amountRequested").toDouble();
    w.amountApproved = d.value("amountApproved").toDouble();
    w.reason = d.value("reason").toString();
    w.status = d.value("status", "Pending").toString();
    w.approvedBy = d.value("approvedBy").toLongLong();
    w.disbursedDate = d.value("disbursedDate").toString();
    w.remarks = d.value("remarks").toString();
    return w;
}

QVariantMap WelfareController::welfareToMap(const mms::WelfareRequest& w) {
    QVariantMap r;
    r["id"] = w.id; r["requestNumber"] = w.requestNumber; r["applicantName"] = w.applicantName;
    r["familyId"] = w.familyId; r["category"] = w.category; r["amountRequested"] = w.amountRequested;
    r["amountApproved"] = w.amountApproved; r["reason"] = w.reason; r["status"] = w.status;
    r["approvedBy"] = w.approvedBy; r["disbursedDate"] = w.disbursedDate; r["remarks"] = w.remarks;
    r["familyNumber"] = w.familyNumber; r["approvedByName"] = w.approvedByName;
    return r;
}
