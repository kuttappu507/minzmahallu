/*
 * app_main.cpp — Main MMS application launcher (QML)
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QFontDatabase>
#include <QDir>
#include <QStandardPaths>
#include <QFile>
#include <cstdio>
#include <csignal>
#include <fstream>
#include <QDateTime>

#include "core/Config.h"
#include "core/Database.h"
#include "core/Logger.h"
#include "core/FontManager.h"
#include "core/I18N.h"
#include "services/SettingsService.h"
#include "services/QmlServices.h"
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

    // Qt 6 uses the Windows Per-Monitor-V2 manifest and native fractional
    // scaling. Do not call Win32 DPI APIs or override Qt scale environment
    // variables here; doing both causes double-scaling and blurry Quick UI.

    logMsg("Step 1: Creating QGuiApplication...");
    QGuiApplication app(argc, argv);
    app.setApplicationName("MinzMahallu");
    app.setOrganizationName("MMS");
    app.setApplicationVersion("1.0.0");
    QQuickStyle::setStyle("Basic");

    // Native text rendering is the correct desktop baseline for crisp text
    // on Windows at 100/125/150% DPI. Avoid CurveTextRendering here because
    // it can make the complete UI appear soft on some Windows GPU/driver
    // combinations.
    QQuickWindow::setTextRenderType(QQuickWindow::NativeTextRendering);

    QString exeDir = QCoreApplication::applicationDirPath();
    g_logFile.open((exeDir + "/mms_error.log").toStdString(), std::ios::out | std::ios::trunc);
    logMsg(QString("Exe dir: %1").arg(exeDir));

    logMsg("Step 2: Loading fonts...");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-SemiBold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/NotoSans-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/NotoSans-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/AnekMalayalam-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/AnekMalayalam-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/AnekMalayalam-SemiBold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/AnekMalayalam-Bold.ttf");
    logMsg("  Fonts OK");

    logMsg("Step 3: Registering Theme singleton...");
    qmlRegisterSingletonType(QUrl("qrc:/qml/theme/Theme.qml"), "MMS.Theme", 1, 0, "Theme");
    logMsg("  Theme OK");

    logMsg("Step 4: Initializing Config...");
    try { mms::Config::instance().initialize("MinzMahallu"); logMsg("  Config OK"); }
    catch (...) { logMsg("  Config FAILED (non-fatal)"); }

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
            sqlDir = exeDir + "/sql";
            logMsg(QString("  Trying fallback sqlDir: %1").arg(sqlDir));
            dbOk = mms::Database::instance().initialize(dbPath, sqlDir);
        }
        logMsg(dbOk ? "  Database OK" : "  Database FAILED — app will launch but operations may fail");
    } catch (const std::exception& e) {
        logMsg(QString("  Database EXCEPTION: %1").arg(e.what()));
    } catch (...) {
        logMsg("  Database UNKNOWN EXCEPTION");
    }

    logMsg("Step 6: FontManager (skipped — fonts loaded in Step 2)");
    logMsg("Step 7: I18N...");
    try { mms::I18N::instance().loadFromSettings(); logMsg("  I18N OK"); }
    catch (...) { logMsg("  I18N FAILED (non-fatal)"); }

    logMsg("Step 8: Settings...");
    try { mms::SettingsService::instance().load(); logMsg("  Settings OK"); }
    catch (...) { logMsg("  Settings FAILED (non-fatal)"); }

    logMsg("Step 9: Creating controllers and models...");
    FamilyController* familyController = new FamilyController(&app);
    FamilyListModel* familyModel = new FamilyListModel(&app); familyModel->setController(familyController);
    MemberController* memberController = new MemberController(&app);
    MemberListModel* memberModel = new MemberListModel(&app); memberModel->setController(memberController);
    SubscriptionController* subscriptionController = new SubscriptionController(&app);
    SubscriptionListModel* subscriptionModel = new SubscriptionListModel(&app); subscriptionModel->setController(subscriptionController);
    DonationController* donationController = new DonationController(&app);
    DonationListModel* donationModel = new DonationListModel(&app); donationModel->setController(donationController);
    AccountingController* accountingController = new AccountingController(&app);
    TransactionListModel* transactionModel = new TransactionListModel(&app); transactionModel->setController(accountingController);
    MarriageController* marriageController = new MarriageController(&app);
    MarriageListModel* marriageModel = new MarriageListModel(&app); marriageModel->connectController(marriageController);
    DeathController* deathController = new DeathController(&app);
    DeathListModel* deathModel = new DeathListModel(&app); deathModel->connectController(deathController);
    WelfareController* welfareController = new WelfareController(&app);
    WelfareListModel* welfareModel = new WelfareListModel(&app); welfareModel->connectController(welfareController);
    UserController* userController = new UserController(&app);
    AuditLogController* auditLogController = new AuditLogController(&app);
    CertificateController* certificateController = new CertificateController(&app);
    ReportController* reportController = new ReportController(&app);
    BackupController* backupController = new BackupController(&app);
    SettingsController* settingsController = new SettingsController(&app);
    AuthController* authController = new AuthController(&app);
    I18NController* i18nController = new I18NController(&app);
    logMsg("  Controllers OK");

    logMsg("Step 10: Creating QML engine...");
    QQmlApplicationEngine engine;
#define CTX(name, value) engine.rootContext()->setContextProperty(name, value)
    CTX("FamilyController", familyController); CTX("familyController", familyController);
    CTX("FamilyModel", familyModel); CTX("familyModel", familyModel);
    CTX("MemberController", memberController); CTX("memberController", memberController);
    CTX("MemberModel", memberModel); CTX("memberModel", memberModel);
    CTX("SubscriptionController", subscriptionController); CTX("subscriptionController", subscriptionController);
    CTX("SubscriptionModel", subscriptionModel); CTX("subscriptionModel", subscriptionModel);
    CTX("DonationController", donationController); CTX("donationController", donationController);
    CTX("DonationModel", donationModel); CTX("donationModel", donationModel);
    CTX("AccountingController", accountingController); CTX("accountingController", accountingController);
    CTX("TransactionModel", transactionModel); CTX("transactionModel", transactionModel);
    CTX("MarriageController", marriageController); CTX("marriageController", marriageController);
    CTX("MarriageModel", marriageModel); CTX("marriageModel", marriageModel);
    CTX("DeathController", deathController); CTX("deathController", deathController);
    CTX("DeathModel", deathModel); CTX("deathModel", deathModel);
    CTX("WelfareController", welfareController); CTX("welfareController", welfareController);
    CTX("WelfareModel", welfareModel); CTX("welfareModel", welfareModel);
    CTX("UserController", userController); CTX("userController", userController);
    CTX("AuditLogController", auditLogController); CTX("auditLogController", auditLogController);
    CTX("CertificateController", certificateController); CTX("certificateController", certificateController);
    CTX("ReportController", reportController); CTX("reportController", reportController);
    CTX("BackupController", backupController); CTX("backupController", backupController);
    CTX("SettingsController", settingsController); CTX("AuthController", authController);
    CTX("I18NController", i18nController);
    QmlServices* services = new QmlServices(&app); CTX("Services", services);
#undef CTX
    logMsg("  Engine OK");

    QObject::connect(&engine, &QQmlApplicationEngine::warnings, &engine, [](const QList<QQmlError>& warnings) {
        for (const auto& w : warnings)
            logMsg(QString("QML WARNING: %1:%2: %3").arg(w.url().toString()).arg(w.line()).arg(w.description()));
    });

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
