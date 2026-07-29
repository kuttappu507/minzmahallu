#include "TokenService.h"
#include "../repositories/TokenRepository.h"
#include "../repositories/FamilyRepository.h"
#include "../core/Database.h"
#include "../core/Logger.h"
#include "AuthSession.h"
#include <QSqlQuery>

namespace mms {

TokenService::TokenService(QObject* parent) : QObject(parent) {}

TokenEvent TokenService::createEvent(const TokenEvent& event, QString* err) {
    if (event.eventName.trimmed().isEmpty()) {
        if (err) *err = "Event name is required";
        return TokenEvent();
    }
    if (event.eventDate.isEmpty()) {
        if (err) *err = "Event date is required";
        return TokenEvent();
    }
    TokenRepository repo;
    TokenEvent e = event;
    e.createdBy = AuthSession::instance().user().id;
    if (!repo.createEvent(e, err)) return TokenEvent();
    Database::instance().execute("INSERT INTO audit_log (user_id, username, action, module, entity_id, description) VALUES (?, ?, ?, ?, ?, ?)", {AuthSession::instance().user().id, AuthSession::instance().user().username, "CREATE", "token", e.id, "Token event created: " + e.eventName});
    return e;
}

bool TokenService::updateEvent(const TokenEvent& event, QString* err) {
    TokenRepository repo;
    if (!repo.updateEvent(event, err)) return false;
    Database::instance().execute("INSERT INTO audit_log (user_id, username, action, module, entity_id, description) VALUES (?, ?, ?, ?, ?, ?)", {AuthSession::instance().user().id, AuthSession::instance().user().username, "EDIT", "token", event.id, "Token event updated: " + event.eventName});
    return true;
}

bool TokenService::deleteEvent(int eventId, QString* err) {
    TokenRepository repo;
    if (!repo.deleteEvent(eventId, err)) return false;
    Database::instance().execute("INSERT INTO audit_log (user_id, username, action, module, entity_id, description) VALUES (?, ?, ?, ?, ?, ?)", {AuthSession::instance().user().id, AuthSession::instance().user().username, "DELETE", "token", eventId, "Token event deleted: " + QString::number(eventId)});
    return true;
}

QList<TokenEvent> TokenService::listEvents(const QString& status) {
    TokenRepository repo;
    return repo.listEvents(status);
}

TokenEvent TokenService::getEvent(int id) {
    TokenRepository repo;
    return repo.findEventById(id);
}

bool TokenService::generateTokens(int eventId, const QList<int>& familyIds, QString* err) {
    TokenRepository repo;
    TokenEvent ev = repo.findEventById(eventId);
    if (ev.id == 0) {
        if (err) *err = "Event not found";
        return false;
    }
    if (ev.status != "Draft") {
        if (err) *err = "Tokens can only be generated for Draft events";
        return false;
    }
    if (familyIds.isEmpty()) {
        if (err) *err = "No families selected";
        return false;
    }
    if (!repo.createAssignments(eventId, familyIds, err)) return false;
    repo.updateEventStatus(eventId, "Active", err);
    Database::instance().execute("INSERT INTO audit_log (user_id, username, action, module, entity_id, description) VALUES (?, ?, ?, ?, ?, ?)", {AuthSession::instance().user().id, AuthSession::instance().user().username, "ADD", "token", eventId, QString("Generated %1 tokens for event: %2").arg(familyIds.size()).arg(ev.eventName)});
    return true;
}

QList<TokenAssignment> TokenService::getAssignments(int eventId) {
    TokenRepository repo;
    return repo.listAssignments(eventId);
}

bool TokenService::markCollected(int assignmentId, QString* err) {
    TokenRepository repo;
    QString username = AuthSession::instance().user().username;
    if (!repo.markCollected(assignmentId, username, err)) return false;
    return true;
}

bool TokenService::markUncollected(int assignmentId, QString* err) {
    TokenRepository repo;
    return repo.markUncollected(assignmentId, err);
}

TokenService::TokenStats TokenService::getStats(int eventId) {
    TokenRepository repo;
    TokenStats stats;
    stats.collected = repo.collectedCount(eventId);
    stats.pending = repo.pendingCount(eventId);
    stats.totalFamilies = stats.collected + stats.pending;
    if (stats.totalFamilies > 0)
        stats.percentage = (double)stats.collected / stats.totalFamilies * 100.0;
    return stats;
}

QList<TokenAssignment> TokenService::getAllActiveFamilies() {
    QList<TokenAssignment> result;
    QSqlQuery q = Database::instance().execute(
        "SELECT f.id, f.family_number, f.house_name, f.ward, f.phone, m.name as head_name "
        "FROM families f "
        "LEFT JOIN members m ON m.family_id = f.id AND m.relationship = 'Head' AND m.status = 'Active' "
        "WHERE f.status = 'Active' ORDER BY f.family_number");
    while (q.next()) {
        TokenAssignment a;
        a.familyId = q.value("id").toInt();
        a.familyNumber = q.value("family_number").toString();
        a.houseName = q.value("house_name").toString();
        a.ward = q.value("ward").toString();
        a.phone = q.value("phone").toString();
        a.headName = q.value("head_name").toString();
        result.append(a);
    }
    return result;
}

QStringList TokenService::getWards() {
    QStringList wards;
    QSqlQuery q = Database::instance().execute("SELECT DISTINCT ward FROM families WHERE ward != '' AND status = 'Active' ORDER BY ward");
    while (q.next()) wards.append(q.value(0).toString());
    return wards;
}

QList<TokenAssignment> TokenService::getFamiliesByWard(const QString& ward) {
    QList<TokenAssignment> result;
    QSqlQuery q = Database::instance().execute(
        "SELECT f.id, f.family_number, f.house_name, f.ward, f.phone, m.name as head_name "
        "FROM families f "
        "LEFT JOIN members m ON m.family_id = f.id AND m.relationship = 'Head' AND m.status = 'Active' "
        "WHERE f.status = 'Active' AND f.ward = ? ORDER BY f.family_number", {ward});
    while (q.next()) {
        TokenAssignment a;
        a.familyId = q.value("id").toInt();
        a.familyNumber = q.value("family_number").toString();
        a.houseName = q.value("house_name").toString();
        a.ward = q.value("ward").toString();
        a.phone = q.value("phone").toString();
        a.headName = q.value("head_name").toString();
        result.append(a);
    }
    return result;
}

} // namespace mms
