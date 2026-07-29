/*
 * DeathRepository.cpp
 */
#include "DeathRepository.h"
#include "../core/Database.h"

namespace mms {

std::optional<Death> DeathRepository::findById(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT d.*, f.family_number, f.house_name FROM deaths d "
        "LEFT JOIN families f ON f.id = d.family_id WHERE d.id = ?", { id });
    if (q.next()) return Death::fromQuery(q);
    return std::nullopt;
}

std::optional<Death> DeathRepository::findByNumber(const QString& num) {
    QSqlQuery q = Database::instance().execute(
        "SELECT d.*, f.family_number, f.house_name FROM deaths d "
        "LEFT JOIN families f ON f.id = d.family_id WHERE d.death_number = ?", { num });
    if (q.next()) return Death::fromQuery(q);
    return std::nullopt;
}

std::vector<Death> DeathRepository::list(int page, int pageSize,
                                         const QString& searchTerm,
                                         const QString& dateFrom,
                                         const QString& dateTo,
                                         int* totalOut) {
    QStringList where;
    QVariantList params;
    if (!searchTerm.isEmpty()) {
        where << "(d.death_number LIKE ? OR d.deceased_name LIKE ? OR d.father_name LIKE ?)";
        QString pat = "%" + searchTerm + "%";
        params << pat << pat << pat;
    }
    if (!dateFrom.isEmpty()) { where << "d.date_of_death >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { where << "d.date_of_death <= ?"; params << dateTo;   }
    QString whereSql = where.isEmpty() ? QString() : ("WHERE " + where.join(" AND "));

    if (totalOut) {
        QVariant c = Database::instance().scalar(
            "SELECT COUNT(*) FROM deaths d " + whereSql, params);
        *totalOut = c.toInt();
    }
    QString sql = QString(
        "SELECT d.*, f.family_number, f.house_name FROM deaths d "
        "LEFT JOIN families f ON f.id = d.family_id "
        "%1 ORDER BY d.date_of_death DESC, d.id DESC LIMIT ? OFFSET ?")
        .arg(whereSql);
    int offset = (page - 1) * pageSize;
    params << pageSize << offset;
    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<Death> result;
    while (q.next()) result.push_back(Death::fromQuery(q));
    return result;
}

QString DeathRepository::generateNextNumber() {
    int year = QDate::currentDate().year();
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM deaths WHERE strftime('%Y', date_of_death) = ?",
        { QString::number(year) });
    int next = v.toInt() + 1;
    return QString("DTH-%1-%2").arg(year).arg(next, 3, 10, QChar('0'));
}

qint64 DeathRepository::create(const Death& d) {
    qint64 id = Database::instance().insert(
        R"(INSERT INTO deaths
           (death_number, deceased_name, father_name, family_id, gender,
            date_of_death, burial_date, cause_of_death, burial_place, age, remarks)
           VALUES (?,?,?,?,?,?,?,?,?,?,?))",
        { d.deathNumber, d.deceasedName, d.fatherName,
          d.familyId > 0 ? QVariant(d.familyId) : QVariant(),
          d.gender, d.dateOfDeath, d.burialDate, d.causeOfDeath, d.burialPlace,
          d.age, d.remarks });

    // If family link exists, mark member as deceased if matched by name
    if (id > 0 && d.familyId > 0) {
        Database::instance().update(
            "UPDATE members SET status = 'Deceased' "
            "WHERE family_id = ? AND name = ?",
            { d.familyId, d.deceasedName });
    }
    return id;
}

bool DeathRepository::update(const Death& d) {
    int n = Database::instance().update(
        R"(UPDATE deaths SET
           death_number = ?, deceased_name = ?, father_name = ?, family_id = ?, gender = ?,
           date_of_death = ?, burial_date = ?, cause_of_death = ?, burial_place = ?,
           age = ?, remarks = ?
           WHERE id = ?)",
        { d.deathNumber, d.deceasedName, d.fatherName,
          d.familyId > 0 ? QVariant(d.familyId) : QVariant(),
          d.gender, d.dateOfDeath, d.burialDate, d.causeOfDeath, d.burialPlace,
          d.age, d.remarks, d.id });
    return n > 0;
}

bool DeathRepository::remove(qint64 id) {
    int n = Database::instance().remove(
        "DELETE FROM deaths WHERE id = ?", { id });
    return n > 0;
}

int DeathRepository::countThisYear() {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM deaths WHERE strftime('%Y', date_of_death) = strftime('%Y','now')");
    return v.toInt();
}

int DeathRepository::countByYear(int year) {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM deaths WHERE strftime('%Y', date_of_death) = ?",
        { QString::number(year) });
    return v.toInt();
}

} // namespace mms
