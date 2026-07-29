/*
 * FontManager.h - Loads bundled Noto Sans and Noto Sans Malayalam fonts
 */
#pragma once
#include <QObject>
#include <QString>

namespace mms {
class FontManager : public QObject {
    Q_OBJECT
public:
    static FontManager& instance();
    int loadAll();
    QString fontFamilyForLanguage(const QString& langCode) const;
    void applyFont(const QString& langCode);
private:
    FontManager() = default;
    ~FontManager() override = default;
    FontManager(const FontManager&) = delete;
    FontManager& operator=(const FontManager&) = delete;
    bool loadFont(const QString& resourcePath);
    int loadedCount_ = 0;
};
} // namespace mms
