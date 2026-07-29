/*
 * UserRepository.cpp
 */
#include "UserRepository.h"
#include "../core/Database.h"
#include "../core/Logger.h"
#include <QSqlQuery>
#include <QSqlRecord>
#include <QDateTime>

namespace mms {

// Qt6 removed QSqlRecord::toMap(); build the map manually.
static QVariantMap recordToMap(const QSqlQuery& q) {
    QVariantMap m;
    QSqlRecord r = q.record();
    for (int i = 0; i < r.count(); ++i) {
        m[r.fieldName(i)] = r.value(i);
    }
    return m;
}

std::optional<User> UserRepository::findByUsername(const QString& username) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM users WHERE username = ? LIMIT 1", { username });
    if (q.next()) {
        return User::fromMap(recordToMap(q));
    }
    return std::nullopt;
}

std::optional<User> UserRepository::findById(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM users WHERE id = ? LIMIT 1", { id });
    if (q.next()) {
        return User::fromMap(recordToMap(q));
    }
    return std::nullopt;
}

std::vector<User> UserRepository::listAll() {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM users ORDER BY username");
    std::vector<User> result;
    while (q.next()) {
        result.push_back(User::fromMap(recordToMap(q)));
    }
    return result;
}

std::vector<User> UserRepository::listByRole(const QString& role) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM users WHERE role = ? AND is_active = 1 ORDER BY full_name", { role });
    std::vector<User> result;
    while (q.next()) {
        result.push_back(User::fromMap(recordToMap(q)));
    }
    return result;
}

qint64 UserRepository::create(const User& user) {
    return Database::instance().insert(
        R"(INSERT INTO users
           (username, full_name, password_hash, password_salt, role, email, phone,
            is_active, is_locked, failed_attempts, must_change_pwd)
           VALUES (?,?,?,?,?,?,?,?,0,0,?))",
        { user.username, user.fullName, user.passwordHash, user.passwordSalt,
          user.role, user.email, user.phone,
          user.isActive ? 1 : 0, user.mustChangePwd ? 1 : 0 });
}

bool UserRepository::update(const User& user) {
    int n = Database::instance().update(
        R"(UPDATE users SET
           full_name = ?, role = ?, email = ?, phone = ?,
           is_active = ?, must_change_pwd = ?
           WHERE id = ?)",
        { user.fullName, user.role, user.email, user.phone,
          user.isActive ? 1 : 0, user.mustChangePwd ? 1 : 0, user.id });
    return n > 0;
}

bool UserRepository::updatePassword(qint64 userId, const QString& hash, const QString& salt) {
    int n = Database::instance().update(
        "UPDATE users SET password_hash = ?, password_salt = ?, must_change_pwd = 0 WHERE id = ?",
        { hash, salt, userId });
    return n > 0;
}

bool UserRepository::updateLastLogin(qint64 userId) {
    int n = Database::instance().update(
        "UPDATE users SET last_login_at = datetime('now') WHERE id = ?",
        { userId });
    return n > 0;
}

bool UserRepository::incrementFailedAttempts(qint64 userId, int lockThreshold, int lockMinutes) {
    QSqlQuery q = Database::instance().execute(
        "SELECT failed_attempts FROM users WHERE id = ?", { userId });
    if (!q.next()) return false;
    int attempts = q.value(0).toInt() + 1;

    if (attempts >= lockThreshold) {
        QString lockUntil = QDateTime::currentDateTime().addSecs(lockMinutes * 60).toString(Qt::ISODate);
        int n = Database::instance().update(
            "UPDATE users SET failed_attempts = ?, is_locked = 1, locked_until = ? WHERE id = ?",
            { attempts, lockUntil, userId });
        Logger::warn(QString("User %1 locked after %2 failed attempts until %3")
                     .arg(userId).arg(attempts).arg(lockUntil));
        return n > 0;
    }
    int n = Database::instance().update(
        "UPDATE users SET failed_attempts = ? WHERE id = ?",
        { attempts, userId });
    return n > 0;
}

bool UserRepository::resetFailedAttempts(qint64 userId) {
    int n = Database::instance().update(
        "UPDATE users SET failed_attempts = 0, is_locked = 0, locked_until = NULL WHERE id = ?",
        { userId });
    return n > 0;
}

bool UserRepository::setActive(qint64 userId, bool active) {
    int n = Database::instance().update(
        "UPDATE users SET is_active = ? WHERE id = ?",
        { active ? 1 : 0, userId });
    return n > 0;
}

bool UserRepository::unlock(qint64 userId) {
    int n = Database::instance().update(
        "UPDATE users SET is_locked = 0, locked_until = NULL, failed_attempts = 0 WHERE id = ?",
        { userId });
    return n > 0;
}

bool UserRepository::remove(qint64 userId) {
    // Prevent deletion of last administrator
    auto user = findById(userId);
    if (!user) return false;
    if (user->role == "Administrator") {
        int adminCount = countByRole("Administrator");
        if (adminCount <= 1) {
            Logger::warn("Cannot delete the last Administrator account");
            return false;
        }
    }
    int n = Database::instance().remove(
        "DELETE FROM users WHERE id = ?", { userId });
    return n > 0;
}

bool UserRepository::hasPermission(qint64 userId, const QString& module, const QString& action) {
    auto u = findById(userId);
    if (!u) return false;
    return roleHasPermission(u->role, module, action);
}

bool UserRepository::roleHasPermission(const QString& role, const QString& module, const QString& action) {
    if (role == "Administrator") return true;  // implicit
    QVariant v = Database::instance().scalar(
        "SELECT allowed FROM permissions WHERE role = ? AND module = ? AND action = ?",
        { role, module, action });
    return v.isValid() && v.toInt() == 1;
}

int UserRepository::count() {
    QVariant v = Database::instance().scalar("SELECT COUNT(*) FROM users");
    return v.toInt();
}

int UserRepository::countByRole(const QString& role) {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM users WHERE role = ? AND is_active = 1", { role });
    return v.toInt();
}

} // namespace mms
