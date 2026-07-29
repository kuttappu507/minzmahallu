/*
 * MemberRepository.h
 */
#pragma once

#include "../models/Member.h"
#include <vector>
#include <optional>
#include <QString>

namespace mms {

class MemberRepository {
public:
    std::optional<Member> findById(qint64 id);
    std::optional<Member> findByCode(const QString& code);

    std::vector<Member> listByFamily(qint64 familyId);
    std::vector<Member> list(int page = 1, int pageSize = 50,
                             const QString& searchTerm = QString(),
                             const QString& genderFilter = QString(),
                             const QString& statusFilter = QString(),
                             qint64 familyIdFilter = 0,
                             int* totalOut = nullptr);
    std::vector<Member> listAll(const QString& statusFilter = QString());

    QString generateNextMemberCode();

    qint64 create(const Member& m);
    bool update(const Member& m);
    bool remove(qint64 id);
    bool setStatus(qint64 id, const QString& status);

    int count();
    int countByStatus(const QString& status);
    int countByGender(const QString& gender);
    int countActiveMembers();

    // Family head
    std::optional<Member> findFamilyHead(qint64 familyId);
    bool setFamilyHead(qint64 familyId, qint64 memberId);
};

} // namespace mms
