import QtQuick
import QtQuick.Controls
import "../theme"

// Compact in-app splash overlay. The application window remains visible;
// only this centered card is shown during startup.
Item {
    id: splash
    anchors.fill: parent
    z: 9999

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    Rectangle {
        id: card
        width: 390
        height: 220
        anchors.centerIn: parent
        radius: 18
        color: Theme.sidebarMid
        border.width: 1
        border.color: Qt.rgba(255,255,255,0.12)

        Column {
            anchors.centerIn: parent
            spacing: 10

            Rectangle {
                width: 54
                height: 54
                radius: 16
                anchors.horizontalCenter: parent.horizontalCenter
                color: Qt.rgba(255,255,255,0.12)
                Text {
                    anchors.centerIn: parent
                    text: "M"
                    font.family: Theme.fontFamily
                    font.pixelSize: 25
                    font.weight: Font.Bold
                    color: "#ffffff"
                }
            }

            Text {
                text: "Minz Mahallu"
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: Theme.fontFamily
                font.pixelSize: 21
                font.weight: Font.DemiBold
                color: "#ffffff"
            }

            Text {
                text: "Management System"
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Theme.sidebarSubTitle
            }

            BusyIndicator {
                width: 22
                height: 22
                anchors.horizontalCenter: parent.horizontalCenter
                running: true
            }
        }
    }

    Timer {
        interval: 1200
        running: true
        repeat: false
        onTriggered: splash.visible = false
    }
}
