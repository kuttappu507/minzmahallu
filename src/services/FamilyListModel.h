/*
 * FamilyListModel.h — QAbstractListModel for the Families list view.
 *
 * Wraps the existing FamilyService::searchFamilies(). Does NOT contain any
 * SQL — all persistence stays in the repository layer.
 *
 * QML usage:
 *   ListView {
 *       model: familyModel   // context property
 *       delegate: Text { text: model.familyNumber + " " + model.houseName }
 *   }
 *
 *   familyModel.searchTerm = "FAM-001"   // triggers reload
 *   familyModel.currentPage = 2          // triggers reload
 *
 * Auto-refreshes when FamilyController emits created/updated/deleted.
 */
#pragma once

#include <QAbstractListModel>
#include <QVariantList>
#include <QString>
#include "FamilyService.h"

class FamilyController;

class FamilyListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int pageSize READ pageSize WRITE setPageSize NOTIFY pageSizeChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY totalPagesChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(int rowCount READ rowCountInt NOTIFY totalCountChanged)
    Q_PROPERTY(QString searchTerm READ searchTerm WRITE setSearchTerm NOTIFY searchTermChanged)
    Q_PROPERTY(QString statusFilter READ statusFilter WRITE setStatusFilter NOTIFY statusFilterChanged)
    Q_PROPERTY(QString wardFilter READ wardFilter WRITE setWardFilter NOTIFY wardFilterChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        FamilyNumberRole,
        HouseNameRole,
        HouseNumberRole,
        WardRole,
        AreaRole,
        AddressRole,
        PincodeRole,
        PhoneRole,
        AlternativePhoneRole,
        StatusRole,
        NotesRole,
        MemberCountRole,
        HeadNameRole
    };
    Q_ENUM(Roles)

    explicit FamilyListModel(QObject* parent = nullptr);

    // ===== QAbstractListModel overrides =====
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // ===== Property getters =====
    int currentPage() const { return currentPage_; }
    int pageSize() const { return pageSize_; }
    int totalPages() const { return totalPages_; }
    int totalCount() const { return totalCount_; }
    int rowCountInt() const { return families_.size(); }
    QString searchTerm() const { return searchTerm_; }
    QString statusFilter() const { return statusFilter_; }
    QString wardFilter() const { return wardFilter_; }
    bool loading() const { return loading_; }

    // ===== Property setters (trigger reload) =====
    void setCurrentPage(int page);
    void setPageSize(int size);
    void setSearchTerm(const QString& term);
    void setStatusFilter(const QString& filter);
    void setWardFilter(const QString& filter);

    // ===== Q_INVOKABLE helpers =====
    Q_INVOKABLE void refresh();
    Q_INVOKABLE QVariantMap get(int index) const;  // get row data as map

    // Connect this model to a FamilyController so it auto-refreshes when
    // data changes. Called from app_main.cpp after both are created.
    void setController(FamilyController* controller);

signals:
    void currentPageChanged();
    void pageSizeChanged();
    void totalPagesChanged();
    void totalCountChanged();
    void searchTermChanged();
    void statusFilterChanged();
    void wardFilterChanged();
    void loadingChanged();

private slots:
    void onFamilyCreated(qint64 id);
    void onFamilyUpdated(qint64 id);
    void onFamilyRemoved(qint64 id);
    void onFamilyArchived(qint64 id);
    void onFamilyRestored(qint64 id);

private:
    void reload();
    void setLoading(bool loading);

    mms::FamilyService svc_;
    std::vector<mms::Family> families_;
    int currentPage_ = 1;
    int pageSize_ = 25;
    int totalCount_ = 0;
    int totalPages_ = 1;
    QString searchTerm_;
    QString statusFilter_;
    QString wardFilter_;
    bool loading_ = false;
    FamilyController* controller_ = nullptr;
};
