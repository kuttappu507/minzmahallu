/*
 * SubscriptionListModel.cpp — Implementation
 */
#include "SubscriptionListModel.h"
#include "SubscriptionController.h"
#include "../models/Subscription.h"
#include <algorithm>

SubscriptionListModel::SubscriptionListModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

int SubscriptionListModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return static_cast<int>(subs_.size());
}

QVariant SubscriptionListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(subs_.size()))
        return {};
    const mms::Subscription& s = subs_[index.row()];
    switch (role) {
        case IdRole:              return s.id;
        case ReceiptNumberRole:   return s.receiptNumber;
        case FamilyNumberRole:    return s.familyNumber;
        case MemberNameRole:      return s.memberName;
        case PlanNameRole:        return s.planName;
        case AmountRole:          return s.amount;
        case AmountPaidRole:      return s.amountPaid;
        case PeriodStartRole:     return s.periodStart;
        case PeriodEndRole:       return s.periodEnd;
        case PaymentDateRole:     return s.paymentDate;
        case PaymentMethodRole:   return s.paymentMethod;
        case StatusRole:          return s.status;
        case RemarksRole:         return s.remarks;
        case FamilyIdRole:        return s.familyId;
        case MemberIdRole:        return s.memberId;
        case PlanIdRole:          return s.planId;
    }
    return {};
}

QHash<int, QByteArray> SubscriptionListModel::roleNames() const {
    return {
        { IdRole,              "id" },
        { ReceiptNumberRole,   "receiptNumber" },
        { FamilyNumberRole,    "familyNumber" },
        { MemberNameRole,      "memberName" },
        { PlanNameRole,        "planName" },
        { AmountRole,          "amount" },
        { AmountPaidRole,      "amountPaid" },
        { PeriodStartRole,     "periodStart" },
        { PeriodEndRole,       "periodEnd" },
        { PaymentDateRole,     "paymentDate" },
        { PaymentMethodRole,   "paymentMethod" },
        { StatusRole,          "status" },
        { RemarksRole,         "remarks" },
        { FamilyIdRole,        "familyId" },
        { MemberIdRole,        "memberId" },
        { PlanIdRole,          "planId" }
    };
}

void SubscriptionListModel::setCurrentPage(int page) {
    if (page < 1) page = 1;
    if (currentPage_ != page) {
        currentPage_ = page; emit currentPageChanged(); reload();
    }
}

void SubscriptionListModel::setPageSize(int size) {
    if (size < 1) size = 25;
    if (pageSize_ != size) {
        pageSize_ = size; emit pageSizeChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void SubscriptionListModel::setStatusFilter(const QString& filter) {
    if (statusFilter_ != filter) {
        statusFilter_ = filter; emit statusFilterChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void SubscriptionListModel::setDateFrom(const QString& d) {
    if (dateFrom_ != d) {
        dateFrom_ = d; emit dateFromChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void SubscriptionListModel::setDateTo(const QString& d) {
    if (dateTo_ != d) {
        dateTo_ = d; emit dateToChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void SubscriptionListModel::refresh() { reload(); }

QVariantMap SubscriptionListModel::get(int index) const {
    if (index < 0 || index >= static_cast<int>(subs_.size())) return {};
    const mms::Subscription& s = subs_[index];
    QVariantMap m;
    m["id"] = s.id;
    m["receiptNumber"] = s.receiptNumber;
    m["familyNumber"] = s.familyNumber;
    m["memberName"] = s.memberName;
    m["planName"] = s.planName;
    m["amount"] = s.amount;
    m["amountPaid"] = s.amountPaid;
    m["periodStart"] = s.periodStart;
    m["periodEnd"] = s.periodEnd;
    m["paymentDate"] = s.paymentDate;
    m["paymentMethod"] = s.paymentMethod;
    m["status"] = s.status;
    m["remarks"] = s.remarks;
    m["familyId"] = s.familyId;
    m["memberId"] = s.memberId;
    m["planId"] = s.planId;
    return m;
}

void SubscriptionListModel::setController(SubscriptionController* controller) {
    if (controller_ == controller) return;
    controller_ = controller;
    if (controller_) {
        connect(controller_, &SubscriptionController::created,  this, &SubscriptionListModel::onCreated);
        connect(controller_, &SubscriptionController::updated,  this, &SubscriptionListModel::onUpdated);
        connect(controller_, &SubscriptionController::removed,  this, &SubscriptionListModel::onRemoved);
    }
}

void SubscriptionListModel::onCreated(qint64) { reload(); }
void SubscriptionListModel::onUpdated(qint64) { reload(); }
void SubscriptionListModel::onRemoved(qint64) { reload(); }

void SubscriptionListModel::reload() {
    setLoading(true);
    int total = 0;
    auto newSubs = svc_.list(currentPage_, pageSize_, statusFilter_, dateFrom_, dateTo_, 0, &total);

    beginResetModel();
    subs_ = std::move(newSubs);
    endResetModel();

    if (totalCount_ != total) { totalCount_ = total; emit totalCountChanged(); }
    int newTotalPages = (pageSize_ > 0) ? std::max(1, (total + pageSize_ - 1) / pageSize_) : 1;
    if (totalPages_ != newTotalPages) { totalPages_ = newTotalPages; emit totalPagesChanged(); }
    setLoading(false);
}

void SubscriptionListModel::setLoading(bool loading) {
    if (loading_ != loading) { loading_ = loading; emit loadingChanged(); }
}
