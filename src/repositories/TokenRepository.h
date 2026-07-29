#pragma once
#include <QString>
#include <QList>
#include "../models/TokenEvent.h"
#include "../models/TokenAssignment.h"

namespace mms {

class TokenRepository {
public:
    // Event CRUD
    bool createEvent(TokenEvent& event, QString* err = nullptr);
    bool updateEvent(const TokenEvent& event, QString* err = nullptr);
    bool deleteEvent(int eventId, QString* err = nullptr);
    QList<TokenEvent> listEvents(const QString& status = "");
    TokenEvent findEventById(int id);
    bool updateEventStatus(int eventId, const QString& status, QString* err = nullptr);

    // Assignment CRUD
    bool createAssignments(int eventId, const QList<int>& familyIds, QString* err = nullptr);
    QList<TokenAssignment> listAssignments(int eventId);
    bool markCollected(int assignmentId, const QString& collectedBy, QString* err = nullptr);
    bool markUncollected(int assignmentId, QString* err = nullptr);
    int collectedCount(int eventId);
    int pendingCount(int eventId);
    bool logPrint(int eventId, const QString& printType, int pageCount, int userId);
    TokenAssignment findByCode(int eventId, const QString& code);
};

} // namespace mms
