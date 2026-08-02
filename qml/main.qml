import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

ApplicationWindow {
    id: win
    visible: true
    width: 1366; height: 768
    minimumWidth: 1200; minimumHeight: 700
    color: Theme.bg
    title: "Minz Mahallu Management"

    property bool sidebarCollapsed: false
    property string currentUser: "Administrator"
    property string currentRole: "Administrator"
    property int currentNavIndex: 0

    // ===== Splash =====
    Rectangle {
        id: splash
        anchors.fill: parent; z: 100
        color: Theme.sidebar; visible: true; opacity: 1
        Column {
            anchors.centerIn: parent; spacing: 16
            Text {
                text: "Minz Mahallu Management"
                font.family: Theme.fontDisplay; font.pixelSize: 26; font.weight: Font.Bold
                color: "#ffffff"; anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: "Mosque Community Administration"
                font.family: Theme.fontPrimary; font.pixelSize: 13; color: "#c9ecd9"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                width: 200; height: 6; radius: 3; color: Theme.sidebarBot
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: parent.width * 0.7; height: parent.height; radius: 3; color: Theme.accent
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
                GradientStop { position: 0.0; color: Theme.sidebarTop }
                GradientStop { position: 0.42; color: Theme.sidebarMid }
                GradientStop { position: 1.0; color: Theme.sidebarBot }
            }

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                // Logo
                Item {
                    Layout.fillWidth: true; Layout.preferredHeight: 76
                    Text {
                        anchors.centerIn: parent
                        text: "MMS"
                        font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold
                        color: "#ffffff"
                        verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
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
                            color: Theme.accent; border.width: 2; border.color: Theme.accentDeep
                            Text {
                                anchors.centerIn: parent
                                text: win.currentUser.charAt(0).toUpperCase()
                                font.family: Theme.fontDisplay; font.pixelSize: 13; font.weight: Font.Bold
                                color: "#4a3606"
                                verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        ColumnLayout {
                            spacing: 2; visible: !sidebarCollapsed
                            Text {
                                text: win.currentUser
                                font.family: Theme.fontPrimary; font.pixelSize: 12; font.weight: Font.Bold
                                color: "#ffffff"; verticalAlignment: Text.AlignVCenter
                            }
                            Text {
                                text: win.currentRole
                                font.family: Theme.fontPrimary; font.pixelSize: 10
                                color: "#c9ecd9"; verticalAlignment: Text.AlignVCenter
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            visible: !sidebarCollapsed
                            text: "⏻"
                            font.family: Theme.fontPrimary; font.pixelSize: 16; color: "#c9ecd9"
                            verticalAlignment: Text.AlignVCenter
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Qt.quit() }
                        }
                    }
                }
            }
        }

        // ===== MAIN COLUMN =====
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

            // Top bar
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 56
                color: Theme.panel
                Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1.5; color: Theme.border }
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 18; anchors.rightMargin: 18; spacing: 12
                    Text {
                        text: navModel.get(win.currentNavIndex) ? navModel.get(win.currentNavIndex).title : ""
                        font.family: Theme.fontDisplay; font.pixelSize: 17; font.weight: Font.Bold
                        color: Theme.text; verticalAlignment: Text.AlignVCenter
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
                        font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Stack of views
            StackLayout {
                Layout.fillWidth: true; Layout.fillHeight: true
                currentIndex: win.currentNavIndex

                // 0 - Dashboard
                Loader { source: "qrc:/qml/views/DashboardView.qml" }
                // 1 - Families
                Loader { source: "qrc:/qml/views/FamiliesView.qml" }
                // 2 - Members
                Loader { source: "qrc:/qml/views/MembersView.qml" }
                // 3 - Subscriptions
                Loader { source: "qrc:/qml/views/SubscriptionsView.qml" }
                // 4 - Donations
                Loader { source: "qrc:/qml/views/DonationsView.qml" }
                // 5 - Accounting
                Loader { source: "qrc:/qml/views/AccountingView.qml" }
                // 6 - Marriage
                Loader { source: "qrc:/qml/views/MarriageView.qml" }
                // 7 - Death
                Loader { source: "qrc:/qml/views/DeathView.qml" }
                // 8 - Welfare
                Loader { source: "qrc:/qml/views/WelfareView.qml" }
                // 9 - Certificates
                Loader { source: "qrc:/qml/views/CertificatesView.qml" }
                // 10 - Tokens
                Loader { source: "qrc:/qml/views/TokensView.qml" }
                // 11 - Reports
                Loader { source: "qrc:/qml/views/ReportsView.qml" }
                // 12 - Settings
                Loader { source: "qrc:/qml/views/SettingsView.qml" }
                // 13 - Users
                Loader { source: "qrc:/qml/views/UsersView.qml" }
                // 14 - Audit Log
                Loader { source: "qrc:/qml/views/AuditLogView.qml" }
                // 15 - Backup
                Loader { source: "qrc:/qml/views/BackupView.qml" }
            }

            // Status bar
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 28
                color: Theme.panelMuted
                Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1.5; color: Theme.border }
                Text {
                    anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter
                    text: "Ready"
                    font.family: Theme.fontPrimary; font.pixelSize: 11; color: "#4f6b5c"
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
            width: navList.width; height: 46
            color: ListView.isCurrentItem ? Qt.rgba(255,255,255,0.10) : (mouseArea.containsMouse ? Qt.rgba(255,255,255,0.05) : "transparent")
            Behavior on color { ColorAnimation { duration: 120 } }
            Rectangle {
                anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                width: 4; color: Theme.accent; visible: ListView.isCurrentItem
            }
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 22; anchors.rightMargin: 14; spacing: 12
                Text {
                    text: model.title.charAt(0)
                    font.family: Theme.fontDisplay; font.pixelSize: 12; font.weight: Font.Bold
                    color: ListView.isCurrentItem ? Theme.accent : Qt.rgba(255,255,255,0.55)
                    verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    visible: !sidebarCollapsed
                    text: model.title
                    font.family: Theme.fontPrimary; font.pixelSize: 13
                    font.weight: ListView.isCurrentItem ? Font.Bold : Font.Medium
                    color: ListView.isCurrentItem ? "#ffffff" : Qt.rgba(255,255,255,0.82)
                    verticalAlignment: Text.AlignVCenter
                }
                Item { Layout.fillWidth: true }
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: navList.currentIndex = index
            }
        }
    }
}
