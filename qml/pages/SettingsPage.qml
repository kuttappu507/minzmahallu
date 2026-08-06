import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// Settings page — placeholder during migration
// SettingsService uses plain C++ methods (not Q_PROPERTY), so QML binding
// requires a wrapper. For now, this page shows the current settings info.
Item {
    id: page

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        Column { Layout.fillWidth: true; spacing: 2
            Text { text: "Settings"; font.family: "Poppins"; font.pixelSize: 21; font.weight: Font.DemiBold; color: "#12241b" }
            Text { text: "Application configuration"; font.family: "Poppins"; font.pixelSize: 12; color: "#4f6b5c" } }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: "#ffffff"; border.width: 1; border.color: "#d2e5d8"
            Column { anchors.centerIn: parent; spacing: 16
                Rectangle { width: 64; height: 64; radius: 32; color: "#f2faf4"; border.width: 1; border.color: "#d2e5d8"; anchors.horizontalCenter: parent.horizontalCenter
                    Item { width: 32; height: 32; anchors.centerIn: parent
                        Image { id: setIcon; source: "qrc:/icons/svg/settings.svg"; sourceSize: Qt.size(32, 32); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                        MultiEffect { anchors.fill: parent; source: setIcon; colorizationColor: "#b2cfbd"; colorization: 1.0 } } }
                Column { spacing: 4; anchors.horizontalCenter: parent.horizontalCenter
                    Text { text: "Settings"; font.family: "Poppins"; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#12241b"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "Mahallu name, theme, language, currency"; font.family: "Poppins"; font.pixelSize: 12; color: "#7e968a"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "Use the legacy MMS.exe for settings management during migration"; font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a"; anchors.horizontalCenter: parent.horizontalCenter } }
            }
        }
    }
}
