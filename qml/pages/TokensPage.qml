import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// Tokens page — placeholder (token tables missing from schema, needs migration first)
Item {
    id: page

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        Column { Layout.fillWidth: true; spacing: 2
            Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_tokens") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXl; font.weight: Font.DemiBold; color: Theme.textPrimary }
            Text { text: "Meat/food distribution token management"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary } }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
            Column { anchors.centerIn: parent; spacing: 16
                Rectangle { width: 64; height: 64; radius: 32; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border; anchors.horizontalCenter: parent.horizontalCenter
                    Item { width: 32; height: 32; anchors.centerIn: parent
                        Image { id: tokIcon; source: "qrc:/icons/svg/token.svg"; sourceSize: Qt.size(32, 32); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                        MultiEffect { anchors.fill: parent; source: tokIcon; colorizationColor: Theme.borderHover; colorization: 1.0 } } }
                Column { spacing: 4; anchors.horizontalCenter: parent.horizontalCenter
                    Text { text: "Token Distribution"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeLg; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "Token events with per-family unique codes"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "Requires database schema migration (token tables missing)"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.danger; anchors.horizontalCenter: parent.horizontalCenter } }
            }
        }
    }
}
