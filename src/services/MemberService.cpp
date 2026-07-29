/*
 * MemberService.cpp
 */
#include "MemberService.h"
#include "../repositories/MemberRepository.h"
#include "../repositories/AuditLogRepository.h"
#include "../core/Logger.h"
#include "../core/Security.h"
#include "../core/Config.h"
#include "AuthSession.h"
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QDate>
#include <stdexcept>

namespace mms {

qint64 MemberService::createMember(Member& m, QString* errorMsg) {
    if (m.name.trimmed().isEmpty()) {
        if (errorMsg) *errorMsg = "Member name is required.";
        return -1;
    }
    if (m.familyId <= 0) {
        if (errorMsg) *errorMsg = "Family must be selected.";
        return -1;
    }
    if (m.gender.isEmpty() || !QStringList{"Male","Female","Other"}.contains(m.gender)) {
        if (errorMsg) *errorMsg = "Gender must be Male, Female, or Other.";
        return -1;
    }
    if (!m.mobile.isEmpty() && !Security::isValidPhone(m.mobile)) {
        if (errorMsg) *errorMsg = "Mobile number format is invalid.";
        return -1;
    }
    if (!m.email.isEmpty() && !Security::isValidEmail(m.email)) {
        if (errorMsg) *errorMsg = "Email format is invalid.";
        return -1;
    }
    // Compute age from DOB
    if (!m.dateOfBirth.isEmpty() && m.age <= 0) {
        QDate dob = QDate::fromString(m.dateOfBirth, Qt::ISODate);
        if (dob.isValid()) {
            m.age = dob.daysTo(QDate::currentDate()) / 365;
        }
    }

    MemberRepository repo;
    if (m.memberCode.isEmpty()) {
        m.memberCode = repo.generateNextMemberCode();
    }

    qint64 id = repo.create(m);
    if (id > 0) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "ADD", "member", id,
                  QString("Created member %1 (%2)").arg(m.memberCode).arg(m.name), "");
    }
    return id;
}

bool MemberService::updateMember(const Member& m, QString* errorMsg) {
    MemberRepository repo;
    if (!repo.findById(m.id)) {
        if (errorMsg) *errorMsg = "Member not found.";
        return false;
    }
    bool ok = repo.update(m);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "EDIT", "member", m.id,
                  QString("Updated member %1").arg(m.name), "");
    }
    return ok;
}

bool MemberService::deleteMember(qint64 id, QString* errorMsg) {
    MemberRepository repo;
    auto m = repo.findById(id);
    if (!m) {
        if (errorMsg) *errorMsg = "Member not found.";
        return false;
    }
    if (m->isHead) {
        if (errorMsg) *errorMsg = "Cannot delete the family head. Assign a new head first.";
        return false;
    }
    bool ok = repo.remove(id);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "DELETE", "member", id,
                  QString("Deleted member %1").arg(m->name), "");
    }
    return ok;
}

std::vector<Member> MemberService::searchMembers(const QString& term, int page, int pageSize,
                                                 const QString& genderFilter,
                                                 const QString& statusFilter,
                                                 qint64 familyIdFilter,
                                                 int* totalOut) {
    MemberRepository repo;
    return repo.list(page, pageSize, term, genderFilter, statusFilter, familyIdFilter, totalOut);
}

std::vector<Member> MemberService::familyMembers(qint64 familyId) {
    MemberRepository repo;
    return repo.listByFamily(familyId);
}

Member MemberService::getMember(qint64 id) {
    MemberRepository repo;
    auto m = repo.findById(id);
    if (!m) throw std::runtime_error("Member not found");
    return *m;
}

bool MemberService::setFamilyHead(qint64 familyId, qint64 memberId) {
    MemberRepository repo;
    bool ok = repo.setFamilyHead(familyId, memberId);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "EDIT", "member", memberId,
                  QString("Set family head for family %1").arg(familyId), "");
    }
    return ok;
}

int MemberService::totalMembers() {
    MemberRepository repo;
    return repo.count();
}

int MemberService::activeMembers() {
    MemberRepository repo;
    return repo.countActiveMembers();
}

int MemberService::maleMembers() {
    MemberRepository repo;
    return repo.countByGender("Male");
}

int MemberService::femaleMembers() {
    MemberRepository repo;
    return repo.countByGender("Female");
}

QString MemberService::savePhoto(const QString& sourcePath, qint64 memberId) {
    if (sourcePath.isEmpty()) return {};
    QFile src(sourcePath);
    if (!src.open(QIODevice::ReadOnly)) return {};

    QString photoDir = Config::instance().attachmentDir() + "/photos";
    QDir().mkpath(photoDir);

    QString ext = QFileInfo(sourcePath).suffix().toLower();
    if (ext.isEmpty()) ext = "jpg";
    QString dest = QString("%1/member_%2.%3").arg(photoDir).arg(memberId).arg(ext);

    if (QFile::exists(dest)) QFile::remove(dest);
    if (!src.copy(dest)) return {};
    return dest;
}

} // namespace mms
