import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// SectionCard — A titled card with icon + content area.
// Used by SettingsPage to group related fields into visually distinct
// sections (Organization / Financial / Appearance / Backup).
// ============================================================================

Rectangle {
    id: card

    property string title: ""
    property string icon: ""
    default property alias content: contentLayout.children

    Layout.fillWidth: true
    implicitHeight: headerRow.height + contentLayout.implicitHeight + 48  // 24 top + 24 bottom padding
    radius: 12
    color: Theme.surface
    border.width: 1
    border.color: Theme.border

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // ===== Header (icon + title) =====
        RowLayout {
            id: headerRow
            Layout.fillWidth: true
            spacing: 10

            Item {
                width: 22; height: 22
                Layout.alignment: Qt.AlignVCenter
                visible: card.icon !== ""
                Image {
                    id: sectionIcon
                    source: card.icon !== "" ? "qrc:/icons/svg/" + card.icon + ".svg" : ""
                    sourceSize: Qt.size(22, 22)
                    anchors.fill: parent
                    fillMode: Image.Pad
                    visible: false
                }
                MultiEffect {
                    anchors.fill: parent
                    source: sectionIcon
                    colorizationColor: Theme.primary
                    colorization: 1.0
                }
            }

            Text {
                text: card.title
                font.family: Theme.activeFontFamily
                font.pixelSize: Theme.fontSizeMd
                font.weight: Font.DemiBold
                color: Theme.textPrimary
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Thin divider line under header
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        // ===== Content (filled by `content` alias) =====
        ColumnLayout {
            id: contentLayout
            Layout.fillWidth: true
            spacing: 16
        }
    }
}
