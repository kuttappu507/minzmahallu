/*
 * DonationListModel.cpp — Implementation
 */
#include "DonationListModel.h"
#include "DonationController.h"
#include "../models/Donation.h"
#include <algorithm>

DonationListModel::DonationListModel(QObject* parent) : QAbstractListModel(parent) {}

int DonationListModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return static_cast<int>(donations_.size());
}

QVariant DonationListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(donations_.size()))
        return {};
    const mms::Donation& d = donations_[index.row()];
    switch (role) {
        case IdRole:             return d.id;
        case ReceiptNumberRole:  return d.receiptNumber;
        case DonorNameRole:      return d.donorName;
        case DonorPhoneRole:     return d.donorPhone;
        case AmountRole:         return d.amount;
        case DonationDateRole:   return d.donationDate;
        case PaymentMethodRole:  return d.paymentMethod;
        case PurposeRole:        return d.purpose;
        case RemarksRole:        return d.remarks;
        case CategoryNameRole:   return d.categoryName;
        case CategoryIdRole:     return d.categoryId;
        case FamilyNumberRole:   return d.familyNumber;
        case FamilyIdRole:       return d.familyId;
        case MemberIdRole:       return d.memberId;
    }
    return {};
}

QHash<int, QByteArray> DonationListModel::roleNames() const {
    return {
        { IdRole,             "id" },
        { ReceiptNumberRole,  "receiptNumber" },
        { DonorNameRole,      "donorName" },
        { DonorPhoneRole,     "donorPhone" },
        { AmountRole,         "amount" },
        { DonationDateRole,   "donationDate" },
        { PaymentMethodRole,  "paymentMethod" },
        { PurposeRole,        "purpose" },
        { RemarksRole,        "remarks" },
        { CategoryNameRole,   "categoryName" },
        { CategoryIdRole,     "categoryId" },
        { FamilyNumberRole,   "familyNumber" },
        { FamilyIdRole,       "familyId" },
        { MemberIdRole,       "memberId" }
    };
}

void DonationListModel::setCurrentPage(int page) {
    if (page < 1) page = 1;
    if (currentPage_ != page) { currentPage_ = page; emit currentPageChanged(); reload(); }
}

void DonationListModel::setPageSize(int size) {
    if (size < 1) size = 25;
    if (pageSize_ != size) {
        pageSize_ = size; emit pageSizeChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void DonationListModel::setSearchTerm(const QString& term) {
    if (searchTerm_ != term) {
        searchTerm_ = term; emit searchTermChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void DonationListModel::setCategoryFilter(const QString& filter) {
    if (categoryFilter_ != filter) {
        categoryFilter_ = filter; emit categoryFilterChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void DonationListModel::setDateFrom(const QString& d) {
    if (dateFrom_ != d) { dateFrom_ = d; emit dateFromChanged(); if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); } reload(); }
}

void DonationListModel::setDateTo(const QString& d) {
    if (dateTo_ != d) { dateTo_ = d; emit dateToChanged(); if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); } reload(); }
}

void DonationListModel::refresh() { reload(); }

QVariantMap DonationListModel::get(int index) const {
    if (index < 0 || index >= static_cast<int>(donations_.size())) return {};
    const mms::Donation& d = donations_[index];
    QVariantMap m;
    m["id"] = d.id; m["receiptNumber"] = d.receiptNumber; m["donorName"] = d.donorName;
    m["donorPhone"] = d.donorPhone; m["amount"] = d.amount; m["donationDate"] = d.donationDate;
    m["paymentMethod"] = d.paymentMethod; m["purpose"] = d.purpose; m["remarks"] = d.remarks;
    m["categoryName"] = d.categoryName; m["categoryId"] = d.categoryId;
    m["familyNumber"] = d.familyNumber; m["familyId"] = d.familyId; m["memberId"] = d.memberId;
    return m;
}

void DonationListModel::setController(DonationController* controller) {
    if (controller_ == controller) return;
    controller_ = controller;
    if (controller_) {
        connect(controller_, &DonationController::created,  this, &DonationListModel::onCreated);
        connect(controller_, &DonationController::updated,  this, &DonationListModel::onUpdated);
        connect(controller_, &DonationController::removed,  this, &DonationListModel::onRemoved);
    }
}

void DonationListModel::onCreated(qint64) { reload(); }
void DonationListModel::onUpdated(qint64) { reload(); }
void DonationListModel::onRemoved(qint64) { reload(); }

void DonationListModel::reload() {
    setLoading(true);
    int total = 0;
    qint64 catId = 0;
    if (!categoryFilter_.isEmpty()) catId = categoryFilter_.toLongLong();
    auto newDonations = svc_.list(currentPage_, pageSize_, dateFrom_, dateTo_, catId, searchTerm_, &total);

    beginResetModel();
    donations_ = std::move(newDonations);
    endResetModel();

    if (totalCount_ != total) { totalCount_ = total; emit totalCountChanged(); }
    int newTotalPages = (pageSize_ > 0) ? std::max(1, (total + pageSize_ - 1) / pageSize_) : 1;
    if (totalPages_ != newTotalPages) { totalPages_ = newTotalPages; emit totalPagesChanged(); }
    setLoading(false);
}

void DonationListModel::setLoading(bool loading) {
    if (loading_ != loading) { loading_ = loading; emit loadingChanged(); }
}
