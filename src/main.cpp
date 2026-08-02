/*
 * main.cpp - Minz Mahallu Management entry point
 * Includes: splash screen, font loading, i18n, text rendering fix
 */
#include "core/Logger.h"
#include "core/Config.h"
#include "core/Database.h"
#include "core/FontManager.h"
#include "core/I18N.h"
#include "services/SettingsService.h"
#include "services/AuthSession.h"
#include "views/MainWindow.h"
#include "views/SplashScreen.h"

#include <QApplication>
#include <QDir>
#include <QStandardPaths>
#include <QMessageBox>
#include <QStyleFactory>
#include <QFontDatabase>
#include <QFont>
#include <QTimer>

#ifdef Q_OS_WIN
#  undef _WIN32_WINNT
#  define _WIN32_WINNT 0x0600  // Vista+ for SetProcessDPIAware
#  undef WINVER
#  define WINVER 0x0600
#  include <windows.h>
#endif

int main(int argc, char* argv[]) {
    // TEXT RENDERING FIX: Round DPI scaling to avoid blurry text on low-res displays
#ifdef Q_OS_WIN
    qputenv("QT_ENABLE_HIGHDPI_SCALING", "1");
    qputenv("QT_AUTO_SCREEN_SCALE_FACTOR", "1");
    qputenv("QT_SCALE_FACTOR_ROUNDING_POLICY", "RoundPreferFloor");
#endif
    QApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::RoundPreferFloor);

    QApplication app(argc, argv);
    app.setApplicationName("MinzMahallu");
    app.setApplicationDisplayName("Minz Mahallu Management");
    app.setOrganizationName("MinzMahallu");
    app.setApplicationVersion("1.0.0");

    app.setStyle(QStyleFactory::create("Fusion"));

    // TEXT RENDERING FIX: Full font hinting for crisp edges
    QFont defaultFont("Segoe UI", 10);
    defaultFont.setStyleStrategy(QFont::PreferAntialias);
    defaultFont.setHintingPreference(QFont::PreferFullHinting);
    defaultFont.setStyleHint(QFont::SansSerif);
    app.setFont(defaultFont);

#ifdef Q_OS_WIN
    SetProcessDPIAware();
#endif

    // Show splash screen FIRST
    mms::SplashScreen splash;
    splash.showLoading();
    app.processEvents();

    // Initialize Config
    mms::Config::instance().initialize("MinzMahallu");
    mms::Logger::instance().initialize(mms::Config::instance().logDir(), mms::Logger::Level::Info);
    mms::Logger::info("=== Minz Mahallu Management Starting ===");
    app.processEvents();

    // Load fonts
    mms::FontManager::instance().loadAll();
    app.processEvents();

    // Initialize Database
    QString dbPath = mms::Config::instance().databasePath();
    QString sqlDir = mms::Config::instance().sqlDir();
    if (!mms::Database::instance().initialize(dbPath, sqlDir)) {
        splash.finish();
        QMessageBox::critical(nullptr, "Database Error",
            "Failed to initialize the database:\n" + mms::Database::instance().lastErrorText() +
            "\n\nApplication will exit.");
        return 1;
    }
    app.processEvents();

    // Load settings, language, theme
    mms::SettingsService::instance().load();
    mms::I18N::instance().loadFromSettings();
    QString savedTheme = mms::Config::instance().theme();
    if (savedTheme.isEmpty()) savedTheme = "light";
    mms::FontManager::instance().applyFont(mms::I18N::instance().currentLanguage());
    mms::SettingsService::instance().applyTheme(savedTheme);
    app.processEvents();

    // Create main window (but don't show yet)
    mms::MainWindow window;

    // When splash finishes, hide it and show main window
    QObject::connect(&splash, &mms::SplashScreen::loadingComplete, [&]() {
        splash.finish();
        window.show();
    });

    // Fallback: force-show window after 5 seconds
    QTimer::singleShot(5000, [&]() {
        if (!window.isVisible()) {
            splash.finish();
            window.show();
        }
    });

    int ret = app.exec();
    mms::Logger::info(QString("=== Minz Mahallu Management Exiting (code %1) ===").arg(ret));
    mms::Database::instance().closeAll();
    mms::Logger::instance().shutdown();
    return ret;
}
