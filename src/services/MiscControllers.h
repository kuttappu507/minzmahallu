/*
 * MiscControllers.h — Combined controllers for Certificate, Report, Backup, Settings
 * Wraps existing services with Q_INVOKABLE methods for QML.
 */
#pragma once

#include <QObject>
#include <QVariantMap>
#include <QVariantList>
#include "CertificateService.h"
#include "ReportService.h"
#include "BackupService.h"
#include "SettingsService.h"
#include "../repositories/CertificateRepository.h"
#include "../repositories/FamilyRepository.h"
#include "../repositories/MemberRepository.h"
#include "../repositories/MarriageRepository.h"
#include "../repositories/DeathRepository.h"

class CertificateController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
public:
    explicit CertificateController(QObject* parent = nullptr) : QObject(parent) {}
    QString lastError() const { return lastError_; }
    Q_INVOKABLE QVariantMap issueMembership(const QString& memberCode);
    Q_INVOKABLE QVariantMap issueResidence(const QString& familyNumber, const QString& issuedTo);
    Q_INVOKABLE QVariantMap issueMarriage(const QString& marriageNumber);
    Q_INVOKABLE QVariantMap issueDeath(const QString& deathNumber);
    Q_INVOKABLE QVariantList list(int page = 1, int pageSize = 50,
                                  const QString& typeFilter = QString(),
                                  const QString& dateFrom = QString(),
                                  const QString& dateTo = QString());
    Q_INVOKABLE int totalCount(const QString& typeFilter = QString(),
                               const QString& dateFrom = QString(),
                               const QString& dateTo = QString());
    Q_INVOKABLE bool remove(qint64 id);
    Q_INVOKABLE QString generatePdf(qint64 certificateId);
    Q_INVOKABLE QString generateMarriagePdf(qint64 marriageId);
    Q_INVOKABLE QString generateDeathPdf(qint64 deathId);
    Q_INVOKABLE QString exportToCsv(const QString& outputPath);
    Q_INVOKABLE QString exportDir() const;
signals:
    void lastErrorChanged();
    void dataChanged();
private:
    mms::CertificateService svc_;
    mms::CertificateRepository repo_;
    QString lastError_;
    void setLastError(const QString& err) { if (lastError_ != err) { lastError_ = err; emit lastErrorChanged(); } }
    static QVariantMap certToMap(const mms::Certificate& c);
};

class ReportController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
public:
    explicit ReportController(QObject* parent = nullptr) : QObject(parent) {}
    QString lastError() const { return lastError_; }
    Q_INVOKABLE QStringList reportTypes();
    Q_INVOKABLE QVariantMap generate(int reportIndex, const QString& dateFrom, const QString& dateTo);
    Q_INVOKABLE QString exportToCsv(int reportIndex, const QString& dateFrom, const QString& dateTo, const QString& outputPath);
    Q_INVOKABLE QString exportToPdf(int reportIndex, const QString& dateFrom, const QString& dateTo, const QString& outputPath);
    Q_INVOKABLE QString exportToExcel(int reportIndex, const QString& dateFrom, const QString& dateTo, const QString& outputPath);
    Q_INVOKABLE QString ensureExportPath(const QString& fileName);
signals:
    void lastErrorChanged();
private:
    mms::ReportService svc_;
    QString lastError_;
    void setLastError(const QString& err) { if (lastError_ != err) { lastError_ = err; emit lastErrorChanged(); } }
    mms::ReportService::ReportRow generateRow(int reportIndex, const QString& dateFrom, const QString& dateTo);
    static QVariantMap rowToMap(const mms::ReportService::ReportRow& row);
};

class BackupController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
public:
    explicit BackupController(QObject* parent = nullptr) : QObject(parent), svc_(parent) {}
    QString lastError() const { return lastError_; }
    Q_INVOKABLE QString createBackup();
    Q_INVOKABLE bool restoreBackup(const QString& zipPath);
    Q_INVOKABLE bool verifyBackup(const QString& zipPath);
    Q_INVOKABLE bool deleteBackup(const QString& path);
    Q_INVOKABLE int pruneOldBackups(int keepCount = 10);
    Q_INVOKABLE QVariantList listBackups();
signals:
    void lastErrorChanged();
    void dataChanged();
private:
    mms::BackupService svc_;
    QString lastError_;
    void setLastError(const QString& err) { if (lastError_ != err) { lastError_ = err; emit lastErrorChanged(); } }
    static QVariantMap backupToMap(const mms::BackupService::BackupInfo& b);
};

