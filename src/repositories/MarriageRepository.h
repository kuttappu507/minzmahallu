/*
 * MarriageRepository.h
 */
#pragma once

#include "../models/Marriage.h"
#include <vector>
#include <optional>
#include <QString>

namespace mms {

class MarriageRepository {
public:
    std::optional<Marriage> findById(qint64 id);
    std::optional<Marriage> findByNumber(const QString& num);

    std::vector<Marriage> list(int page = 1, int pageSize = 50,
                               const QString& searchTerm = QString(),
                               const QString& dateFrom = QString(),
                               const QString& dateTo = QString(),
                               int* totalOut = nullptr);

    QString generateNextNumber();
    qint64 create(const Marriage& m);
    bool update(const Marriage& m);
    bool remove(qint64 id);

    int countThisYear();
    int countByYear(int year);
};

} // namespace mms
