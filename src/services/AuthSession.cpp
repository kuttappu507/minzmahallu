/*
 * AuthSession.cpp
 */
#include "AuthSession.h"
#include "../repositories/UserRepository.h"

namespace mms {

AuthSession& AuthSession::instance() {
    static AuthSession inst;
    return inst;
}

void AuthSession::setUser(const User& u) {
    user_ = u;
    loginTime_ = QDateTime::currentDateTime();
    emit loggedIn(u);
}

bool AuthSession::hasPermission(const QString& module, const QString& action) const {
    if (!isLoggedIn()) return false;
    UserRepository repo;
    return repo.hasPermission(user_.id, module, action);
}

void AuthSession::clear() {
    User old = user_;
    user_ = User{};
    token_.clear();
    loginTime_ = QDateTime();
    if (old.id > 0) emit loggedOut();
}

} // namespace mms
