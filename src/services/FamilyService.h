/*
 * FamilyService.h
 */
#pragma once

#include "../models/Family.h"
#include <vector>
#include <QString>

namespace mms {

class FamilyService {
public:
    // Create family with auto-generated family number if empty.
    // Validates required fields. Returns new id or -1; sets errorMsg.
    qint64 createFamily(Family& f, QString* errorMsg = nullptr);

    bool updateFamily(const Family& f, QString* errorMsg = nullptr);
    bool archiveFamily(qint64 id);
    bool restoreFamily(qint64 id);
    bool deleteFamily(qint64 id, QString* errorMsg = nullptr);  // hard delete if no members

    std::vector<Family> searchFamilies(const QString& term, int page = 1, int pageSize = 50,
                                       const QString& statusFilter = QString(),
                                       const QString& wardFilter = QString(),
                                       int* totalOut = nullptr);

    Family getFamily(qint64 id);          // throws std::runtime_error if not found
    int totalFamilies();
    int activeFamilies();
    QStringList wards();
};

} // namespace mms
