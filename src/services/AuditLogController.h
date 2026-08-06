/*
 * AuditLogController.h — QML-facing controller for Audit Log module (read-only).
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include "../repositories/AuditLogRepository.h"

class AuditLogController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit AuditLogController(QObject* parent = nullptr) : QObject(parent) {}
    QString lastError() const { return lastError_; }

    Q_INVOKABLE QVariantList list(int page = 1, int pageSize = 50,
                                  const QString& actionFilter = QString(),
                                  const QString& moduleFilter = QString(),
                                  const QString& userFilter = QString());
    Q_INVOKABLE int countToday();

signals:
    void lastErrorChanged();

private:
    mms::AuditLogRepository repo_;
    QString lastError_;
};
