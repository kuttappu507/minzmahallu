/*
 * AuthSession.h - Holds the currently authenticated user session
 *
 * Singleton-style accessor scoped to the application lifetime.
 * Emits signals on login/logout.
 */
#pragma once

#include "../models/User.h"
#include <QObject>
#include <QString>
#include <QDateTime>

namespace mms {

class AuthSession : public QObject {
    Q_OBJECT
public:
    static AuthSession& instance();

    bool isLoggedIn() const { return user_.id > 0; }
    const User& user() const { return user_; }
    QString token() const { return token_; }
    QDateTime loginTime() const { return loginTime_; }

    void setUser(const User& u);
    void setToken(const QString& t) { token_ = t; }
    void setLoginTime(const QDateTime& t) { loginTime_ = t; }

    bool hasPermission(const QString& module, const QString& action) const;

    void clear();

signals:
    void loggedIn(const User& user);
    void loggedOut();
    void permissionDenied(const QString& module, const QString& action);

private:
    AuthSession() = default;
    ~AuthSession() override = default;
    AuthSession(const AuthSession&) = delete;
    AuthSession& operator=(const AuthSession&) = delete;

    User user_;
    QString token_;
    QDateTime loginTime_;
};

} // namespace mms
