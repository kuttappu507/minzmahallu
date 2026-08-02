#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QFile>
#include <QDir>
#include <QDateTime>
#include <QStandardPaths>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <csignal>
#include <cstdlib>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

// Backend includes
#include "core/Logger.h"
#include "core/Config.h"
#include "core/Database.h"
#include "core/FontManager.h"
#include "core/I18N.h"
#include "services/SettingsService.h"
#include "services/AuthSession.h"

using namespace mms;

static std::ofstream g_logFile;

void logMsg(const QString& msg) {
    QString ts = QDateTime::currentDateTime().toString("hh:mm:ss.zzz");
    QString line = QString("[%1] %2").arg(ts, msg);
    if (g_logFile.is_open()) { g_logFile << line.toStdString() << std::endl; g_logFile.flush(); }
    std::cout << line.toStdString() << std::endl; fflush(stdout);
}

void crashHandler(int sig) {
    logMsg(QString("CRASH! Signal %1").arg(sig));
    if (g_logFile.is_open()) { g_logFile << "=== CRASHED ===" << std::endl; g_logFile.close(); }
    exit(1);
}

// Full main.qml embedded as raw string
static const char* MAIN_QML = R"QML(
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: win
    visible: true
    width: 1366; height: 768
    minimumWidth: 1200; minimumHeight: 700
    color: "#e7f4ea"
    title: "Minz Mahallu Management"

    property bool sidebarCollapsed: false
    property string currentUser: "Administrator"
    property string currentRole: "Administrator"
    property int currentNavIndex: 0

    // Splash — centered, not fullscreen
    Rectangle {
        id: splash
        anchors.fill: parent; z: 100
        color: "#065f46"; visible: true; opacity: 1
        Column {
            anchors.centerIn: parent; spacing: 16
            Text {
                text: "Minz Mahallu Management"
                font.family: "Poppins"; font.pixelSize: 26; font.weight: Font.Bold
                color: "#ffffff"; anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: "Mosque Community Administration"
                font.family: "Poppins"; font.pixelSize: 13; color: "#c9ecd9"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                width: 200; height: 6; radius: 3; color: "#04463a"
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: parent.width * 0.7; height: parent.height; radius: 3; color: "#f2c14e"
                    NumberAnimation on width { from: 0; to: 140; duration: 1800; running: true }
                }
            }
        }
        Timer { interval: 2200; running: true; onTriggered: { splash.opacity = 0; fade.running = true } }
        NumberAnimation { id: fade; target: splash; property: "opacity"; to: 0; duration: 500; onStopped: splash.visible = false }
    }

    RowLayout {
        anchors.fill: parent; spacing: 0

        // ===== SIDEBAR =====
        Rectangle {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: sidebarCollapsed ? 80 : 260
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            clip: true
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#0a7f5d" }
                GradientStop { position: 0.42; color: "#065f46" }
                GradientStop { position: 1.0; color: "#044633" }
            }

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                // Logo area
                Item {
                    Layout.fillWidth: true; Layout.preferredHeight: 76
                    Text {
                        anchors.centerIn: parent
                        text: "MMS"
                        font.family: "Space Grotesk"; font.pixelSize: 22; font.weight: Font.Bold
                        color: "#ffffff"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Nav list
                ListView {
                    id: navList
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; model: navModel; delegate: navDelegate
                    currentIndex: win.currentNavIndex
                    onCurrentIndexChanged: win.currentNavIndex = currentIndex
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                }

                // User card
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 72
                    color: "transparent"
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Qt.rgba(1,1,1,0.14) }
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 10
                        Rectangle {
                            width: 36; height: 36; radius: 9
                            color: "#f2c14e"; border.width: 2; border.color: "#b98317"
                            Text {
                                anchors.centerIn: parent
                                text: "A"
                                font.family: "Space Grotesk"; font.pixelSize: 13; font.weight: Font.Bold
                                color: "#4a3606"
                                verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        ColumnLayout {
                            spacing: 2; visible: !sidebarCollapsed
                            Text {
                                text: win.currentUser
                                font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Bold
                                color: "#ffffff"
                                verticalAlignment: Text.AlignVCenter
                            }
                            Text {
                                text: win.currentRole
                                font.family: "Poppins"; font.pixelSize: 10
                                color: "#9fd8c3"
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // Flap button
            Rectangle {
                width: 26; height: 62; radius: 9
                anchors.right: parent.right; anchors.rightMargin: -13
                anchors.verticalCenter: parent.verticalCenter
                color: flapMA.containsMouse ? "#0aa06f" : "#047857"
                border.width: 1; border.color: "#0a7f5d"; z: 50
                Text {
                    anchors.centerIn: parent
                    text: sidebarCollapsed ? ">" : "<"
                    color: "#ffffff"; font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                }
                MouseArea { id: flapMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sidebarCollapsed = !sidebarCollapsed }
            }
        }

        // ===== MAIN COLUMN =====
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

            // Top bar
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 58
                color: "#ffffff"
                Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1.5; color: "#d2e5d8" }
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 18; anchors.rightMargin: 18; spacing: 13
                    Text {
                        text: "Minz Mahallu /"
                        font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.DemiBold
                        color: "#7e968a"
                        verticalAlignment: Text.AlignVCenter
                    }
                    Text {
                        text: navModel.get(win.currentNavIndex) ? navModel.get(win.currentNavIndex).title : ""
                        font.family: "Space Grotesk"; font.pixelSize: 15; font.weight: Font.Bold
                        color: "#12241b"
                        verticalAlignment: Text.AlignVCenter
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "v1.0.0"
                        font.family: "Poppins"; font.pixelSize: 11
                        color: "#7e968a"
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Content area
            StackLayout {
                id: contentStack
                Layout.fillWidth: true; Layout.fillHeight: true
                currentIndex: win.currentNavIndex

                // ===== DASHBOARD =====
                ScrollView {
                    clip: true
                    ColumnLayout {
                        width: contentStack.width; spacing: 16
                        Layout.leftMargin: 22; Layout.rightMargin: 22; Layout.topMargin: 20; Layout.bottomMargin: 26

                        // Header
                        RowLayout {
                            Layout.fillWidth: true; spacing: 14
                            ColumnLayout {
                                spacing: 4
                                Text {
                                    text: "Assalamu Alaikum, " + win.currentUser
                                    font.family: "Space Grotesk"; font.pixelSize: 21; font.weight: Font.Bold
                                    color: "#12241b"
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Text {
                                    text: "Here's what's happening in your mahallu today."
                                    font.family: "Poppins"; font.pixelSize: 12
                                    color: "#4f6b5c"
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                radius: 7; color: "#e6ebf2"; border.width: 1.5; border.color: "#64748b"
                                implicitHeight: 32; Layout.rightMargin: 8
                                Text {
                                    anchors.centerIn: parent; anchors.margins: 12
                                    text: Qt.formatDate(new Date(), "dddd, dd MMMM yyyy")
                                    font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Bold
                                    color: "#33415c"
                                    verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        // Stat cards 5x2
                        GridLayout {
                            Layout.fillWidth: true; columns: 5; columnSpacing: 12; rowSpacing: 12
                            Repeater {
                                model: ListModel {
                                    ListElement { label: "FAMILIES"; value: "248"; delta: "+6 this month"; up: 1; bg: "#d3f5e6"; bc: "#059669"; tc: "#04543c" }
                                    ListElement { label: "MEMBERS"; value: "1,142"; delta: "+18 this month"; up: 1; bg: "#c8f6f1"; bc: "#0d9488"; tc: "#0f5e54" }
                                    ListElement { label: "ACTIVE"; value: "986"; delta: "86.3% active"; up: 1; bg: "#d7edfb"; bc: "#0284c7"; tc: "#0a5480" }
                                    ListElement { label: "COLLECTION"; value: "Rs.48,200"; delta: "+9.1% vs June"; up: 1; bg: "#fcebc8"; bc: "#d97706"; tc: "#7c4403" }
                                    ListElement { label: "DUES"; value: "Rs.36,400"; delta: "7 families overdue"; up: 0; bg: "#fddfe5"; bc: "#e11d48"; tc: "#95102e" }
                                    ListElement { label: "DONATIONS"; value: "Rs.92,750"; delta: "+12.4% vs June"; up: 1; bg: "#fadfeb"; bc: "#db2777"; tc: "#93184f" }
                                    ListElement { label: "WELFARE"; value: "Rs.1,45,000"; delta: "14 beneficiaries"; up: 1; bg: "#e7defc"; bc: "#7c3aed"; tc: "#5423b7" }
                                    ListElement { label: "MARRIAGES"; value: "17"; delta: "2 this quarter"; up: 1; bg: "#ffe4cf"; bc: "#ea580c"; tc: "#8f3708" }
                                    ListElement { label: "DEATHS"; value: "9"; delta: "1 this month"; up: 0; bg: "#e6ebf2"; bc: "#64748b"; tc: "#33415c" }
                                    ListElement { label: "BALANCE"; value: "Rs.4,56,320"; delta: "across all funds"; up: 1; bg: "#dbe7fd"; bc: "#2563eb"; tc: "#1e3fae" }
                                }
                                delegate: Rectangle {
                                    Layout.fillWidth: true; radius: 10
                                    color: model.bg; border.width: 1.5; border.color: model.bc
                                    implicitHeight: 130
                                    ColumnLayout {
                                        anchors.fill: parent; anchors.margins: 14; spacing: 8
                                        // Top row: icon + delta
                                        RowLayout {
                                            Layout.fillWidth: true; spacing: 8
                                            Rectangle {
                                                width: 37; height: 37; radius: 9; color: model.bc
                                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                            }
                                            Item { Layout.fillWidth: true }
                                            Rectangle {
                                                radius: 99; color: "#ffffff"; border.width: 1.5; border.color: model.bc
                                                implicitHeight: 22
                                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                                Text {
                                                    anchors.centerIn: parent; anchors.margins: 8
                                                    text: (model.up ? "^ " : "v ") + model.delta
                                                    font.family: "Poppins"; font.pixelSize: 9; font.weight: Font.Black
                                                    color: model.tc
                                                    verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                                                }
                                            }
                                        }
                                        // Value
                                        Text {
                                            text: model.value
                                            font.family: "Space Grotesk"; font.pixelSize: 22; font.weight: Font.Bold
                                            color: model.tc
                                            Layout.fillWidth: true; elide: Text.ElideRight
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        // Label
                                        Text {
                                            text: model.label
                                            font.family: "Poppins"; font.pixelSize: 9; font.weight: Font.Black
                                            color: model.tc; opacity: 0.75
                                            Layout.fillWidth: true; elide: Text.ElideRight
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }

                        // Chart placeholders 2x2
                        GridLayout {
                            Layout.fillWidth: true; columns: 2; columnSpacing: 12; rowSpacing: 12
                            Repeater {
                                model: ListModel {
                                    ListElement { title: "Collections"; sub: "Subscription receipts - last 12 months" }
                                    ListElement { title: "Donations"; sub: "All categories - last 12 months" }
                                    ListElement { title: "Income vs Expense"; sub: "Financial year 2026-27 - to date" }
                                    ListElement { title: "Membership Growth"; sub: "Total registered members" }
                                }
                                delegate: Rectangle {
                                    Layout.fillWidth: true; Layout.minimumHeight: 220
                                    radius: 10; color: "#ffffff"; border.width: 1.5; border.color: "#d2e5d8"
                                    ColumnLayout {
                                        anchors.fill: parent; anchors.margins: 16; spacing: 4
                                        Text {
                                            text: model.title
                                            font.family: "Poppins"; font.pixelSize: 14; font.weight: Font.Bold
                                            color: "#12241b"
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        Text {
                                            text: model.sub
                                            font.family: "Poppins"; font.pixelSize: 11
                                            color: "#7e968a"
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        Item { Layout.fillWidth: true; Layout.fillHeight: true }
                                    }
                                }
                            }
                        }

                        // Recent activity
                        Rectangle {
                            Layout.fillWidth: true
                            radius: 10; color: "#ffffff"; border.width: 1.5; border.color: "#d2e5d8"
                            implicitHeight: 280
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 16; spacing: 6
                                Text {
                                    text: "Recent Activity"
                                    font.family: "Poppins"; font.pixelSize: 14; font.weight: Font.Bold
                                    color: "#12241b"
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Text {
                                    text: "Latest user actions across all modules"
                                    font.family: "Poppins"; font.pixelSize: 11
                                    color: "#7e968a"
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Item { Layout.fillHeight: true }
                            }
                        }
                    }
                }

                // ===== OTHER VIEWS (placeholder) =====
                Repeater {
                    model: 15
                    delegate: Rectangle {
                        color: "#e7f4ea"
                        Text {
                            anchors.centerIn: parent
                            text: navModel.get(index + 1) ? navModel.get(index + 1).title : ""
                            font.family: "Poppins"; font.pixelSize: 24; color: "#7e968a"
                            verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // Status bar
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 28
                color: "#f2faf4"
                Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1.5; color: "#d2e5d8" }
                Text {
                    anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter
                    text: "Ready"
                    font.family: "Poppins"; font.pixelSize: 11; color: "#4f6b5c"
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    ListModel {
        id: navModel
        ListElement { title: "Dashboard" }
        ListElement { title: "Families" }
        ListElement { title: "Members" }
        ListElement { title: "Subscriptions" }
        ListElement { title: "Donations" }
        ListElement { title: "Accounting" }
        ListElement { title: "Marriage" }
        ListElement { title: "Death" }
        ListElement { title: "Welfare" }
        ListElement { title: "Certificates" }
        ListElement { title: "Tokens" }
        ListElement { title: "Reports" }
        ListElement { title: "Settings" }
        ListElement { title: "Users" }
        ListElement { title: "Audit Log" }
        ListElement { title: "Backup" }
    }

    Component {
        id: navDelegate
        Rectangle {
            width: navList.width; height: 44; radius: 9
            color: navMA.containsMouse ? Qt.rgba(1,1,1,0.09) : (navList.currentIndex === index ? Qt.rgba(1,1,1,0.14) : "transparent")
            Behavior on color { ColorAnimation { duration: 140 } }
            Rectangle {
                visible: navList.currentIndex === index
                width: 4; height: 22; radius: 2; color: "#f2c14e"
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                anchors.fill: parent; anchors.leftMargin: 24
                verticalAlignment: Text.AlignVCenter
                text: model.title
                font.family: "Poppins"; font.pixelSize: 13; font.weight: Font.Bold
                color: navList.currentIndex === index ? "#ffffff" : "#c4e7d7"
                elide: Text.ElideRight; visible: !sidebarCollapsed
            }
            MouseArea { id: navMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: navList.currentIndex = index }
        }
    }
}
)QML";

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

    logMsg("Step 1: Creating QApplication...");
    QApplication app(argc, argv);
    app.setApplicationName("MMS");
    app.setOrganizationName("Mahallu Management System");

    QString exeDir = QCoreApplication::applicationDirPath();
    g_logFile.open((exeDir + "/mms_error.log").toStdString(), std::ios::out | std::ios::trunc);
    logMsg(QString("Exe dir: %1").arg(exeDir));

    // Backend init — each step wrapped with error handling
    logMsg("Step 2: Loading fonts...");
    try { FontManager::instance().loadAll(); FontManager::instance().applyFont("en"); logMsg("  Fonts OK"); }
    catch (...) { logMsg("  Fonts FAILED (non-fatal)"); }

    logMsg("Step 3: Loading config...");
    try { Config::instance().initialize(); logMsg("  Config OK"); }
    catch (...) { logMsg("  Config FAILED (non-fatal)"); }

    logMsg("Step 4: Initializing database...");
    try {
        QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir().mkpath(dbPath);
        dbPath = QDir(dbPath).filePath("mms.db");
        QString sqlDir = QFile::exists(exeDir + "/sql/schema.sql") ? exeDir + "/sql" : QString();
        if (!Database::instance().initialize(dbPath, sqlDir)) {
            Database::instance().initialize("mms.db", "sql");
        }
        logMsg("  Database OK");
    } catch (...) { logMsg("  Database FAILED (non-fatal)"); }

    logMsg("Step 5: Setting up i18n...");
    try { I18N::instance().setLanguage("en"); logMsg("  I18N OK"); }
    catch (...) { logMsg("  I18N FAILED (non-fatal)"); }

    logMsg("Step 6: Setting QuickStyle...");
    QQuickStyle::setStyle("Basic");

    logMsg("Step 7: Creating QML engine...");
    QQmlApplicationEngine engine;

    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        &engine, [](const QList<QQmlError> &warnings) {
            for (const auto &w : warnings)
                logMsg(QString("QML WARNING: %1:%2: %3").arg(w.url().toString()).arg(w.line()).arg(w.description()));
        });

    logMsg("Step 8: Loading embedded QML...");
    engine.loadData(MAIN_QML, QUrl("qrc:/embedded_main.qml"));

    if (engine.rootObjects().isEmpty()) {
        logMsg("FAILED: QML did not load!");
        QString fsPath = exeDir + "/qml/main.qml";
        logMsg(QString("Trying filesystem: %1").arg(fsPath));
        if (QFile::exists(fsPath)) { engine.load(QUrl::fromLocalFile(fsPath)); }
    }

    if (engine.rootObjects().isEmpty()) {
        logMsg("FATAL: All QML loading failed!");
        if (g_logFile.is_open()) g_logFile.close();
#ifdef Q_OS_WIN
        MessageBoxA(nullptr, "Failed to load QML. Check mms_error.log.", "MMS Error", MB_ICONERROR | MB_OK);
#endif
        return -1;
    }

    logMsg("SUCCESS: QML loaded! Running event loop.");
    int ret = app.exec();
    logMsg(QString("Exited with code %1").arg(ret));
    if (g_logFile.is_open()) g_logFile.close();
    return ret;
}
