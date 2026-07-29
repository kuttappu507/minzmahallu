/*
 * AuditLog.h - Audit log model
 */
#pragma once

#include <QString>
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlRecord>

namespace mms {

struct AuditLog {
    qint64 id = 0;
    qint64 userId = 0;
    QString username;
    QString action;        // LOGIN, LOGOUT, ADD, EDIT, DELETE, PRINT, EXPORT, BACKUP, RESTORE
    QString module;
    qint64 entityId = 0;
    QString description;
    QString ipAddress;
    QDateTime createdAt;

    static AuditLog fromQuery(const QSqlQuery& q) {
        AuditLog a;
        a.id = q.value("id").toLongLong();
        a.userId = q.value("user_id").toLongLong();
        a.username = q.value("username").toString();
        a.action = q.value("action").toString();
        a.module = q.value("module").toString();
        a.entityId = q.value("entity_id").toLongLong();
        a.description = q.value("description").toString();
        a.ipAddress = q.value("ip_address").toString();
        a.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);
        return a;
    }
};

struct Certificate {
    qint64 id = 0;
    QString certificateNumber;
    QString type;        // Membership, Residence, Marriage, Death, Character, Income
    qint64 memberId = 0;
    qint64 familyId = 0;
    qint64 marriageId = 0;
    qint64 deathId = 0;
    QString issuedTo;
    QString issuedDate;
    qint64 issuedBy = 0;
    QString qrPayload;
    QString notes;
    QDateTime createdAt;

    // Joined
    QString issuedByName;

    static Certificate fromQuery(const QSqlQuery& q) {
        Certificate c;
        c.id = q.value("id").toLongLong();
        c.certificateNumber = q.value("certificate_number").toString();
        c.type = q.value("type").toString();
        c.memberId = q.value("member_id").toLongLong();
        c.familyId = q.value("family_id").toLongLong();
        c.marriageId = q.value("marriage_id").toLongLong();
        c.deathId = q.value("death_id").toLongLong();
        c.issuedTo = q.value("issued_to").toString();
        c.issuedDate = q.value("issued_date").toString();
        c.issuedBy = q.value("issued_by").toLongLong();
        c.qrPayload = q.value("qr_payload").toString();
        c.notes = q.value("notes").toString();
        c.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);

        int idx = q.record().indexOf("issued_by_name");
        if (idx >= 0) c.issuedByName = q.value(idx).toString();
        return c;
    }
};

struct Document {
    qint64 id = 0;
    QString linkedModule;
    qint64 linkedId = 0;
    QString fileName;
    QString filePath;
    QString fileType;
    qint64 fileSize = 0;
    qint64 uploadedBy = 0;
    QDateTime uploadedAt;

    static Document fromQuery(const QSqlQuery& q) {
        Document d;
        d.id = q.value("id").toLongLong();
        d.linkedModule = q.value("linked_module").toString();
        d.linkedId = q.value("linked_id").toLongLong();
        d.fileName = q.value("file_name").toString();
        d.filePath = q.value("file_path").toString();
        d.fileType = q.value("file_type").toString();
        d.fileSize = q.value("file_size").toLongLong();
        d.uploadedBy = q.value("uploaded_by").toLongLong();
        d.uploadedAt = QDateTime::fromString(q.value("uploaded_at").toString(), Qt::ISODate);
        return d;
    }
};

} // namespace mms
