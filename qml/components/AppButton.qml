import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../theme"

// Reusable application button. All surface/text colors come from Theme so
// controls remain readable in both light and dark modes.
Button {
    id: root

    property string variant: "primary"
    property string iconName: ""
    property int iconSize: 16

    implicitHeight: 36
    implicitWidth: Math.max(80, contentRow.implicitWidth + 28)
    padding: 0
    hoverEnabled: true

    contentItem: Item {
        width: root.width
        height: root.height
        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6
            Item {
                width: root.iconName !== "" ? root.iconSize : 0
                height: root.iconSize
                visible: root.iconName !== ""
                Image {
                    id: btnIcon
                    source: root.iconName !== "" ? "qrc:/icons/svg/" + root.iconName + ".svg" : ""
                    sourceSize: Qt.size(root.iconSize, root.iconSize)
                    anchors.fill: parent
                    fillMode: Image.Pad
                    visible: false
                }
                MultiEffect {
                    anchors.fill: parent
                    source: btnIcon
                    colorizationColor: root.enabled ? _iconColor : Theme.textDisabled
                    colorization: 1.0
                }
            }
            Text {
                text: root.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMd
                font.weight: Theme.fontWeightSemiBold
                color: root.enabled ? _textColor : Theme.textDisabled
                visible: root.text !== ""
            }
        }
    }

    background: Rectangle {
        radius: Theme.radiusXl
        color: !root.enabled ? Theme.surfacePressed :
               root.pressed ? _pressedColor :
               root.hovered ? _hoverColor : _baseColor
        border.width: root.variant === "secondary" || root.variant === "ghost" ? 1 : 0
        border.color: root.variant === "secondary" ? (root.hovered ? Theme.borderHover : Theme.border) : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }

    readonly property color _baseColor: {
        switch (variant) {
            case "primary": return Theme.primary
            case "secondary": return Theme.surface
            case "danger": return Theme.dangerHover
            case "ghost": return "transparent"
            default: return Theme.primary
        }
    }
    readonly property color _hoverColor: {
        switch (variant) {
            case "primary": return Theme.primaryHover
            case "secondary": return Theme.surfaceHover
            case "danger": return Theme.danger
            case "ghost": return Theme.surfaceHover
            default: return Theme.primaryHover
        }
    }
    readonly property color _pressedColor: {
        switch (variant) {
            case "primary": return Theme.primaryPressed
            case "secondary": return Theme.surfacePressed
            case "danger": return "#991b1b"
            case "ghost": return Theme.surfacePressed
            default: return Theme.primaryPressed
        }
    }
    readonly property color _textColor: {
        switch (variant) {
            case "primary": return Theme.primaryOn
            case "secondary": return Theme.textPrimary
            case "danger": return "#ffffff"
            case "ghost": return Theme.textSecondary
            default: return Theme.primaryOn
        }
    }
    readonly property color _iconColor: {
        switch (variant) {
            case "primary": return Theme.primaryOn
            case "secondary": return Theme.textSecondary
            case "danger": return "#ffffff"
            case "ghost": return Theme.textSecondary
            default: return Theme.primaryOn
        }
    }
}
