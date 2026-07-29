/*
 * AccountingService.cpp
 */
#include "AccountingService.h"
#include "../repositories/AccountingRepository.h"
#include "../repositories/AuditLogRepository.h"
#include "AuthSession.h"
#include <QDate>
#include <stdexcept>

namespace mms {

std::vector<LedgerAccount> AccountingService::accounts(const QString& typeFilter) {
    AccountingRepository repo;
    return repo.listAccounts(typeFilter);
}

LedgerAccount AccountingService::account(qint64 id) {
    AccountingRepository repo;
    auto a = repo.findAccount(id);
    if (!a) throw std::runtime_error("Account not found");
    return *a;
}

qint64 AccountingService::createTransaction(Transaction& t, QString* errorMsg) {
    if (t.accountId <= 0) { if (errorMsg) *errorMsg = "Account is required."; return -1; }
    if (t.amount <= 0)    { if (errorMsg) *errorMsg = "Amount must be positive."; return -1; }
    if (t.txnDate.isEmpty()) t.txnDate = QDate::currentDate().toString(Qt::ISODate);
    if (t.createdBy <= 0) t.createdBy = AuthSession::instance().user().id;

    AccountingRepository repo;
    auto acc = repo.findAccount(t.accountId);
    if (!acc) { if (errorMsg) *errorMsg = "Account not found."; return -1; }
    t.type = acc->type == "Expense" ? "Expense" : "Income";

    qint64 id = repo.createTransaction(t);
    if (id > 0) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "ADD", "accounting", id,
                  QString("Created %1 txn ₹%2 (%3)").arg(t.type).arg(t.amount).arg(acc->name), "");
    }
    return id;
}

bool AccountingService::updateTransaction(const Transaction& t, QString* errorMsg) {
    AccountingRepository repo;
    if (!repo.findTransaction(t.id)) {
        if (errorMsg) *errorMsg = "Transaction not found.";
        return false;
    }
    bool ok = repo.updateTransaction(t);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "EDIT", "accounting", t.id,
                  QString("Updated txn ₹%1").arg(t.amount), "");
    }
    return ok;
}

bool AccountingService::deleteTransaction(qint64 id) {
    AccountingRepository repo;
    bool ok = repo.removeTransaction(id);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "DELETE", "accounting", id, "Deleted transaction", "");
    }
    return ok;
}

std::vector<Transaction> AccountingService::listTransactions(int page, int pageSize,
                                                             const QString& dateFrom,
                                                             const QString& dateTo,
                                                             const QString& typeFilter,
                                                             qint64 accountId,
                                                             int* totalOut) {
    AccountingRepository repo;
    return repo.listTransactions(page, pageSize, dateFrom, dateTo, typeFilter, accountId, totalOut);
}

double AccountingService::totalIncome(const QString& from, const QString& to) {
    AccountingRepository repo;
    return repo.totalIncome(from, to);
}

double AccountingService::totalExpense(const QString& from, const QString& to) {
    AccountingRepository repo;
    return repo.totalExpense(from, to);
}

double AccountingService::balance(const QString& from, const QString& to) {
    AccountingRepository repo;
    return repo.balance(from, to);
}

std::vector<AccountingRepository::MonthlyRow> AccountingService::monthlySummary(int year) {
    AccountingRepository repo;
    return repo.monthlySummary(year);
}

std::vector<AccountingRepository::AccountTotal> AccountingService::accountTotals(const QString& from, const QString& to) {
    AccountingRepository repo;
    return repo.accountTotals(from, to);
}

} // namespace mms
