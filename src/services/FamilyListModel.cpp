/*
 * FamilyListModel.cpp — Implementation
 */
#include "FamilyListModel.h"
#include "FamilyController.h"
#include "../models/Family.h"

FamilyListModel::FamilyListModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

// ============================================================================
// QAbstractListModel overrides
// ============================================================================

int FamilyListModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return static_cast<int>(families_.size());
}

QVariant FamilyListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(families_.size()))
        return {};
    const mms::Family& f = families_[index.row()];
    switch (role) {
        case IdRole:                return f.id;
        case FamilyNumberRole:      return f.familyNumber;
        case HouseNameRole:         return f.houseName;
        case HouseNumberRole:       return f.houseNumber;
        case WardRole:              return f.ward;
        case AreaRole:              return f.area;
        case AddressRole:           return f.address;
        case PincodeRole:           return f.pincode;
        case PhoneRole:             return f.phone;
        case AlternativePhoneRole:  return f.alternativePhone;
        case StatusRole:            return f.status;
        case NotesRole:             return f.notes;
        case MemberCountRole:       return f.memberCount;
        case HeadNameRole:          return f.headName;
    }
    return {};
}

QHash<int, QByteArray> FamilyListModel::roleNames() const {
    return {
        { IdRole,                "id" },
        { FamilyNumberRole,      "familyNumber" },
        { HouseNameRole,         "houseName" },
        { HouseNumberRole,       "houseNumber" },
        { WardRole,              "ward" },
        { AreaRole,              "area" },
        { AddressRole,           "address" },
        { PincodeRole,           "pincode" },
        { PhoneRole,             "phone" },
        { AlternativePhoneRole,  "alternativePhone" },
        { StatusRole,            "status" },
        { NotesRole,             "notes" },
        { MemberCountRole,       "memberCount" },
        { HeadNameRole,          "headName" }
    };
}

// ============================================================================
// Property setters — each triggers a reload
// ============================================================================

void FamilyListModel::setCurrentPage(int page) {
    if (page < 1) page = 1;
    if (currentPage_ != page) {
        currentPage_ = page;
        emit currentPageChanged();
        reload();
    }
}

void FamilyListModel::setPageSize(int size) {
    if (size < 1) size = 25;
    if (pageSize_ != size) {
        pageSize_ = size;
        emit pageSizeChanged();
        // Page 1 of new size
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void FamilyListModel::setSearchTerm(const QString& term) {
    if (searchTerm_ != term) {
        searchTerm_ = term;
        emit searchTermChanged();
        // Reset to page 1 on new search
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void FamilyListModel::setStatusFilter(const QString& filter) {
    if (statusFilter_ != filter) {
        statusFilter_ = filter;
        emit statusFilterChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void FamilyListModel::setWardFilter(const QString& filter) {
    if (wardFilter_ != filter) {
        wardFilter_ = filter;
        emit wardFilterChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

// ============================================================================
// Q_INVOKABLE helpers
// ============================================================================

void FamilyListModel::refresh() {
    reload();
}

QVariantMap FamilyListModel::get(int index) const {
    if (index < 0 || index >= static_cast<int>(families_.size()))
        return {};
    const mms::Family& f = families_[index];
    QVariantMap m;
    m["id"] = f.id;
    m["familyNumber"] = f.familyNumber;
    m["houseName"] = f.houseName;
    m["houseNumber"] = f.houseNumber;
    m["ward"] = f.ward;
    m["area"] = f.area;
    m["address"] = f.address;
    m["pincode"] = f.pincode;
    m["phone"] = f.phone;
    m["alternativePhone"] = f.alternativePhone;
    m["status"] = f.status;
    m["notes"] = f.notes;
    m["memberCount"] = f.memberCount;
    m["headName"] = f.headName;
    return m;
}

void FamilyListModel::setController(FamilyController* controller) {
    if (controller_ == controller) return;
    controller_ = controller;
    if (controller_) {
        connect(controller_, &FamilyController::created,   this, &FamilyListModel::onFamilyCreated);
        connect(controller_, &FamilyController::updated,   this, &FamilyListModel::onFamilyUpdated);
        connect(controller_, &FamilyController::removed,   this, &FamilyListModel::onFamilyRemoved);
        connect(controller_, &FamilyController::archived,  this, &FamilyListModel::onFamilyArchived);
        connect(controller_, &FamilyController::restored,  this, &FamilyListModel::onFamilyRestored);
    }
}

// ============================================================================
// Slots — auto-refresh when controller signals changes
// ============================================================================

void FamilyListModel::onFamilyCreated(qint64)   { reload(); }
void FamilyListModel::onFamilyUpdated(qint64)   { reload(); }
void FamilyListModel::onFamilyRemoved(qint64)   { reload(); }
void FamilyListModel::onFamilyArchived(qint64)  { reload(); }
void FamilyListModel::onFamilyRestored(qint64)  { reload(); }

// ============================================================================
// Private
// ============================================================================

void FamilyListModel::reload() {
    setLoading(true);
    int total = 0;
    auto newFamilies = svc_.searchFamilies(searchTerm_, currentPage_, pageSize_,
                                            statusFilter_, wardFilter_, &total);

    beginResetModel();
    families_ = std::move(newFamilies);
    endResetModel();

    if (totalCount_ != total) {
        totalCount_ = total;
        emit totalCountChanged();
    }
    int newTotalPages = (pageSize_ > 0) ? std::max(1, (total + pageSize_ - 1) / pageSize_) : 1;
    if (totalPages_ != newTotalPages) {
        totalPages_ = newTotalPages;
        emit totalPagesChanged();
    }
    setLoading(false);
}

void FamilyListModel::setLoading(bool loading) {
    if (loading_ != loading) {
        loading_ = loading;
        emit loadingChanged();
    }
}
