/*
 * User.h - User domain model
 */
#pragma once

#include <QString>
#include <QDateTime>
#include <QVariantMap>

namespace mms {

struct User {
    qint64 id = 0;
    QString username;
    QString fullName;
    QString passwordHash;
    QString passwordSalt;
    QString role;            // Administrator, President, Secretary, Treasurer, Imam, Staff, Auditor
    QString email;
    QString phone;
    bool isActive = true;
    bool isLocked = false;
    int failedAttempts = 0;
    QDateTime lockedUntil;
    QDateTime lastLoginAt;
    bool mustChangePwd = false;
    QDateTime createdAt;
    QDateTime updatedAt;

    static User fromMap(const QVariantMap& m) {
        User u;
        u.id = m.value("id").toLongLong();
        u.username = m.value("username").toString();
        u.fullName = m.value("full_name").toString();
        u.passwordHash = m.value("password_hash").toString();
        u.passwordSalt = m.value("password_salt").toString();
        u.role = m.value("role").toString();
        u.email = m.value("email").toString();
        u.phone = m.value("phone").toString();
        u.isActive = m.value("is_active").toInt() == 1;
        u.isLocked = m.value("is_locked").toInt() == 1;
        u.failedAttempts = m.value("failed_attempts").toInt();
        QString lu = m.value("locked_until").toString();
        if (!lu.isEmpty()) u.lockedUntil = QDateTime::fromString(lu, Qt::ISODate);
        QString ll = m.value("last_login_at").toString();
        if (!ll.isEmpty()) u.lastLoginAt = QDateTime::fromString(ll, Qt::ISODate);
        u.mustChangePwd = m.value("must_change_pwd").toInt() == 1;
        u.createdAt = QDateTime::fromString(m.value("created_at").toString(), Qt::ISODate);
        u.updatedAt = QDateTime::fromString(m.value("updated_at").toString(), Qt::ISODate);
        return u;
    }

    QVariantMap toMap() const {
        QVariantMap m;
        m["id"] = id;
        m["username"] = username;
        m["full_name"] = fullName;
        m["password_hash"] = passwordHash;
        m["password_salt"] = passwordSalt;
        m["role"] = role;
        m["email"] = email;
        m["phone"] = phone;
        m["is_active"] = isActive ? 1 : 0;
        m["is_locked"] = isLocked ? 1 : 0;
        m["failed_attempts"] = failedAttempts;
        m["locked_until"] = lockedUntil.isValid() ? lockedUntil.toString(Qt::ISODate) : QVariant();
        m["last_login_at"] = lastLoginAt.isValid() ? lastLoginAt.toString(Qt::ISODate) : QVariant();
        m["must_change_pwd"] = mustChangePwd ? 1 : 0;
        return m;
    }
};

} // namespace mms
