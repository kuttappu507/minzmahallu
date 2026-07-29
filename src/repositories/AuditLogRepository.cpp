/*
 * AuditLogRepository.cpp
 */
#include "AuditLogRepository.h"
#include "../core/Database.h"

namespace mms {

void AuditLogRepository::log(qint64 userId, const QString& username, const QString& action,
                             const QString& module, qint64 entityId, const QString& description,
                             const QString& ipAddress) {
    Database::instance().insert(
        "INSERT INTO audit_log (user_id, username, action, module, entity_id, description, ip_address) "
        "VALUES (?,?,?,?,?,?,?)",
        { userId > 0 ? QVariant(userId) : QVariant(), username, action, module,
          entityId > 0 ? QVariant(entityId) : QVariant(), description, ipAddress });
}

std::vector<AuditLog> AuditLogRepository::list(int page, int pageSize,
                                               const QString& actionFilter,
                                               const QString& moduleFilter,
                                               const QString& userFilter,
                                               const QString& dateFrom,
                                               const QString& dateTo,
                                               int* totalOut) {
    QStringList where;
    QVariantList params;
    if (!actionFilter.isEmpty()) { where << "action = ?";     params << actionFilter; }
    if (!moduleFilter.isEmpty()) { where << "module = ?";     params << moduleFilter; }
    if (!userFilter.isEmpty())   { where << "username = ?";   params << userFilter;   }
    if (!dateFrom.isEmpty())     { where << "date(created_at) >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())       { where << "date(created_at) <= ?"; params << dateTo;   }
    QString whereSql = where.isEmpty() ? QString() : ("WHERE " + where.join(" AND "));

    if (totalOut) {
        QVariant c = Database::instance().scalar(
            "SELECT COUNT(*) FROM audit_log " + whereSql, params);
        *totalOut = c.toInt();
    }

    QString sql = QString(
        "SELECT * FROM audit_log %1 ORDER BY created_at DESC, id DESC LIMIT ? OFFSET ?")
        .arg(whereSql);
    int offset = (page - 1) * pageSize;
    params << pageSize << offset;
    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<AuditLog> result;
    while (q.next()) result.push_back(AuditLog::fromQuery(q));
    return result;
}

int AuditLogRepository::countToday() {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM audit_log WHERE date(created_at) = date('now')");
    return v.toInt();
}

int AuditLogRepository::countByAction(const QString& action) {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM audit_log WHERE action = ?", { action });
    return v.toInt();
}

} // namespace mms
