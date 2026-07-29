/*
 * RegisterServices.cpp - Implementations for Marriage, Death, Welfare services
 */
#include "RegisterServices.h"
#include "../repositories/MarriageRepository.h"
#include "../repositories/DeathRepository.h"
#include "../repositories/WelfareRepository.h"
#include "../repositories/AuditLogRepository.h"
#include "AuthSession.h"
#include <QDate>
#include <stdexcept>

namespace mms {

// ===========================================================================
// MarriageService
// ===========================================================================
qint64 MarriageService::createMarriage(Marriage& m, QString* errorMsg) {
    if (m.brideName.trimmed().isEmpty()) { if (errorMsg) *errorMsg = "Bride name is required."; return -1; }
    if (m.groomName.trimmed().isEmpty()) { if (errorMsg) *errorMsg = "Groom name is required."; return -1; }
    if (m.nikahDate.isEmpty())            { if (errorMsg) *errorMsg = "Nikah date is required."; return -1; }
    if (m.registrationDate.isEmpty()) m.registrationDate = QDate::currentDate().toString(Qt::ISODate);
    if (m.marriageNumber.isEmpty()) m.marriageNumber = nextMarriageNumber();

    MarriageRepository repo;
    qint64 id = repo.create(m);
    if (id > 0) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "ADD", "marriage", id,
                  QString("Registered marriage %1 (%2 x %3)").arg(m.marriageNumber).arg(m.brideName).arg(m.groomName), "");
    }
    return id;
}

bool MarriageService::updateMarriage(const Marriage& m, QString* errorMsg) {
    MarriageRepository repo;
    if (!repo.findById(m.id)) { if (errorMsg) *errorMsg = "Marriage record not found."; return false; }
    bool ok = repo.update(m);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "EDIT", "marriage", m.id,
                  QString("Updated marriage %1").arg(m.marriageNumber), "");
    }
    return ok;
}

bool MarriageService::deleteMarriage(qint64 id) {
    MarriageRepository repo;
    auto m = repo.findById(id);
    bool ok = repo.remove(id);
    if (ok && m) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "DELETE", "marriage", id,
                  QString("Deleted marriage %1").arg(m->marriageNumber), "");
    }
    return ok;
}

std::vector<Marriage> MarriageService::list(int page, int pageSize,
                                            const QString& searchTerm,
                                            const QString& dateFrom,
                                            const QString& dateTo,
                                            int* totalOut) {
    MarriageRepository repo;
    return repo.list(page, pageSize, searchTerm, dateFrom, dateTo, totalOut);
}

Marriage MarriageService::getMarriage(qint64 id) {
    MarriageRepository repo;
    auto m = repo.findById(id);
    if (!m) throw std::runtime_error("Marriage not found");
    return *m;
}

QString MarriageService::nextMarriageNumber() {
    MarriageRepository repo;
    return repo.generateNextNumber();
}

int MarriageService::countThisYear() {
    MarriageRepository repo;
    return repo.countThisYear();
}

// ===========================================================================
// DeathService
// ===========================================================================
qint64 DeathService::createDeath(Death& d, QString* errorMsg) {
    if (d.deceasedName.trimmed().isEmpty()) { if (errorMsg) *errorMsg = "Deceased name is required."; return -1; }
    if (d.dateOfDeath.isEmpty())            { if (errorMsg) *errorMsg = "Date of death is required."; return -1; }
    if (d.deathNumber.isEmpty()) d.deathNumber = nextDeathNumber();

    DeathRepository repo;
    qint64 id = repo.create(d);
    if (id > 0) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "ADD", "death", id,
                  QString("Registered death %1 (%2)").arg(d.deathNumber).arg(d.deceasedName), "");
    }
    return id;
}

bool DeathService::updateDeath(const Death& d, QString* errorMsg) {
    DeathRepository repo;
    if (!repo.findById(d.id)) { if (errorMsg) *errorMsg = "Death record not found."; return false; }
    bool ok = repo.update(d);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "EDIT", "death", d.id,
                  QString("Updated death %1").arg(d.deathNumber), "");
    }
    return ok;
}

bool DeathService::deleteDeath(qint64 id) {
    DeathRepository repo;
    auto d = repo.findById(id);
    bool ok = repo.remove(id);
    if (ok && d) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "DELETE", "death", id,
                  QString("Deleted death %1").arg(d->deathNumber), "");
    }
    return ok;
}

std::vector<Death> DeathService::list(int page, int pageSize,
                                      const QString& searchTerm,
                                      const QString& dateFrom,
                                      const QString& dateTo,
                                      int* totalOut) {
    DeathRepository repo;
    return repo.list(page, pageSize, searchTerm, dateFrom, dateTo, totalOut);
}

