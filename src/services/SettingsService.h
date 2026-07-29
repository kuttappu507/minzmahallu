/*
 * SettingsService.h
 */
#pragma once
#include <QObject>
#include <QString>

namespace mms {

struct MahalluSettings {
    QString mahalluName, address, phone, email, logoPath, sealPath;
    QString financialYearStart, currencySymbol, theme, language;
    bool autoBackup;
    int backupIntervalHours;
    QString receiptPrefix;
};

class SettingsService : public QObject {
    Q_OBJECT
public:
    static SettingsService& instance();
    MahalluSettings load();
    bool save(const MahalluSettings& s);
    void applyTheme(const QString& themeName);
    QString currentTheme() const;
    QString receiptPrefix() const;
    QString currencySymbol() const;
    QString currentLanguage() const;
    void setLanguage(const QString& langCode);
private:
    SettingsService() = default;
    ~SettingsService() override = default;
    SettingsService(const SettingsService&) = delete;
    SettingsService& operator=(const SettingsService&) = delete;
    MahalluSettings cached_;
};

} // namespace mms
