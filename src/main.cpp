/*
 * main.cpp — QML entry point with detailed error output
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
#include <QQmlEngine>
#include <QDir>
#include <QFontDatabase>
#include <QQuickStyle>
#include <QStandardPaths>
#include <QMessageBox>

#ifdef Q_OS_WIN
#  undef _WIN32_WINNT
#  define _WIN32_WINNT 0x0600
#  undef WINVER
#  define WINVER 0x0600
#  include <windows.h>
#endif

using namespace mms;

// Simple inline QML — absolute minimum that should always work
static const char* SIMPLE_QML =
"import QtQuick\n"
"import QtQuick.Controls\n"
"ApplicationWindow {\n"
"    visible: true; width: 800; height: 600\n"
"    title: \"MMS\"\n"
"    color: \"#e7f4ea\"\n"
"    Text {\n"
"        anchors.centerIn: parent\n"
"        text: \"MMS is running\"\n"
"        font.pixelSize: 24\n"
"        color: \"#12241b\"\n"
"    }\n"
"}\n";

int main(int argc, char* argv[]) {
#ifdef Q_OS_WIN
    SetProcessDPIAware();
#endif

    qputenv("QT_ENABLE_HIGHDPI_SCALING", "1");

    QApplication app(argc, argv);
    app.setApplicationName("MMS");
    app.setOrganizationName("Mahallu Management System");

    QQuickStyle::setStyle("Basic");

    // Init backend
    FontManager::instance().loadAll();
    FontManager::instance().applyFont("en");
    Config::instance().initialize();

    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dbPath);
    dbPath = QDir(dbPath).filePath("mms.db");
    QString exeDir = QCoreApplication::applicationDirPath();
    QString sqlDir = QFile::exists(exeDir + "/sql/schema.sql") ? exeDir + "/sql" : QString();
    if (!Database::instance().initialize(dbPath, sqlDir)) {
        Database::instance().initialize("mms.db", "sql");
    }
    I18N::instance().setLanguage("en");

    Logger::info("=== MMS Starting ===");

    // Create engine
    QQmlApplicationEngine engine;

    // Capture QML warnings/errors
    QObject::connect(&engine, &QQmlApplicationEngine::warnings, &engine,
        [](const QList<QQmlError> &warnings) {
            for (const auto &w : warnings) {
                QString msg = QString("QML WARNING: %1:%2:%3: %4")
                    .arg(w.url().toString())
                    .arg(w.line())
                    .arg(w.column())
                    .arg(w.description());
                Logger::error(msg);
                fprintf(stderr, "%s\n", msg.toUtf8().constData());
            }
        });

    engine.addImportPath("qrc:/");
    engine.rootContext()->setContextProperty("appVersion", APP_VERSION_STR);

    // STEP 1: Try loading from qrc
    Logger::info("Trying qrc:/qml/main.qml...");
    engine.load(QUrl("qrc:/qml/main.qml"));

    if (engine.rootObjects().isEmpty()) {
        Logger::error("qrc:/qml/main.qml failed");

        // STEP 2: Try simple inline QML (tests if QML engine works at all)
        Logger::info("Trying simple inline QML...");
        engine.loadData(SIMPLE_QML, QUrl("qrc:/simple.qml"));

        if (engine.rootObjects().isEmpty()) {
            Logger::error("Even simple QML failed — QML engine is broken");

            // Last resort: show a message box
            QMessageBox::critical(nullptr, "MMS Error",
                "Failed to initialize QML engine.\n\n"
                "This usually means Qt6Quick.dll or Qt6Qml.dll is missing or corrupted.\n"
                "Please ensure all Qt DLLs are in the same folder as MMS.exe.");
            return -1;
        }

        Logger::info("Simple QML loaded — main.qml has an error");
    } else {
        Logger::info("=== QML UI loaded successfully ===");
    }

    return app.exec();
}
