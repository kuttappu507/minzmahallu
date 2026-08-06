/*
 * MemberListModel.cpp — Implementation
 */
#include "MemberListModel.h"
#include "MemberController.h"
#include "../models/Member.h"
#include <algorithm>

MemberListModel::MemberListModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

int MemberListModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return static_cast<int>(members_.size());
}

QVariant MemberListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= static_cast<int>(members_.size()))
        return {};
    const mms::Member& m = members_[index.row()];
    switch (role) {
        case IdRole:             return m.id;
        case MemberCodeRole:     return m.memberCode;
        case NameRole:           return m.name;
        case GenderRole:         return m.gender;
        case AgeRole:            return m.age;
        case RelationshipRole:   return m.relationship;
        case MobileRole:         return m.mobile;
        case EmailRole:          return m.email;
        case StatusRole:         return m.status;
        case IsHeadRole:         return m.isHead;
        case FamilyIdRole:       return m.familyId;
        case FamilyNumberRole:   return m.familyNumber;
        case HouseNameRole:      return m.houseName;
        case OccupationRole:     return m.occupation;
        case BloodGroupRole:     return m.bloodGroup;
        case MaritalStatusRole:  return m.maritalStatus;
    }
    return {};
}

QHash<int, QByteArray> MemberListModel::roleNames() const {
    return {
        { IdRole,             "id" },
        { MemberCodeRole,     "memberCode" },
        { NameRole,           "name" },
        { GenderRole,         "gender" },
        { AgeRole,            "age" },
        { RelationshipRole,   "relationship" },
        { MobileRole,         "mobile" },
        { EmailRole,          "email" },
        { StatusRole,         "status" },
        { IsHeadRole,         "isHead" },
        { FamilyIdRole,       "familyId" },
        { FamilyNumberRole,   "familyNumber" },
        { HouseNameRole,      "houseName" },
        { OccupationRole,     "occupation" },
        { BloodGroupRole,     "bloodGroup" },
        { MaritalStatusRole,  "maritalStatus" }
    };
}

void MemberListModel::setCurrentPage(int page) {
    if (page < 1) page = 1;
    if (currentPage_ != page) {
        currentPage_ = page;
        emit currentPageChanged();
        reload();
    }
}

void MemberListModel::setPageSize(int size) {
    if (size < 1) size = 25;
    if (pageSize_ != size) {
        pageSize_ = size;
        emit pageSizeChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void MemberListModel::setSearchTerm(const QString& term) {
    if (searchTerm_ != term) {
        searchTerm_ = term;
        emit searchTermChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void MemberListModel::setGenderFilter(const QString& filter) {
    if (genderFilter_ != filter) {
        genderFilter_ = filter;
        emit genderFilterChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void MemberListModel::setStatusFilter(const QString& filter) {
    if (statusFilter_ != filter) {
        statusFilter_ = filter;
        emit statusFilterChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void MemberListModel::setFamilyIdFilter(qint64 filter) {
    if (familyIdFilter_ != filter) {
        familyIdFilter_ = filter;
        emit familyIdFilterChanged();
        if (currentPage_ != 1) { currentPage_ = 1; emit currentPageChanged(); }
        reload();
    }
}

void MemberListModel::refresh() { reload(); }

QVariantMap MemberListModel::get(int index) const {
    if (index < 0 || index >= static_cast<int>(members_.size())) return {};
    const mms::Member& m = members_[index];
    QVariantMap map;
    map["id"] = m.id;
    map["familyId"] = m.familyId;
    map["memberCode"] = m.memberCode;
    map["name"] = m.name;
    map["gender"] = m.gender;
    map["age"] = m.age;
    map["relationship"] = m.relationship;
    map["mobile"] = m.mobile;
    map["email"] = m.email;
    map["status"] = m.status;
    map["isHead"] = m.isHead;
    map["familyNumber"] = m.familyNumber;
    map["houseName"] = m.houseName;
    map["occupation"] = m.occupation;
    map["bloodGroup"] = m.bloodGroup;
    map["maritalStatus"] = m.maritalStatus;
    return map;
}

void MemberListModel::setController(MemberController* controller) {
    if (controller_ == controller) return;
    controller_ = controller;
    if (controller_) {
        connect(controller_, &MemberController::created,  this, &MemberListModel::onMemberCreated);
        connect(controller_, &MemberController::updated,  this, &MemberListModel::onMemberUpdated);
        connect(controller_, &MemberController::removed,  this, &MemberListModel::onMemberRemoved);
    }
}

void MemberListModel::onMemberCreated(qint64) { reload(); }
void MemberListModel::onMemberUpdated(qint64) { reload(); }
void MemberListModel::onMemberRemoved(qint64) { reload(); }

void MemberListModel::reload() {
    setLoading(true);
    int total = 0;
    auto newMembers = svc_.searchMembers(searchTerm_, currentPage_, pageSize_,
                                          genderFilter_, statusFilter_, familyIdFilter_, &total);

    beginResetModel();
    members_ = std::move(newMembers);
    endResetModel();

    if (totalCount_ != total) { totalCount_ = total; emit totalCountChanged(); }
    int newTotalPages = (pageSize_ > 0) ? std::max(1, (total + pageSize_ - 1) / pageSize_) : 1;
    if (totalPages_ != newTotalPages) { totalPages_ = newTotalPages; emit totalPagesChanged(); }
    setLoading(false);
}

void MemberListModel::setLoading(bool loading) {
    if (loading_ != loading) { loading_ = loading; emit loadingChanged(); }
}
