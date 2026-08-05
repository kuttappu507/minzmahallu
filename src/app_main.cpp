/*
 * app_main.cpp — Main MMS application launcher
 *
 * Initializes backend (Config, Database, Services) and loads AppShell.qml
 * which contains the sidebar, topbar, and page switching.
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QFontDatabase>
#include <QDir>
#include <QStandardPaths>
#include <cstdio>

#include "core/Config.h"
#include "core/Database.h"
#include "core/Logger.h"
#include "core/FontManager.h"
#include "core/I18N.h"
#include "services/SettingsService.h"
#include "services/QmlServices.h"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("MinzMahallu");
    app.setOrganizationName("MMS");
    app.setApplicationVersion("1.0.0");
    QQuickStyle::setStyle("Basic");

    // Load fonts
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-SemiBold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Bold.ttf");

    // Register Theme singleton
    qmlRegisterSingletonType(QUrl("qrc:/qml/theme/Theme.qml"), "MMS.Theme", 1, 0, "Theme");

    // Initialize backend
    mms::Config::instance().initialize("MinzMahallu");
    QString dbPath = mms::Config::instance().databasePath();
    QString sqlDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(sqlDir);
    
    // Find SQL dir in app bundle
    QString exeDir = QCoreApplication::applicationDirPath();
    if (QFile::exists(exeDir + "/sql/schema.sql")) sqlDir = exeDir + "/sql";
    else if (QFile::exists(":/sql/schema.sql")) sqlDir = "";
    
    if (!mms::Database::instance().initialize(dbPath, sqlDir)) {
        // Try alternate location
        mms::Database::instance().initialize("mms.db", "sql");
    }
    
    mms::FontManager::instance().loadAll();
    mms::FontManager::instance().applyFont("en");
    mms::I18N::instance().setLanguage("en");
    mms::SettingsService::instance().load();

    // Create QmlServices and register as context property
    QmlServices* services = new QmlServices(&app);
    
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("Services", services);

    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        &engine, [](const QList<QQmlError>& warnings) {
            for (const auto& w : warnings)
                std::fprintf(stderr, "QML WARNING: %s:%d: %s\n",
                    w.url().toString().toUtf8().constData(), w.line(),
                    w.description().toUtf8().constData());
        });

    std::fprintf(stderr, "[app] Loading AppShell.qml...\n");
    engine.load(QUrl("qrc:/qml/design/AppShell.qml"));
    if (engine.rootObjects().isEmpty()) {
        std::fprintf(stderr, "[app] FAILED to load\n");
        return 1;
    }
    std::fprintf(stderr, "[app] Loaded. Running.\n");
    return app.exec();
}
