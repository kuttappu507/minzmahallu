/*
 * FamilyRepository.h
 */
#pragma once

#include "../models/Family.h"
#include <vector>
#include <optional>
#include <QString>

namespace mms {

class FamilyRepository {
public:
    std::optional<Family> findById(qint64 id);
    std::optional<Family> findByNumber(const QString& familyNumber);

    // Paginated list with optional search term and status filter.
    // page is 1-based; pageSize rows per page. Returns rows + total count.
    std::vector<Family> list(int page = 1, int pageSize = 50,
                             const QString& searchTerm = QString(),
                             const QString& statusFilter = QString(),
                             const QString& wardFilter = QString(),
                             int* totalOut = nullptr);

    // Full list (no pagination) - for exports/reports
    std::vector<Family> listAll(const QString& statusFilter = QString());

    // Total count
    int count();

    // Generate next family number in format FAM-NNNN
    QString generateNextFamilyNumber();

    // CRUD
    qint64 create(const Family& f);
    bool update(const Family& f);
    bool remove(qint64 id);             // soft delete (set status='Archived')
    bool hardDelete(qint64 id);         // actual delete (use with care)
    bool archive(qint64 id);
    bool restore(qint64 id);

    // Stats
    int countByStatus(const QString& status);
    int countByWard(const QString& ward);

    // Get list of distinct wards
    QStringList listWards();
};

} // namespace mms
