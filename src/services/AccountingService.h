/*
 * AccountingService.h
 */
#pragma once

#include "../models/Transaction.h"
#include "../repositories/AccountingRepository.h"
#include <vector>
#include <QString>

namespace mms {

class AccountingService {
public:
    // Accounts
    std::vector<LedgerAccount> accounts(const QString& typeFilter = QString());
    LedgerAccount account(qint64 id);

    // Transactions
    qint64 createTransaction(Transaction& t, QString* errorMsg = nullptr);
    bool updateTransaction(const Transaction& t, QString* errorMsg = nullptr);
    bool deleteTransaction(qint64 id);

    std::vector<Transaction> listTransactions(int page = 1, int pageSize = 50,
                                              const QString& dateFrom = QString(),
                                              const QString& dateTo = QString(),
                                              const QString& typeFilter = QString(),
                                              qint64 accountId = 0,
                                              int* totalOut = nullptr);

    // Summary
    double totalIncome(const QString& from, const QString& to);
    double totalExpense(const QString& from, const QString& to);
    double balance(const QString& from, const QString& to);

    std::vector<AccountingRepository::MonthlyRow> monthlySummary(int year);
    std::vector<AccountingRepository::AccountTotal> accountTotals(const QString& from, const QString& to);
};

} // namespace mms
