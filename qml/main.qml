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

    // Splash
    Rectangle {
        id: splash
        anchors.fill: parent; z: 100
        color: "#065f46"; visible: true; opacity: 1
        Column {
            anchors.centerIn: parent; spacing: 20
            Text {
                text: "Minz Mahallu Management"
                font.family: "Space Grotesk"; font.pixelSize: 26; font.weight: Font.Bold
                color: "#ffffff"; anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Loading..."
                font.family: "Poppins"; font.pixelSize: 12; color: "#d7f2e4"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Timer { interval: 2000; running: true; onTriggered: { splash.opacity = 0; fade.running = true } }
        NumberAnimation { id: fade; target: splash; property: "opacity"; to: 0; duration: 500; onStopped: splash.visible = false }
    }

    RowLayout {
        anchors.fill: parent; spacing: 0

        // SIDEBAR
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

                // Logo
                Item {
                    Layout.fillWidth: true; Layout.preferredHeight: 80
                    Text {
                        anchors.centerIn: parent
                        text: "MMS"
                        font.family: "Space Grotesk"; font.pixelSize: 24; font.weight: Font.Bold
                        color: "#ffffff"
                    }
                }

                // Nav
                ListView {
                    id: navList
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; model: navModel; delegate: navDelegate
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                }

                // User card
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 70
                    color: "transparent"
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "rgba(255,255,255,0.14)" }
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 10
                        Rectangle {
                            width: 36; height: 36; radius: 9
                            color: "#f2c14e"; border.width: 2; border.color: "#b98317"
                            Text { anchors.centerIn: parent; text: "A"; font.family: "Space Grotesk"; font.pixelSize: 13; font.weight: Font.Bold; color: "#4a3606" }
                        }
                        ColumnLayout {
                            spacing: 1; visible: !sidebarCollapsed
                            Text { text: currentUser; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Bold; color: "#ffffff" }
                            Text { text: currentRole; font.family: "Poppins"; font.pixelSize: 10; color: "#9fd8c3" }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // Flap
            Rectangle {
                width: 26; height: 62; radius: 9
                anchors.right: parent.right; anchors.rightMargin: -13
                anchors.verticalCenter: parent.verticalCenter
                color: flapMA.containsMouse ? "#0aa06f" : "#047857"
                border.width: 1; border.color: "#0a7f5d"; z: 50
                Text { anchors.centerIn: parent; text: sidebarCollapsed ? ">" : "<"; color: "#ffffff"; font.pixelSize: 14 }
                MouseArea { id: flapMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: sidebarCollapsed = !sidebarCollapsed }
            }
        }

        // MAIN COLUMN
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

            // Top bar
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 58
                color: "#ffffff"
                Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1.5; color: "#d2e5d8" }
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 18; anchors.rightMargin: 18; spacing: 13
                    Text { text: "Minz Mahallu /"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.DemiBold; color: "#7e968a" }
                    Text { text: navModel.get(navList.currentIndex) ? navModel.get(navList.currentIndex).title : ""; font.family: "Space Grotesk"; font.pixelSize: 15; font.weight: Font.Bold; color: "#12241b" }
                    Item { Layout.fillWidth: true }
                    Text { text: "v1.0.0"; font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a" }
                }
            }

            // Content
            StackLayout {
                id: contentStack
                Layout.fillWidth: true; Layout.fillHeight: true
                currentIndex: navList.currentIndex
                Repeater {
                    model: navModel
                    delegate: Rectangle {
                        color: "#e7f4ea"
                        Text { anchors.centerIn: parent; text: model.title; font.pixelSize: 24; color: "#7e968a" }
                    }
                }
            }

            // Status bar
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 28
                color: "#f2faf4"
                Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1.5; color: "#d2e5d8" }
                Text { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: "Ready"; font.family: "Poppins"; font.pixelSize: 11; color: "#4f6b5c" }
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
            width: navList.width; height: 44
            anchors.margins: 2
            radius: 9
            color: navMA.containsMouse ? "rgba(255,255,255,0.09)" : (navList.currentIndex === index ? "rgba(255,255,255,0.14)" : "transparent")
            Behavior on color { ColorAnimation { duration: 140 } }
            Rectangle {
                visible: navList.currentIndex === index
                width: 4; height: 22; radius: 2; color: "#f2c14e"
                anchors.left: parent.left; anchors.leftMargin: 0; anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                anchors.fill: parent; anchors.leftMargin: 24
                verticalAlignment: Text.AlignVCenter
                text: model.title
                font.family: "Poppins"; font.pixelSize: 13; font.weight: Font.Bold
                color: navList.currentIndex === index ? "#ffffff" : "#c4e7d7"
                elide: Text.ElideRight
                visible: !sidebarCollapsed
            }
            MouseArea { id: navMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: navList.currentIndex = index }
        }
    }
}
