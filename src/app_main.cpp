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
#include <QScreen>
#include <QSurfaceFormat>
#include <QColorSpace>
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
#include "services/FamilyController.h"
#include "services/FamilyListModel.h"
#include "services/MemberController.h"
#include "services/MemberListModel.h"
#include "services/SubscriptionController.h"
#include "services/SubscriptionListModel.h"
#include "services/DonationController.h"
#include "services/DonationListModel.h"
#include "services/AccountingController.h"
#include "services/TransactionListModel.h"
#include "services/RegisterControllers.h"
#include "services/RegisterListModels.h"
#include "services/UserController.h"
#include "services/AuditLogController.h"
#include "services/MiscControllers.h"
#include "services/AuthController.h"
#include "services/I18NController.h"
#include "services/DashboardController.h"

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
    // Qt 6 is natively Per-Monitor-V2 DPI aware on Windows via the
    // embedded application manifest (resources/app.manifest).
    // Do NOT call SetProcessDpiAwarenessContext — it conflicts with Qt.
#endif

    // ===== HIGH-DPI COLOR FIX (BEFORE QGuiApplication) =====
    // Force explicit 8-bit RGBA channel depth and standard sRGB color space.
    // This prevents DXGI swapchain from negotiating BGRA or extended color
    // spaces under Windows High-DPI scaling or HDR environments, which
    // causes Red/Blue channel swap.
    QSurfaceFormat format;
    format.setRedBufferSize(8);
    format.setGreenBufferSize(8);
    format.setBlueBufferSize(8);
    format.setAlphaBufferSize(8);
    format.setColorSpace(QColorSpace::SRgb);
    QSurfaceFormat::setDefaultFormat(format);

    // Fix Windows High-DPI rounding policy — PassThrough means exact scaling
    // (e.g. 1.25x for 125%, 1.5x for 150%) — no integer rounding blur.
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough
    );

    // RHI backend fallback — if D3D11 causes color distortion, try OpenGL.
    // Default: let Qt choose (usually D3D11 on Windows).
    // qputenv("QSG_RHI_BACKEND", "opengl");  // Uncomment if D3D causes issues

    logMsg("Step 1: Creating QGuiApplication...");
    QGuiApplication app(argc, argv);
    app.setApplicationName("MinzMahallu");
    app.setOrganizationName("MMS");
    app.setApplicationVersion("1.0.0");
    QQuickStyle::setStyle("Basic");

    QString exeDir = QCoreApplication::applicationDirPath();
    g_logFile.open((exeDir + "/mms_error.log").toStdString(), std::ios::out | std::ios::trunc);
    logMsg(QString("Exe dir: %1").arg(exeDir));

    // Log DPI diagnostics
    auto screen = app.primaryScreen();
    if (screen) {
        logMsg(QString("  Screen: %1 | Logical DPI: %2 | Physical DPI: %3 | devicePixelRatio: %4")
               .arg(screen->name())
               .arg(screen->logicalDotsPerInch())
               .arg(screen->physicalDotsPerInch())
               .arg(screen->devicePixelRatio()));
        logMsg(QString("  Geometry: %1x%2 | Available: %3x%4")
               .arg(screen->size().width()).arg(screen->size().height())
               .arg(screen->availableSize().width()).arg(screen->availableSize().height()));
    }

    // Load fonts from qrc
    logMsg("Step 2: Loading fonts...");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-SemiBold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/NotoSans-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/NotoSans-Bold.ttf");
    // Load Anek Malayalam fonts for Malayalam language support
    QFontDatabase::addApplicationFont(":/fonts/AnekMalayalam-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/AnekMalayalam-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/AnekMalayalam-SemiBold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/AnekMalayalam-Bold.ttf");
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

    // I18N — load language from settings
    logMsg("Step 7: I18N...");
    try { mms::I18N::instance().loadFromSettings(); logMsg("  I18N OK"); }
    catch (...) { logMsg("  I18N FAILED (non-fatal)"); }

    // Settings
    logMsg("Step 8: Settings...");
    try { mms::SettingsService::instance().load(); logMsg("  Settings OK"); }
    catch (...) { logMsg("  Settings FAILED (non-fatal)"); }

    // Create FamilyController + FamilyListModel
    logMsg("Step 9: Creating FamilyController + FamilyListModel + MemberController + MemberListModel...");
    FamilyController* familyController = new FamilyController(&app);
    FamilyListModel* familyModel = new FamilyListModel(&app);
    familyModel->setController(familyController);  // auto-refresh on CRUD

    MemberController* memberController = new MemberController(&app);
    MemberListModel* memberModel = new MemberListModel(&app);
    memberModel->setController(memberController);  // auto-refresh on CRUD

    SubscriptionController* subscriptionController = new SubscriptionController(&app);
    SubscriptionListModel* subscriptionModel = new SubscriptionListModel(&app);
    subscriptionModel->setController(subscriptionController);

    DonationController* donationController = new DonationController(&app);
    DonationListModel* donationModel = new DonationListModel(&app);
    donationModel->setController(donationController);

    AccountingController* accountingController = new AccountingController(&app);
    TransactionListModel* transactionModel = new TransactionListModel(&app);
    transactionModel->setController(accountingController);

    MarriageController* marriageController = new MarriageController(&app);
    MarriageListModel* marriageModel = new MarriageListModel(&app);
    marriageModel->connectController(marriageController);

    DeathController* deathController = new DeathController(&app);
    DeathListModel* deathModel = new DeathListModel(&app);
    deathModel->connectController(deathController);

    WelfareController* welfareController = new WelfareController(&app);
    WelfareListModel* welfareModel = new WelfareListModel(&app);
    welfareModel->connectController(welfareController);

    UserController* userController = new UserController(&app);
    AuditLogController* auditLogController = new AuditLogController(&app);

    CertificateController* certificateController = new CertificateController(&app);
    ReportController* reportController = new ReportController(&app);
    BackupController* backupController = new BackupController(&app);
    SettingsController* settingsController = new SettingsController(&app);

    AuthController* authController = new AuthController(&app);
    I18NController* i18NController = new I18NController(&app);
    DashboardController* dashboardController = new DashboardController(&app);
    // Connect dashboard to all controllers' CRUD signals for auto-refresh
    dashboardController->connectToSignals(
        familyController, memberController, subscriptionController,
        donationController, accountingController,
        marriageController, deathController, welfareController);
    logMsg("  Controllers OK");

    // Create QML engine
    logMsg("Step 10: Creating QML engine...");
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("FamilyController", familyController);
    engine.rootContext()->setContextProperty("familyController", familyController);
    engine.rootContext()->setContextProperty("FamilyModel", familyModel);
    engine.rootContext()->setContextProperty("familyModel", familyModel);
    engine.rootContext()->setContextProperty("MemberController", memberController);
    engine.rootContext()->setContextProperty("memberController", memberController);
    engine.rootContext()->setContextProperty("MemberModel", memberModel);
    engine.rootContext()->setContextProperty("memberModel", memberModel);
    engine.rootContext()->setContextProperty("SubscriptionController", subscriptionController);
    engine.rootContext()->setContextProperty("subscriptionController", subscriptionController);
    engine.rootContext()->setContextProperty("SubscriptionModel", subscriptionModel);
    engine.rootContext()->setContextProperty("subscriptionModel", subscriptionModel);
    engine.rootContext()->setContextProperty("DonationController", donationController);
    engine.rootContext()->setContextProperty("donationController", donationController);
    engine.rootContext()->setContextProperty("DonationModel", donationModel);
    engine.rootContext()->setContextProperty("donationModel", donationModel);
    engine.rootContext()->setContextProperty("AccountingController", accountingController);
    engine.rootContext()->setContextProperty("accountingController", accountingController);
    engine.rootContext()->setContextProperty("TransactionModel", transactionModel);
    engine.rootContext()->setContextProperty("transactionModel", transactionModel);
    engine.rootContext()->setContextProperty("MarriageController", marriageController);
    engine.rootContext()->setContextProperty("marriageController", marriageController);
    engine.rootContext()->setContextProperty("MarriageModel", marriageModel);
    engine.rootContext()->setContextProperty("marriageModel", marriageModel);
    engine.rootContext()->setContextProperty("DeathController", deathController);
    engine.rootContext()->setContextProperty("deathController", deathController);
    engine.rootContext()->setContextProperty("DeathModel", deathModel);
    engine.rootContext()->setContextProperty("deathModel", deathModel);
    engine.rootContext()->setContextProperty("WelfareController", welfareController);
    engine.rootContext()->setContextProperty("welfareController", welfareController);
    engine.rootContext()->setContextProperty("WelfareModel", welfareModel);
    engine.rootContext()->setContextProperty("welfareModel", welfareModel);
    engine.rootContext()->setContextProperty("UserController", userController);
    engine.rootContext()->setContextProperty("userController", userController);
    engine.rootContext()->setContextProperty("AuditLogController", auditLogController);
    engine.rootContext()->setContextProperty("auditLogController", auditLogController);
    engine.rootContext()->setContextProperty("CertificateController", certificateController);
    engine.rootContext()->setContextProperty("ReportController", reportController);
    engine.rootContext()->setContextProperty("BackupController", backupController);
    engine.rootContext()->setContextProperty("SettingsController", settingsController);
    engine.rootContext()->setContextProperty("AuthController", authController);
    engine.rootContext()->setContextProperty("I18NController", i18NController);
    engine.rootContext()->setContextProperty("DashboardController", dashboardController);
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
// trigger
