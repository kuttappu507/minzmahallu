/*
 * DonationController.cpp — Implementation
 */
#include "DonationController.h"
#include "../models/Donation.h"
#include "../repositories/DonationRepository.h"

DonationController::DonationController(QObject* parent) : QObject(parent) {}

QVariantMap DonationController::create(const QVariantMap& data) {
    QVariantMap result;
    mms::Donation d = mapToDonation(data);
    QString err;
    qint64 id = svc_.createDonation(d, &err);
    if (id > 0) {
        result["success"] = true; result["id"] = id;
        setLastError(QString()); emit created(id); bumpSummary();
    } else {
        result["success"] = false; result["id"] = 0;
        result["error"] = err; result["field"] = guessField(err);
        setLastError(err); emit errorOccurred(err);
    }
    return result;
}

QVariantMap DonationController::update(qint64 id, const QVariantMap& data) {
    QVariantMap result;
    mms::Donation d = mapToDonation(data);
    d.id = id;
    QString err;
    bool ok = svc_.updateDonation(d, &err);
    if (ok) { result["success"] = true; setLastError(QString()); emit updated(id); bumpSummary(); }
    else { result["success"] = false; result["error"] = err; result["field"] = guessField(err); setLastError(err); emit errorOccurred(err); }
    return result;
}

QVariantMap DonationController::remove(qint64 id) {
    QVariantMap result;
    bool ok = svc_.deleteDonation(id);
    if (ok) { result["success"] = true; setLastError(QString()); emit removed(id); bumpSummary(); }
    else { result["success"] = false; result["error"] = lastError(); emit errorOccurred(lastError()); }
    return result;
}

QVariantMap DonationController::get(qint64 id) {
    mms::DonationRepository repo;
    auto d = repo.findById(id);
    if (d) return donationToMap(*d);
    return {};
}

QVariantList DonationController::categories() {
    QVariantList out;
    auto cats = svc_.categories();
    for (const auto& c : cats) {
        QVariantMap m;
        m["id"] = c.id; m["name"] = c.name; m["description"] = c.description;
        out.append(m);
    }
    return out;
}

QString DonationController::nextReceiptNumber() { return svc_.nextReceiptNumber(); }

double DonationController::totalDonations(const QString& from, const QString& to) {
    return svc_.totalDonations(from, to);
}

void DonationController::setLastError(const QString& err) {
    if (lastError_ != err) { lastError_ = err; emit lastErrorChanged(); }
}

mms::Donation DonationController::mapToDonation(const QVariantMap& d) {
    mms::Donation don;
    don.id = d.value("id").toLongLong();
    don.donorName = d.value("donorName").toString();
    don.donorPhone = d.value("donorPhone").toString();
    don.donorAddress = d.value("donorAddress").toString();
    don.familyId = d.value("familyId").toLongLong();
    don.memberId = d.value("memberId").toLongLong();
    don.categoryId = d.value("categoryId").toLongLong();
    don.amount = d.value("amount").toDouble();
    don.donationDate = d.value("donationDate").toString();
    don.receiptNumber = d.value("receiptNumber").toString();
    don.purpose = d.value("purpose").toString();
    don.remarks = d.value("remarks").toString();
    don.paymentMethod = d.value("paymentMethod").toString();
    don.receivedBy = d.value("receivedBy").toLongLong();
    return don;
}

QVariantMap DonationController::donationToMap(const mms::Donation& d) {
    QVariantMap m;
    m["id"] = d.id;
    m["donorName"] = d.donorName;
    m["donorPhone"] = d.donorPhone;
    m["donorAddress"] = d.donorAddress;
    m["familyId"] = d.familyId;
    m["memberId"] = d.memberId;
    m["categoryId"] = d.categoryId;
    m["amount"] = d.amount;
    m["donationDate"] = d.donationDate;
    m["receiptNumber"] = d.receiptNumber;
    m["purpose"] = d.purpose;
    m["remarks"] = d.remarks;
    m["paymentMethod"] = d.paymentMethod;
    m["receivedBy"] = d.receivedBy;
    m["categoryName"] = d.categoryName;
    m["familyNumber"] = d.familyNumber;
    return m;
}

QString DonationController::guessField(const QString& error) {
    QString lower = error.toLower();
    if (lower.contains("donor")) return "donorName";
    if (lower.contains("amount")) return "amount";
    if (lower.contains("categor")) return "categoryId";
    return QString();
}
