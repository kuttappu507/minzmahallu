/*
 * I18N.h - Internationalization system for Minz Mahallu Management
 * Supports English (en) and Malayalam (ml)
 */
#pragma once
#include <QString>
#include <QHash>
#include <QStringList>

namespace mms {

class I18N {
public:
    static I18N& instance();
    static QString tr(const QString& key);
    QString currentLanguage() const { return currentLang_; }
    void setLanguage(const QString& langCode);
    QStringList availableLanguages() const { return {"en", "ml"}; }
    QString languageDisplayName(const QString& code) const;
    void loadFromSettings();
    using LanguageChangedCallback = void(*)(const QString&);
    void setLanguageChangedCallback(LanguageChangedCallback cb) { callback_ = cb; }
private:
    I18N();
    ~I18N() = default;
    I18N(const I18N&) = delete;
    I18N& operator=(const I18N&) = delete;
    void initTranslations();
    QHash<QString, QHash<QString, QString>> translations_;
    QString currentLang_ = "en";
    LanguageChangedCallback callback_ = nullptr;
};

} // namespace mms
#define TR(key) mms::I18N::tr(key)
