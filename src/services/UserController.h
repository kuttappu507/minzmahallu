/*
 * UserController.h — QML-facing controller for Users module.
 * Read-only list + profile update + activate/deactivate + unlock.
 * Password changes stay in the widgets app for now (security-sensitive).
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include "AuthService.h"

class UserController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit UserController(QObject* parent = nullptr);
    QString lastError() const { return lastError_; }

    Q_INVOKABLE QVariantList list();
    Q_INVOKABLE QVariantMap get(qint64 id);
    Q_INVOKABLE QVariantMap update(qint64 id, const QVariantMap& data);
    Q_INVOKABLE QVariantMap setActive(qint64 id, bool active);
    Q_INVOKABLE QVariantMap unlock(qint64 id);
    Q_INVOKABLE QVariantMap remove(qint64 id);
    Q_INVOKABLE QStringList roles() const;

signals:
    void lastErrorChanged();
    void updated(qint64 id);
    void removed(qint64 id);
    void errorOccurred(const QString& message);

private:
    mms::AuthService svc_;
    mms::UserRepository repo_;
    QString lastError_;
    void setLastError(const QString& err) { if (lastError_ != err) { lastError_ = err; emit lastErrorChanged(); } }
    static QVariantMap userToMap(const mms::User& u);
};
