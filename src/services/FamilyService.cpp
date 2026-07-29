/*
 * FamilyService.cpp
 */
#include "FamilyService.h"
#include "../repositories/FamilyRepository.h"
#include "../repositories/AuditLogRepository.h"
#include "../core/Logger.h"
#include "../core/Security.h"
#include "AuthSession.h"
#include <stdexcept>

namespace mms {

qint64 FamilyService::createFamily(Family& f, QString* errorMsg) {
    if (f.houseName.trimmed().isEmpty() && f.address.trimmed().isEmpty()) {
        if (errorMsg) *errorMsg = "Either House Name or Address is required.";
        return -1;
    }
    if (f.phone.isEmpty() && f.alternativePhone.isEmpty()) {
        if (errorMsg) *errorMsg = "At least one phone number is required.";
        return -1;
    }
    if (!f.phone.isEmpty() && !Security::isValidPhone(f.phone)) {
        if (errorMsg) *errorMsg = "Phone number format is invalid.";
        return -1;
    }
    if (!f.pincode.isEmpty() && !Security::isValidPincode(f.pincode)) {
        if (errorMsg) *errorMsg = "Pincode must be a 6-digit number.";
        return -1;
    }

    FamilyRepository repo;
    if (f.familyNumber.isEmpty()) {
        f.familyNumber = repo.generateNextFamilyNumber();
    } else if (repo.findByNumber(f.familyNumber)) {
        if (errorMsg) *errorMsg = "Family number already exists.";
        return -1;
    }

    qint64 id = repo.create(f);
    if (id > 0) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "ADD", "family", id,
                  QString("Created family %1 (%2)").arg(f.familyNumber).arg(f.houseName), "");
    }
    return id;
}

bool FamilyService::updateFamily(const Family& f, QString* errorMsg) {
    FamilyRepository repo;
    if (!repo.findById(f.id)) {
        if (errorMsg) *errorMsg = "Family not found.";
        return false;
    }
    bool ok = repo.update(f);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "EDIT", "family", f.id,
                  QString("Updated family %1").arg(f.familyNumber), "");
    }
    return ok;
}

bool FamilyService::archiveFamily(qint64 id) {
    FamilyRepository repo;
    bool ok = repo.archive(id);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "ARCHIVE", "family", id, "Archived family", "");
    }
    return ok;
}

bool FamilyService::restoreFamily(qint64 id) {
    FamilyRepository repo;
    bool ok = repo.restore(id);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "RESTORE", "family", id, "Restored family", "");
    }
    return ok;
}

bool FamilyService::deleteFamily(qint64 id, QString* errorMsg) {
    FamilyRepository repo;
    bool ok = repo.hardDelete(id);
    if (!ok) {
        if (errorMsg) *errorMsg = "Cannot delete family: it still has members. "
                                  "Move or delete members first, or use Archive instead.";
        return false;
    }
    AuditLogRepository audit;
    auto u = AuthSession::instance().user();
    audit.log(u.id, u.username, "DELETE", "family", id, "Hard-deleted family", "");
    return true;
}

std::vector<Family> FamilyService::searchFamilies(const QString& term, int page, int pageSize,
                                                  const QString& statusFilter,
                                                  const QString& wardFilter,
                                                  int* totalOut) {
    FamilyRepository repo;
    return repo.list(page, pageSize, term, statusFilter, wardFilter, totalOut);
}

Family FamilyService::getFamily(qint64 id) {
    FamilyRepository repo;
    auto f = repo.findById(id);
    if (!f) throw std::runtime_error("Family not found");
    return *f;
}

int FamilyService::totalFamilies() {
    FamilyRepository repo;
    return repo.count();
}

int FamilyService::activeFamilies() {
    FamilyRepository repo;
    return repo.countByStatus("Active");
}

QStringList FamilyService::wards() {
    FamilyRepository repo;
    return repo.listWards();
}

} // namespace mms
