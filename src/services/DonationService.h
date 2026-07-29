/*
 * DonationService.h
 */
#pragma once

#include "../models/Donation.h"
#include <vector>
#include <QString>

namespace mms {

class DonationService {
public:
    qint64 createDonation(Donation& d, QString* errorMsg = nullptr);
    bool updateDonation(const Donation& d, QString* errorMsg = nullptr);
    bool deleteDonation(qint64 id);

    std::vector<Donation> list(int page = 1, int pageSize = 50,
                               const QString& dateFrom = QString(),
                               const QString& dateTo = QString(),
                               qint64 categoryId = 0,
                               const QString& searchTerm = QString(),
                               int* totalOut = nullptr);

    std::vector<DonationCategory> categories();
    std::vector<Donation> donorHistory(const QString& name);

    double totalDonations(const QString& from, const QString& to);
    QString nextReceiptNumber();
};

} // namespace mms
