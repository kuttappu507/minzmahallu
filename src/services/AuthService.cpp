/*
 * AuthService.cpp
 */
#include "AuthService.h"
#include "../core/Security.h"
#include "../core/Logger.h"
#include "../core/Database.h"
#include "../repositories/UserRepository.h"
#include "../repositories/AuditLogRepository.h"
#include <QDateTime>

namespace mms {

constexpr int MAX_FAILED_ATTEMPTS = 5;
constexpr int LOCK_DURATION_MIN   = 15;

AuthService::AuthService(QObject* parent) : QObject(parent) {}

AuthService::LoginResult AuthService::login(const QString& username, const QString& password) {
    LoginResult result;
    UserRepository users;

    auto user = users.findByUsername(username);
    if (!user) {
        result.errorMessage = "Invalid username or password.";
        Logger::warn(QString("Failed login attempt for unknown user: %1").arg(username));
        return result;
    }

    if (!user->isActive) {
        result.errorMessage = "This account has been deactivated. Contact the administrator.";
        return result;
    }

    // Check lock
    if (user->isLocked) {
        if (user->lockedUntil.isValid() && user->lockedUntil > QDateTime::currentDateTime()) {
            result.accountLocked = true;
            qint64 secsLeft = QDateTime::currentDateTime().secsTo(user->lockedUntil);
            result.errorMessage = QString("Account is locked. Try again in %1 minutes.")
                                      .arg((secsLeft + 59) / 60);
            return result;
        } else {
            // Lock expired - unlock
            users.unlock(user->id);
            user->isLocked = false;
            user->failedAttempts = 0;
        }
    }

    if (!Security::instance().verifyPassword(password, user->passwordHash)) {
        users.incrementFailedAttempts(user->id, MAX_FAILED_ATTEMPTS, LOCK_DURATION_MIN);
        int remaining = MAX_FAILED_ATTEMPTS - (user->failedAttempts + 1);
        result.remainingAttempts = std::max(0, remaining);
        if (remaining <= 0) {
            result.accountLocked = true;
            result.errorMessage = QString("Account locked due to too many failed attempts. "
                                          "Try again in %1 minutes.").arg(LOCK_DURATION_MIN);
        } else {
            result.errorMessage = QString("Invalid username or password. %1 attempt(s) remaining.")
                                      .arg(remaining);
        }
        AuditLogRepository audit;
        audit.log(user->id, username, "LOGIN_FAILED", "auth", 0,
                  "Failed login attempt", "");
        return result;
    }

    // Success
    users.resetFailedAttempts(user->id);
    users.updateLastLogin(user->id);

    AuthSession::instance().setUser(*user);
    AuthSession::instance().setToken(Security::generateToken());

    AuditLogRepository audit;
    audit.log(user->id, username, "LOGIN", "auth", user->id, "User logged in", "");

    result.success = true;
    result.mustChangePassword = user->mustChangePwd;
    Logger::info(QString("User %1 logged in successfully").arg(username));
    return result;
}

void AuthService::logout() {
    if (AuthSession::instance().isLoggedIn()) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "LOGOUT", "auth", u.id, "User logged out", "");
        Logger::info(QString("User %1 logged out").arg(u.username));
    }
    AuthSession::instance().clear();
}

bool AuthService::validatePassword(const QString& password, QString* error) {
    if (password.length() < 8) {
        if (error) *error = "Password must be at least 8 characters long.";
        return false;
    }
    if (!Security::isStrongPassword(password)) {
        if (error) *error = "Password must contain uppercase, lowercase, digit, and special character.";
        return false;
    }
    return true;
}

bool AuthService::changePassword(qint64 userId, const QString& oldPassword, const QString& newPassword) {
    UserRepository users;
    auto user = users.findById(userId);
    if (!user) return false;

    if (!Security::instance().verifyPassword(oldPassword, user->passwordHash)) {
        Logger::warn(QString("Password change failed for user %1: wrong current password").arg(userId));
        return false;
    }
    QString err;
    if (!validatePassword(newPassword, &err)) {
        Logger::warn(QString("Password change failed for user %1: %2").arg(userId).arg(err));
        return false;
    }
    QByteArray salt = Security::generateSalt();
    QString hash = Security::instance().hashPassword(newPassword, salt);
    bool ok = users.updatePassword(userId, hash, QString::fromUtf8(salt.toBase64()));
    if (ok) {
        AuditLogRepository audit;
        audit.log(userId, user->username, "PASSWORD_CHANGE", "auth", userId, "User changed password", "");
    }
    return ok;
}

