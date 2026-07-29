#pragma once
#include <QString>
#include <QMetaType>

namespace mms {

struct TokenEvent {
    int     id          = 0;
    QString eventName;
    QString eventType   = "Meat Distribution";
    QString eventDate;
    QString eventTime;
    QString venue;
    QString description;
    QString notes;
    QString status      = "Draft";
    int     totalFamilies = 0;
    int     createdBy   = 0;
    QString createdAt;
    QString updatedAt;
};

} // namespace mms
Q_DECLARE_METATYPE(mms::TokenEvent)
