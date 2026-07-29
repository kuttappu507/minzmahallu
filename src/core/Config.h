/*
 * Config.h - Application configuration & path management
 *
 * Provides:
 *  - Application data directory (writable location for DB, logs, backups, attachments)
 *  - Application settings persistence (using QSettings)
 *  - Helpers to read/write individual settings
 */
#pragma once

#include <QObject>
#include <QString>
#include <QDir>
#include <QSettings>
#include <QVariant>

namespace mms {

class Config : public QObject {
    Q_OBJECT
public:
    static Config& instance();

    // Initialize directories. Call once at startup.
    void initialize(const QString& appName = "MMS");

    // Directory accessors
    QString dataDir()      const { return dataDir_; }
    QString databasePath() const { return dataDir_ + "/mms.db"; }
    QString logDir()       const { return dataDir_ + "/logs"; }
    QString backupDir()    const { return backupDir_; }
    QString attachmentDir()const { return dataDir_ + "/attachments"; }
    QString exportDir()    const { return dataDir_ + "/exports"; }
    QString sqlDir()       const { return sqlDir_; }
    QString templateDir()  const { return templateDir_; }

    // Generic settings accessors
    QVariant get(const QString& key, const QVariant& defaultValue = {}) const;
    void set(const QString& key, const QVariant& value);
    bool contains(const QString& key) const;
    void remove(const QString& key);

    // Convenience
    QString lastBackupPath() const;
    void setLastBackupPath(const QString& path);

    QString theme() const;
    void setTheme(const QString& theme);

    QString language() const;
    void setLanguage(const QString& code);

    bool autoBackupEnabled() const;
    void setAutoBackupEnabled(bool enabled);

    int autoBackupIntervalHours() const;
    void setAutoBackupIntervalHours(int hours);

    // Set directories when running from a portable location (e.g., USB stick)
    void setPortableMode(bool portable) { portable_ = portable; }
    bool isPortable() const { return portable_; }

private:
    Config();
    ~Config() override;
    Config(const Config&) = delete;
    Config& operator=(const Config&) = delete;

    QString dataDir_;
    QString backupDir_;
    QString sqlDir_;
    QString templateDir_;
    bool portable_ = false;
    std::unique_ptr<QSettings> settings_;
};

} // namespace mms
