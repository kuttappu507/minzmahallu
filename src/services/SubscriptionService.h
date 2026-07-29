/*
 * SubscriptionService.h
 */
#pragma once

#include "../models/Subscription.h"
#include "../repositories/SubscriptionRepository.h"
#include <vector>
#include <QString>

namespace mms {

class SubscriptionService {
public:
    qint64 createSubscription(Subscription& s, QString* errorMsg = nullptr);
    bool updateSubscription(const Subscription& s, QString* errorMsg = nullptr);
    bool deleteSubscription(qint64 id);

    std::vector<Subscription> list(int page = 1, int pageSize = 50,
                                   const QString& statusFilter = QString(),
                                   const QString& dateFrom = QString(),
                                   const QString& dateTo = QString(),
                                   qint64 familyId = 0,
                                   int* totalOut = nullptr);

    std::vector<SubscriptionRepository::DefaulterRow> defaulters();
    int markOverdue();

    std::vector<SubscriptionPlan> plans();

    double totalCollected(const QString& dateFrom, const QString& dateTo);
    double totalPending();
    double monthlyCollection();

    QString nextReceiptNumber();
};

} // namespace mms
