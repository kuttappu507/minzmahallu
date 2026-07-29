#pragma once
#include <QString>
#include <QMetaType>

namespace mms {

struct TokenAssignment {
    int     id           = 0;
    int     eventId      = 0;
    int     familyId     = 0;
    QString familyNumber;
    QString houseName;
    QString headName;
    QString ward;
    QString phone;
    QString uniqueCode;
    int     serialNumber = 0;
    bool    isCollected  = false;
    QString collectedAt;
    QString collectedBy;
    QString notes;
    QString createdAt;
};

} // namespace mms
Q_DECLARE_METATYPE(mms::TokenAssignment)
