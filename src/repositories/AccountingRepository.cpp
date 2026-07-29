/*
 * AccountingRepository.cpp
 */
#include "AccountingRepository.h"
#include "../core/Database.h"

namespace mms {

std::vector<LedgerAccount> AccountingRepository::listAccounts(const QString& typeFilter) {
    QString sql = "SELECT * FROM ledger_accounts WHERE is_active = 1";
    QVariantList params;
    if (!typeFilter.isEmpty()) { sql += " AND type = ?"; params << typeFilter; }
    sql += " ORDER BY code";
    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<LedgerAccount> result;
    while (q.next()) {
        LedgerAccount a;
        a.id = q.value("id").toLongLong();
        a.code = q.value("code").toString();
        a.name = q.value("name").toString();
        a.type = q.value("type").toString();
        a.category = q.value("category").toString();
        a.isActive = q.value("is_active").toInt() == 1;
        result.push_back(a);
    }
    return result;
}

std::optional<LedgerAccount> AccountingRepository::findAccount(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM ledger_accounts WHERE id = ?", { id });
    if (!q.next()) return std::nullopt;
    LedgerAccount a;
    a.id = q.value("id").toLongLong();
    a.code = q.value("code").toString();
    a.name = q.value("name").toString();
    a.type = q.value("type").toString();
    a.category = q.value("category").toString();
    a.isActive = q.value("is_active").toInt() == 1;
    return a;
}

std::optional<LedgerAccount> AccountingRepository::findAccountByCode(const QString& code) {
    QSqlQuery q = Database::instance().execute(
        "SELECT * FROM ledger_accounts WHERE code = ?", { code });
    if (!q.next()) return std::nullopt;
    LedgerAccount a;
    a.id = q.value("id").toLongLong();
    a.code = q.value("code").toString();
    a.name = q.value("name").toString();
    a.type = q.value("type").toString();
    a.category = q.value("category").toString();
    a.isActive = q.value("is_active").toInt() == 1;
    return a;
}

qint64 AccountingRepository::createAccount(const LedgerAccount& a) {
    return Database::instance().insert(
        "INSERT INTO ledger_accounts (code, name, type, category, is_active) VALUES (?,?,?,?,1)",
        { a.code, a.name, a.type, a.category });
}

bool AccountingRepository::updateAccount(const LedgerAccount& a) {
    int n = Database::instance().update(
        "UPDATE ledger_accounts SET code = ?, name = ?, type = ?, category = ?, is_active = ? WHERE id = ?",
        { a.code, a.name, a.type, a.category, a.isActive ? 1 : 0, a.id });
    return n > 0;
}

std::optional<Transaction> AccountingRepository::findTransaction(qint64 id) {
    QSqlQuery q = Database::instance().execute(
        "SELECT t.*, la.name AS account_name, la.code AS account_code FROM transactions t "
        "LEFT JOIN ledger_accounts la ON la.id = t.account_id WHERE t.id = ?", { id });
    if (q.next()) return Transaction::fromQuery(q);
    return std::nullopt;
}

std::vector<Transaction> AccountingRepository::listTransactions(int page, int pageSize,
                                                                const QString& dateFrom,
                                                                const QString& dateTo,
                                                                const QString& typeFilter,
                                                                qint64 accountId,
                                                                int* totalOut) {
    QStringList where;
    QVariantList params;
    if (!dateFrom.isEmpty()) { where << "t.txn_date >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { where << "t.txn_date <= ?"; params << dateTo;   }
    if (!typeFilter.isEmpty()){ where << "t.type = ?";     params << typeFilter;}
    if (accountId > 0)       { where << "t.account_id = ?";params << accountId; }
    QString whereSql = where.isEmpty() ? QString() : ("WHERE " + where.join(" AND "));

    if (totalOut) {
        QVariant c = Database::instance().scalar(
            "SELECT COUNT(*) FROM transactions t " + whereSql, params);
        *totalOut = c.toInt();
    }

    QString sql = QString(
        "SELECT t.*, la.name AS account_name, la.code AS account_code FROM transactions t "
        "LEFT JOIN ledger_accounts la ON la.id = t.account_id "
        "%1 ORDER BY t.txn_date DESC, t.id DESC LIMIT ? OFFSET ?")
        .arg(whereSql);

    int offset = (page - 1) * pageSize;
    params << pageSize << offset;
    QSqlQuery q = Database::instance().execute(sql, params);
    std::vector<Transaction> result;
    while (q.next()) result.push_back(Transaction::fromQuery(q));
    return result;
}

qint64 AccountingRepository::createTransaction(const Transaction& t) {
    return Database::instance().insert(
        R"(INSERT INTO transactions
           (txn_date, account_id, type, amount, payment_method, reference, description,
            linked_module, linked_id, receipt_number, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?))",
        { t.txnDate, t.accountId, t.type, t.amount, t.paymentMethod, t.reference,
          t.description, t.linkedModule,
          t.linkedId > 0 ? QVariant(t.linkedId) : QVariant(),
          t.receiptNumber, t.createdBy > 0 ? QVariant(t.createdBy) : QVariant() });
}

bool AccountingRepository::updateTransaction(const Transaction& t) {
    int n = Database::instance().update(
        R"(UPDATE transactions SET
           txn_date = ?, account_id = ?, type = ?, amount = ?, payment_method = ?,
           reference = ?, description = ?, receipt_number = ?
           WHERE id = ?)",
        { t.txnDate, t.accountId, t.type, t.amount, t.paymentMethod, t.reference,
          t.description, t.receiptNumber, t.id });
    return n > 0;
}

