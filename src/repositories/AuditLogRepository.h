/*
 * AuditLogRepository.h
 */
#pragma once

#include "../models/AuditLog.h"
#include "../models/AuditLog.h"
#include <vector>
#include <QString>

namespace mms {

class AuditLogRepository {
public:
    void log(qint64 userId, const QString& username, const QString& action,
             const QString& module, qint64 entityId, const QString& description,
             const QString& ipAddress = QString());

    std::vector<AuditLog> list(int page = 1, int pageSize = 100,
                               const QString& actionFilter = QString(),
                               const QString& moduleFilter = QString(),
                               const QString& userFilter = QString(),
                               const QString& dateFrom = QString(),
                               const QString& dateTo = QString(),
                               int* totalOut = nullptr);

    int countToday();
    int countByAction(const QString& action);
};

} // namespace mms
