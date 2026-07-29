/*
 * UserRepository.h
 */
#pragma once

#include "../models/User.h"
#include <vector>
#include <optional>
#include <QString>
#include <QVariantList>

namespace mms {

class UserRepository {
public:
    // Find user by username; returns std::nullopt if not found
    std::optional<User> findByUsername(const QString& username);

    // Find user by id
    std::optional<User> findById(qint64 id);

    // List all users
    std::vector<User> listAll();

    // List users by role
    std::vector<User> listByRole(const QString& role);

    // Create a new user; returns the new user id (or -1 on failure)
    qint64 create(const User& user);

    // Update an existing user's profile (no password change)
    bool update(const User& user);

    // Update password hash + salt
    bool updatePassword(qint64 userId, const QString& hash, const QString& salt);

    // Update last login timestamp
    bool updateLastLogin(qint64 userId);

    // Increment failed attempts; lock user if threshold exceeded
    bool incrementFailedAttempts(qint64 userId, int lockThreshold = 5, int lockMinutes = 15);

    // Reset failed attempts on successful login
    bool resetFailedAttempts(qint64 userId);

    // Activate/deactivate user
    bool setActive(qint64 userId, bool active);

    // Unlock user manually
    bool unlock(qint64 userId);

    // Delete user (cannot delete the last Administrator)
    bool remove(qint64 userId);

    // Check role permission for module/action
    bool hasPermission(qint64 userId, const QString& module, const QString& action);

    // Check role permission by role name
    bool roleHasPermission(const QString& role, const QString& module, const QString& action);

    // Count users
    int count();
    int countByRole(const QString& role);
};

} // namespace mms
