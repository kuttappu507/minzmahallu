/*
 * SubscriptionService.cpp
 */
#include "SubscriptionService.h"
#include "../repositories/SubscriptionRepository.h"
#include "../repositories/AuditLogRepository.h"
#include "AuthSession.h"
#include <QDate>

namespace mms {

qint64 SubscriptionService::createSubscription(Subscription& s, QString* errorMsg) {
    if (s.familyId <= 0) { if (errorMsg) *errorMsg = "Family is required."; return -1; }
    if (s.planId <= 0)   { if (errorMsg) *errorMsg = "Subscription plan is required."; return -1; }
    if (s.amount <= 0)   { if (errorMsg) *errorMsg = "Amount must be greater than zero."; return -1; }
    if (s.amountPaid > s.amount) {
        if (errorMsg) *errorMsg = "Amount paid cannot exceed total amount.";
        return -1;
    }

    if (s.status == "Paid" && s.amountPaid < s.amount) s.status = "Partial";
    if (s.status == "Paid" && s.paymentDate.isEmpty()) s.paymentDate = QDate::currentDate().toString(Qt::ISODate);
    if (s.receiptNumber.isEmpty()) s.receiptNumber = nextReceiptNumber();
    if (s.collectedBy <= 0) s.collectedBy = AuthSession::instance().user().id;

    SubscriptionRepository repo;
    qint64 id = repo.create(s);
    if (id > 0) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "ADD", "subscription", id,
                  QString("Created subscription %1 (₹%2, %3)").arg(s.receiptNumber).arg(s.amount).arg(s.status), "");
    }
    return id;
}

bool SubscriptionService::updateSubscription(const Subscription& s, QString* errorMsg) {
    SubscriptionRepository repo;
    if (!repo.findById(s.id)) {
        if (errorMsg) *errorMsg = "Subscription not found.";
        return false;
    }
    bool ok = repo.update(s);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "EDIT", "subscription", s.id,
                  QString("Updated subscription %1").arg(s.receiptNumber), "");
    }
    return ok;
}

bool SubscriptionService::deleteSubscription(qint64 id) {
    SubscriptionRepository repo;
    auto s = repo.findById(id);
    bool ok = repo.remove(id);
    if (ok && s) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "DELETE", "subscription", id,
                  QString("Deleted subscription %1").arg(s->receiptNumber), "");
    }
    return ok;
}

std::vector<Subscription> SubscriptionService::list(int page, int pageSize,
                                                    const QString& statusFilter,
                                                    const QString& dateFrom,
                                                    const QString& dateTo,
                                                    qint64 familyId,
                                                    int* totalOut) {
    SubscriptionRepository repo;
    return repo.list(page, pageSize, statusFilter, dateFrom, dateTo, familyId, totalOut);
}

std::vector<SubscriptionRepository::DefaulterRow> SubscriptionService::defaulters() {
    SubscriptionRepository repo;
    return repo.defaulters();
}

int SubscriptionService::markOverdue() {
    SubscriptionRepository repo;
    return repo.markOverdue();
}

std::vector<SubscriptionPlan> SubscriptionService::plans() {
    SubscriptionRepository repo;
    return repo.listPlans();
}

double SubscriptionService::totalCollected(const QString& dateFrom, const QString& dateTo) {
    SubscriptionRepository repo;
    return repo.totalCollected(dateFrom, dateTo);
}

double SubscriptionService::totalPending() {
    SubscriptionRepository repo;
    return repo.totalPending();
}

double SubscriptionService::monthlyCollection() {
    SubscriptionRepository repo;
    return repo.totalCollectedThisMonth();
}

QString SubscriptionService::nextReceiptNumber() {
    SubscriptionRepository repo;
    return repo.generateNextReceiptNumber();
}

} // namespace mms
