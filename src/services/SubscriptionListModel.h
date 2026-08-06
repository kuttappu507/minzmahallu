/*
 * SubscriptionListModel.h — QAbstractListModel for Subscriptions list view.
 * Same pattern as FamilyListModel.
 */
#pragma once

#include <QAbstractListModel>
#include <QString>
#include "SubscriptionService.h"

class SubscriptionController;

class SubscriptionListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
    Q_PROPERTY(int pageSize READ pageSize WRITE setPageSize NOTIFY pageSizeChanged)
    Q_PROPERTY(int totalPages READ totalPages NOTIFY totalPagesChanged)
    Q_PROPERTY(int totalCount READ totalCount NOTIFY totalCountChanged)
    Q_PROPERTY(int rowCount READ rowCountInt NOTIFY totalCountChanged)
    Q_PROPERTY(QString statusFilter READ statusFilter WRITE setStatusFilter NOTIFY statusFilterChanged)
    Q_PROPERTY(QString dateFrom READ dateFrom WRITE setDateFrom NOTIFY dateFromChanged)
    Q_PROPERTY(QString dateTo READ dateTo WRITE setDateTo NOTIFY dateToChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        ReceiptNumberRole,
        FamilyNumberRole,
        MemberNameRole,
        PlanNameRole,
        AmountRole,
        AmountPaidRole,
        PeriodStartRole,
        PeriodEndRole,
        PaymentDateRole,
        PaymentMethodRole,
        StatusRole,
        RemarksRole,
        FamilyIdRole,
        MemberIdRole,
        PlanIdRole
    };
    Q_ENUM(Roles)

    explicit SubscriptionListModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int currentPage() const { return currentPage_; }
    int pageSize() const { return pageSize_; }
    int totalPages() const { return totalPages_; }
    int totalCount() const { return totalCount_; }
    int rowCountInt() const { return static_cast<int>(subs_.size()); }
    QString statusFilter() const { return statusFilter_; }
    QString dateFrom() const { return dateFrom_; }
    QString dateTo() const { return dateTo_; }
    bool loading() const { return loading_; }

    void setCurrentPage(int page);
    void setPageSize(int size);
    void setStatusFilter(const QString& filter);
    void setDateFrom(const QString& d);
    void setDateTo(const QString& d);

    Q_INVOKABLE void refresh();
    Q_INVOKABLE QVariantMap get(int index) const;

    void setController(SubscriptionController* controller);

signals:
    void currentPageChanged();
    void pageSizeChanged();
    void totalPagesChanged();
    void totalCountChanged();
    void statusFilterChanged();
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

    mms::SubscriptionService svc_;
    std::vector<mms::Subscription> subs_;
    int currentPage_ = 1;
    int pageSize_ = 25;
    int totalCount_ = 0;
    int totalPages_ = 1;
    QString statusFilter_;
    QString dateFrom_;
    QString dateTo_;
    bool loading_ = false;
    SubscriptionController* controller_ = nullptr;
};
