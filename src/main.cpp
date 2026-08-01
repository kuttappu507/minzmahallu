/*
 * main.cpp — QML entry point with error handling
 */
#include "core/Logger.h"
#include "core/Config.h"
#include "core/Database.h"
#include "core/FontManager.h"
#include "core/I18N.h"
#include "services/SettingsService.h"
#include "services/AuthSession.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFontDatabase>
#include <QQuickStyle>
#include <QStandardPaths>
#include <QQuickWindow>

#ifdef Q_OS_WIN
#  undef _WIN32_WINNT
#  define _WIN32_WINNT 0x0600
#  undef WINVER
#  define WINVER 0x0600
#  include <windows.h>
#endif

using namespace mms;

// Fallback QML — shown if the main QML file fails to load
static const char* FALLBACK_QML =
R"QML(
import QtQuick
import QtQuick.Controls
ApplicationWindow {
    visible: true; width: 600; height: 400
    title: "MMS — Error"
    color: "#065f46"
    Column {
        anchors.centerIn: parent; spacing: 20
        Text {
            text: "Failed to load UI"
            font.pixelSize: 24; font.bold: true; color: "#ffffff"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: "The QML file could not be loaded.\nCheck that Qt6Quick.dll and Qt6Qml.dll are present."
            font.pixelSize: 14; color: "#c9ecd9"
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
)QML";

int main(int argc, char* argv[]) {
#ifdef Q_OS_WIN
    SetProcessDPIAware();
#endif

    qputenv("QT_ENABLE_HIGHDPI_SCALING", "1");
    qputenv("QT_AUTO_SCREEN_SCALE_FACTOR", "1");

    // Use QGuiApplication for pure QML (not QApplication which needs Widgets)
    QGuiApplication app(argc, argv);
    app.setApplicationName("MMS");
    app.setOrganizationName("Mahallu Management System");

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
        Database::instance().initialize("mms.db", "sql");
    }

    I18N::instance().setLanguage("en");

    Logger::info("=== Minz Mahallu Management Starting (QML) ===");

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");
    engine.rootContext()->setContextProperty("appVersion", APP_VERSION_STR);

    // Try loading main QML from qrc
    engine.load(QUrl("qrc:/qml/main.qml"));

    if (engine.rootObjects().isEmpty()) {
        Logger::error("Failed to load qrc:/qml/main.qml — trying fallback");

        // Try filesystem path
        QString qmlPath = exeDir + "/qml/main.qml";
        if (QFile::exists(qmlPath)) {
            engine.load(QUrl::fromLocalFile(qmlPath));
        }

        // If still empty, load fallback QML inline
        if (engine.rootObjects().isEmpty()) {
            Logger::error("All QML loading failed — showing error window");
            engine.loadData(FALLBACK_QML, QUrl());
        }
    }

    if (engine.rootObjects().isEmpty()) {
        Logger::error("Even fallback QML failed — aborting");
        return -1;
    }

    Logger::info("=== QML UI loaded ===");
    return app.exec();
}
