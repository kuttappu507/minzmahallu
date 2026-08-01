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
        // English: Poppins (primary)
        { ":/fonts/Poppins-Regular.ttf",   "" },
        { ":/fonts/Poppins-Medium.ttf",    "" },
        { ":/fonts/Poppins-SemiBold.ttf",  "" },
        { ":/fonts/Poppins-Bold.ttf",      "" },
        // Malayalam: Gayathri (primary)
        { ":/fonts/Gayathri-Regular.ttf",  "" },
        { ":/fonts/Gayathri-Bold.ttf",     "" },
        // Fallbacks (kept for compatibility)
        { ":/fonts/NotoSans-Regular.ttf",  "" },
        { ":/fonts/NotoSans-Bold.ttf",     "" },
        { ":/fonts/AnekMalayalam-Regular.ttf",  "" },
        { ":/fonts/AnekMalayalam-Bold.ttf",     "" },
    };
    for (const auto& f : fonts) {
        bool ok = false;
        if (QFile::exists(f.resourcePath)) ok = loadFont(f.resourcePath);
        if (!ok && f.fallbackPath[0] && QFile::exists(f.fallbackPath)) ok = loadFont(f.fallbackPath);
        if (ok) ++loadedCount_;
    }
    Logger::info(QString("Total fonts loaded: %1").arg(loadedCount_));
    return loadedCount_;
}

QString FontManager::fontFamilyForLanguage(const QString& langCode) const {
    if (langCode == "ml") return "Gayathri";
    return "Poppins";
}

void FontManager::applyFont(const QString& langCode) {
    QString family = fontFamilyForLanguage(langCode);
    QFont font(family, 10);
    font.setStyleStrategy(QFont::PreferAntialias);
    font.setHintingPreference(QFont::PreferFullHinting);
    QStringList fallbacks;
    if (langCode == "ml")
        fallbacks << "Gayathri" << "Anek Malayalam" << "Poppins" << "Noto Sans" << "Segoe UI";
    else
        fallbacks << "Poppins" << "Noto Sans" << "Segoe UI" << "Arial";
    font.setFamilies(fallbacks);
    qApp->setFont(font);
    Logger::info(QString("Applied font family: %1 (lang: %2)").arg(family).arg(langCode));
}

} // namespace mms
