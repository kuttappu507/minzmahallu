/*
 * AccountingController.h — QML-facing controller for Accounting module.
 * Thin wrapper around existing AccountingService.
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include "AccountingService.h"

class AccountingController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit AccountingController(QObject* parent = nullptr);
    QString lastError() const { return lastError_; }

    Q_INVOKABLE QVariantMap create(const QVariantMap& data);
    Q_INVOKABLE QVariantMap update(qint64 id, const QVariantMap& data);
    Q_INVOKABLE QVariantMap remove(qint64 id);

    Q_INVOKABLE QVariantMap get(qint64 id);
    Q_INVOKABLE QVariantList accounts(const QString& typeFilter = QString());
    Q_INVOKABLE double totalIncome(const QString& from, const QString& to);
    Q_INVOKABLE double totalExpense(const QString& from, const QString& to);
    Q_INVOKABLE double balance(const QString& from, const QString& to);

signals:
    void lastErrorChanged();
    void created(qint64 id);
    void updated(qint64 id);
    void removed(qint64 id);
    void errorOccurred(const QString& message);

private:
    mms::AccountingService svc_;
    QString lastError_;
    void setLastError(const QString& err);
    static mms::Transaction mapToTransaction(const QVariantMap& d);
    static QVariantMap transactionToMap(const mms::Transaction& t);
    static QString guessField(const QString& error);
};
