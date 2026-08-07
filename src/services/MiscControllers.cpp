/*
 * MiscControllers.cpp — Implementation for Certificate/Report/Backup/Settings
 */
#include "MiscControllers.h"
#include "../core/Config.h"
#include <QDate>
#include <QFileInfo>

// ============================================================================
// CertificateController
// ============================================================================

QVariantMap CertificateController::issueMembership(const QString& memberCode) {
    QVariantMap result;
    mms::MemberRepository memRepo;
    auto m = memRepo.findByCode(memberCode);
    if (!m) { result["success"] = false; result["error"] = "Member not found with code: " + memberCode; setLastError("Member not found"); return result; }

    mms::Certificate c;
    c.type = "Membership";
    c.memberId = m->id;
    c.familyId = m->familyId;
    c.issuedTo = m->name;
    c.issuedDate = QDate::currentDate().toString(Qt::ISODate);

    QString err;
    qint64 id = svc_.issueCertificate(c, &err);
    if (id > 0) {
        result["success"] = true;
        result["id"] = id;
        result["certificateNumber"] = c.certificateNumber;
        emit dataChanged();
    } else {
        result["success"] = false;
        result["error"] = err;
        setLastError(err);
    }
    return result;
}

QVariantMap CertificateController::issueResidence(const QString& familyNumber, const QString& issuedTo) {
    QVariantMap result;
    mms::FamilyRepository famRepo;
    auto f = famRepo.findByNumber(familyNumber);
    if (!f) { result["success"] = false; result["error"] = "Family not found with number: " + familyNumber; setLastError("Family not found"); return result; }

    mms::Certificate c;
    c.type = "Residence";
    c.familyId = f->id;
    c.issuedTo = issuedTo.isEmpty() ? f->houseName : issuedTo;
    c.issuedDate = QDate::currentDate().toString(Qt::ISODate);

    QString err;
    qint64 id = svc_.issueCertificate(c, &err);
    if (id > 0) {
        result["success"] = true;
        result["id"] = id;
        result["certificateNumber"] = c.certificateNumber;
        emit dataChanged();
    } else {
        result["success"] = false;
        result["error"] = err;
        setLastError(err);
    }
    return result;
}

QVariantMap CertificateController::issueMarriage(const QString& marriageNumber) {
    QVariantMap result;
    mms::MarriageRepository marRepo;
    auto m = marRepo.findByNumber(marriageNumber);
    if (!m) { result["success"] = false; result["error"] = "Marriage record not found with number: " + marriageNumber; setLastError("Marriage not found"); return result; }

    mms::Certificate c;
    c.type = "Marriage";
    c.marriageId = m->id;
    c.issuedTo = m->brideName + " & " + m->groomName;
    c.issuedDate = QDate::currentDate().toString(Qt::ISODate);

    QString err;
    qint64 id = svc_.issueCertificate(c, &err);
    if (id > 0) {
        result["success"] = true;
        result["id"] = id;
        result["certificateNumber"] = c.certificateNumber;
        emit dataChanged();
    } else {
        result["success"] = false;
        result["error"] = err;
        setLastError(err);
    }
    return result;
}

QVariantMap CertificateController::issueDeath(const QString& deathNumber) {
    QVariantMap result;
    mms::DeathRepository deathRepo;
    auto d = deathRepo.findByNumber(deathNumber);
    if (!d) { result["success"] = false; result["error"] = "Death record not found with number: " + deathNumber; setLastError("Death not found"); return result; }

    mms::Certificate c;
    c.type = "Death";
    c.deathId = d->id;
    c.issuedTo = d->deceasedName;
    c.issuedDate = QDate::currentDate().toString(Qt::ISODate);

    QString err;
    qint64 id = svc_.issueCertificate(c, &err);
    if (id > 0) {
        result["success"] = true;
        result["id"] = id;
        result["certificateNumber"] = c.certificateNumber;
        emit dataChanged();
    } else {
        result["success"] = false;
        result["error"] = err;
        setLastError(err);
    }
    return result;
}

QVariantList CertificateController::list(int page, int pageSize, const QString& typeFilter, const QString& dateFrom, const QString& dateTo) {
    QVariantList out;
    int total = 0;
    auto certs = svc_.list(page, pageSize, typeFilter, dateFrom, dateTo, &total);
    for (const auto& c : certs) {
        out.append(certToMap(c));
    }
    return out;
}

