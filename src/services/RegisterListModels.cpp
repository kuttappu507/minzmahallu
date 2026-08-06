/*
 * RegisterListModels.cpp — Implementation for Marriage/Death/Welfare list models
 */
#include "RegisterListModels.h"
#include "RegisterControllers.h"
#include <algorithm>

// ============================================================================
// MarriageListModel
// ============================================================================
QVariant MarriageListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= (int)items_.size()) return {};
    const mms::Marriage& m = items_[index.row()];
    switch (role) {
        case IdRole: return m.id;
        case MarriageNumberRole: return m.marriageNumber;
        case BrideNameRole: return m.brideName;
        case GroomNameRole: return m.groomName;
        case NikahDateRole: return m.nikahDate;
        case PlaceRole: return m.place;
        case ImamNameRole: return m.imamName;
        case RegistrationDateRole: return m.registrationDate;
        case MaharRole: return m.mahar;
    }
    return {};
}

QHash<int, QByteArray> MarriageListModel::roleNames() const {
    return {{IdRole,"id"},{MarriageNumberRole,"marriageNumber"},{BrideNameRole,"brideName"},
            {GroomNameRole,"groomName"},{NikahDateRole,"nikahDate"},{PlaceRole,"place"},
            {ImamNameRole,"imamName"},{RegistrationDateRole,"registrationDate"},{MaharRole,"mahar"}};
}

void MarriageListModel::connectController(QObject* controller) {
    connect(controller, SIGNAL(created(qint64)), this, SLOT(onCreated()));
    connect(controller, SIGNAL(updated(qint64)), this, SLOT(onUpdated()));
    connect(controller, SIGNAL(removed(qint64)), this, SLOT(onRemoved()));
}

void MarriageListModel::reload() {
    setLoading(true);
    int total = 0;
    auto items = svc_.list(page_, pageSize_, search_, "", "", &total);
    beginResetModel(); items_ = std::move(items); endResetModel();
    if (total_ != total) { total_ = total; emit totalCountChanged(); }
    int tp = std::max(1, (total + pageSize_ - 1) / pageSize_);
    if (totalPages_ != tp) { totalPages_ = tp; emit totalPagesChanged(); }
    setLoading(false);
}

// ============================================================================
// DeathListModel
// ============================================================================
QVariant DeathListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= (int)items_.size()) return {};
    const mms::Death& d = items_[index.row()];
    switch (role) {
        case IdRole: return d.id;
        case DeathNumberRole: return d.deathNumber;
        case DeceasedNameRole: return d.deceasedName;
        case FatherNameRole: return d.fatherName;
        case GenderRole: return d.gender;
        case DateOfDeathRole: return d.dateOfDeath;
        case BurialDateRole: return d.burialDate;
        case AgeRole: return d.age;
        case FamilyNumberRole: return d.familyNumber;
        case CauseOfDeathRole: return d.causeOfDeath;
    }
    return {};
}

QHash<int, QByteArray> DeathListModel::roleNames() const {
    return {{IdRole,"id"},{DeathNumberRole,"deathNumber"},{DeceasedNameRole,"deceasedName"},
            {FatherNameRole,"fatherName"},{GenderRole,"gender"},{DateOfDeathRole,"dateOfDeath"},
            {BurialDateRole,"burialDate"},{AgeRole,"age"},{FamilyNumberRole,"familyNumber"},
            {CauseOfDeathRole,"causeOfDeath"}};
}

void DeathListModel::connectController(QObject* controller) {
    connect(controller, SIGNAL(created(qint64)), this, SLOT(onCreated()));
    connect(controller, SIGNAL(updated(qint64)), this, SLOT(onUpdated()));
    connect(controller, SIGNAL(removed(qint64)), this, SLOT(onRemoved()));
}

void DeathListModel::reload() {
    setLoading(true);
    int total = 0;
    auto items = svc_.list(page_, pageSize_, search_, "", "", &total);
    beginResetModel(); items_ = std::move(items); endResetModel();
    if (total_ != total) { total_ = total; emit totalCountChanged(); }
    int tp = std::max(1, (total + pageSize_ - 1) / pageSize_);
    if (totalPages_ != tp) { totalPages_ = tp; emit totalPagesChanged(); }
    setLoading(false);
}

// ============================================================================
// WelfareListModel
// ============================================================================
QVariant WelfareListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() < 0 || index.row() >= (int)items_.size()) return {};
    const mms::WelfareRequest& w = items_[index.row()];
    switch (role) {
        case IdRole: return w.id;
        case RequestNumberRole: return w.requestNumber;
        case ApplicantNameRole: return w.applicantName;
        case CategoryRole: return w.category;
        case AmountRequestedRole: return w.amountRequested;
        case AmountApprovedRole: return w.amountApproved;
        case StatusRole: return w.status;
        case ReasonRole: return w.reason;
        case FamilyNumberRole: return w.familyNumber;
        case DisbursedDateRole: return w.disbursedDate;
    }
    return {};
}

QHash<int, QByteArray> WelfareListModel::roleNames() const {
    return {{IdRole,"id"},{RequestNumberRole,"requestNumber"},{ApplicantNameRole,"applicantName"},
            {CategoryRole,"category"},{AmountRequestedRole,"amountRequested"},{AmountApprovedRole,"amountApproved"},
            {StatusRole,"status"},{ReasonRole,"reason"},{FamilyNumberRole,"familyNumber"},
            {DisbursedDateRole,"disbursedDate"}};
}

void WelfareListModel::connectController(QObject* controller) {
    connect(controller, SIGNAL(created(qint64)), this, SLOT(onCreated()));
    connect(controller, SIGNAL(updated(qint64)), this, SLOT(onUpdated()));
    connect(controller, SIGNAL(removed(qint64)), this, SLOT(onRemoved()));
}

void WelfareListModel::reload() {
    setLoading(true);
    int total = 0;
    auto items = svc_.list(page_, pageSize_, statusFilter_, categoryFilter_, search_, &total);
    beginResetModel(); items_ = std::move(items); endResetModel();
    if (total_ != total) { total_ = total; emit totalCountChanged(); }
    int tp = std::max(1, (total + pageSize_ - 1) / pageSize_);
    if (totalPages_ != tp) { totalPages_ = tp; emit totalPagesChanged(); }
    setLoading(false);
}
