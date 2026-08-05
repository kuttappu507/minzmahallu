/*
 * QmlServices.h — C++ facade exposing MMS backend services to QML
 *
 * Registered as context property "Services" in main.cpp.
 * QML calls: Services.searchFamilies(...), Services.createFamily({...}), etc.
 * All methods return QVariantList/QVariantMap (QML-friendly types).
 */
#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QStringList>

namespace mms {
    class FamilyService;
    struct Family;
}

class QmlServices : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    Q_PROPERTY(QStringList wards READ wards CONSTANT)
    Q_PROPERTY(int totalFamilies READ totalFamilies NOTIFY dataChanged)

public:
    explicit QmlServices(QObject* parent = nullptr);
    ~QmlServices();

    QString lastError() const { return lastError_; }
    QStringList wards() const;
    int totalFamilies() const;

    // ===== Families =====
    Q_INVOKABLE QVariantList searchFamilies(const QString& term, int page, int pageSize,
                                             const QString& statusFilter, const QString& wardFilter);
    Q_INVOKABLE QVariantMap getFamily(qint64 id);
    Q_INVOKABLE QVariantList getFamilyMembers(qint64 familyId);
    Q_INVOKABLE qint64 createFamily(const QVariantMap& data);
    Q_INVOKABLE bool updateFamily(qint64 id, const QVariantMap& data);
    Q_INVOKABLE bool deleteFamily(qint64 id);
    Q_INVOKABLE bool archiveFamily(qint64 id);
    Q_INVOKABLE bool restoreFamily(qint64 id);

signals:
    void lastErrorChanged();
    void dataChanged();

private:
    mms::FamilyService* familySvc_;
    QString lastError_;
};
