#pragma once
#include <QObject>
#include <QList>
#include "../models/TokenEvent.h"
#include "../models/TokenAssignment.h"

namespace mms {

class TokenService : public QObject {
    Q_OBJECT
public:
    explicit TokenService(QObject* parent = nullptr);

    struct TokenStats {
        int totalFamilies = 0;
        int collected = 0;
        int pending = 0;
        double percentage = 0.0;
    };

    // Event Management
    TokenEvent createEvent(const TokenEvent& event, QString* err = nullptr);
    bool updateEvent(const TokenEvent& event, QString* err = nullptr);
    bool deleteEvent(int eventId, QString* err = nullptr);
    QList<TokenEvent> listEvents(const QString& status = "");
    TokenEvent getEvent(int id);

    // Assignment Management
    bool generateTokens(int eventId, const QList<int>& familyIds, QString* err = nullptr);
    QList<TokenAssignment> getAssignments(int eventId);
    bool markCollected(int assignmentId, QString* err = nullptr);
    bool markUncollected(int assignmentId, QString* err = nullptr);

    // Statistics
    TokenStats getStats(int eventId);

    // Family Selection Helpers
    QList<TokenAssignment> getAllActiveFamilies();
    QList<TokenAssignment> getFamiliesByWard(const QString& ward);
    QStringList getWards();
};

} // namespace mms
