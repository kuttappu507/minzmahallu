/*
 * MemberRepository.cpp
 */
#include "MemberRepository.h"
#include "../core/Database.h"
#include "../core/Logger.h"

namespace mms {

std::optional<Member> MemberRepository::findById(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM members WHERE id = ?", { id });
    if (q.next()) return Member::fromQuery(q);
    return std::nullopt;
}

std::optional<Member> MemberRepository::findByCode(const QString& code) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM members WHERE member_code = ?", { code });
    if (q.next()) return Member::fromQuery(q);
    return std::nullopt;
}

std::vector<Member> MemberRepository::listByFamily(qint64 familyId) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM members WHERE family_id = ? ORDER BY is_head DESC, date_of_birth", { familyId });
    std::vector<Member> result;
    while (q.next()) result.push_back(Member::fromQuery(q));
    return result;
}

std::vector<Member> MemberRepository::list(int page, int pageSize,
                                           const QString& searchTerm,
                                           const QString& genderFilter,
                                           const QString& statusFilter,
                                           qint64 familyIdFilter,
                                           int* totalOut) {
    QStringList where;
    QVariantList params;

    if (!searchTerm.isEmpty()) {
        where << "(m.name LIKE ? OR m.mobile LIKE ? OR m.member_code LIKE ? OR m.email LIKE ?)";
        QString pat = "%" + searchTerm + "%";
        params << pat << pat << pat << pat;
    }
    if (!genderFilter.isEmpty()) {
        where << "m.gender = ?";
        params << genderFilter;
    }
    if (!statusFilter.isEmpty()) {
        where << "m.status = ?";
        params << statusFilter;
    }
    if (familyIdFilter > 0) {
        where << "m.family_id = ?";
        params << familyIdFilter;
    }

    QString whereSql = where.isEmpty() ? QString() : ("WHERE " + where.join(" AND "));

    if (totalOut) {
        QVariant c = Database::instance().scalar(
            "SELECT COUNT(*) FROM members m " + whereSql, params);
        *totalOut = c.toInt();
    }

    QString sql = QString(
        "SELECT m.*, f.family_number, f.house_name FROM members m "
        "LEFT JOIN families f ON f.id = m.family_id "
        "%1 ORDER BY m.is_head DESC, m.name LIMIT ? OFFSET ?")
        .arg(whereSql);

    int offset = (page - 1) * pageSize;
    params << pageSize << offset;

    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<Member> result;
    while (q.next()) result.push_back(Member::fromQuery(q));
    return result;
}

std::vector<Member> MemberRepository::listAll(const QString& statusFilter) {
    QString sql = "SELECT m.*, f.family_number, f.house_name FROM members m "
                  "LEFT JOIN families f ON f.id = m.family_id";
    QVariantList params;
    if (!statusFilter.isEmpty()) {
        sql += " WHERE m.status = ?";
        params << statusFilter;
    }
    sql += " ORDER BY m.name";
    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<Member> result;
    while (q.next()) result.push_back(Member::fromQuery(q));
    return result;
}

QString MemberRepository::generateNextMemberCode() {
    QVariant last = Database::instance().scalar(
        "SELECT member_code FROM members WHERE member_code IS NOT NULL ORDER BY id DESC LIMIT 1");
    int next = 1;
    if (last.isValid()) {
        QString s = last.toString();
        int dash = s.indexOf('-');
        if (dash >= 0) {
            bool ok = false;
            int n = s.mid(dash + 1).toInt(&ok);
            if (ok) next = n + 1;
        }
    }
    return QString("MEM-%1").arg(next, 4, 10, QChar('0'));
}

qint64 MemberRepository::create(const Member& m) {
    return Database::instance().insert(
        R"(INSERT INTO members
           (family_id, member_code, photo_path, name, arabic_name, gender,
            date_of_birth, age, blood_group, occupation, education, marital_status,
            mobile, email, nationality, address, emergency_contact, relationship,
            is_head, status)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?))",
        { m.familyId, m.memberCode, m.photoPath, m.name, m.arabicName, m.gender,
          m.dateOfBirth, m.age, m.bloodGroup, m.occupation, m.education, m.maritalStatus,
          m.mobile, m.email, m.nationality, m.address, m.emergencyContact, m.relationship,
          m.isHead ? 1 : 0, m.status });
}

bool MemberRepository::update(const Member& m) {
    int n = Database::instance().update(
        R"(UPDATE members SET
           family_id = ?, member_code = ?, photo_path = ?, name = ?, arabic_name = ?,
           gender = ?, date_of_birth = ?, age = ?, blood_group = ?, occupation = ?,
           education = ?, marital_status = ?, mobile = ?, email = ?, nationality = ?,
           address = ?, emergency_contact = ?, relationship = ?, is_head = ?, status = ?
           WHERE id = ?)",
        { m.familyId, m.memberCode, m.photoPath, m.name, m.arabicName, m.gender,
          m.dateOfBirth, m.age, m.bloodGroup, m.occupation, m.education, m.maritalStatus,
          m.mobile, m.email, m.nationality, m.address, m.emergencyContact, m.relationship,
          m.isHead ? 1 : 0, m.status, m.id });
    return n > 0;
}

bool MemberRepository::remove(qint64 id) {
    int n = Database::instance().remove(
        "DELETE FROM members WHERE id = ?", { id });
    return n > 0;
}

bool MemberRepository::setStatus(qint64 id, const QString& status) {
    int n = Database::instance().update(
        "UPDATE members SET status = ? WHERE id = ?", { status, id });
    return n > 0;
}

int MemberRepository::count() {
    QVariant c = Database::instance().scalar("SELECT COUNT(*) FROM members");
    return c.toInt();
}

int MemberRepository::countByStatus(const QString& status) {
    QVariant c = Database::instance().scalar(
        "SELECT COUNT(*) FROM members WHERE status = ?", { status });
    return c.toInt();
}

int MemberRepository::countByGender(const QString& gender) {
    QVariant c = Database::instance().scalar(
        "SELECT COUNT(*) FROM members WHERE gender = ? AND status = 'Active'", { gender });
    return c.toInt();
}

int MemberRepository::countActiveMembers() {
    return countByStatus("Active");
}

std::optional<Member> MemberRepository::findFamilyHead(qint64 familyId) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM members WHERE family_id = ? AND is_head = 1 LIMIT 1", { familyId });
    if (q.next()) return Member::fromQuery(q);
    return std::nullopt;
}

bool MemberRepository::setFamilyHead(qint64 familyId, qint64 memberId) {
    return Database::instance().transaction([&]() {
        Database::instance().update(
            "UPDATE members SET is_head = 0 WHERE family_id = ?", { familyId });
        int n = Database::instance().update(
            "UPDATE members SET is_head = 1, relationship = 'Head' WHERE id = ? AND family_id = ?",
            { memberId, familyId });
        return n > 0;
    });
}

} // namespace mms
