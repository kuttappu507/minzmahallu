/*
 * AuthService.h - Authentication & authorization service
 */
#pragma once

#include "../models/User.h"
#include "AuthSession.h"
#include <QObject>
#include <QString>
#include <optional>

namespace mms {

class AuthService : public QObject {
    Q_OBJECT
public:
    explicit AuthService(QObject* parent = nullptr);

    struct LoginResult {
        bool success = false;
        QString errorMessage;
        bool mustChangePassword = false;
        bool accountLocked = false;
        int remainingAttempts = 0;
    };

    LoginResult login(const QString& username, const QString& password);
    void logout();

    bool changePassword(qint64 userId, const QString& oldPassword, const QString& newPassword);
    bool resetPassword(qint64 userId, const QString& newPassword);
    bool adminResetPassword(qint64 targetUserId, const QString& newPassword);

    // User management (admin only)
    qint64 createUser(const QString& username, const QString& fullName, const QString& password,
                      const QString& role, const QString& email = QString(),
                      const QString& phone = QString(), bool mustChangePwd = true);
    bool updateUserProfile(qint64 userId, const QString& fullName, const QString& role,
                           const QString& email, const QString& phone, bool active);
    bool deleteUser(qint64 userId);
    bool unlockUser(qint64 userId);

    // Password policy
    static QString passwordPolicyDescription();

private:
    bool validatePassword(const QString& password, QString* error = nullptr);
};

} // namespace mms
