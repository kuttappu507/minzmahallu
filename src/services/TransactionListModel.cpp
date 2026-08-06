/*
 * TransactionListModel.cpp — Implementation
 */
#include "TransactionListModel.h"
#include "AccountingController.h"
#include "../models/Transaction.h"
#include <algorithm>

TransactionListModel::TransactionListModel(QObject* parent) : QAbstractListModel(parent) {}

int TransactionListModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return static_cast<int>(txns_.size());
}

QVariant TransactionListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(txns_.size()))
        return {};
    const mms::Transaction& t = txns_[index.row()];
    switch (role) {
        case IdRole:              return t.id;
        case TxnDateRole:         return t.txnDate;
        case AccountNameRole:     return t.accountName;
        case AccountCodeRole:     return t.accountCode;
        case TypeRole:            return t.type;
        case AmountRole:          return t.amount;
        case PaymentMethodRole:   return t.paymentMethod;
        case ReferenceRole:       return t.reference;
        case DescriptionRole:     return t.description;
        case ReceiptNumberRole:   return t.receiptNumber;
        case AccountIdRole:       return t.accountId;
    }
    return {};
}

QHash<int, QByteArray> TransactionListModel::roleNames() const {
    return {
        { IdRole,             "id" },
        { TxnDateRole,        "txnDate" },
        { AccountNameRole,    "accountName" },
        { AccountCodeRole,    "accountCode" },
        { TypeRole,           "type" },
        { AmountRole,         "amount" },
        { PaymentMethodRole,  "paymentMethod" },
        { ReferenceRole,      "reference" },
        { DescriptionRole,    "description" },
        { ReceiptNumberRole,  "receiptNumber" },
        { AccountIdRole,      "accountId" }
    };
}

void TransactionListModel::setCurrentPage(int page) {
    if (page < 1) page = 1;
    if (currentPage_ != page) { currentPage_ = page; emit currentPageChanged(); reload(); }
}

void TransactionListModel::setPageSize(int size) {
    if (size < 1) size = 25;
    if (pageSize_ != size) { pageSize_ = size; emit pageSizeChanged(); if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); } reload(); }
}

void TransactionListModel::setTypeFilter(const QString& filter) {
    if (typeFilter_ != filter) { typeFilter_ = filter; emit typeFilterChanged(); if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); } reload(); }
}

void TransactionListModel::setDateFrom(const QString& d) {
    if (dateFrom_ != d) { dateFrom_ = d; emit dateFromChanged(); if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); } reload(); }
}

void TransactionListModel::setDateTo(const QString& d) {
    if (dateTo_ != d) { dateTo_ = d; emit dateToChanged(); if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); } reload(); }
}

void TransactionListModel::refresh() { reload(); }

QVariantMap TransactionListModel::get(int index) const {
    if (index < 0 || index >= static_cast<int>(txns_.size())) return {};
    const mms::Transaction& t = txns_[index];
    QVariantMap m;
    m["id"] = t.id; m["txnDate"] = t.txnDate; m["accountName"] = t.accountName;
    m["accountCode"] = t.accountCode; m["type"] = t.type; m["amount"] = t.amount;
    m["paymentMethod"] = t.paymentMethod; m["reference"] = t.reference;
    m["description"] = t.description; m["receiptNumber"] = t.receiptNumber;
    m["accountId"] = t.accountId;
    return m;
}

void TransactionListModel::setController(AccountingController* controller) {
    if (controller_ == controller) return;
    controller_ = controller;
    if (controller_) {
        connect(controller_, &AccountingController::created,  this, &TransactionListModel::onCreated);
        connect(controller_, &AccountingController::updated,  this, &TransactionListModel::onUpdated);
        connect(controller_, &AccountingController::removed,  this, &TransactionListModel::onRemoved);
    }
}

void TransactionListModel::onCreated(qint64) { reload(); }
void TransactionListModel::onUpdated(qint64) { reload(); }
void TransactionListModel::onRemoved(qint64) { reload(); }

void TransactionListModel::reload() {
    setLoading(true);
    int total = 0;
    qint64 accId = 0;
    auto newTxns = svc_.listTransactions(currentPage_, pageSize_, dateFrom_, dateTo_, typeFilter_, accId, &total);
    beginResetModel();
    txns_ = std::move(newTxns);
    endResetModel();
    if (totalCount_ != total) { totalCount_ = total; emit totalCountChanged(); }
    int newTotalPages = (pageSize_ > 0) ? std::max(1, (total + pageSize_ - 1) / pageSize_) : 1;
    if (totalPages_ != newTotalPages) { totalPages_ = newTotalPages; emit totalPagesChanged(); }
    setLoading(false);
}

void TransactionListModel::setLoading(bool loading) {
    if (loading_ != loading) { loading_ = loading; emit loadingChanged(); }
}
