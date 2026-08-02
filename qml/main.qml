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
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Qt.rgba(1,1,1,0.14
