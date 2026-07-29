/*
 * FamilyRepository.cpp
 */
#include "FamilyRepository.h"
#include "../core/Database.h"
#include "../core/Logger.h"
#include <QSqlQuery>
#include <QSqlRecord>

namespace mms {

std::optional<Family> FamilyRepository::findById(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM families WHERE id = ?", { id });
    if (q.next()) return Family::fromQuery(q);
    return std::nullopt;
}

std::optional<Family> FamilyRepository::findByNumber(const QString& familyNumber) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM families WHERE family_number = ?", { familyNumber });
    if (q.next()) return Family::fromQuery(q);
    return std::nullopt;
}

std::vector<Family> FamilyRepository::list(int page, int pageSize,
                                           const QString& searchTerm,
                                           const QString& statusFilter,
                                           const QString& wardFilter,
                                           int* totalOut) {
    QStringList where;
    QVariantList params;

    if (!searchTerm.isEmpty()) {
        where << "(family_number LIKE ? OR house_name LIKE ? OR phone LIKE ? OR area LIKE ?)";
        QString pat = "%" + searchTerm + "%";
        params << pat << pat << pat << pat;
    }
    if (!statusFilter.isEmpty()) {
        where << "status = ?";
        params << statusFilter;
    }
    if (!wardFilter.isEmpty()) {
        where << "ward = ?";
        params << wardFilter;
    }

    QString whereSql = where.isEmpty() ? QString() : ("WHERE " + where.join(" AND "));

    if (totalOut) {
        QVariant c = Database::instance().scalar(
            "SELECT COUNT(*) FROM families " + whereSql, params);
        *totalOut = c.toInt();
    }

    QString sql = QString(
        "SELECT f.*, "
        "  (SELECT COUNT(*) FROM members m WHERE m.family_id = f.id) AS member_count, "
        "  (SELECT name FROM members m WHERE m.family_id = f.id AND m.is_head = 1 LIMIT 1) AS head_name "
        "FROM families f %1 ORDER BY family_number LIMIT ? OFFSET ?")
        .arg(whereSql);

    int offset = (page - 1) * pageSize;
    params << pageSize << offset;

    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<Family> result;
    while (q.next()) {
        result.push_back(Family::fromQuery(q));
    }
    return result;
}

std::vector<Family> FamilyRepository::listAll(const QString& statusFilter) {
    QString sql = "SELECT * FROM families";
    QVariantList params;
    if (!statusFilter.isEmpty()) {
        sql += " WHERE status = ?";
        params << statusFilter;
    }
    sql += " ORDER BY family_number";
    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<Family> result;
    while (q.next()) {
        result.push_back(Family::fromQuery(q));
    }
    return result;
}

int FamilyRepository::count() {
    QVariant c = Database::instance().scalar("SELECT COUNT(*) FROM families");
    return c.toInt();
}

QString FamilyRepository::generateNextFamilyNumber() {
    QVariant last = Database::instance().scalar(
        "SELECT family_number FROM families ORDER BY id DESC LIMIT 1");
    int next = 1;
    if (last.isValid()) {
        QString s = last.toString();
        // Extract numeric part after dash
        int dash = s.indexOf('-');
        if (dash >= 0) {
            bool ok = false;
            int n = s.mid(dash + 1).toInt(&ok);
            if (ok) next = n + 1;
        }
    }
    return QString("FAM-%1").arg(next, 4, 10, QChar('0'));
}

qint64 FamilyRepository::create(const Family& f) {
    return Database::instance().insert(
        R"(INSERT INTO families
           (family_number, house_name, house_number, ward, area, address,
            pincode, phone, alternative_phone, status, notes)
           VALUES (?,?,?,?,?,?,?,?,?,?,?))",
        { f.familyNumber, f.houseName, f.houseNumber, f.ward, f.area, f.address,
          f.pincode, f.phone, f.alternativePhone, f.status, f.notes });
}

bool FamilyRepository::update(const Family& f) {
    int n = Database::instance().update(
        R"(UPDATE families SET
           family_number = ?, house_name = ?, house_number = ?, ward = ?, area = ?,
           address = ?, pincode = ?, phone = ?, alternative_phone = ?,
           status = ?, notes = ?
           WHERE id = ?)",
        { f.familyNumber, f.houseName, f.houseNumber, f.ward, f.area, f.address,
          f.pincode, f.phone, f.alternativePhone, f.status, f.notes, f.id });
    return n > 0;
}

bool FamilyRepository::remove(qint64 id) {
    return archive(id);
}

bool FamilyRepository::hardDelete(qint64 id) {
    // Block if there are linked members
    QVariant mc = Database::instance().scalar(
        "SELECT COUNT(*) FROM members WHERE family_id = ?", { id });
    if (mc.toInt() > 0) {
        Logger::warn(QString("Cannot hard delete family %1: still has %2 members")
                     .arg(id).arg(mc.toInt()));
        return false;
    }
    int n = Database::instance().remove(
        "DELETE FROM families WHERE id = ?", { id });
    return n > 0;
}

bool FamilyRepository::archive(qint64 id) {
    int n = Database::instance().update(
        "UPDATE families SET status = 'Archived' WHERE id = ?", { id });
    return n > 0;
}

bool FamilyRepository::restore(qint64 id) {
    int n = Database::instance().update(
        "UPDATE families SET status = 'Active' WHERE id = ?", { id });
    return n > 0;
}

int FamilyRepository::countByStatus(const QString& status) {
    QVariant c = Database::instance().scalar(
        "SELECT COUNT(*) FROM families WHERE status = ?", { status });
    return c.toInt();
}

int FamilyRepository::countByWard(const QString& ward) {
    QVariant c = Database::instance().scalar(
        "SELECT COUNT(*) FROM families WHERE ward = ? AND status = 'Active'", { ward });
    return c.toInt();
}

QStringList FamilyRepository::listWards() {
    QSqlQuery q = Database::instance().execute(
        "SELECT DISTINCT ward FROM families WHERE ward != '' ORDER BY ward");
    QStringList result;
    while (q.next()) {
        result << q.value(0).toString();
    }
    return result;
}

} // namespace mms
