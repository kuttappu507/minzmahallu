/*
 * DeathRepository.h
 */
#pragma once

#include "../models/Death.h"
#include <vector>
#include <optional>
#include <QString>

namespace mms {

class DeathRepository {
public:
    std::optional<Death> findById(qint64 id);
    std::optional<Death> findByNumber(const QString& num);

    std::vector<Death> list(int page = 1, int pageSize = 50,
                            const QString& searchTerm = QString(),
                            const QString& dateFrom = QString(),
                            const QString& dateTo = QString(),
                            int* totalOut = nullptr);

    QString generateNextNumber();
    qint64 create(const Death& d);
    bool update(const Death& d);
    bool remove(qint64 id);

    int countThisYear();
    int countByYear(int year);
};

} // namespace mms
