/*
 * DonationListModel.h — QAbstractListModel for Donations list view.
 */
#pragma once

#include <QAbstractListModel>
#include <QString>
#include "DonationService.h"

class DonationController;

class DonationListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int pageSize READ pageSize WRITE setPageSize NOTIFY pageSizeChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY totalPagesChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(int rowCount READ rowCountInt NOTIFY totalCountChanged)
    Q_PROPERTY(QString searchTerm READ searchTerm WRITE setSearchTerm NOTIFY searchTermChanged)
    Q_PROPERTY(QString categoryFilter READ categoryFilter WRITE setCategoryFilter NOTIFY categoryFilterChanged)
    Q_PROPERTY(QString dateFrom READ dateFrom WRITE setDateFrom NOTIFY dateFromChanged)
    Q_PROPERTY(QString dateTo READ dateTo WRITE setDateTo NOTIFY dateToChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        ReceiptNumberRole,
        DonorNameRole,
        DonorPhoneRole,
        AmountRole,
        DonationDateRole,
        PaymentMethodRole,
        PurposeRole,
        RemarksRole,
        CategoryNameRole,
        CategoryIdRole,
        FamilyNumberRole,
        FamilyIdRole,
        MemberIdRole
    };
    Q_ENUM(Roles)

    explicit DonationListModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int currentPage() const { return currentPage_; }
    int pageSize() const { return pageSize_; }
    int totalPages() const { return totalPages_; }
    int totalCount() const { return totalCount_; }
    int rowCountInt() const { return static_cast<int>(donations_.size()); }
    QString searchTerm() const { return searchTerm_; }
    QString categoryFilter() const { return categoryFilter_; }
    QString dateFrom() const { return dateFrom_; }
    QString dateTo() const { return dateTo_; }
    bool loading() const { return loading_; }

    void setCurrentPage(int page);
    void setPageSize(int size);
    void setSearchTerm(const QString& term);
    void setCategoryFilter(const QString& filter);
    void setDateFrom(const QString& d);
    void setDateTo(const QString& d);

    Q_INVOKABLE void refresh();
    Q_INVOKABLE QVariantMap get(int index) const;

    void setController(DonationController* controller);

signals:
    void currentPageChanged();
    void pageSizeChanged();
    void totalPagesChanged();
    void totalCountChanged();
    void searchTermChanged();
    void categoryFilterChanged();
    void dateFromChanged();
    void dateToChanged();
    void loadingChanged();

private slots:
    void onCreated(qint64 id);
    void onUpdated(qint64 id);
    void onRemoved(qint64 id);

private:
    void reload();
    void setLoading(bool loading);

    mms::DonationService svc_;
    std::vector<mms::Donation> donations_;
    int currentPage_ = 1;
    int pageSize_ = 25;
    int totalCount_ = 0;
    int totalPages_ = 1;
    QString searchTerm_;
    QString categoryFilter_;
    QString dateFrom_;
    QString dateTo_;
    bool loading_ = false;
    DonationController* controller_ = nullptr;
};