Death DeathService::getDeath(qint64 id) {
    DeathRepository repo;
    auto d = repo.findById(id);
    if (!d) throw std::runtime_error("Death record not found");
    return *d;
}

QString DeathService::nextDeathNumber() {
    DeathRepository repo;
    return repo.generateNextNumber();
}

int DeathService::countThisYear() {
    DeathRepository repo;
    return repo.countThisYear();
}

// ===========================================================================
// WelfareService
// ===========================================================================
qint64 WelfareService::createRequest(WelfareRequest& w, QString* errorMsg) {
    if (w.applicantName.trimmed().isEmpty()) { if (errorMsg) *errorMsg = "Applicant name is required."; return -1; }
    if (w.amountRequested <= 0)              { if (errorMsg) *errorMsg = "Requested amount must be positive."; return -1; }
    if (w.reason.trimmed().isEmpty())        { if (errorMsg) *errorMsg = "Reason is required."; return -1; }
    static const QStringList cats = {"Medical Aid","Education Aid","Marriage Assistance","Financial Assistance"};
    if (!cats.contains(w.category))          { if (errorMsg) *errorMsg = "Invalid category."; return -1; }

    if (w.requestNumber.isEmpty()) w.requestNumber = nextRequestNumber();

    WelfareRepository repo;
    qint64 id = repo.create(w);
    if (id > 0) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "ADD", "welfare", id,
                  QString("Created welfare request %1 (₹%2, %3)").arg(w.requestNumber).arg(w.amountRequested).arg(w.category), "");
    }
    return id;
}

bool WelfareService::updateRequest(const WelfareRequest& w, QString* errorMsg) {
    WelfareRepository repo;
    if (!repo.findById(w.id)) { if (errorMsg) *errorMsg = "Welfare request not found."; return false; }
    bool ok = repo.update(w);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "EDIT", "welfare", w.id,
                  QString("Updated welfare request %1").arg(w.requestNumber), "");
    }
    return ok;
}

bool WelfareService::deleteRequest(qint64 id) {
    WelfareRepository repo;
    auto w = repo.findById(id);
    bool ok = repo.remove(id);
    if (ok && w) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "DELETE", "welfare", id,
                  QString("Deleted welfare request %1").arg(w->requestNumber), "");
    }
    return ok;
}

bool WelfareService::approveRequest(qint64 id, double amount, const QString& remarks) {
    WelfareRepository repo;
    auto w = repo.findById(id);
    if (!w) return false;
    qint64 approverId = AuthSession::instance().user().id;
    bool ok = repo.approve(id, approverId, amount, remarks);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "APPROVE", "welfare", id,
                  QString("Approved welfare %1 for ₹%2").arg(w->requestNumber).arg(amount), "");
    }
    return ok;
}

bool WelfareService::rejectRequest(qint64 id, const QString& remarks) {
    WelfareRepository repo;
    auto w = repo.findById(id);
    if (!w) return false;
    qint64 approverId = AuthSession::instance().user().id;
    bool ok = repo.reject(id, approverId, remarks);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "REJECT", "welfare", id,
                  QString("Rejected welfare %1").arg(w->requestNumber), "");
    }
    return ok;
}

bool WelfareService::disburseRequest(qint64 id, const QString& date) {
    WelfareRepository repo;
    auto w = repo.findById(id);
    if (!w) return false;
    bool ok = repo.disburse(id, date.isEmpty() ? QDate::currentDate().toString(Qt::ISODate) : date);
    if (ok) {
        AuditLogRepository audit;
        auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "DISBURSE", "welfare", id,
                  QString("Disbursed welfare %1 (₹%2)").arg(w->requestNumber).arg(w->amountApproved), "");
    }
    return ok;
}

std::vector<WelfareRequest> WelfareService::list(int page, int pageSize,
                                                 const QString& statusFilter,
                                                 const QString& categoryFilter,
                                                 const QString& searchTerm,
                                                 int* totalOut) {
    WelfareRepository repo;
    return repo.list(page, pageSize, statusFilter, categoryFilter, searchTerm, totalOut);
}

WelfareRequest WelfareService::getRequest(qint64 id) {
    WelfareRepository repo;
    auto w = repo.findById(id);
    if (!w) throw std::runtime_error("Welfare request not found");
    return *w;
}

QString WelfareService::nextRequestNumber() {
    WelfareRepository repo;
    return repo.generateNextNumber();
}

} // namespace mms
