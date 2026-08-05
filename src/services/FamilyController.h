/*
 * FamilyController.h — QML-facing controller for the Families module.
 *
 * Thin wrapper around the existing FamilyService. Does NOT duplicate any
 * business logic — all validation, auto-numbering, audit logging, etc.
 * stays in FamilyService / FamilyRepository.
 *
 * Registered as a QML context property "FamilyController" in app_main.cpp.
 *
 * Design:
 *   - create/update/delete return QVariantMap (not bare qint64/bool) so QML
 *     can check {success, id, error, field} in one call.
 *   - Emits created(qint64)/updated(qint64)/deleted(qint64) signals that
 *     FamilyListModel listens to for real-time refresh.
 *   - Q_PROPERTY lastError + databaseReady for QML binding.
 *   - Q_INVOKABLE getWards() / nextFamilyNumber() / get(id) for dialogs.
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include <QStringList>
#include "FamilyService.h"

class FamilyController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    Q_PROPERTY(bool databaseReady READ databaseReady NOTIFY databaseReadyChanged)

public:
    explicit FamilyController(QObject* parent = nullptr);

    QString lastError() const { return lastError_; }
    bool databaseReady() const { return databaseReady_; }

    // ===== CRUD — all return QVariantMap with keys: success, id, error, field =====

    // Create a new family. data keys (camelCase): familyNumber, houseName,
    // houseNumber, ward, area, address, pincode, phone, alternativePhone,
    // status, notes.
    // Returns: { success: bool, id: qint64 (>0 on success), error: QString, field: QString }
    Q_INVOKABLE QVariantMap create(const QVariantMap& data);

    // Update an existing family. Same data keys as create. id is the family id.
    // Returns: { success: bool, error: QString, field: QString }
    Q_INVOKABLE QVariantMap update(qint64 id, const QVariantMap& data);

    // Hard-delete a family (fails if it still has members).
    // Returns: { success: bool, error: QString }
    Q_INVOKABLE QVariantMap remove(qint64 id);

    // Archive (soft delete) a family.
    Q_INVOKABLE QVariantMap archive(qint64 id);

    // Restore an archived family.
    Q_INVOKABLE QVariantMap restore(qint64 id);

    // ===== Read helpers for dialogs =====

    // Get a single family as QVariantMap (camelCase keys). Empty map on failure.
    Q_INVOKABLE QVariantMap get(qint64 id);

    // Get members of a family (for view detail).
    Q_INVOKABLE QVariantList getMembers(qint64 familyId);

    // Get distinct wards from the database (for filter combo).
    Q_INVOKABLE QStringList wards();

    // Preview the next family number that would be auto-generated.
    Q_INVOKABLE QString nextFamilyNumber();

signals:
    void lastErrorChanged();
    void databaseReadyChanged();

    // Real-time change signals — FamilyListModel listens to these.
    void created(qint64 id);
    void updated(qint64 id);
    void archived(qint64 id);
    void restored(qint64 id);
    void removed(qint64 id);

    // General error signal for toasts/banners.
    void errorOccurred(const QString& message);

private:
    mms::FamilyService svc_;
    QString lastError_;
    bool databaseReady_ = false;

    void setLastError(const QString& err);
    void setDatabaseReady(bool ready);

    // Convert QVariantMap (camelCase, from QML) → Family struct (for service calls)
    static mms::Family mapToFamily(const QVariantMap& d);

    // Convert Family struct → QVariantMap (camelCase, for QML consumption)
    static QVariantMap familyToMap(const mms::Family& f);

    // Guess which form field the error relates to (for QML highlighting)
    static QString guessField(const QString& error);
};
