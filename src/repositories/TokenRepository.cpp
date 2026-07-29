#include "TokenRepository.h"
#include "../core/Database.h"
#include "../core/Logger.h"
#include <QRandomGenerator>
#include <QSet>
#include <QSqlQuery>
#include <QSqlError>

namespace mms {

bool TokenRepository::createEvent(TokenEvent& event, QString* err) {
    QString sql = "INSERT INTO token_events (event_name, event_type, event_date, event_time, venue, description, notes, status, total_families, created_by) "
                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    qint64 id = Database::instance().insert(sql, {
        event.eventName, event.eventType, event.eventDate, event.eventTime,
        event.venue, event.description, event.notes, event.status,
        event.totalFamilies, event.createdBy
    });
    if (id <= 0) {
        if (err) *err = Database::instance().lastError().text();
        return false;
    }
    event.id = (int)id;
    return true;
}

bool TokenRepository::updateEvent(const TokenEvent& event, QString* err) {
    QString sql = "UPDATE token_events SET event_name=?, event_type=?, event_date=?, event_time=?, venue=?, description=?, notes=?, status=?, total_families=? WHERE id=?";
    int n = Database::instance().update(sql, {
        event.eventName, event.eventType, event.eventDate, event.eventTime,
        event.venue, event.description, event.notes, event.status,
        event.totalFamilies, event.id
    });
    if (n <= 0 && err) *err = Database::instance().lastError().text();
    return n > 0;
}

bool TokenRepository::deleteEvent(int eventId, QString* err) {
    TokenEvent ev = findEventById(eventId);
    if (ev.status == "Active" || ev.status == "Completed") {
        if (err) *err = "Cannot delete an Active or Completed event";
        return false;
    }
    int n = Database::instance().update("DELETE FROM token_events WHERE id=?", {eventId});
    return n > 0;
}

QList<TokenEvent> TokenRepository::listEvents(const QString& status) {
    QList<TokenEvent> result;
    QString sql = "SELECT * FROM token_events";
    if (!status.isEmpty()) sql += " WHERE status = ?";
    sql += " ORDER BY event_date DESC, created_at DESC";
    QSqlQuery q = status.isEmpty() ? Database::instance().execute(sql)
                                   : Database::instance().execute(sql, {status});
    while (q.next()) {
        TokenEvent e;
        e.id = q.value("id").toInt();
        e.eventName = q.value("event_name").toString();
        e.eventType = q.value("event_type").toString();
        e.eventDate = q.value("event_date").toString();
        e.eventTime = q.value("event_time").toString();
        e.venue = q.value("venue").toString();
        e.description = q.value("description").toString();
        e.notes = q.value("notes").toString();
        e.status = q.value("status").toString();
        e.totalFamilies = q.value("total_families").toInt();
        e.createdBy = q.value("created_by").toInt();
        e.createdAt = q.value("created_at").toString();
        e.updatedAt = q.value("updated_at").toString();
        result.append(e);
    }
    return result;
}

TokenEvent TokenRepository::findEventById(int id) {
    QSqlQuery q = Database::instance().execute("SELECT * FROM token_events WHERE id=?", {id});
    TokenEvent e;
    if (q.next()) {
        e.id = q.value("id").toInt();
        e.eventName = q.value("event_name").toString();
        e.eventType = q.value("event_type").toString();
        e.eventDate = q.value("event_date").toString();
        e.eventTime = q.value("event_time").toString();
        e.venue = q.value("venue").toString();
        e.description = q.value("description").toString();
        e.notes = q.value("notes").toString();
        e.status = q.value("status").toString();
        e.totalFamilies = q.value("total_families").toInt();
        e.createdBy = q.value("created_by").toInt();
        e.createdAt = q.value("created_at").toString();
        e.updatedAt = q.value("updated_at").toString();
    }
    return e;
}

bool TokenRepository::updateEventStatus(int eventId, const QString& status, QString* err) {
    int n = Database::instance().update("UPDATE token_events SET status=? WHERE id=?", {status, eventId});
    if (n <= 0 && err) *err = Database::instance().lastError().text();
    return n > 0;
}

bool TokenRepository::createAssignments(int eventId, const QList<int>& familyIds, QString* err) {
    // Generate unique 4-digit codes (1000-9999) with collision avoidance
    QSet<int> usedCodes;
    // First load existing codes for this event
    QSqlQuery existingQ = Database::instance().execute(
        "SELECT unique_code FROM token_assignments WHERE event_id=?", {eventId});
    while (existingQ.next()) {
        usedCodes.insert(existingQ.value(0).toString().toInt());
    }

    Database::instance().beginTransaction();
    int serial = 1;
    for (int familyId : familyIds) {
        // Generate unique code
        int code;
        int attempts = 0;
        do {
            code = QRandomGenerator::global()->bounded(1000, 10000);
            attempts++;
            if (attempts > 10000) {
                if (err) *err = "Could not generate unique code after 10000 attempts";
                Database::instance().rollbackTransaction();
                return false;
            }
        } while (usedCodes.contains(code));
        usedCodes.insert(code);

        QString codeStr = QString("%1").arg(code, 4, 10, QChar('0'));
        qint64 id = Database::instance().insert(
            "INSERT INTO token_assignments (event_id, family_id, unique_code, serial_number) VALUES (?, ?, ?, ?)",
            {eventId, familyId, codeStr, serial});
        if (id <= 0) {
            if (err) *err = Database::instance().lastError().text();
            Database::instance().rollbackTransaction();
            return false;
        }
        serial++;
    }
    // Update total_families
    Database::instance().update("UPDATE token_events SET total_families=? WHERE id=?",
                                {familyIds.size(), eventId});
    Database::instance().commitTransaction();
    return true;
}

QList<TokenAssignment> TokenRepository::listAssignments(int eventId) {
    QList<TokenAssignment> result;
    QString sql = "SELECT ta.*, f.family_number, f.house_name, f.ward, f.phone, m.name as head_name "
                  "FROM token_assignments ta "
                  "JOIN families f ON f.id = ta.family_id "
                  "LEFT JOIN members m ON m.family_id = ta.family_id AND m.relationship = 'Head' AND m.status = 'Active' "
                  "WHERE ta.event_id = ? ORDER BY ta.serial_number ASC";
    QSqlQuery q = Database::instance().execute(sql, {eventId});
    while (q.next()) {
        TokenAssignment a;
        a.id = q.value("id").toInt();
        a.eventId = q.value("event_id").toInt();
        a.familyId = q.value("family_id").toInt();
        a.familyNumber = q.value("family_number").toString();
        a.houseName = q.value("house_name").toString();
        a.headName = q.value("head_name").toString();
        a.ward = q.value("ward").toString();
        a.phone = q.value("phone").toString();
        a.uniqueCode = q.value("unique_code").toString();
        a.serialNumber = q.value("serial_number").toInt();
        a.isCollected = q.value("is_collected").toInt() == 1;
        a.collectedAt = q.value("collected_at").toString();
        a.collectedBy = q.value("collected_by").toString();
        a.notes = q.value("notes").toString();
        a.createdAt = q.value("created_at").toString();
        result.append(a);
    }
    return result;
}

bool TokenRepository::markCollected(int assignmentId, const QString& collectedBy, QString* err) {
    int n = Database::instance().update(
        "UPDATE token_assignments SET is_collected=1, collected_at=datetime('now','localtime'), collected_by=? WHERE id=?",
        {collectedBy, assignmentId});
    return n > 0;
}

bool TokenRepository::markUncollected(int assignmentId, QString* err) {
    int n = Database::instance().update(
        "UPDATE token_assignments SET is_collected=0, collected_at=NULL, collected_by=NULL WHERE id=?",
        {assignmentId});
    return n > 0;
}

int TokenRepository::collectedCount(int eventId) {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM token_assignments WHERE event_id=? AND is_collected=1", {eventId});
    return v.toInt();
}

int TokenRepository::pendingCount(int eventId) {
    QVariant v = Database::instance().scalar(
        "SELECT COUNT(*) FROM token_assignments WHERE event_id=? AND is_collected=0", {eventId});
    return v.toInt();
}

bool TokenRepository::logPrint(int eventId, const QString& printType, int pageCount, int userId) {
    qint64 id = Database::instance().insert(
        "INSERT INTO token_print_log (event_id, print_type, printed_by, page_count) VALUES (?, ?, ?, ?)",
        {eventId, printType, userId, pageCount});
    return id > 0;
}

TokenAssignment TokenRepository::findByCode(int eventId, const QString& code) {
    QSqlQuery q = Database::instance().execute(
        "SELECT ta.*, f.family_number, f.house_name, f.ward, f.phone, m.name as head_name "
        "FROM token_assignments ta "
        "JOIN families f ON f.id = ta.family_id "
        "LEFT JOIN members m ON m.family_id = ta.family_id AND m.relationship = 'Head' AND m.status = 'Active' "
        "WHERE ta.event_id=? AND ta.unique_code=?", {eventId, code});
    TokenAssignment a;
    if (q.next()) {
        a.id = q.value("id").toInt();
        a.eventId = q.value("event_id").toInt();
        a.familyId = q.value("family_id").toInt();
        a.familyNumber = q.value("family_number").toString();
        a.houseName = q.value("house_name").toString();
        a.headName = q.value("head_name").toString();
        a.ward = q.value("ward").toString();
        a.phone = q.value("phone").toString();
        a.uniqueCode = q.value("unique_code").toString();
        a.serialNumber = q.value("serial_number").toInt();
        a.isCollected = q.value("is_collected").toInt() == 1;
        a.collectedAt = q.value("collected_at").toString();
        a.collectedBy = q.value("collected_by").toString();
    }
    return a;
}

} // namespace mms
