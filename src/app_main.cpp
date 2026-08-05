/*
 * app_main.cpp — Main MMS application launcher
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QFontDatabase>
#include <QDir>
#include <QStandardPaths>
#include <QFile>
#include <cstdio>
#include <csignal>
#include <fstream>
#include <QDateTime>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

#include "core/Config.h"
#include "core/Database.h"
#include "core/Logger.h"
#include "core/FontManager.h"
#include "core/I18N.h"
#include "services/SettingsService.h"
#include "services/QmlServices.h"

static std::ofstream g_logFile;

void logMsg(const QString& msg) {
    QString ts = QDateTime::currentDateTime().toString("hh:mm:ss.zzz");
    QString line = QString("[%1] %2").arg(ts, msg);
    if (g_logFile.is_open()) { g_logFile << line.toStdString() << std::endl; g_logFile.flush(); }
    std::fprintf(stderr, "%s\n", line.toUtf8().constData());
}

void crashHandler(int sig) {
    logMsg(QString("CRASH! Signal %1").arg(sig));
    if (g_logFile.is_open()) { g_logFile << "=== CRASHED ===" << std::endl; g_logFile.close(); }
    exit(1);
}


int main(int argc, char* argv[]) {
    std::signal(SIGSEGV, crashHandler);
    std::signal(SIGABRT, crashHandler);

#ifdef Q_OS_WIN
    AllocConsole();
    freopen("CONOUT$", "w", stdout);
    freopen("CONOUT$", "w", stderr);
    SetProcessDPIAware();
#endif

    qputenv("QT_ENABLE_HIGHDPI_SCALING", "1");

    logMsg("Step 1: Creating QGuiApplication...");
    QGuiApplication app(argc, argv);
    app.setApplicationName("MinzMahallu");
    app.setOrganizationName("MMS");
    app.setApplicationVersion("1.0.0");
    QQuickStyle::setStyle("Basic");

    QString exeDir = QCoreApplication::applicationDirPath();
    g_logFile.open((exeDir + "/mms_error.log").toStdString(), std::ios::out | std::ios::trunc);
    logMsg(QString("Exe dir: %1").arg(exeDir));

    // Load fonts from qrc
    logMsg("Step 2: Loading fonts...");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-SemiBold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Bold.ttf");
    // Also load fonts from mms.qrc (NotoSans, AnekMalayalam)
    QFontDatabase::addApplicationFont(":/fonts/NotoSans-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/NotoSans-Bold.ttf");
    logMsg("  Fonts OK");

    // Register Theme singleton
    logMsg("Step 3: Registering Theme singleton...");
    qmlRegisterSingletonType(QUrl("qrc:/qml/theme/Theme.qml"), "MMS.Theme", 1, 0, "Theme");
    logMsg("  Theme OK");

    // Initialize Config
    logMsg("Step 4: Initializing Config...");
    try { mms::Config::instance().initialize("MinzMahallu"); logMsg("  Config OK"); }
    catch (...) { logMsg("  Config FAILED (non-fatal)"); }

    // Initialize Database
    logMsg("Step 5: Initializing Database...");
    try {
        QString dbPath = mms::Config::instance().databasePath();
        QString sqlDir = exeDir + "/sql";
        logMsg(QString("  dbPath: %1").arg(dbPath));
        logMsg(QString("  sqlDir: %1").arg(sqlDir));
        logMsg(QString("  sql/schema.sql exists: %1").arg(QFile::exists(sqlDir + "/schema.sql") ? "YES" : "NO"));
        
        if (!mms::Database::instance().initialize(dbPath, sqlDir)) {
            logMsg("  Database init failed, trying alternate...");
            mms::Database::instance().initialize("mms.db", "sql");
        }
        logMsg("  Database OK");
    } catch (...) { logMsg("  Database FAILED (non-fatal)"); }

    // Skip FontManager — fonts already loaded above via QFontDatabase
    logMsg("Step 6: FontManager (skipped — fonts loaded in Step 2)");

    // I18N
    logMsg("Step 7: I18N...");
    try { mms::I18N::instance().setLanguage("en"); logMsg("  I18N OK"); }
    catch (...) { logMsg("  I18N FAILED (non-fatal)"); }

    // Settings
    logMsg("Step 8: Settings...");
    try { mms::SettingsService::instance().load(); logMsg("  Settings OK"); }
    catch (...) { logMsg("  Settings FAILED (non-fatal)"); }

    // Create QmlServices
    logMsg("Step 9: Creating QmlServices...");
    QmlServices* services = new QmlServices(&app);
    logMsg("  QmlServices OK");

    // Create QML engine
    logMsg("Step 10: Creating QML engine...");
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("Services", services);
    logMsg("  Engine OK");

    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        &engine, [](const QList<QQmlError>& warnings) {
            for (const auto& w : warnings)
                logMsg(QString("QML WARNING: %1:%2: %3").arg(w.url().toString()).arg(w.line()).arg(w.description()));
        });

    // Load AppShell
    logMsg("Step 11: Loading AppShell.qml...");
    engine.load(QUrl("qrc:/qml/design/AppShell.qml"));

    if (engine.rootObjects().isEmpty()) {
        logMsg("FAILED: QML did not load!");
        if (g_logFile.is_open()) g_logFile.close();
        return -1;
    }

    logMsg("SUCCESS: AppShell loaded. Running event loop.");
    int ret = app.exec();
    logMsg(QString("Exited with code %1").arg(ret));
    if (g_logFile.is_open()) g_logFile.close();
    return ret;
}
