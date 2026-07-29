/*
 * MemberService.h
 */
#pragma once

#include "../models/Member.h"
#include <vector>
#include <QString>

namespace mms {

class MemberService {
public:
    qint64 createMember(Member& m, QString* errorMsg = nullptr);
    bool updateMember(const Member& m, QString* errorMsg = nullptr);
    bool deleteMember(qint64 id, QString* errorMsg = nullptr);

    std::vector<Member> searchMembers(const QString& term, int page = 1, int pageSize = 50,
                                      const QString& genderFilter = QString(),
                                      const QString& statusFilter = QString(),
                                      qint64 familyIdFilter = 0,
                                      int* totalOut = nullptr);

    std::vector<Member> familyMembers(qint64 familyId);
    Member getMember(qint64 id);
    bool setFamilyHead(qint64 familyId, qint64 memberId);

    int totalMembers();
    int activeMembers();
    int maleMembers();
    int femaleMembers();

    // Photo handling: copies a file into the attachments dir and returns the new path
    QString savePhoto(const QString& sourcePath, qint64 memberId);
};

} // namespace mms
