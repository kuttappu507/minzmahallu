/*
 * RegisterListModels.h — Combined list models for Marriage, Death, Welfare
 */
#pragma once

#include <QAbstractListModel>
#include "RegisterServices.h"

// ============================================================================
// MarriageListModel
// ============================================================================
class MarriageListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY totalPagesChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(int rowCount READ rowCountInt NOTIFY totalCountChanged)
    Q_PROPERTY(QString searchTerm READ searchTerm WRITE setSearchTerm NOTIFY searchTermChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1, MarriageNumberRole, BrideNameRole, GroomNameRole,
        NikahDateRole, PlaceRole, ImamNameRole, RegistrationDateRole, MaharRole
    };
    Q_ENUM(Roles)

    explicit MarriageListModel(QObject* parent = nullptr) : QAbstractListModel(parent) {}

    int rowCount(const QModelIndex& parent = QModelIndex()) const override { return parent.isValid() ? 0 : (int)items_.size(); }
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int currentPage() const { return page_; }
    int totalPages() const { return totalPages_; }
    int totalCount() const { return total_; }
    int rowCountInt() const { return (int)items_.size(); }
    QString searchTerm() const { return search_; }
    bool loading() const { return loading_; }

    void setCurrentPage(int p) { if (p != page_) { page_ = p; emit currentPageChanged(); reload(); } }
    void setSearchTerm(const QString& s) { if (s != search_) { search_ = s; if (page_ != 1) { page_ = 1; emit currentPageChanged(); } emit searchTermChanged(); reload(); } }

    Q_INVOKABLE void refresh() { reload(); }

    void connectController(QObject* controller);

signals:
    void currentPageChanged(); void totalPagesChanged(); void totalCountChanged();
    void searchTermChanged(); void loadingChanged();

private slots:
    void onCreated() { reload(); }
    void onUpdated() { reload(); }
    void onRemoved() { reload(); }

private:
    void reload();
    void setLoading(bool l) { if (loading_ != l) { loading_ = l; emit loadingChanged(); } }

    mms::MarriageService svc_;
    std::vector<mms::Marriage> items_;
    int page_ = 1, pageSize_ = 25, total_ = 0, totalPages_ = 1;
    QString search_;
    bool loading_ = false;
};

// ============================================================================
// DeathListModel
// ============================================================================
class DeathListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY totalPagesChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(int rowCount READ rowCountInt NOTIFY totalCountChanged)
    Q_PROPERTY(QString searchTerm READ searchTerm WRITE setSearchTerm NOTIFY searchTermChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1, DeathNumberRole, DeceasedNameRole, FatherNameRole,
        GenderRole, DateOfDeathRole, BurialDateRole, AgeRole, FamilyNumberRole, CauseOfDeathRole
    };
    Q_ENUM(Roles)

    explicit DeathListModel(QObject* parent = nullptr) : QAbstractListModel(parent) {}

    int rowCount(const QModelIndex& parent = QModelIndex()) const override { return parent.isValid() ? 0 : (int)items_.size(); }
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int currentPage() const { return page_; }
    int totalPages() const { return totalPages_; }
    int totalCount() const { return total_; }
    int rowCountInt() const { return (int)items_.size(); }
    QString searchTerm() const { return search_; }
    bool loading() const { return loading_; }

    void setCurrentPage(int p) { if (p != page_) { page_ = p; emit currentPageChanged(); reload(); } }
    void setSearchTerm(const QString& s) { if (s != search_) { search_ = s; if (page_ != 1) { page_ = 1; emit currentPageChanged(); } emit searchTermChanged(); reload(); } }

    Q_INVOKABLE void refresh() { reload(); }

    void connectController(QObject* controller);

signals:
    void currentPageChanged(); void totalPagesChanged(); void totalCountChanged();
    void searchTermChanged(); void loadingChanged();

private slots:
    void onCreated() { reload(); }
    void onUpdated() { reload(); }
    void onRemoved() { reload(); }

private:
    void reload();
    void setLoading(bool l) { if (loading_ != l) { loading_ = l; emit loadingChanged(); } }

    mms::DeathService svc_;
    std::vector<mms::Death> items_;
    int page_ = 1, pageSize_ = 25, total_ = 0, totalPages_ = 1;
    QString search_;
    bool loading_ = false;
};

// ============================================================================
// WelfareListModel
// ============================================================================
class WelfareListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY totalPagesChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(int rowCount READ rowCountInt NOTIFY totalCountChanged)
    Q_PROPERTY(QString statusFilter READ statusFilter WRITE setStatusFilter NOTIFY statusFilterChanged)
    Q_PROPERTY(QString categoryFilter READ categoryFilter WRITE setCategoryFilter NOTIFY categoryFilterChanged)
    Q_PROPERTY(QString searchTerm READ searchTerm WRITE setSearchTerm NOTIFY searchTermChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1, RequestNumberRole, ApplicantNameRole, CategoryRole,
        AmountRequestedRole, AmountApprovedRole, StatusRole, ReasonRole,
        FamilyNumberRole, DisbursedDateRole
    };
    Q_ENUM(Roles)

    explicit WelfareListModel(QObject* parent = nullptr) : QAbstractListModel(parent) {}

    int rowCount(const QModelIndex& parent = QModelIndex()) const override { return parent.isValid() ? 0 : (int)items_.size(); }
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int currentPage() const { return page_; }
    int totalPages() const { return totalPages_; }
    int totalCount() const { return total_; }
    int rowCountInt() const { return (int)items_.size(); }
    QString statusFilter() const { return statusFilter_; }
    QString categoryFilter() const { return categoryFilter_; }
    QString searchTerm() const { return search_; }
    bool loading() const { return loading_; }

    void setCurrentPage(int p) { if (p != page_) { page_ = p; emit currentPageChanged(); reload(); } }
    void setStatusFilter(const QString& s) { if (s != statusFilter_) { statusFilter_ = s; if (page_ != 1) { page_ = 1; emit currentPageChanged(); } emit statusFilterChanged(); reload(); } }
    void setCategoryFilter(const QString& c) { if (c != categoryFilter_) { categoryFilter_ = c; if (page_ != 1) { page_ = 1; emit currentPageChanged(); } emit categoryFilterChanged(); reload(); } }
    void setSearchTerm(const QString& s) { if (s != search_) { search_ = s; if (page_ != 1) { page_ = 1; emit currentPageChanged(); } emit searchTermChanged(); reload(); } }

    Q_INVOKABLE void refresh() { reload(); }

    void connectController(QObject* controller);

signals:
    void currentPageChanged(); void totalPagesChanged(); void totalCountChanged();
    void statusFilterChanged(); void categoryFilterChanged();
    void searchTermChanged(); void loadingChanged();

private slots:
    void onCreated() { reload(); }
    void onUpdated() { reload(); }
    void onRemoved() { reload(); }

private:
    void reload();
    void setLoading(bool l) { if (loading_ != l) { loading_ = l; emit loadingChanged(); } }

    mms::WelfareService svc_;
    std::vector<mms::WelfareRequest> items_;
    int page_ = 1, pageSize_ = 25, total_ = 0, totalPages_ = 1;
    QString statusFilter_, categoryFilter_, search_;
    bool loading_ = false;
};
