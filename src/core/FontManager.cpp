#include "FontManager.h"
#include "Logger.h"
#include <QFontDatabase>
#include <QApplication>
#include <QFont>
#include <QFile>

namespace mms {

FontManager& FontManager::instance() { static FontManager inst; return inst; }

bool FontManager::loadFont(const QString& resourcePath) {
    int id = QFontDatabase::addApplicationFont(resourcePath);
    if (id < 0) {
        Logger::error("Failed to load font: " + resourcePath);
        return false;
    }
    QStringList families = QFontDatabase::applicationFontFamilies(id);
    if (!families.isEmpty())
        Logger::info(QString("Loaded font: %1 (family: %2)").arg(resourcePath).arg(families.first()));
    return true;
}

int FontManager::loadAll() {
    Logger::info("Loading bundled fonts...");
    struct FontDef { const char* resourcePath; const char* fallbackPath; };
    FontDef fonts[] = {
        { ":/fonts/NotoSans-Regular.ttf", "/home/z/fonts/NotoSans-Regular.ttf" },
        { ":/fonts/NotoSans-Bold.ttf", "/home/z/fonts/NotoSans-Bold.ttf" },
        { ":/fonts/AnekMalayalam-Regular.ttf", "/home/z/fonts/anek/AnekMalayalam-Regular.ttf" },
        { ":/fonts/AnekMalayalam-Medium.ttf", "/home/z/fonts/anek/AnekMalayalam-Medium.ttf" },
        { ":/fonts/AnekMalayalam-SemiBold.ttf", "/home/z/fonts/anek/AnekMalayalam-SemiBold.ttf" },
        { ":/fonts/AnekMalayalam-Bold.ttf", "/home/z/fonts/anek/AnekMalayalam-Bold.ttf" },
    };
    for (const auto& f : fonts) {
        bool ok = false;
        if (QFile::exists(f.resourcePath)) ok = loadFont(f.resourcePath);
        if (!ok && QFile::exists(f.fallbackPath)) ok = loadFont(f.fallbackPath);
        if (ok) ++loadedCount_;
    }
    Logger::info(QString("Total fonts loaded: %1").arg(loadedCount_));
    return loadedCount_;
}

QString FontManager::fontFamilyForLanguage(const QString& langCode) const {
    if (langCode == "ml") return "Anek Malayalam";
    return "Noto Sans";
}

void FontManager::applyFont(const QString& langCode) {
    QString family = fontFamilyForLanguage(langCode);
    QFont font(family, 10);
    font.setStyleStrategy(QFont::PreferAntialias);
    font.setHintingPreference(QFont::PreferFullHinting);
    QStringList fallbacks;
    if (langCode == "ml")
        fallbacks << "Anek Malayalam" << "Noto Sans" << "Segoe UI" << "Arial";
    else
        fallbacks << "Noto Sans" << "Anek Malayalam" << "Segoe UI" << "Arial";
    font.setFamilies(fallbacks);
    qApp->setFont(font);
    Logger::info(QString("Applied font family: %1 (lang: %2)").arg(family).arg(langCode));
}

} // namespace mms
