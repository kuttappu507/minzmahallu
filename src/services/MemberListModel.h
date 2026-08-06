/*
 * MemberListModel.h — QAbstractListModel for the Members list view.
 *
 * Same pattern as FamilyListModel. Wraps MemberService::searchMembers().
 */
#pragma once

#include <QAbstractListModel>
#include <QString>
#include "MemberService.h"

class MemberController;

class MemberListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int pageSize READ pageSize WRITE setPageSize NOTIFY pageSizeChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY totalPagesChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(int rowCount READ rowCountInt NOTIFY totalCountChanged)
    Q_PROPERTY(QString searchTerm READ searchTerm WRITE setSearchTerm NOTIFY searchTermChanged)
    Q_PROPERTY(QString genderFilter READ genderFilter WRITE setGenderFilter NOTIFY genderFilterChanged)
    Q_PROPERTY(QString statusFilter READ statusFilter WRITE setStatusFilter NOTIFY statusFilterChanged)
    Q_PROPERTY(qint64 familyIdFilter READ familyIdFilter WRITE setFamilyIdFilter NOTIFY familyIdFilterChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        MemberCodeRole,
        NameRole,
        GenderRole,
        AgeRole,
        RelationshipRole,
        MobileRole,
        EmailRole,
        StatusRole,
        IsHeadRole,
        FamilyIdRole,
        FamilyNumberRole,
        HouseNameRole,
        OccupationRole,
        BloodGroupRole,
        MaritalStatusRole
    };
    Q_ENUM(Roles)

    explicit MemberListModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int currentPage() const { return currentPage_; }
    int pageSize() const { return pageSize_; }
    int totalPages() const { return totalPages_; }
    int totalCount() const { return totalCount_; }
    int rowCountInt() const { return static_cast<int>(members_.size()); }
    QString searchTerm() const { return searchTerm_; }
    QString genderFilter() const { return genderFilter_; }
    QString statusFilter() const { return statusFilter_; }
    qint64 familyIdFilter() const { return familyIdFilter_; }
    bool loading() const { return loading_; }

    void setCurrentPage(int page);
    void setPageSize(int size);
    void setSearchTerm(const QString& term);
    void setGenderFilter(const QString& filter);
    void setStatusFilter(const QString& filter);
    void setFamilyIdFilter(qint64 filter);

    Q_INVOKABLE void refresh();
    Q_INVOKABLE QVariantMap get(int index) const;

    void setController(MemberController* controller);

signals:
    void currentPageChanged();
    void pageSizeChanged();
    void totalPagesChanged();
    void totalCountChanged();
    void searchTermChanged();
    void genderFilterChanged();
    void statusFilterChanged();
    void familyIdFilterChanged();
    void loadingChanged();

private slots:
    void onMemberCreated(qint64 id);
    void onMemberUpdated(qint64 id);
    void onMemberRemoved(qint64 id);

private:
    void reload();
    void setLoading(bool loading);

    mms::MemberService svc_;
    std::vector<mms::Member> members_;
    int currentPage_ = 1;
    int pageSize_ = 25;
    int totalCount_ = 0;
    int totalPages_ = 1;
    QString searchTerm_;
    QString genderFilter_;
    QString statusFilter_;
    qint64 familyIdFilter_ = 0;
    bool loading_ = false;
    MemberController* controller_ = nullptr;
};
