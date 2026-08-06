/*
 * SubscriptionController.cpp — Implementation
 */
#include "SubscriptionController.h"
#include "FamilyService.h"
#include "MemberService.h"
#include "../models/Family.h"
#include "../models/Member.h"
#include "../models/Subscription.h"
#include <QDate>

SubscriptionController::SubscriptionController(QObject* parent)
    : QObject(parent)
{
}

QVariantMap SubscriptionController::create(const QVariantMap& data) {
    QVariantMap result;
    mms::Subscription s = mapToSubscription(data);

    QString err;
    qint64 id = svc_.createSubscription(s, &err);

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

QVariantMap SubscriptionController::update(qint64 id, const QVariantMap& data) {
    QVariantMap result;
    mms::Subscription s = mapToSubscription(data);
    s.id = id;

    QString err;
    bool ok = svc_.updateSubscription(s, &err);

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

QVariantMap SubscriptionController::remove(qint64 id) {
    QVariantMap result;
    bool ok = svc_.deleteSubscription(id);
    if (ok) {
        result["success"] = true;
        setLastError(QString());
        emit removed(id);
    } else {
        result["success"] = false;
        result["error"] = lastError();
        emit errorOccurred(lastError());
    }
    return result;
}

int SubscriptionController::markOverdue() {
    return svc_.markOverdue();
}

QVariantMap SubscriptionController::get(qint64 id) {
    mms::SubscriptionRepository repo;
    auto s = repo.findById(id);
    if (s) return subscriptionToMap(*s);
    return {};
}

QVariantList SubscriptionController::plans() {
    QVariantList out;
    auto pl = svc_.plans();
    for (const auto& p : pl) {
        QVariantMap m;
        m["id"] = p.id;
        m["name"] = p.name;
        m["frequency"] = p.frequency;
        m["defaultAmount"] = p.defaultAmount;
        m["description"] = p.description;
        out.append(m);
    }
    return out;
}

QVariantList SubscriptionController::activeFamilies() {
    QVariantList out;
    mms::FamilyService famSvc;
    auto families = famSvc.searchFamilies("", 1, 10000, "Active", "");
    for (const auto& f : families) {
        QVariantMap m;
        m["id"] = f.id;
        m["familyNumber"] = f.familyNumber;
        m["houseName"] = f.houseName;
        out.append(m);
    }
    return out;
}

QVariantList SubscriptionController::familyMembers(qint64 familyId) {
    QVariantList out;
    mms::MemberService memSvc;
    auto members = memSvc.familyMembers(familyId);
    for (const auto& m : members) {
        QVariantMap v;
        v["id"] = m.id;
        v["name"] = m.name;
        v["relationship"] = m.relationship;
        v["isHead"] = m.isHead;
        out.append(v);
    }
    return out;
}

QString SubscriptionController::nextReceiptNumber() {
    return svc_.nextReceiptNumber();
}

double SubscriptionController::totalCollected(const QString& from, const QString& to) {
    return svc_.totalCollected(from, to);
}

double SubscriptionController::totalPending() {
    return svc_.totalPending();
}

// ===== Private =====

void SubscriptionController::setLastError(const QString& err) {
    if (lastError_ != err) {
        lastError_ = err;
        emit lastErrorChanged();
    }
}

mms::Subscription SubscriptionController::mapToSubscription(const QVariantMap& d) {
    mms::Subscription s;
    s.id = d.value("id").toLongLong();
    s.familyId = d.value("familyId").toLongLong();
    s.memberId = d.value("memberId").toLongLong();
    s.planId = d.value("planId").toLongLong();
    s.periodStart = d.value("periodStart").toString();
    s.periodEnd = d.value("periodEnd").toString();
    s.amount = d.value("amount").toDouble();
    s.amountPaid = d.value("amountPaid").toDouble();
    s.paymentDate = d.value("paymentDate").toString();
    s.receiptNumber = d.value("receiptNumber").toString();
    s.paymentMethod = d.value("paymentMethod").toString();
    s.transactionRef = d.value("transactionRef").toString();
    s.status = d.value("status", "Pending").toString();
    s.collectedBy = d.value("collectedBy").toLongLong();
    s.remarks = d.value("remarks").toString();
    return s;
}

QVariantMap SubscriptionController::subscriptionToMap(const mms::Subscription& s) {
    QVariantMap m;
    m["id"] = s.id;
    m["familyId"] = s.familyId;
    m["memberId"] = s.memberId;
    m["planId"] = s.planId;
    m["periodStart"] = s.periodStart;
    m["periodEnd"] = s.periodEnd;
    m["amount"] = s.amount;
    m["amountPaid"] = s.amountPaid;
    m["paymentDate"] = s.paymentDate;
    m["receiptNumber"] = s.receiptNumber;
    m["paymentMethod"] = s.paymentMethod;
    m["transactionRef"] = s.transactionRef;
    m["status"] = s.status;
    m["collectedBy"] = s.collectedBy;
    m["remarks"] = s.remarks;
    m["familyNumber"] = s.familyNumber;
    m["memberName"] = s.memberName;
    m["planName"] = s.planName;
    return m;
}

QString SubscriptionController::guessField(const QString& error) {
    QString lower = error.toLower();
    if (lower.contains("family")) return "familyId";
    if (lower.contains("plan")) return "planId";
    if (lower.contains("amount")) return "amount";
    return QString();
}
