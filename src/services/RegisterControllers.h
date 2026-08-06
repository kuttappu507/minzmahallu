/*
 * RegisterControllers.h — Combined controllers for Marriage, Death, Welfare
 * (kept in one file for compactness, same pattern as RegisterServices.h)
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include "RegisterServices.h"

class MarriageController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
public:
    explicit MarriageController(QObject* parent = nullptr) : QObject(parent) {}
    QString lastError() const { return lastError_; }

    Q_INVOKABLE QVariantMap create(const QVariantMap& data);
    Q_INVOKABLE QVariantMap update(qint64 id, const QVariantMap& data);
    Q_INVOKABLE QVariantMap remove(qint64 id);
    Q_INVOKABLE QVariantMap get(qint64 id);
    Q_INVOKABLE QString nextNumber();

signals:
    void lastErrorChanged();
    void created(qint64 id);
    void updated(qint64 id);
    void removed(qint64 id);
    void errorOccurred(const QString& message);

private:
    mms::MarriageService svc_;
    QString lastError_;
    void setLastError(const QString& err) { if (lastError_ != err) { lastError_ = err; emit lastErrorChanged(); } }
    static mms::Marriage mapToMarriage(const QVariantMap& d);
    static QVariantMap marriageToMap(const mms::Marriage& m);
};

class DeathController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
public:
    explicit DeathController(QObject* parent = nullptr) : QObject(parent) {}
    QString lastError() const { return lastError_; }

    Q_INVOKABLE QVariantMap create(const QVariantMap& data);
    Q_INVOKABLE QVariantMap update(qint64 id, const QVariantMap& data);
    Q_INVOKABLE QVariantMap remove(qint64 id);
    Q_INVOKABLE QVariantMap get(qint64 id);
    Q_INVOKABLE QString nextNumber();
    Q_INVOKABLE QVariantList activeFamilies();

signals:
    void lastErrorChanged();
    void created(qint64 id);
    void updated(qint64 id);
    void removed(qint64 id);
    void errorOccurred(const QString& message);

private:
    mms::DeathService svc_;
    QString lastError_;
    void setLastError(const QString& err) { if (lastError_ != err) { lastError_ = err; emit lastErrorChanged(); } }
    static mms::Death mapToDeath(const QVariantMap& d);
    static QVariantMap deathToMap(const mms::Death& d);
};

class WelfareController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
public:
    explicit WelfareController(QObject* parent = nullptr) : QObject(parent) {}
    QString lastError() const { return lastError_; }

    Q_INVOKABLE QVariantMap create(const QVariantMap& data);
    Q_INVOKABLE QVariantMap update(qint64 id, const QVariantMap& data);
    Q_INVOKABLE QVariantMap remove(qint64 id);
    Q_INVOKABLE QVariantMap approve(qint64 id, double amount, const QString& remarks);
    Q_INVOKABLE QVariantMap reject(qint64 id, const QString& remarks);
    Q_INVOKABLE QVariantMap disburse(qint64 id, const QString& date);
    Q_INVOKABLE QVariantMap get(qint64 id);
    Q_INVOKABLE QString nextNumber();
    Q_INVOKABLE QStringList categories() const;
    Q_INVOKABLE QVariantList activeFamilies();

signals:
    void lastErrorChanged();
    void created(qint64 id);
    void updated(qint64 id);
    void removed(qint64 id);
    void errorOccurred(const QString& message);

private:
    mms::WelfareService svc_;
    QString lastError_;
    void setLastError(const QString& err) { if (lastError_ != err) { lastError_ = err; emit lastErrorChanged(); } }
    static mms::WelfareRequest mapToWelfare(const QVariantMap& d);
    static QVariantMap welfareToMap(const mms::WelfareRequest& w);
};