bool AuthService::resetPassword(qint64 userId, const QString& newPassword) {
    QString err;
    if (!validatePassword(newPassword, &err)) return false;

    UserRepository users;
    auto user = users.findById(userId);
    if (!user) return false;

    QByteArray salt = Security::generateSalt();
    QString hash = Security::instance().hashPassword(newPassword, salt);
    bool ok = users.updatePassword(userId, hash, QString::fromUtf8(salt.toBase64()));
    if (ok) {
        AuditLogRepository audit;
        audit.log(AuthSession::instance().user().id, AuthSession::instance().user().username,
                  "PASSWORD_RESET", "auth", userId, "Admin reset user password", "");
    }
    return ok;
}

bool AuthService::adminResetPassword(qint64 targetUserId, const QString& newPassword) {
    return resetPassword(targetUserId, newPassword);
}

qint64 AuthService::createUser(const QString& username, const QString& fullName, const QString& password,
                               const QString& role, const QString& email, const QString& phone,
                               bool mustChangePwd) {
    if (username.length() < 3) return -1;
    QString err;
    if (!validatePassword(password, &err)) {
        Logger::warn(QString("Create user failed: %1").arg(err));
        return -1;
    }

    static const QStringList validRoles = {
        "Administrator","President","Secretary","Treasurer","Imam","Staff","Auditor"
    };
    if (!validRoles.contains(role)) return -1;

    UserRepository users;
    if (users.findByUsername(username)) {
        Logger::warn(QString("Create user failed: username %1 already exists").arg(username));
        return -1;
    }

    QByteArray salt = Security::generateSalt();
    QString hash = Security::instance().hashPassword(password, salt);

    User u;
    u.username = username;
    u.fullName = fullName;
    u.passwordHash = hash;
    u.passwordSalt = QString::fromUtf8(salt.toBase64());
    u.role = role;
    u.email = email;
    u.phone = phone;
    u.isActive = true;
    u.mustChangePwd = mustChangePwd;

    qint64 id = users.create(u);
    if (id > 0) {
        AuditLogRepository audit;
        audit.log(AuthSession::instance().user().id, AuthSession::instance().user().username,
                  "ADD", "user", id,
                  QString("Created user %1 (%2, role=%3)").arg(username).arg(fullName).arg(role), "");
    }
    return id;
}

bool AuthService::updateUserProfile(qint64 userId, const QString& fullName, const QString& role,
                                    const QString& email, const QString& phone, bool active) {
    UserRepository users;
    auto user = users.findById(userId);
    if (!user) return false;
    user->fullName = fullName;
    user->role = role;
    user->email = email;
    user->phone = phone;
    user->isActive = active;
    bool ok = users.update(*user);
    if (ok) {
        AuditLogRepository audit;
        audit.log(AuthSession::instance().user().id, AuthSession::instance().user().username,
                  "EDIT", "user", userId,
                  QString("Updated user profile: %1").arg(user->username), "");
    }
    return ok;
}

bool AuthService::deleteUser(qint64 userId) {
    UserRepository users;
    auto user = users.findById(userId);
    if (!user) return false;
    if (user->id == AuthSession::instance().user().id) {
        Logger::warn("User cannot delete their own account");
        return false;
    }
    bool ok = users.remove(userId);
    if (ok) {
        AuditLogRepository audit;
        audit.log(AuthSession::instance().user().id, AuthSession::instance().user().username,
                  "DELETE", "user", userId,
                  QString("Deleted user %1").arg(user->username), "");
    }
    return ok;
}

bool AuthService::unlockUser(qint64 userId) {
    UserRepository users;
    bool ok = users.unlock(userId);
    if (ok) {
        AuditLogRepository audit;
        audit.log(AuthSession::instance().user().id, AuthSession::instance().user().username,
                  "UNLOCK", "user", userId, "Manually unlocked user", "");
    }
    return ok;
}

QString AuthService::passwordPolicyDescription() {
    return "Password must be at least 8 characters long and contain at least one uppercase letter, "
           "one lowercase letter, one digit, and one special character.";
}

} // namespace mms
