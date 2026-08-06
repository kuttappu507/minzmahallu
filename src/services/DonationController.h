/*
 * DonationController.h — QML-facing controller for Donations module.
 * Thin wrapper around existing DonationService. Same pattern as FamilyController.
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include <QStringList>
#include "DonationService.h"

class DonationController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    Q_PROPERTY(int summaryRevision READ summaryRevision NOTIFY summaryRevisionChanged)

public:
    explicit DonationController(QObject* parent = nullptr);

    QString lastError() const { return lastError_; }
    int summaryRevision() const { return summaryRevision_; }

    Q_INVOKABLE QVariantMap create(const QVariantMap& data);
    Q_INVOKABLE QVariantMap update(qint64 id, const QVariantMap& data);
    Q_INVOKABLE QVariantMap remove(qint64 id);

    Q_INVOKABLE QVariantMap get(qint64 id);
    Q_INVOKABLE QVariantList categories();
    Q_INVOKABLE QString nextReceiptNumber();
    Q_INVOKABLE double totalDonations(const QString& from, const QString& to);

signals:
    void lastErrorChanged();
    void created(qint64 id);
    void updated(qint64 id);
    void removed(qint64 id);
    void errorOccurred(const QString& message);
    void summaryRevisionChanged();

private:
    mms::DonationService svc_;
    QString lastError_;
    int summaryRevision_ = 0;
    void bumpSummary() { ++summaryRevision_; emit summaryRevisionChanged(); }

    void setLastError(const QString& err);
    static mms::Donation mapToDonation(const QVariantMap& d);
    static QVariantMap donationToMap(const mms::Donation& d);
    static QString guessField(const QString& error);
};
