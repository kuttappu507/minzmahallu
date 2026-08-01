/*
 * main.cpp — QML-based entry point
 *
 * Backend (C++): Database, Services, Repositories stay as-is
 * Frontend (QML): main.qml drives the entire UI
 */
#include "core/Logger.h"
#include "core/Config.h"
#include "core/Database.h"
#include "core/FontManager.h"
#include "core/I18N.h"
#include "services/SettingsService.h"
#include "services/AuthSession.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFontDatabase>
#include <QQuickStyle>
#include <QStandardPaths>

#ifdef Q_OS_WIN
#  undef _WIN32_WINNT
#  define _WIN32_WINNT 0x0600
#  undef WINVER
#  define WINVER 0x0600
#  include <windows.h>
#endif

using namespace mms;

int main(int argc, char* argv[]) {
#ifdef Q_OS_WIN
    SetProcessDPIAware();
#endif

    // High DPI
    qputenv("QT_ENABLE_HIGHDPI_SCALING", "1");
    qputenv("QT_AUTO_SCREEN_SCALE_FACTOR", "1");

    QApplication app(argc, argv);
    app.setApplicationName("MMS");
    app.setOrganizationName("Mahallu Management System");

    // Set QuickStyle to Basic (no system theme interference)
    QQuickStyle::setStyle("Basic");

    // Initialize fonts
    FontManager::instance().loadAll();
    FontManager::instance().applyFont("en");

    // Initialize config
    Config::instance().initialize();

    // Initialize database
    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dbPath);
    dbPath = QDir(dbPath).filePath("mms.db");

    QString exeDir = QCoreApplication::applicationDirPath();
    QString sqlDir = QFile::exists(exeDir + "/sql/schema.sql") ? exeDir + "/sql" : QString();

    if (!Database::instance().initialize(dbPath, sqlDir)) {
        // Try relative path
        Database::instance().initialize("mms.db", "sql");
    }

    // Initialize i18n
    I18N::instance().setLanguage("en");

    // Apply theme
    QString savedTheme = Config::instance().theme();
    if (savedTheme.isEmpty()) savedTheme = "light";
    SettingsService::instance().applyTheme(savedTheme);

    Logger::info("=== Minz Mahallu Management Starting (QML mode) ===");

    // Load QML
    QQmlApplicationEngine engine;

    // Add import paths for QML modules
    engine.addImportPath("qrc:/qml");
    QString qmlDir = QCoreApplication::applicationDirPath() + "/qml";
    if (QDir(qmlDir).exists()) engine.addImportPath(qmlDir);

    // Expose backend to QML
    engine.rootContext()->setContextProperty("appVersion", APP_VERSION_STR);

    engine.load(QUrl("qrc:/qml/main.qml"));
    if (engine.rootObjects().isEmpty()) {
        Logger::error("Failed to load QML main.qml");
        return -1;
    }

    Logger::info("=== QML UI loaded successfully ===");

    int ret = app.exec();

    Logger::info(QString("=== Minz Mahallu Management Exiting (code %1) ===").arg(ret));
    return ret;
}