bool AccountingRepository::removeTransaction(qint64 id) {
    int n = Database::instance().remove(
        "DELETE FROM transactions WHERE id = ?", { id });
    return n > 0;
}

double AccountingRepository::totalIncome(const QString& dateFrom, const QString& dateTo) {
    QVariant v = Database::instance().scalar(
        "SELECT COALESCE(SUM(amount),0) FROM transactions WHERE type = 'Income' "
        "AND txn_date >= ? AND txn_date <= ?", { dateFrom, dateTo });
    return v.toDouble();
}

double AccountingRepository::totalExpense(const QString& dateFrom, const QString& dateTo) {
    QVariant v = Database::instance().scalar(
        "SELECT COALESCE(SUM(amount),0) FROM transactions WHERE type = 'Expense' "
        "AND txn_date >= ? AND txn_date <= ?", { dateFrom, dateTo });
    return v.toDouble();
}

double AccountingRepository::balance(const QString& dateFrom, const QString& dateTo) {
    return totalIncome(dateFrom, dateTo) - totalExpense(dateFrom, dateTo);
}

std::vector<AccountingRepository::MonthlyRow> AccountingRepository::monthlySummary(int year) {
    QSqlQuery q = Database::instance().execute(
        R"(SELECT strftime('%Y-%m', txn_date) AS month,
                  SUM(CASE WHEN type='Income' THEN amount ELSE 0 END) AS income,
                  SUM(CASE WHEN type='Expense' THEN amount ELSE 0 END) AS expense
           FROM transactions
           WHERE strftime('%Y', txn_date) = ?
           GROUP BY month ORDER BY month)",
        { QString::number(year) });
    std::vector<MonthlyRow> result;
    while (q.next()) {
        MonthlyRow r;
        r.month = q.value(0).toString();
        r.income = q.value(1).toDouble();
        r.expense = q.value(2).toDouble();
        result.push_back(r);
    }
    return result;
}

std::vector<AccountingRepository::AccountTotal> AccountingRepository::accountTotals(const QString& dateFrom, const QString& dateTo) {
    QSqlQuery q = Database::instance().execute(
        R"(SELECT la.code, la.name, la.type, COALESCE(SUM(t.amount),0)
           FROM ledger_accounts la
           LEFT JOIN transactions t ON t.account_id = la.id
             AND t.txn_date >= ? AND t.txn_date <= ?
           WHERE la.is_active = 1
           GROUP BY la.id ORDER BY la.type, la.code)",
        { dateFrom, dateTo });
    std::vector<AccountTotal> result;
    while (q.next()) {
        AccountTotal a;
        a.code = q.value(0).toString();
        a.name = q.value(1).toString();
        a.type = q.value(2).toString();
        a.total = q.value(3).toDouble();
        result.push_back(a);
    }
    return result;
}

} // namespace mms
