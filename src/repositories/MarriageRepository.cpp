/*
 * MarriageRepository.cpp
 */
#include "MarriageRepository.h"
#include "../core/Database.h"
#include "../core/Security.h"

namespace mms {

std::optional<Marriage> MarriageRepository::findById(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT m.*, u.full_name AS imam_name FROM marriages m "
        "LEFT JOIN users u ON u.id = m.imam_id WHERE m.id = ?", { id });
    if (q.next()) return Marriage::fromQuery(q);
    return std::nullopt;
}

std::optional<Marriage> MarriageRepository::findByNumber(const QString& num) {
    QSqlQuery q = Database::instance().execute(
        "SELECT m.*, u.full_name AS imam_name FROM marriages m "
        "LEFT JOIN users u ON u.id = m.imam_id WHERE m.marriage_number = ?", { num });
    if (q.next()) return Marriage::fromQuery(q);
    return std::nullopt;
}

std::vector<Marriage> MarriageRepository::list(int page, int pageSize,
                                               const QString& searchTerm,
                                               const QString& dateFrom,
                                               const QString& dateTo,
                                               int* totalOut) {
    QStringList where;
    QVariantList params;
    if (!searchTerm.isEmpty()) {
        where << "(m.marriage_number LIKE ? OR m.bride_name LIKE ? OR m.groom_name LIKE ? OR m.bride_father LIKE ? OR m.groom_father LIKE ?)";
        QString pat = "%" + searchTerm + "%";
        params << pat << pat << pat << pat << pat;
    }
    if (!dateFrom.isEmpty()) { where << "m.nikah_date >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { where << "m.nikah_date <= ?"; params << dateTo;   }
    QString whereSql = where.isEmpty() ? QString() : ("WHERE " + where.join(" AND "));

    if (totalOut) {
        QVariant c = Database::instance().scalar(
            "SELECT COUNT(*) FROM marriages m " + whereSql, params);
        *totalOut = c.toInt();
    }

    QString sql = QString(
        "SELECT m.*, u.full_name AS imam_name FROM marriages m "
        "LEFT JOIN users u ON u.id = m.imam_id "
        "%1 ORDER BY m.nikah_date DESC, m.id DESC LIMIT ? OFFSET ?")
        .arg(whereSql);
    int offset = (page - 1) * pageSize;
    params << pageSize << offset;
    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<Marriage> result;
    while (q.next()) result.push_back(Marriage::fromQuery(q));
    return result;
}

QString MarriageRepository::generateNextNumber() {
    int year = QDate::currentDate().year();
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM marriages WHERE strftime('%Y', nikah_date) = ?",
        { QString::number(year) });
    int next = v.toInt() + 1;
    return QString("MRG-%1-%2").arg(year).arg(next, 3, 10, QChar('0'));
}

qint64 MarriageRepository::create(const Marriage& m) {
    return Database::instance().insert(
        R"(INSERT INTO marriages
           (marriage_number, bride_name, bride_father, bride_address,
            groom_name, groom_father, groom_address,
            witness1, witness2, witness3, witness4,
            mahar, nikah_date, registration_date, imam_id, place, remarks)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?))",
        { m.marriageNumber, m.brideName, m.brideFather, m.brideAddress,
          m.groomName, m.groomFather, m.groomAddress,
          m.witness1, m.witness2, m.witness3, m.witness4,
          m.mahar, m.nikahDate, m.registrationDate,
          m.imamId > 0 ? QVariant(m.imamId) : QVariant(),
          m.place, m.remarks });
}

bool MarriageRepository::update(const Marriage& m) {
    int n = Database::instance().update(
        R"(UPDATE marriages SET
           marriage_number = ?, bride_name = ?, bride_father = ?, bride_address = ?,
           groom_name = ?, groom_father = ?, groom_address = ?,
           witness1 = ?, witness2 = ?, witness3 = ?, witness4 = ?,
           mahar = ?, nikah_date = ?, registration_date = ?, imam_id = ?,
           place = ?, remarks = ?
           WHERE id = ?)",
        { m.marriageNumber, m.brideName, m.brideFather, m.brideAddress,
          m.groomName, m.groomFather, m.groomAddress,
          m.witness1, m.witness2, m.witness3, m.witness4,
          m.mahar, m.nikahDate, m.registrationDate,
          m.imamId > 0 ? QVariant(m.imamId) : QVariant(),
          m.place, m.remarks, m.id });
    return n > 0;
}

bool MarriageRepository::remove(qint64 id) {
    int n = Database::instance().remove(
        "DELETE FROM marriages WHERE id = ?", { id });
    return n > 0;
}

int MarriageRepository::countThisYear() {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM marriages WHERE strftime('%Y', nikah_date) = strftime('%Y','now')");
    return v.toInt();
}

int MarriageRepository::countByYear(int year) {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM marriages WHERE strftime('%Y', nikah_date) = ?",
        { QString::number(year) });
    return v.toInt();
}

} // namespace mms
