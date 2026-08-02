import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// IconButton — SVG icon button with hover surface + tooltip
//
// Modes:
//   - compact (icon only): IconButton { iconName: "edit" }
//   - with label:          IconButton { iconName: "plus"; text: "Add" }
//
// Variants:
//   "default"    — icon color secondary, hover surface
//   "primary"    — icon color emerald
//   "danger"     — icon color coral (destructive)
//   "selected"   — emerald background, white icon
// ============================================================================

Button {
    id: root

    property string iconName: ""
    property string variant: "default"    // default | primary | danger | selected
    property bool compact: false
    property int iconSize: Theme.iconSizeMd
    property string tooltipText: ""

    implicitHeight: compact ? iconSize + 10 : Theme.controlHeightLg
    implicitWidth: compact ? implicitHeight :
                            (text !== "" ? contentRow.implicitWidth + 20 : implicitHeight)
    padding: 0
    hoverEnabled: true

    readonly property string _iconSource: iconName !== "" ? "qrc:/icons/svg/" + iconName + ".svg" : ""

    // Tooltip
    ToolTip.visible: tooltipText !== "" && hovered
    ToolTip.delay: 600
    ToolTip.text: tooltipText
    ToolTip.timeout: 3000

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
                colorizationColor: root.enabled ? _iconColor : Theme.textDisabled
                colorization: 1.0
                Behavior on colorizationColor { ColorAnimation { duration: Theme.animFast } }
            }
        }

        Text {
            text: root.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd
            font.weight: Theme.fontWeightMedium
            color: root.enabled ? _textColor : Theme.textDisabled
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== "" && !root.compact
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }
    }

    background: Rectangle {
        radius: root.compact ? Theme.radiusSm : Theme.radiusMd
        color: !root.enabled ? "transparent" :
               root.variant === "selected" ? Theme.primary :
               root.pressed ? Theme.surfacePressed :
               root.hovered ? Theme.surfaceHover :
               "transparent"

        border.width: 0
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    // Focus ring
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: (root.compact ? Theme.radiusSm : Theme.radiusMd) + 2
        color: "transparent"
        border.width: 2
        border.color: Qt.rgba(0.02, 0.59, 0.41, 0.30)
        visible: root.activeFocus && root.enabled
        z: -1
    }

    readonly property color _iconColor: {
        if (!root.enabled) return Theme.textDisabled
        if (root.variant === "selected") return Theme.textOnPrimary
        if (root.variant === "danger") return root.hovered ? Theme.coralHover : Theme.coral
        if (root.variant === "primary") return root.hovered ? Theme.primaryHover : Theme.primary
        return root.hovered ? Theme.primary : Theme.textSecondary
    }
    readonly property color _textColor: {
        if (!root.enabled) return Theme.textDisabled
        if (root.variant === "selected") return Theme.textOnPrimary
        if (root.variant === "danger") return root.hovered ? Theme.coralHover : Theme.coral
        if (root.variant === "primary") return root.hovered ? Theme.primaryHover : Theme.primary
        return root.hovered ? Theme.primary : Theme.textSecondary
    }
}
