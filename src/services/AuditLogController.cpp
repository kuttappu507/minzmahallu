/*
 * AuditLogController.cpp — Implementation
 */
#include "AuditLogController.h"

QVariantList AuditLogController::list(int page, int pageSize,
                                       const QString& actionFilter,
                                       const QString& moduleFilter,
                                       const QString& userFilter) {
    QVariantList out;
    int total = 0;
    auto items = repo_.list(page, pageSize, actionFilter, moduleFilter, userFilter, "", "", &total);
    for (const auto& a : items) {
        QVariantMap m;
        m["id"] = a.id; m["userId"] = a.userId; m["username"] = a.username;
        m["action"] = a.action; m["module"] = a.module; m["entityId"] = a.entityId;
        m["description"] = a.description; m["ipAddress"] = a.ipAddress;
        m["createdAt"] = a.createdAt.isValid() ? a.createdAt.toString(Qt::ISODate) : "";
        out.append(m);
    }
    return out;
}

int AuditLogController::countToday() { return repo_.countToday(); }