int CertificateController::totalCount(const QString& typeFilter, const QString& dateFrom, const QString& dateTo) {
    int total = 0;
    svc_.list(1, 1, typeFilter, dateFrom, dateTo, &total);
    return total;
}

bool CertificateController::remove(qint64 id) {
    bool ok = repo_.remove(id);
    if (ok) emit dataChanged();
    else setLastError("Failed to delete certificate");
    return ok;
}

QString CertificateController::generatePdf(qint64 certificateId) {
    QString err;
    QString path = svc_.generatePdf(certificateId, &err);
    if (path.isEmpty()) setLastError(err);
    return path;
}

QString CertificateController::generateMarriagePdf(qint64 marriageId) {
    QString err;
    QString path = svc_.generateMarriageCertificatePdf(marriageId, &err);
    if (path.isEmpty()) setLastError(err);
    return path;
}

QString CertificateController::generateDeathPdf(qint64 deathId) {
    QString err;
    QString path = svc_.generateDeathCertificatePdf(deathId, &err);
    if (path.isEmpty()) setLastError(err);
    return path;
}

QString CertificateController::exportToCsv(const QString& outputPath) {
    auto certs = svc_.list(1, 10000, "", "", "", nullptr);
    QStringList lines;
    lines << "Certificate No,Type,Issued To,Date,Issued By";
    for (const auto& c : certs) {
        lines << QString("%1,%2,%3,%4,%5")
            .arg(c.certificateNumber, c.type, c.issuedTo, c.issuedDate, c.issuedByName);
    }
    QString csv = lines.join("\n");
    QFile f(outputPath);
    if (f.open(QIODevice::WriteOnly)) {
        f.write(csv.toUtf8());
        f.close();
        return outputPath;
    }
    setLastError("Failed to write CSV");
    return "";
}

QString CertificateController::exportDir() const {
    return mms::Config::instance().exportDir();
}

QVariantMap CertificateController::certToMap(const mms::Certificate& c) {
    QVariantMap m;
    m["id"] = c.id;
    m["certificateNumber"] = c.certificateNumber;
    m["type"] = c.type;
    m["memberId"] = c.memberId;
    m["familyId"] = c.familyId;
    m["marriageId"] = c.marriageId;
    m["deathId"] = c.deathId;
    m["issuedTo"] = c.issuedTo;
    m["issuedDate"] = c.issuedDate;
    m["issuedByName"] = c.issuedByName;
    return m;
}

// ============================================================================
// ReportController
// ============================================================================

QStringList ReportController::reportTypes() {
    return {
        "Family Register", "Member Register", "Active Members", "Family Directory",
        "Subscription Report", "Defaulters Report", "Donation Report",
        "Income Report", "Expense Report", "Cash Book Report",
        "Financial Summary", "Marriage Register Report", "Death Register Report", "Welfare Report"
    };
}

mms::ReportService::ReportRow ReportController::generateRow(int reportIndex, const QString& dateFrom, const QString& dateTo) {
    switch (reportIndex) {
        case 0: return svc_.familyRegister();
        case 1: return svc_.memberRegister();
        case 2: return svc_.activeMembers();
        case 3: return svc_.familyDirectory();
        case 4: return svc_.subscriptionReport(dateFrom, dateTo);
        case 5: return svc_.defaultersReport();
        case 6: return svc_.donationReport(dateFrom, dateTo);
        case 7: return svc_.incomeReport(dateFrom, dateTo);
        case 8: return svc_.expenseReport(dateFrom, dateTo);
        case 9: return svc_.cashBookReport(dateFrom, dateTo);
        case 10: return svc_.financialSummary(dateFrom, dateTo);
        case 11: return svc_.marriageRegisterReport(dateFrom, dateTo);
        case 12: return svc_.deathRegisterReport(dateFrom, dateTo);
        case 13: return svc_.welfareReport(dateFrom, dateTo);
        default: return {};
    }
}

QVariantMap ReportController::generate(int reportIndex, const QString& dateFrom, const QString& dateTo) {
    auto row = generateRow(reportIndex, dateFrom, dateTo);
    return rowToMap(row);
}

