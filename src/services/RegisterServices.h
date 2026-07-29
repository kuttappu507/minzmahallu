/*
 * MarriageService.h, DeathService.h, WelfareService.h - combined header
 * (kept in one file for compactness; each service has its own .cpp)
 */
#pragma once

#include "../models/Marriage.h"
#include "../models/Death.h"
#include "../models/Welfare.h"
#include <vector>
#include <QString>

namespace mms {

class MarriageService {
public:
    qint64 createMarriage(Marriage& m, QString* errorMsg = nullptr);
    bool updateMarriage(const Marriage& m, QString* errorMsg = nullptr);
    bool deleteMarriage(qint64 id);

    std::vector<Marriage> list(int page = 1, int pageSize = 50,
                               const QString& searchTerm = QString(),
                               const QString& dateFrom = QString(),
                               const QString& dateTo = QString(),
                               int* totalOut = nullptr);
    Marriage getMarriage(qint64 id);
    QString nextMarriageNumber();
    int countThisYear();
};

class DeathService {
public:
    qint64 createDeath(Death& d, QString* errorMsg = nullptr);
    bool updateDeath(const Death& d, QString* errorMsg = nullptr);
    bool deleteDeath(qint64 id);

    std::vector<Death> list(int page = 1, int pageSize = 50,
                            const QString& searchTerm = QString(),
                            const QString& dateFrom = QString(),
                            const QString& dateTo = QString(),
                            int* totalOut = nullptr);
    Death getDeath(qint64 id);
    QString nextDeathNumber();
    int countThisYear();
};

class WelfareService {
public:
    qint64 createRequest(WelfareRequest& w, QString* errorMsg = nullptr);
    bool updateRequest(const WelfareRequest& w, QString* errorMsg = nullptr);
    bool deleteRequest(qint64 id);

    bool approveRequest(qint64 id, double amount, const QString& remarks);
    bool rejectRequest(qint64 id, const QString& remarks);
    bool disburseRequest(qint64 id, const QString& date);

    std::vector<WelfareRequest> list(int page = 1, int pageSize = 50,
                                     const QString& statusFilter = QString(),
                                     const QString& categoryFilter = QString(),
                                     const QString& searchTerm = QString(),
                                     int* totalOut = nullptr);
    WelfareRequest getRequest(qint64 id);
    QString nextRequestNumber();
};

} // namespace mms
