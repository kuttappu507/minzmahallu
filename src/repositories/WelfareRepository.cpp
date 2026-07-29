/*
 * WelfareRepository.cpp
 */
#include "WelfareRepository.h"
#include "../core/Database.h"

namespace mms {

std::optional<WelfareRequest> WelfareRepository::findById(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT w.*, f.family_number, u.full_name AS approved_by_name FROM welfare_requests w "
        "LEFT JOIN families f ON f.id = w.family_id "
        "LEFT JOIN users u ON u.id = w.approved_by WHERE w.id = ?", { id });
    if (q.next()) return WelfareRequest::fromQuery(q);
    return std::nullopt;
}

std::optional<WelfareRequest> WelfareRepository::findByNumber(const QString& num) {
    QSqlQuery q = Database::instance().execute(
        "SELECT w.*, f.family_number, u.full_name AS approved_by_name FROM welfare_requests w "
        "LEFT JOIN families f ON f.id = w.family_id "
        "LEFT JOIN users u ON u.id = w.approved_by WHERE w.request_number = ?", { num });
    if (q.next()) return WelfareRequest::fromQuery(q);
    return std::nullopt;
}

std::vector<WelfareRequest> WelfareRepository::list(int page, int pageSize,
                                                    const QString& statusFilter,
                                                    const QString& categoryFilter,
                                                    const QString& searchTerm,
                                                    int* totalOut) {
    QStringList where;
    QVariantList params;
    if (!statusFilter.isEmpty())   { where << "w.status = ?";   params << statusFilter; }
    if (!categoryFilter.isEmpty()) { where << "w.category = ?"; params << categoryFilter; }
    if (!searchTerm.isEmpty()) {
        where << "(w.request_number LIKE ? OR w.applicant_name LIKE ?)";
        QString pat = "%" + searchTerm + "%";
        params << pat << pat;
    }
    QString whereSql = where.isEmpty() ? QString() : ("WHERE " + where.join(" AND "));

    if (totalOut) {
        QVariant c = Database::instance().scalar(
            "SELECT COUNT(*) FROM welfare_requests w " + whereSql, params);
        *totalOut = c.toInt();
    }

    QString sql = QString(
        "SELECT w.*, f.family_number, u.full_name AS approved_by_name FROM welfare_requests w "
        "LEFT JOIN families f ON f.id = w.family_id "
        "LEFT JOIN users u ON u.id = w.approved_by "
        "%1 ORDER BY w.created_at DESC LIMIT ? OFFSET ?")
        .arg(whereSql);
    int offset = (page - 1) * pageSize;
    params << pageSize << offset;
    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<WelfareRequest> result;
    while (q.next()) result.push_back(WelfareRequest::fromQuery(q));
    return result;
}

QString WelfareRepository::generateNextNumber() {
    int year = QDate::currentDate().year();
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM welfare_requests WHERE strftime('%Y', created_at) = ?",
        { QString::number(year) });
    int next = v.toInt() + 1;
    return QString("WEL-%1-%2").arg(year).arg(next, 3, 10, QChar('0'));
}

qint64 WelfareRepository::create(const WelfareRequest& w) {
    return Database::instance().insert(
        R"(INSERT INTO welfare_requests
           (request_number, applicant_name, family_id, category,
            amount_requested, amount_approved, reason, status, remarks)
           VALUES (?,?,?,?,?,?,?,?,'Pending',?))",
        { w.requestNumber, w.applicantName,
          w.familyId > 0 ? QVariant(w.familyId) : QVariant(),
          w.category, w.amountRequested, w.amountApproved, w.reason, w.remarks });
}

bool WelfareRepository::update(const WelfareRequest& w) {
    int n = Database::instance().update(
        R"(UPDATE welfare_requests SET
           applicant_name = ?, family_id = ?, category = ?,
           amount_requested = ?, reason = ?, status = ?, remarks = ?
           WHERE id = ?)",
        { w.applicantName, w.familyId > 0 ? QVariant(w.familyId) : QVariant(),
          w.category, w.amountRequested, w.reason, w.status, w.remarks, w.id });
    return n > 0;
}

bool WelfareRepository::remove(qint64 id) {
    int n = Database::instance().remove(
        "DELETE FROM welfare_requests WHERE id = ?", { id });
    return n > 0;
}

bool WelfareRepository::approve(qint64 id, qint64 approverId, double approvedAmount, const QString& remarks) {
    int n = Database::instance().update(
        "UPDATE welfare_requests SET status = 'Approved', approved_by = ?, "
        "amount_approved = ?, remarks = ? WHERE id = ?",
        { approverId, approvedAmount, remarks, id });
    return n > 0;
}

bool WelfareRepository::reject(qint64 id, qint64 approverId, const QString& remarks) {
    int n = Database::instance().update(
        "UPDATE welfare_requests SET status = 'Rejected', approved_by = ?, remarks = ? WHERE id = ?",
        { approverId, remarks, id });
    return n > 0;
}

bool WelfareRepository::disburse(qint64 id, const QString& disbursementDate) {
    bool ok = Database::instance().transaction([&]() {
        int n = Database::instance().update(
            "UPDATE welfare_requests SET status = 'Disbursed', disbursed_date = ? WHERE id = ?",
            { disbursementDate, id });
        if (n <= 0) return false;

        // Create welfare expense transaction
        auto w = findById(id);
        if (!w) return false;
        Database::instance().insert(
            R"(INSERT INTO transactions
               (txn_date, account_id, type, amount, payment_method, description,
                linked_module, linked_id, created_by)
               VALUES (?, (SELECT id FROM ledger_accounts WHERE code='EXP-WEL'),
                       'Expense', ?, 'Bank Transfer', ?, 'welfare', ?, ?))",
            { disbursementDate, w->amountApproved,
              QString("Welfare disbursement - %1 (%2)").arg(w->applicantName).arg(w->requestNumber),
              id, w->approvedBy });
        return true;
    });
    return ok;
}

int WelfareRepository::countByStatus(const QString& status) {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM welfare_requests WHERE status = ?", { status });
    return v.toInt();
}

double WelfareRepository::totalDisbursedThisYear() {
    QVariant v = Database::instance().scalar(
        "SELECT COALESCE(SUM(amount_approved),0) FROM welfare_requests "
        "WHERE status = 'Disbursed' AND strftime('%Y', disbursed_date) = strftime('%Y','now')");
    return v.toDouble();
}

std::vector<WelfareRequest> WelfareRepository::listByFamily(qint64 familyId) {
    QSqlQuery q = Database::instance().execute(
        "SELECT w.*, f.family_number, u.full_name AS approved_by_name FROM welfare_requests w "
        "LEFT JOIN families f ON f.id = w.family_id "
        "LEFT JOIN users u ON u.id = w.approved_by WHERE w.family_id = ? ORDER BY w.created_at DESC",
        { familyId });
    std::vector<WelfareRequest> result;
    while (q.next()) result.push_back(WelfareRequest::fromQuery(q));
    return result;
}

} // namespace mms
