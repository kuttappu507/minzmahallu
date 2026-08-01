/*
 * main.cpp — QML entry point with verbose logging
 * 
 * Uses qt_add_qml_module registered QML at qrc:/qml/main.qml
 * Falls back to filesystem path if qrc fails.
 * Prints detailed diagnostics to stdout/stderr.
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
#include <QFile>
#include <QFontDatabase>
#include <QQuickStyle>
#include <QStandardPaths>
#include <iostream>

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

    qputenv("QT_ENABLE_HIGHDPI_SCALING", "1");

    std::cout << "[MMS] Starting application..." << std::endl;

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

    QQmlApplicationEngine engine;

    // Verbose QML error capture
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() {
            std::cerr << "[MMS CRITICAL] QML object creation failed!" << std::endl;
        }, Qt::QueuedConnection);

    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        &engine, [](const QList<QQmlError> &warnings) {
            for (const auto &w : warnings) {
                std::cerr << "[MMS QML WARNING] " << w.url().toString().toStdString()
                          << ":" << w.line() << ":" << w.column() << ": "
                          << w.description().toStdString() << std::endl;
            }
        });

    engine.rootContext()->setContextProperty("appVersion", APP_VERSION_STR);

    // STEP 1: Try qrc:/qml/main.qml (registered by qt_add_qml_module)
    QUrl qrcUrl("qrc:/qml/main.qml");
    std::cout << "[MMS] Loading QML from: " << qrcUrl.toString().toStdString() << std::endl;

    engine.load(qrcUrl);

    // STEP 2: If qrc fails, try filesystem path
    if (engine.rootObjects().isEmpty()) {
        std::cout << "[MMS WARNING] QRC load failed. Trying filesystem..." << std::endl;

        // Try multiple filesystem locations
        QStringList paths = {
            exeDir + "/qml/main.qml",
            exeDir + "/resources/qml/main.qml",
            QCoreApplication::applicationDirPath() + "/../qml/main.qml",
        };

        for (const auto& path : paths) {
            std::cout << "[MMS] Checking: " << path.toStdString() << std::endl;
            if (QFile::exists(path)) {
                std::cout << "[MMS] Found! Loading from disk..." << std::endl;
                engine.load(QUrl::fromLocalFile(path));
                if (!engine.rootObjects().isEmpty()) break;
            }
        }
    }

    // STEP 3: Final check
    if (engine.rootObjects().isEmpty()) {
        std::cerr << "[MMS FATAL] All QML loading attempts failed!" << std::endl;
        std::cerr << "[MMS] Checked: qrc:/qml/main.qml" << std::endl;
        std::cerr << "[MMS] Checked: " << (exeDir + "/qml/main.qml").toStdString() << std::endl;
        return -1;
    }

    std::cout << "[MMS RUNNING] QML UI loaded successfully." << std::endl;
    Logger::info("=== QML UI loaded ===");

    return app.exec();
}
