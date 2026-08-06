/*
 * UserController.cpp — Implementation
 */
#include "UserController.h"
#include "../repositories/UserRepository.h"

UserController::UserController(QObject* parent) : QObject(parent) {}

QVariantList UserController::list() {
    QVariantList out;
    for (const auto& u : repo_.listAll()) {
        out.append(userToMap(u));
    }
    return out;
}

QVariantMap UserController::get(qint64 id) {
    auto u = repo_.findById(id);
    if (u) return userToMap(*u);
    return {};
}

QVariantMap UserController::update(qint64 id, const QVariantMap& data) {
    QVariantMap result;
    auto u = repo_.findById(id);
    if (!u) { result["success"] = false; result["error"] = "User not found."; setLastError("User not found."); return result; }
    u->fullName = data.value("fullName").toString();
    u->role = data.value("role").toString();
    u->email = data.value("email").toString();
    u->phone = data.value("phone").toString();
    bool ok = repo_.update(*u);
    if (ok) { result["success"] = true; emit updated(id); }
    else { result["success"] = false; result["error"] = "Update failed."; setLastError("Update failed."); }
    return result;
}

QVariantMap UserController::setActive(qint64 id, bool active) {
    QVariantMap result;
    bool ok = repo_.setActive(id, active);
    if (ok) { result["success"] = true; emit updated(id); }
    else { result["success"] = false; result["error"] = "Failed to update status."; setLastError("Failed."); }
    return result;
}

QVariantMap UserController::unlock(qint64 id) {
    QVariantMap result;
    bool ok = repo_.unlock(id);
    if (ok) { result["success"] = true; emit updated(id); }
    else { result["success"] = false; result["error"] = "Failed to unlock."; setLastError("Failed."); }
    return result;
}

QVariantMap UserController::remove(qint64 id) {
    QVariantMap result;
    bool ok = repo_.remove(id);
    if (ok) { result["success"] = true; emit removed(id); }
    else { result["success"] = false; result["error"] = "Cannot delete user (may be the last Administrator)."; setLastError("Cannot delete."); }
    return result;
}

QStringList UserController::roles() const {
    return {"Administrator", "President", "Secretary", "Treasurer", "Imam", "Staff", "Auditor"};
}

QVariantMap UserController::userToMap(const mms::User& u) {
    QVariantMap m;
    m["id"] = u.id; m["username"] = u.username; m["fullName"] = u.fullName;
    m["role"] = u.role; m["email"] = u.email; m["phone"] = u.phone;
    m["isActive"] = u.isActive; m["isLocked"] = u.isLocked;
    m["failedAttempts"] = u.failedAttempts;
    m["lastLoginAt"] = u.lastLoginAt.isValid() ? u.lastLoginAt.toString(Qt::ISODate) : "";
    m["mustChangePwd"] = u.mustChangePwd;
    m["createdAt"] = u.createdAt.isValid() ? u.createdAt.toString(Qt::ISODate) : "";
    return m;
}
