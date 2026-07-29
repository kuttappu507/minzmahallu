/*
 * DonationService.cpp
 */
#include "DonationService.h"
#include "../repositories/DonationRepository.h"
#include "../repositories/AuditLogRepository.h"
#include "AuthSession.h"
#include <QDate>

namespace mms {

qint64 DonationService::createDonation(Donation& d, QString* errorMsg) {
    if (d.donorName.trimmed().isEmpty()) {
        if (errorMsg) *errorMsg = "Donor name is required.";
        return -1;
    }
    if (d.amount <= 0) {
        if (errorMsg) *errorMsg = "Amount must be greater than zero.";
        return -1;
    }
    if (d.categoryId <= 0) {
        if (errorMsg) *errorMsg = "Donation category is required.";
        return -1;
    }
    if (d.donationDate.isEmpty()) d.donationDate = QDate::currentDate().toString(Qt::ISODate);
    if (d.receiptNumber.isEmpty()) d.receiptNumber = nextReceiptNumber();
    if (d.receivedBy <= 0) d.receivedBy = AuthSession::instance().user().id;

    DonationRepository repo;
    qint64 id = repo.create(d);
    if (id > 0) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "ADD", "donation", id,
                  QString("Recorded donation %1 (₹%2 from %3)").arg(d.receiptNumber).arg(d.amount).arg(d.donorName), "");
    }
    return id;
}

bool DonationService::updateDonation(const Donation& d, QString* errorMsg) {
    DonationRepository repo;
    if (!repo.findById(d.id)) {
        if (errorMsg) *errorMsg = "Donation not found.";
        return false;
    }
    bool ok = repo.update(d);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "EDIT", "donation", d.id,
                  QString("Updated donation %1").arg(d.receiptNumber), "");
    }
    return ok;
}

bool DonationService::deleteDonation(qint64 id) {
    DonationRepository repo;
    auto d = repo.findById(id);
    bool ok = repo.remove(id);
    if (ok && d) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "DELETE", "donation", id,
                  QString("Deleted donation %1").arg(d->receiptNumber), "");
    }
    return ok;
}

std::vector<Donation> DonationService::list(int page, int pageSize,
                                            const QString& dateFrom,
                                            const QString& dateTo,
                                            qint64 categoryId,
                                            const QString& searchTerm,
                                            int* totalOut) {
    DonationRepository repo;
    return repo.list(page, pageSize, dateFrom, dateTo, categoryId, searchTerm, totalOut);
}

std::vector<DonationCategory> DonationService::categories() {
    DonationRepository repo;
    return repo.listCategories();
}

std::vector<Donation> DonationService::donorHistory(const QString& name) {
    DonationRepository repo;
    return repo.donorHistory(name);
}

double DonationService::totalDonations(const QString& from, const QString& to) {
    DonationRepository repo;
    return repo.totalDonations(from, to);
}

QString DonationService::nextReceiptNumber() {
    DonationRepository repo;
    return repo.generateReceiptNumber();
}

} // namespace mms