class SettingsController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString mahalluName READ mahalluName WRITE setMahalluName NOTIFY settingsChanged)
    Q_PROPERTY(QString address READ address WRITE setAddress NOTIFY settingsChanged)
    Q_PROPERTY(QString phone READ phone WRITE setPhone NOTIFY settingsChanged)
    Q_PROPERTY(QString email READ email WRITE setEmail NOTIFY settingsChanged)
    Q_PROPERTY(QString currencySymbol READ currencySymbol WRITE setCurrencySymbol NOTIFY settingsChanged)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY settingsChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY settingsChanged)
    Q_PROPERTY(QString financialYearStart READ financialYearStart WRITE setFinancialYearStart NOTIFY settingsChanged)
    Q_PROPERTY(QString receiptPrefix READ receiptPrefix WRITE setReceiptPrefix NOTIFY settingsChanged)
    Q_PROPERTY(bool autoBackup READ autoBackup WRITE setAutoBackup NOTIFY settingsChanged)
    Q_PROPERTY(int backupIntervalHours READ backupIntervalHours WRITE setBackupIntervalHours NOTIFY settingsChanged)
    Q_PROPERTY(QString logoPath READ logoPath WRITE setLogoPath NOTIFY settingsChanged)
    Q_PROPERTY(QString sealPath READ sealPath WRITE setSealPath NOTIFY settingsChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
public:
    explicit SettingsController(QObject* parent = nullptr) : QObject(parent) { load(); }
    QString mahalluName() const { return s_.mahalluName; }
    QString address() const { return s_.address; }
    QString phone() const { return s_.phone; }
    QString email() const { return s_.email; }
    QString currencySymbol() const { return s_.currencySymbol; }
    QString theme() const { return s_.theme; }
    QString language() const { return s_.language; }
    QString financialYearStart() const { return s_.financialYearStart; }
    QString receiptPrefix() const { return s_.receiptPrefix; }
    bool autoBackup() const { return s_.autoBackup; }
    int backupIntervalHours() const { return s_.backupIntervalHours; }
    QString logoPath() const { return s_.logoPath; }
    QString sealPath() const { return s_.sealPath; }
    QString lastError() const { return lastError_; }

    void setMahalluName(const QString& v) { if (s_.mahalluName == v) return; s_.mahalluName = v; emit settingsChanged(); }
    void setAddress(const QString& v) { if (s_.address == v) return; s_.address = v; emit settingsChanged(); }
    void setPhone(const QString& v) { if (s_.phone == v) return; s_.phone = v; emit settingsChanged(); }
    void setEmail(const QString& v) { if (s_.email == v) return; s_.email = v; emit settingsChanged(); }
    void setCurrencySymbol(const QString& v) { if (s_.currencySymbol == v) return; s_.currencySymbol = v; emit settingsChanged(); }
    void setTheme(const QString& v) {
        if (v != "light" && v != "dark") return;
        if (s_.theme == v) return;
        s_.theme = v;
        mms::SettingsService::instance().applyTheme(v);
        emit settingsChanged();
    }
    void setLanguage(const QString& v) {
        if (v != "en" && v != "ml") return;
        if (s_.language == v) return;
        s_.language = v;
        mms::SettingsService::instance().setLanguage(v);
        emit settingsChanged();
    }
    void setFinancialYearStart(const QString& v) { if (s_.financialYearStart == v) return; s_.financialYearStart = v; emit settingsChanged(); }
    void setReceiptPrefix(const QString& v) { if (s_.receiptPrefix == v) return; s_.receiptPrefix = v; emit settingsChanged(); }
    void setAutoBackup(bool v) { if (s_.autoBackup == v) return; s_.autoBackup = v; emit settingsChanged(); }
    void setBackupIntervalHours(int v) { if (s_.backupIntervalHours == v) return; s_.backupIntervalHours = v; emit settingsChanged(); }
    void setLogoPath(const QString& v) { if (s_.logoPath == v) return; s_.logoPath = v; emit settingsChanged(); }
    void setSealPath(const QString& v) { if (s_.sealPath == v) return; s_.sealPath = v; emit settingsChanged(); }
    Q_INVOKABLE void load();
    Q_INVOKABLE bool save();
signals:
    void settingsChanged();
    void lastErrorChanged();
private:
    mms::MahalluSettings s_;
    QString lastError_;
};