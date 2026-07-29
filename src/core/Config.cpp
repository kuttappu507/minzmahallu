/*
 * Config.cpp - Implementation
 */
#include "Config.h"
#include "Logger.h"
#include <QStandardPaths>
#include <QCoreApplication>
#include <QFileInfo>

namespace mms {

Config& Config::instance() {
    static Config inst;
    return inst;
}

Config::Config() = default;
Config::~Config() = default;

void Config::initialize(const QString& appName) {
    // Detect portable mode: if "mms.portable" marker file exists next to the
    // executable, treat that directory as the data root.
    QString exeDir = QCoreApplication::applicationDirPath();
    if (QFileInfo::exists(exeDir + "/mms.portable")) {
        portable_ = true;
        dataDir_  = exeDir + "/data";
    } else {
        dataDir_ = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        if (dataDir_.isEmpty()) {
            dataDir_ = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
                     + "/" + appName;
        }
    }

    QDir().mkpath(dataDir_);
    QDir().mkpath(dataDir_ + "/logs");
    QDir().mkpath(dataDir_ + "/attachments");
    QDir().mkpath(dataDir_ + "/exports");
    backupDir_ = dataDir_ + "/backups";
    QDir().mkpath(backupDir_);

    // Locate SQL & templates relative to exe directory (installed layout)
    sqlDir_      = exeDir + "/sql";
    templateDir_ = exeDir + "/templates";

    // Fall back to source tree paths if not found (dev mode)
    if (!QFileInfo::exists(sqlDir_ + "/schema.sql")) {
        sqlDir_ = exeDir + "/../../sql";
    }
    if (!QFileInfo::exists(templateDir_)) {
        templateDir_ = exeDir + "/../../resources/templates";
    }

    // Settings: use INI file in data dir
    QString settingsPath = dataDir_ + "/mms.ini";
    settings_ = std::make_unique<QSettings>(settingsPath, QSettings::IniFormat);
    // Qt6 uses UTF-8 for INI files by default

    Logger::info(QString("Config initialized. Data dir: %1 | SQL dir: %2 | Portable: %3")
                 .arg(dataDir_).arg(sqlDir_).arg(portable_ ? "yes" : "no"));
}

QVariant Config::get(const QString& key, const QVariant& defaultValue) const {
    if (!settings_) return defaultValue;
    return settings_->value(key, defaultValue);
}

void Config::set(const QString& key, const QVariant& value) {
    if (!settings_) return;
    settings_->setValue(key, value);
    settings_->sync();
}

bool Config::contains(const QString& key) const {
    return settings_ && settings_->contains(key);
}

void Config::remove(const QString& key) {
    if (settings_) settings_->remove(key);
}

QString Config::lastBackupPath() const {
    return get("backup/lastPath", "").toString();
}

void Config::setLastBackupPath(const QString& path) {
    set("backup/lastPath", path);
}

QString Config::theme() const {
    return get("ui/theme", "light").toString();
}

void Config::setTheme(const QString& theme) {
    set("ui/theme", theme);
}

QString Config::language() const {
    return get("ui/language", "en").toString();
}

void Config::setLanguage(const QString& code) {
    set("ui/language", code);
}

bool Config::autoBackupEnabled() const {
    return get("backup/autoEnabled", true).toBool();
}

void Config::setAutoBackupEnabled(bool enabled) {
    set("backup/autoEnabled", enabled);
}

int Config::autoBackupIntervalHours() const {
    return get("backup/intervalHours", 24).toInt();
}

void Config::setAutoBackupIntervalHours(int hours) {
    set("backup/intervalHours", hours);
}

} // namespace mms
