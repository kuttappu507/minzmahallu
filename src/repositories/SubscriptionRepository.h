/*
 * SubscriptionRepository.h
 */
#pragma once

#include "../models/Subscription.h"
#include <vector>
#include <optional>
#include <QString>

namespace mms {

class SubscriptionRepository {
public:
    std::optional<Subscription> findById(qint64 id);
    std::optional<Subscription> findByReceiptNumber(const QString& receipt);

    std::vector<SubscriptionPlan> listPlans();
    std::optional<SubscriptionPlan> findPlan(qint64 id);

    std::vector<Subscription> list(int page = 1, int pageSize = 50,
                                   const QString& statusFilter = QString(),
                                   const QString& dateFrom = QString(),
                                   const QString& dateTo = QString(),
                                   qint64 familyId = 0,
                                   int* totalOut = nullptr);

    // Generate next receipt number
    QString generateNextReceiptNumber(const QString& prefix = "RCP");

    qint64 create(const Subscription& s);
    bool update(const Subscription& s);
    bool remove(qint64 id);

    // Mark overdue: any pending subscription whose period_end < today
    int markOverdue();

    // Defaulters: families with pending/overdue subscriptions
    struct DefaulterRow {
        qint64 familyId;
        QString familyNumber;
        QString houseName;
        QString phone;
        int pendingCount;
        double dueAmount;
    };
    std::vector<DefaulterRow> defaulters();

    // Summary
    double totalCollected(const QString& dateFrom, const QString& dateTo);
    double totalPending();
    double totalCollectedThisMonth();
};

} // namespace mms
