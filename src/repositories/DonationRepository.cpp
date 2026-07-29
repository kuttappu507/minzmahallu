/*
 * DonationRepository.cpp
 */
#include "DonationRepository.h"
#include "../core/Database.h"
#include "../core/Security.h"

namespace mms {

std::optional<Donation> DonationRepository::findById(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT d.*, c.name AS category_name, f.family_number FROM donations d "
        "LEFT JOIN donation_categories c ON c.id = d.category_id "
        "LEFT JOIN families f ON f.id = d.family_id WHERE d.id = ?", { id });
    if (q.next()) return Donation::fromQuery(q);
    return std::nullopt;
}

std::optional<Donation> DonationRepository::findByReceipt(const QString& receipt) {
    QSqlQuery q = Database::instance().execute(
        "SELECT d.*, c.name AS category_name, f.family_number FROM donations d "
        "LEFT JOIN donation_categories c ON c.id = d.category_id "
        "LEFT JOIN families f ON f.id = d.family_id WHERE d.receipt_number = ?", { receipt });
    if (q.next()) return Donation::fromQuery(q);
    return std::nullopt;
}

std::vector<DonationCategory> DonationRepository::listCategories() {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM donation_categories WHERE is_active = 1 ORDER BY name");
    std::vector<DonationCategory> result;
    while (q.next()) {
        DonationCategory c;
        c.id = q.value("id").toLongLong();
        c.name = q.value("name").toString();
        c.description = q.value("description").toString();
        c.isActive = q.value("is_active").toInt() == 1;
        result.push_back(c);
    }
    return result;
}

std::optional<DonationCategory> DonationRepository::findCategory(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM donation_categories WHERE id = ?", { id });
    if (!q.next()) return std::nullopt;
    DonationCategory c;
    c.id = q.value("id").toLongLong();
    c.name = q.value("name").toString();
    c.description = q.value("description").toString();
    c.isActive = q.value("is_active").toInt() == 1;
    return c;
}

std::vector<Donation> DonationRepository::list(int page, int pageSize,
                                               const QString& dateFrom,
                                               const QString& dateTo,
                                               qint64 categoryId,
                                               const QString& searchTerm,
                                               int* totalOut) {
    QStringList where;
    QVariantList params;
    if (!dateFrom.isEmpty()) { where << "d.donation_date >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { where << "d.donation_date <= ?"; params << dateTo;   }
    if (categoryId > 0)      { where << "d.category_id = ?";    params << categoryId; }
    if (!searchTerm.isEmpty()) {
        where << "(d.donor_name LIKE ? OR d.receipt_number LIKE ?)";
        QString pat = "%" + searchTerm + "%";
        params << pat << pat;
    }
    QString whereSql = where.isEmpty() ? QString() : ("WHERE " + where.join(" AND "));

    if (totalOut) {
        QVariant c = Database::instance().scalar(
            "SELECT COUNT(*) FROM donations d " + whereSql, params);
        *totalOut = c.toInt();
    }

    QString sql = QString(
        "SELECT d.*, c.name AS category_name, f.family_number FROM donations d "
        "LEFT JOIN donation_categories c ON c.id = d.category_id "
        "LEFT JOIN families f ON f.id = d.family_id "
        "%1 ORDER BY d.donation_date DESC, d.id DESC LIMIT ? OFFSET ?")
        .arg(whereSql);

    int offset = (page - 1) * pageSize;
    params << pageSize << offset;
    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<Donation> result;
    while (q.next()) result.push_back(Donation::fromQuery(q));
    return result;
}

QString DonationRepository::generateReceiptNumber() {
    return Security::generateReference("DON", 6);
}

qint64 DonationRepository::create(const Donation& d) {
    qint64 id = Database::instance().insert(
        R"(INSERT INTO donations
           (donor_name, donor_phone, donor_address, family_id, member_id, category_id,
            amount, donation_date, receipt_number, purpose, remarks, payment_method, received_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?))",
        { d.donorName, d.donorPhone, d.donorAddress,
          d.familyId > 0 ? QVariant(d.familyId) : QVariant(),
          d.memberId > 0 ? QVariant(d.memberId) : QVariant(),
          d.categoryId, d.amount, d.donationDate, d.receiptNumber, d.purpose, d.remarks,
          d.paymentMethod, d.receivedBy > 0 ? QVariant(d.receivedBy) : QVariant() });

    if (id > 0) {
        // Auto-create accounting transaction
        Database::instance().insert(
            R"(INSERT INTO transactions
               (txn_date, account_id, type, amount, payment_method, description,
                linked_module, linked_id, receipt_number, created_by)
               VALUES (?, (SELECT id FROM ledger_accounts WHERE code='INC-DON'),
                       'Income', ?, ?, ?, 'donation', ?, ?, ?))",
            { d.donationDate, d.amount, d.paymentMethod,
              QString("Donation - %1 (%2)").arg(d.donorName).arg(d.receiptNumber),
              id, d.receiptNumber,
              d.receivedBy > 0 ? QVariant(d.receivedBy) : QVariant() });
    }
    return id;
}

bool DonationRepository::update(const Donation& d) {
    int n = Database::instance().update(
        R"(UPDATE donations SET
           donor_name = ?, donor_phone = ?, donor_address = ?, family_id = ?, member_id = ?,
           category_id = ?, amount = ?, donation_date = ?, receipt_number = ?,
           purpose = ?, remarks = ?, payment_method = ?, received_by = ?
           WHERE id = ?)",
        { d.donorName, d.donorPhone, d.donorAddress,
          d.familyId > 0 ? QVariant(d.familyId) : QVariant(),
          d.memberId > 0 ? QVariant(d.memberId) : QVariant(),
          d.categoryId, d.amount, d.donationDate, d.receiptNumber, d.purpose, d.remarks,
          d.paymentMethod, d.receivedBy > 0 ? QVariant(d.receivedBy) : QVariant(), d.id });
    return n > 0;
}

bool DonationRepository::remove(qint64 id) {
    // Also remove linked transactions
    Database::instance().remove(
        "DELETE FROM transactions WHERE linked_module = 'donation' AND linked_id = ?", { id });
    int n = Database::instance().remove(
        "DELETE FROM donations WHERE id = ?", { id });
    return n > 0;
}

double DonationRepository::totalDonations(const QString& dateFrom, const QString& dateTo) {
    QVariant v = Database::instance().scalar(
        "SELECT COALESCE(SUM(amount),0) FROM donations "
        "WHERE donation_date >= ? AND donation_date <= ?", { dateFrom, dateTo });
    return v.toDouble();
}

double DonationRepository::totalByCategory(qint64 categoryId, const QString& dateFrom, const QString& dateTo) {
    QVariant v = Database::instance().scalar(
        "SELECT COALESCE(SUM(amount),0) FROM donations "
        "WHERE category_id = ? AND donation_date >= ? AND donation_date <= ?",
        { categoryId, dateFrom, dateTo });
    return v.toDouble();
}

std::vector<Donation> DonationRepository::donorHistory(const QString& donorName) {
    QSqlQuery q = Database::instance().execute(
        "SELECT d.*, c.name AS category_name, f.family_number FROM donations d "
        "LEFT JOIN donation_categories c ON c.id = d.category_id "
        "LEFT JOIN families f ON f.id = d.family_id "
        "WHERE d.donor_name = ? ORDER BY d.donation_date DESC", { donorName });
    std::vector<Donation> result;
    while (q.next()) result.push_back(Donation::fromQuery(q));
    return result;
}

} // namespace mms
