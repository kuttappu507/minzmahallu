/*
 * CertificateRepository.cpp
 */
#include "CertificateRepository.h"
#include "../core/Database.h"
#include "../core/Security.h"
#include <QFile>

namespace mms {

std::optional<Certificate> CertificateRepository::findById(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT c.*, u.full_name AS issued_by_name FROM certificates c "
        "LEFT JOIN users u ON u.id = c.issued_by WHERE c.id = ?", { id });
    if (q.next()) return Certificate::fromQuery(q);
    return std::nullopt;
}

std::optional<Certificate> CertificateRepository::findByNumber(const QString& num) {
    QSqlQuery q = Database::instance().execute(
        "SELECT c.*, u.full_name AS issued_by_name FROM certificates c "
        "LEFT JOIN users u ON u.id = c.issued_by WHERE c.certificate_number = ?", { num });
    if (q.next()) return Certificate::fromQuery(q);
    return std::nullopt;
}

std::vector<Certificate> CertificateRepository::list(int page, int pageSize,
                                                     const QString& typeFilter,
                                                     const QString& dateFrom,
                                                     const QString& dateTo,
                                                     int* totalOut) {
    QStringList where;
    QVariantList params;
    if (!typeFilter.isEmpty()) { where << "c.type = ?"; params << typeFilter; }
    if (!dateFrom.isEmpty())   { where << "c.issued_date >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())     { where << "c.issued_date <= ?"; params << dateTo; }
    QString whereSql = where.isEmpty() ? QString() : ("WHERE " + where.join(" AND "));

    if (totalOut) {
        QVariant c = Database::instance().scalar(
            "SELECT COUNT(*) FROM certificates c " + whereSql, params);
        *totalOut = c.toInt();
    }

    QString sql = QString(
        "SELECT c.*, u.full_name AS issued_by_name FROM certificates c "
        "LEFT JOIN users u ON u.id = c.issued_by "
        "%1 ORDER BY c.issued_date DESC, c.id DESC LIMIT ? OFFSET ?")
        .arg(whereSql);
    int offset = (page - 1) * pageSize;
    params << pageSize << offset;
    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<Certificate> result;
    while (q.next()) result.push_back(Certificate::fromQuery(q));
    return result;
}

QString CertificateRepository::generateNumber(const QString& type) {
    int year = QDate::currentDate().year();
    QString prefix;
    if (type == "Membership")    prefix = "MEM-CRT";
    else if (type == "Residence") prefix = "RES-CRT";
    else if (type == "Marriage")  prefix = "MARR-CRT";
    else if (type == "Death")     prefix = "DTH-CRT";
    else if (type == "Character") prefix = "CHR-CRT";
    else if (type == "Income")    prefix = "INC-CRT";
    else                          prefix = "CRT";

    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM certificates WHERE type = ? AND strftime('%Y', issued_date) = ?",
        { type, QString::number(year) });
    int next = v.toInt() + 1;
    return QString("%1-%2-%3").arg(prefix).arg(year).arg(next, 4, 10, QChar('0'));
}

qint64 CertificateRepository::create(Certificate& c) {
    if (c.certificateNumber.isEmpty()) {
        c.certificateNumber = generateNumber(c.type);
    }
    if (c.qrPayload.isEmpty()) {
        c.qrPayload = Security::generateQrPayload(c.type, 0, c.certificateNumber);
    }
    qint64 id = Database::instance().insert(
        R"(INSERT INTO certificates
           (certificate_number, type, member_id, family_id, marriage_id, death_id,
            issued_to, issued_date, issued_by, qr_payload, notes)
           VALUES (?,?,?,?,?,?,?,?,?,?,?))",
        { c.certificateNumber, c.type,
          c.memberId > 0 ? QVariant(c.memberId) : QVariant(),
          c.familyId > 0 ? QVariant(c.familyId) : QVariant(),
          c.marriageId > 0 ? QVariant(c.marriageId) : QVariant(),
          c.deathId > 0 ? QVariant(c.deathId) : QVariant(),
          c.issuedTo, c.issuedDate,
          c.issuedBy > 0 ? QVariant(c.issuedBy) : QVariant(),
          c.qrPayload, c.notes });

    if (id > 0 && c.qrPayload.contains('|')) {
        // Update QR payload with real cert id
        auto parts = c.qrPayload.split('|');
        if (parts.size() >= 3) {
            parts[2] = QString::number(id);
            QString updated = parts.join('|');
            Database::instance().update(
                "UPDATE certificates SET qr_payload = ? WHERE id = ?",
                { updated, id });
            c.qrPayload = updated;
        }
    }
    return id;
}

bool CertificateRepository::remove(qint64 id) {
    int n = Database::instance().remove(
        "DELETE FROM certificates WHERE id = ?", { id });
    return n > 0;
}

int CertificateRepository::countByType(const QString& type) {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM certificates WHERE type = ?", { type });
    return v.toInt();
}

int CertificateRepository::countThisYear() {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM certificates WHERE strftime('%Y', issued_date) = strftime('%Y','now')");
    return v.toInt();
}

// ---- DocumentRepository ----

std::vector<Document> DocumentRepository::listFor(const QString& module, qint64 linkedId) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM documents WHERE linked_module = ? AND linked_id = ? ORDER BY uploaded_at DESC",
        { module, linkedId });
    std::vector<Document> result;
    while (q.next()) result.push_back(Document::fromQuery(q));
    return result;
}

std::optional<Document> DocumentRepository::findById(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM documents WHERE id = ?", { id });
    if (q.next()) return Document::fromQuery(q);
    return std::nullopt;
}

qint64 DocumentRepository::create(Document& d) {
    return Database::instance().insert(
        "INSERT INTO documents (linked_module, linked_id, file_name, file_path, file_type, file_size, uploaded_by) "
        "VALUES (?,?,?,?,?,?,?)",
        { d.linkedModule, d.linkedId, d.fileName, d.filePath, d.fileType, d.fileSize,
          d.uploadedBy > 0 ? QVariant(d.uploadedBy) : QVariant() });
}

bool DocumentRepository::remove(qint64 id) {
    auto doc = findById(id);
    if (!doc) return false;
    QFile::remove(doc->filePath);
    int n = Database::instance().remove(
        "DELETE FROM documents WHERE id = ?", { id });
    return n > 0;
}

bool DocumentRepository::removeForLink(const QString& module, qint64 linkedId) {
    auto docs = listFor(module, linkedId);
    for (auto& d : docs) QFile::remove(d.filePath);
    int n = Database::instance().remove(
        "DELETE FROM documents WHERE linked_module = ? AND linked_id = ?",
        { module, linkedId });
    return n > 0;
}

int DocumentRepository::countForLink(const QString& module, qint64 linkedId) {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM documents WHERE linked_module = ? AND linked_id = ?",
        { module, linkedId });
    return v.toInt();
}

} // namespace mms
