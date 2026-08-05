/*
 * app_main.cpp — Main MMS application launcher (QML)
 *
 * Initializes:
 *   1. QGuiApplication + QQuickStyle
 *   2. Fonts (from qrc)
 *   3. Theme singleton
 *   4. Config (paths)
 *   5. Database (schema + seed + migrations) — CRITICAL: if this fails,
 *      we still launch but expose databaseReady=false to QML so the UI
 *      can show an error screen instead of silently failing every query.
 *   6. I18N + Settings
 *   7. FamilyController + FamilyListModel (registered as context properties)
 *   8. QML engine + load AppShell.qml
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
#include "services/FamilyController.h"
#include "services/FamilyListModel.h"

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

    // Initialize Database — CRITICAL
    // If this fails, the app still launches but FamilyController.databaseReady
    // will be false, and every service call will fail with a visible error.
    logMsg("Step 5: Initializing Database...");
    bool dbOk = false;
    try {
        QString dbPath = mms::Config::instance().databasePath();
        QString sqlDir = mms::Config::instance().sqlDir();
        logMsg(QString("  dbPath: %1").arg(dbPath));
        logMsg(QString("  sqlDir: %1").arg(sqlDir));
        logMsg(QString("  sql/schema.sql exists: %1").arg(QFile::exists(sqlDir + "/schema.sql") ? "YES" : "NO"));

        dbOk = mms::Database::instance().initialize(dbPath, sqlDir);
        if (!dbOk) {
            logMsg(QString("  Database init FAILED: %1").arg(mms::Database::instance().lastErrorText()));
            // Try fallback — exeDir/sql
            sqlDir = exeDir + "/sql";
            logMsg(QString("  Trying fallback sqlDir: %1").arg(sqlDir));
            dbOk = mms::Database::instance().initialize(dbPath, sqlDir);
        }
        if (dbOk) {
            logMsg("  Database OK");
        } else {
            logMsg("  Database FAILED — app will launch but all operations will fail");
        }
    } catch (const std::exception& e) {
        logMsg(QString("  Database EXCEPTION: %1").arg(e.what()));
    } catch (...) {
        logMsg("  Database UNKNOWN EXCEPTION");
    }

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

    // Create FamilyController + FamilyListModel
    logMsg("Step 9: Creating FamilyController + FamilyListModel...");
    FamilyController* familyController = new FamilyController(&app);
    FamilyListModel* familyModel = new FamilyListModel(&app);
    familyModel->setController(familyController);  // auto-refresh on CRUD
    logMsg("  Controllers OK");

    // Create QML engine
    logMsg("Step 10: Creating QML engine...");
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("FamilyController", familyController);
    engine.rootContext()->setContextProperty("familyController", familyController);
    engine.rootContext()->setContextProperty("FamilyModel", familyModel);
    engine.rootContext()->setContextProperty("familyModel", familyModel);

    // Keep legacy QmlServices for backward compat during migration (other
    // modules may still reference "Services"). Can be removed once all
    // modules have their own controllers.
    QmlServices* services = new QmlServices(&app);
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
