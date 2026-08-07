/*
 * AuthController.h — QML-facing controller for authentication & session.
 * Wraps existing AuthService + AuthSession. Exposes login/logout/user.
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include "AuthService.h"
#include "AuthSession.h"

class AuthController : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY sessionChanged)
    Q_PROPERTY(QVariantMap user READ user NOTIFY sessionChanged)
    Q_PROPERTY(QString fullName READ fullName NOTIFY sessionChanged)
    Q_PROPERTY(QString username READ username NOTIFY sessionChanged)
    Q_PROPERTY(QString role READ role NOTIFY sessionChanged)
    Q_PROPERTY(QString initials READ initials NOTIFY sessionChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit AuthController(QObject* parent = nullptr);

    bool isLoggedIn() const { return mms::AuthSession::instance().isLoggedIn(); }
    QVariantMap user() const;
    QString fullName() const;
    QString username() const;
    QString role() const;
    QString initials() const;
    QString lastError() const { return lastError_; }

    Q_INVOKABLE QVariantMap login(const QString& username, const QString& password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool changePassword(const QString& oldPassword, const QString& newPassword);
    Q_INVOKABLE bool hasPermission(const QString& module, const QString& action);
    Q_INVOKABLE QStringList roles() const;

signals:
    void sessionChanged();
    void lastErrorChanged();
    void loginFailed(const QString& message);

private slots:
    void onLoggedIn(const mms::User& user);
    void onLoggedOut();

private:
    mms::AuthService svc_;
    QString lastError_;
    void setLastError(const QString& err);
};
