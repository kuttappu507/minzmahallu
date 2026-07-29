#include "SettingsService.h"
#include "../core/Database.h"
#include "../core/Config.h"
#include "../core/Logger.h"
#include "../core/FontManager.h"
#include "../core/I18N.h"
#include "../repositories/AuditLogRepository.h"
#include "AuthSession.h"
#include <QApplication>
#include <QFile>
#include <QFont>
#include <QDir>
#include <QCoreApplication>
#include <QSqlQuery>

namespace mms {

SettingsService& SettingsService::instance() { static SettingsService inst; return inst; }

MahalluSettings SettingsService::load() {
    QSqlQuery q = Database::instance().execute("SELECT * FROM settings WHERE id = 1");
    if (!q.next()) return MahalluSettings{};
    cached_.mahalluName = q.value("mahallu_name").toString();
    cached_.address = q.value("address").toString();
    cached_.phone = q.value("phone").toString();
    cached_.email = q.value("email").toString();
    cached_.logoPath = q.value("logo_path").toString();
    cached_.sealPath = q.value("seal_path").toString();
    cached_.financialYearStart = q.value("financial_year_start").toString();
    cached_.currencySymbol = q.value("currency_symbol").toString();
    cached_.theme = q.value("theme").toString();
    int langIdx = q.record().indexOf("language");
    cached_.language = (langIdx >= 0 && !q.value(langIdx).isNull()) ? q.value(langIdx).toString() : "en";
    cached_.autoBackup = q.value("auto_backup").toInt() == 1;
    cached_.backupIntervalHours = q.value("backup_interval_hours").toInt();
    cached_.receiptPrefix = q.value("receipt_prefix").toString();
    if (cached_.language.isEmpty()) cached_.language = Config::instance().language();
    if (cached_.language.isEmpty()) cached_.language = "en";
    return cached_;
}

bool SettingsService::save(const MahalluSettings& s) {
    int n = Database::instance().update(
        R"(UPDATE settings SET mahallu_name=?, address=?, phone=?, email=?,
           logo_path=?, seal_path=?, financial_year_start=?, currency_symbol=?,
           theme=?, language=?, auto_backup=?, backup_interval_hours=?, receipt_prefix=?,
           updated_at=datetime('now') WHERE id=1)",
        { s.mahalluName, s.address, s.phone, s.email, s.logoPath, s.sealPath,
          s.financialYearStart, s.currencySymbol, s.theme, s.language,
          s.autoBackup ? 1 : 0, s.backupIntervalHours, s.receiptPrefix });
    if (n <= 0 && Database::instance().lastErrorText().contains("language", Qt::CaseInsensitive)) {
        n = Database::instance().update(
            R"(UPDATE settings SET mahallu_name=?, address=?, phone=?, email=?,
               logo_path=?, seal_path=?, financial_year_start=?, currency_symbol=?,
               theme=?, auto_backup=?, backup_interval_hours=?, receipt_prefix=?,
               updated_at=datetime('now') WHERE id=1)",
            { s.mahalluName, s.address, s.phone, s.email, s.logoPath, s.sealPath,
              s.financialYearStart, s.currencySymbol, s.theme,
              s.autoBackup ? 1 : 0, s.backupIntervalHours, s.receiptPrefix });
    }
    cached_ = s;
    Config::instance().setTheme(s.theme);
    Config::instance().setAutoBackupEnabled(s.autoBackup);
    Config::instance().setAutoBackupIntervalHours(s.backupIntervalHours);
    Config::instance().setLanguage(s.language);
    if (n > 0) { AuditLogRepository audit; auto u = AuthSession::instance().user();
        audit.log(u.id, u.username, "EDIT", "settings", 0, "Updated settings", ""); }
    return n > 0;
}

void SettingsService::applyTheme(const QString& themeName) {
    QString qss;
    QString resPath = QString(":/styles/%1.qss").arg(themeName);
    QFile resFile(resPath);
    if (resFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qss = QString::fromUtf8(resFile.readAll());
        resFile.close();
        Logger::info("Theme loaded from Qt resource: " + resPath);
    }
    if (qss.isEmpty()) {
        QString exeDir = QCoreApplication::applicationDirPath();
        QString fsPath = exeDir + "/resources/styles/" + themeName + ".qss";
        QFile fsFile(fsPath);
        if (fsFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qss = QString::fromUtf8(fsFile.readAll());
            fsFile.close();
            Logger::info("Theme loaded from filesystem: " + fsPath);
        }
    }
    if (qss.isEmpty()) { Logger::error("Cannot load stylesheet: " + themeName); return; }
    qApp->setStyleSheet(qss);
    FontManager::instance().applyFont(I18N::instance().currentLanguage());
    Config::instance().setTheme(themeName);
}

QString SettingsService::currentTheme() const { return Config::instance().theme(); }
QString SettingsService::currentLanguage() const { return Config::instance().language(); }
void SettingsService::setLanguage(const QString& langCode) {
    Config::instance().setLanguage(langCode);
    FontManager::instance().applyFont(langCode);
    I18N::instance().setLanguage(langCode);
}
QString SettingsService::receiptPrefix() const { return cached_.receiptPrefix.isEmpty() ? "RCP" : cached_.receiptPrefix; }
QString SettingsService::currencySymbol() const { return cached_.currencySymbol.isEmpty() ? QString::fromUtf8("\xe2\x82\xb9") : cached_.currencySymbol; }

} // namespace mms
