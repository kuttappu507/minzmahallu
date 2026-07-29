/*
 * AccountingRepository.h
 */
#pragma once

#include "../models/Transaction.h"
#include <vector>
#include <optional>
#include <QString>

namespace mms {

class AccountingRepository {
public:
    std::vector<LedgerAccount> listAccounts(const QString& typeFilter = QString());
    std::optional<LedgerAccount> findAccount(qint64 id);
    std::optional<LedgerAccount> findAccountByCode(const QString& code);

    qint64 createAccount(const LedgerAccount& a);
    bool updateAccount(const LedgerAccount& a);

    std::optional<Transaction> findTransaction(qint64 id);
    std::vector<Transaction> listTransactions(int page = 1, int pageSize = 50,
                                              const QString& dateFrom = QString(),
                                              const QString& dateTo = QString(),
                                              const QString& typeFilter = QString(),
                                              qint64 accountId = 0,
                                              int* totalOut = nullptr);

    qint64 createTransaction(const Transaction& t);
    bool updateTransaction(const Transaction& t);
    bool removeTransaction(qint64 id);

    // Summary
    double totalIncome(const QString& dateFrom, const QString& dateTo);
    double totalExpense(const QString& dateFrom, const QString& dateTo);
    double balance(const QString& dateFrom, const QString& dateTo);

    // Monthly summary: returns [{month, income, expense}]
    struct MonthlyRow { QString month; double income; double expense; };
    std::vector<MonthlyRow> monthlySummary(int year);

    // Per-account totals
    struct AccountTotal { QString code; QString name; QString type; double total; };
    std::vector<AccountTotal> accountTotals(const QString& dateFrom, const QString& dateTo);
};

} // namespace mms