QString ReportController::exportToCsv(int reportIndex, const QString& dateFrom, const QString& dateTo, const QString& outputPath) {
    auto row = generateRow(reportIndex, dateFrom, dateTo);
    return svc_.exportToCsv(row, outputPath);
}

QString ReportController::exportToPdf(int reportIndex, const QString& dateFrom, const QString& dateTo, const QString& outputPath) {
    auto row = generateRow(reportIndex, dateFrom, dateTo);
    QStringList types = reportTypes();
    QString title = (reportIndex >= 0 && reportIndex < types.size()) ? types[reportIndex] : "Report";
    return svc_.exportToPdf(row, title, outputPath, dateFrom, dateTo);
}

QString ReportController::exportToExcel(int reportIndex, const QString& dateFrom, const QString& dateTo, const QString& outputPath) {
    auto row = generateRow(reportIndex, dateFrom, dateTo);
    QStringList types = reportTypes();
    QString title = (reportIndex >= 0 && reportIndex < types.size()) ? types[reportIndex] : "Report";
    return svc_.exportToExcel(row, title, outputPath);
}

QString ReportController::ensureExportPath(const QString& fileName) {
    return svc_.ensureExportPath(fileName);
}

QVariantMap ReportController::rowToMap(const mms::ReportService::ReportRow& row) {
    QVariantMap m;
    m["headers"] = QVariant::fromValue(row.headers);
    QVariantList rows;
    for (int r = 0; r < row.rowCount; ++r) {
        QVariantList rowCells;
        for (int c = 0; c < row.headers.size(); ++c) {
            rowCells.append(row.cell(r, c));
        }
        rows.append(QVariant(rowCells));
    }
    m["rows"] = rows;
    m["rowCount"] = row.rowCount;
    m["columnCount"] = row.headers.size();
    return m;
}

// ============================================================================
// BackupController
// ============================================================================

QString BackupController::createBackup() {
    QString err;
    QString path = svc_.createBackup(&err);
    if (path.isEmpty()) setLastError(err);
    else emit dataChanged();
    return path;
}

bool BackupController::restoreBackup(const QString& zipPath) {
    QString err;
    bool ok = svc_.restoreBackup(zipPath, &err);
    if (!ok) setLastError(err);
    return ok;
}

bool BackupController::verifyBackup(const QString& zipPath) {
    QString err;
    bool ok = svc_.verifyBackup(zipPath, &err);
    if (!ok) setLastError(err);
    return ok;
}

bool BackupController::deleteBackup(const QString& path) {
    bool ok = QFile::remove(path);
    if (ok) emit dataChanged();
    else setLastError("Failed to delete backup file");
    return ok;
}

int BackupController::pruneOldBackups(int keepCount) {
    int n = svc_.pruneOldBackups(keepCount);
    emit dataChanged();
    return n;
}

QVariantList BackupController::listBackups() {
    QVariantList out;
    auto backups = svc_.listBackups();
    for (const auto& b : backups) {
        out.append(backupToMap(b));
    }
    return out;
}

QVariantMap BackupController::backupToMap(const mms::BackupService::BackupInfo& b) {
    QVariantMap m;
    m["fileName"] = b.fileName;
    m["fullPath"] = b.fullPath;
    m["created"] = b.created.toString("yyyy-MM-dd hh:mm");
    m["sizeBytes"] = b.sizeBytes;
    double size = b.sizeBytes;
    QString unit = "B";
    if (size >= 1048576) { size /= 1048576; unit = "MB"; }
    else if (size >= 1024) { size /= 1024; unit = "KB"; }
    m["sizeDisplay"] = QString::number(size, 'f', 1) + " " + unit;
    return m;
}

// ============================================================================
// SettingsController
// ============================================================================

void SettingsController::load() {
    s_ = mms::SettingsService::instance().load();
    emit settingsChanged();
}

bool SettingsController::save() {
    bool ok = mms::SettingsService::instance().save(s_);
    if (ok) {
        mms::SettingsService::instance().applyTheme(s_.theme);
    } else {
        lastError_ = "Failed to save settings";
        emit lastErrorChanged();
    }
    return ok;
}
