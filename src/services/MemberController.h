/*
 * MemberController.h — QML-facing controller for the Members module.
 *
 * Thin wrapper around the existing MemberService. Does NOT duplicate any
 * business logic — all validation, auto-numbering, audit logging, etc.
 * stays in MemberService / MemberRepository.
 *
 * Same pattern as FamilyController.
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include <QStringList>
#include "MemberService.h"

class MemberController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit MemberController(QObject* parent = nullptr);

    QString lastError() const { return lastError_; }

    // ===== CRUD — all return QVariantMap { success, id, error, field } =====
    Q_INVOKABLE QVariantMap create(const QVariantMap& data);
    Q_INVOKABLE QVariantMap update(qint64 id, const QVariantMap& data);
    Q_INVOKABLE QVariantMap remove(qint64 id);

    // ===== Read helpers =====
    Q_INVOKABLE QVariantMap get(qint64 id);
    Q_INVOKABLE QVariantList getFamilyMembers(qint64 familyId);
    Q_INVOKABLE QStringList relationships() const;
    Q_INVOKABLE QString nextMemberCode();

    // ===== Family combo data — list of {id, familyNumber, houseName} for the form =====
    Q_INVOKABLE QVariantList activeFamilies();

signals:
    void lastErrorChanged();
    void created(qint64 id);
    void updated(qint64 id);
    void removed(qint64 id);
    void errorOccurred(const QString& message);

private:
    mms::MemberService svc_;
    QString lastError_;

    void setLastError(const QString& err);
    static mms::Member mapToMember(const QVariantMap& d);
    static QVariantMap memberToMap(const mms::Member& m);
    static QString guessField(const QString& error);
};
