import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// IconButton — SVG icon button with optional label
//
// Designed for toolbar actions, table row actions, and compact controls.
// Uses MultiEffect to tint SVG icons to any color.
//
// Modes:
//   - icon only (compact): IconButton { icon: "edit"; onClicked: ... }
//   - icon + label:        IconButton { icon: "plus"; text: "Add Family" }
//
// The `icon` property takes a bare name (e.g. "plus") and resolves to
// qrc:/icons/svg/plus.svg automatically.
// ============================================================================

Button {
    id: root

    // ===== Public API =====
    property string iconName: ""               // bare icon name, e.g. "plus", "edit", "trash"
    property color tintColor: Theme.textSecondary   // icon color
    property color tintColorHover: Theme.primary     // icon color on hover
    property bool compact: false                   // true = icon only, no padding around
    property int iconSize: Theme.iconSizeMd

    // ===== Sizing =====
    implicitHeight: compact ? iconSize + 8 : Theme.controlHeightMd
    implicitWidth: compact ? implicitHeight :
                            (text !== "" ? contentRow.implicitWidth + 20 : implicitHeight)
    padding: 0

    // ===== Resolve icon source =====
    readonly property string _iconSource: iconName !== "" ? "qrc:/icons/svg/" + iconName + ".svg" : ""

    // ===== Content =====
    contentItem: Row {
        id: contentRow
        spacing: 6

        Item {
            width: root.iconSize
            height: root.iconSize
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: iconImage
                source: root._iconSource
                sourceSize: Qt.size(root.iconSize, root.iconSize)
                anchors.fill: parent
                fillMode: Image.Pad
                visible: false
            }

            MultiEffect {
                anchors.fill: parent
                source: iconImage
                colorizationColor: root.enabled ?
                    (root.hovered || root.pressed ? root.tintColorHover : root.tintColor) :
                    Theme.textDisabled
                colorization: 1.0
                Behavior on colorizationColor { ColorAnimation { duration: Theme.animFast } }
            }
        }

        Text {
            text: root.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd
            font.weight: Theme.fontWeightMedium
            color: root.enabled ?
                (root.hovered ? Theme.primary : Theme.textSecondary) :
                Theme.textDisabled
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== "" && !root.compact
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }
    }

    // ===== Background (subtle hover for non-compact) =====
    background: Rectangle {
        radius: root.compact ? Theme.radiusSm : Theme.radiusMd
        color: !root.enabled ? "transparent" :
               root.pressed ? Theme.surfacePressed :
               root.hovered ? Theme.surfaceHover :
               "transparent"

        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        // Subtle border for non-compact, or no border for compact
        border.width: root.compact ? 0 : 1
        border.color: root.hovered ? Theme.borderHover : Theme.border
        visible: !root.compact || root.hovered
    }

    // ===== Focus ring =====
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: parent ? parent.radius + 2 : Theme.radiusSm + 2
        color: "transparent"
        border.width: 2
        border.color: Qt.rgba(0.02, 0.59, 0.41, 0.30)
        visible: root.activeFocus && root.enabled
        z: -1
    }
}
