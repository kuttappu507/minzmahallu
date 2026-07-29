/*
 * WelfareRepository.h
 */
#pragma once

#include "../models/Welfare.h"
#include <vector>
#include <optional>
#include <QString>

namespace mms {

class WelfareRepository {
public:
    std::optional<WelfareRequest> findById(qint64 id);
    std::optional<WelfareRequest> findByNumber(const QString& num);

    std::vector<WelfareRequest> list(int page = 1, int pageSize = 50,
                                     const QString& statusFilter = QString(),
                                     const QString& categoryFilter = QString(),
                                     const QString& searchTerm = QString(),
                                     int* totalOut = nullptr);

    QString generateNextNumber();
    qint64 create(const WelfareRequest& w);
    bool update(const WelfareRequest& w);
    bool remove(qint64 id);

    bool approve(qint64 id, qint64 approverId, double approvedAmount, const QString& remarks);
    bool reject(qint64 id, qint64 approverId, const QString& remarks);
    bool disburse(qint64 id, const QString& disbursementDate);

    int countByStatus(const QString& status);
    double totalDisbursedThisYear();
    std::vector<WelfareRequest> listByFamily(qint64 familyId);
};

} // namespace mms
