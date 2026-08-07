/*
 * AuthController.cpp — Implementation
 */
#include "AuthController.h"

AuthController::AuthController(QObject* parent)
    : QObject(parent)
{
    connect(&mms::AuthSession::instance(), &mms::AuthSession::loggedIn, this, &AuthController::onLoggedIn);
    connect(&mms::AuthSession::instance(), &mms::AuthSession::loggedOut, this, &AuthController::onLoggedOut);
}

QVariantMap AuthController::user() const {
    auto& u = mms::AuthSession::instance().user();
    QVariantMap m;
    m["id"] = u.id;
    m["username"] = u.username;
    m["fullName"] = u.fullName;
    m["role"] = u.role;
    m["email"] = u.email;
    m["phone"] = u.phone;
    m["isActive"] = u.isActive;
    m["mustChangePwd"] = u.mustChangePwd;
    return m;
}

QString AuthController::fullName() const {
    return mms::AuthSession::instance().user().fullName;
}

QString AuthController::username() const {
    return mms::AuthSession::instance().user().username;
}

QString AuthController::role() const {
    return mms::AuthSession::instance().user().role;
}

QString AuthController::initials() const {
    auto& u = mms::AuthSession::instance().user();
    if (!u.fullName.isEmpty()) {
        auto parts = u.fullName.split(' ', Qt::SkipEmptyParts);
        if (parts.size() >= 2) return parts[0].left(1).toUpper() + parts[1].left(1).toUpper();
        return u.fullName.left(2).toUpper();
    }
    return u.username.left(2).toUpper();
}

QVariantMap AuthController::login(const QString& username, const QString& password) {
    QVariantMap result;
    auto loginResult = svc_.login(username, password);

    if (loginResult.success) {
        result["success"] = true;
        result["mustChangePassword"] = loginResult.mustChangePassword;
        result["accountLocked"] = loginResult.accountLocked;
        result["remainingAttempts"] = loginResult.remainingAttempts;
        setLastError(QString());
        // AuthSession::setUser is called inside AuthService::login
        // onLoggedIn slot will fire and emit sessionChanged
    } else {
        result["success"] = false;
        result["error"] = loginResult.errorMessage;
        result["accountLocked"] = loginResult.accountLocked;
        result["remainingAttempts"] = loginResult.remainingAttempts;
        setLastError(loginResult.errorMessage);
        emit loginFailed(loginResult.errorMessage);
    }
    return result;
}

void AuthController::logout() {
    svc_.logout();
    mms::AuthSession::instance().clear();
    // onLoggedOut slot will fire and emit sessionChanged
}

bool AuthController::changePassword(const QString& oldPassword, const QString& newPassword) {
    auto userId = mms::AuthSession::instance().user().id;
    bool ok = svc_.changePassword(userId, oldPassword, newPassword);
    if (!ok) setLastError("Password change failed. Check your old password.");
    return ok;
}

bool AuthController::hasPermission(const QString& module, const QString& action) {
    return mms::AuthSession::instance().hasPermission(module, action);
}

QStringList AuthController::roles() const {
    return {"Administrator", "President", "Secretary", "Treasurer", "Imam", "Staff", "Auditor"};
}

void AuthController::onLoggedIn(const mms::User& user) {
    Q_UNUSED(user)
    emit sessionChanged();
}

void AuthController::onLoggedOut() {
    emit sessionChanged();
}

void AuthController::setLastError(const QString& err) {
    if (lastError_ != err) {
        lastError_ = err;
        emit lastErrorChanged();
    }
}
