/*
 * DonationRepository.h
 */
#pragma once

#include "../models/Donation.h"
#include <vector>
#include <optional>
#include <QString>

namespace mms {

class DonationRepository {
public:
    std::optional<Donation> findById(qint64 id);
    std::optional<Donation> findByReceipt(const QString& receipt);

    std::vector<DonationCategory> listCategories();
    std::optional<DonationCategory> findCategory(qint64 id);

    std::vector<Donation> list(int page = 1, int pageSize = 50,
                               const QString& dateFrom = QString(),
                               const QString& dateTo = QString(),
                               qint64 categoryId = 0,
                               const QString& searchTerm = QString(),
                               int* totalOut = nullptr);

    QString generateReceiptNumber();

    qint64 create(const Donation& d);
    bool update(const Donation& d);
    bool remove(qint64 id);

    double totalDonations(const QString& dateFrom, const QString& dateTo);
    double totalByCategory(qint64 categoryId, const QString& dateFrom, const QString& dateTo);

    // Per-donor history
    std::vector<Donation> donorHistory(const QString& donorName);
};

} // namespace mms
