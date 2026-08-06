/*
 * AccountingController.cpp — Implementation
 */
#include "AccountingController.h"
#include "../repositories/AccountingRepository.h"

AccountingController::AccountingController(QObject* parent) : QObject(parent) {}

QVariantMap AccountingController::create(const QVariantMap& data) {
    QVariantMap result;
    mms::Transaction t = mapToTransaction(data);
    QString err;
    qint64 id = svc_.createTransaction(t, &err);
    if (id > 0) { result["success"] = true; result["id"] = id; setLastError(QString()); emit created(id); bumpSummary(); }
    else { result["success"] = false; result["id"] = 0; result["error"] = err; result["field"] = guessField(err); setLastError(err); emit errorOccurred(err); }
    return result;
}

QVariantMap AccountingController::update(qint64 id, const QVariantMap& data) {
    QVariantMap result;
    mms::Transaction t = mapToTransaction(data);
    t.id = id;
    QString err;
    bool ok = svc_.updateTransaction(t, &err);
    if (ok) { result["success"] = true; setLastError(QString()); emit updated(id); bumpSummary(); }
    else { result["success"] = false; result["error"] = err; result["field"] = guessField(err); setLastError(err); emit errorOccurred(err); }
    return result;
}

QVariantMap AccountingController::remove(qint64 id) {
    QVariantMap result;
    bool ok = svc_.deleteTransaction(id);
    if (ok) { result["success"] = true; setLastError(QString()); emit removed(id); bumpSummary(); }
    else { result["success"] = false; result["error"] = lastError(); emit errorOccurred(lastError()); }
    return result;
}

QVariantMap AccountingController::get(qint64 id) {
    mms::AccountingRepository repo;
    auto t = repo.findTransaction(id);
    if (t) return transactionToMap(*t);
    return {};
}

QVariantList AccountingController::accounts(const QString& typeFilter) {
    QVariantList out;
    auto accs = svc_.accounts(typeFilter);
    for (const auto& a : accs) {
        QVariantMap m;
        m["id"] = a.id; m["code"] = a.code; m["name"] = a.name;
        m["type"] = a.type; m["category"] = a.category; m["isActive"] = a.isActive;
        out.append(m);
    }
    return out;
}

double AccountingController::totalIncome(const QString& from, const QString& to) { return svc_.totalIncome(from, to); }
double AccountingController::totalExpense(const QString& from, const QString& to) { return svc_.totalExpense(from, to); }
double AccountingController::balance(const QString& from, const QString& to) { return svc_.balance(from, to); }

void AccountingController::setLastError(const QString& err) {
    if (lastError_ != err) { lastError_ = err; emit lastErrorChanged(); }
}

mms::Transaction AccountingController::mapToTransaction(const QVariantMap& d) {
    mms::Transaction t;
    t.id = d.value("id").toLongLong();
    t.txnDate = d.value("txnDate").toString();
    t.accountId = d.value("accountId").toLongLong();
    t.type = d.value("type").toString();
    t.amount = d.value("amount").toDouble();
    t.paymentMethod = d.value("paymentMethod").toString();
    t.reference = d.value("reference").toString();
    t.description = d.value("description").toString();
    t.linkedModule = d.value("linkedModule").toString();
    t.linkedId = d.value("linkedId").toLongLong();
    t.receiptNumber = d.value("receiptNumber").toString();
    t.createdBy = d.value("createdBy").toLongLong();
    return t;
}

QVariantMap AccountingController::transactionToMap(const mms::Transaction& t) {
    QVariantMap m;
    m["id"] = t.id; m["txnDate"] = t.txnDate; m["accountId"] = t.accountId;
    m["type"] = t.type; m["amount"] = t.amount; m["paymentMethod"] = t.paymentMethod;
    m["reference"] = t.reference; m["description"] = t.description;
    m["linkedModule"] = t.linkedModule; m["linkedId"] = t.linkedId;
    m["receiptNumber"] = t.receiptNumber; m["createdBy"] = t.createdBy;
    m["accountName"] = t.accountName; m["accountCode"] = t.accountCode;
    return m;
}

QString AccountingController::guessField(const QString& error) {
    QString lower = error.toLower();
    if (lower.contains("account")) return "accountId";
    if (lower.contains("amount")) return "amount";
    return QString();
}
