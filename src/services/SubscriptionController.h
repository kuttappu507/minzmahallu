/*
 * SubscriptionController.h — QML-facing controller for Subscriptions module.
 * Thin wrapper around existing SubscriptionService. Same pattern as FamilyController.
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include <QStringList>
#include "SubscriptionService.h"

class SubscriptionController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit SubscriptionController(QObject* parent = nullptr);

    QString lastError() const { return lastError_; }

    Q_INVOKABLE QVariantMap create(const QVariantMap& data);
    Q_INVOKABLE QVariantMap update(qint64 id, const QVariantMap& data);
    Q_INVOKABLE QVariantMap remove(qint64 id);
    Q_INVOKABLE int markOverdue();

    Q_INVOKABLE QVariantMap get(qint64 id);
    Q_INVOKABLE QVariantList plans();
    Q_INVOKABLE QVariantList activeFamilies();
    Q_INVOKABLE QVariantList familyMembers(qint64 familyId);
    Q_INVOKABLE QString nextReceiptNumber();
    Q_INVOKABLE double totalCollected(const QString& from, const QString& to);
    Q_INVOKABLE double totalPending();

signals:
    void lastErrorChanged();
    void created(qint64 id);
    void updated(qint64 id);
    void removed(qint64 id);
    void errorOccurred(const QString& message);

private:
    mms::SubscriptionService svc_;
    QString lastError_;

    void setLastError(const QString& err);
    static mms::Subscription mapToSubscription(const QVariantMap& d);
    static QVariantMap subscriptionToMap(const mms::Subscription& s);
    static QString guessField(const QString& error);
};
