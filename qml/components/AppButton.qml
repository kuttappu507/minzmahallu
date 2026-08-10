import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Effects

// ============================================================================
// AppButton — Reusable button matching DashboardV3 design language
// Variants: primary (emerald), secondary (white border), danger (rose), ghost
// Height: 36px. Radius: 9px. Font: Poppins 13px.
// ============================================================================

Button {
    id: root

    property string variant: "primary"    // primary | secondary | danger | ghost
    property string iconName: ""
    property int iconSize: 16

    implicitHeight: 36
    implicitWidth: Math.max(80, contentRow.implicitWidth + 28)
    padding: 0
    hoverEnabled: true

    // contentItem fills the entire button (padding:0). We use an Item wrapper
    // with the Row anchored to centerIn so icon+text are centered BOTH
    // horizontally and vertically. A bare Row would left-align its children.
    contentItem: Item {
        width: root.width; height: root.height
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
                    colorizationColor: root.enabled ? _iconColor : Theme.borderHover
                    colorization: 1.0
                }
            }

            Text {
                text: root.text
                font.family: Theme.activeFontFamily
                font.pixelSize: Theme.fontSizeMd
                font.weight: Font.DemiBold
                color: root.enabled ? _textColor : Theme.borderHover
                visible: root.text !== ""
            }
        }
    }

    background: Rectangle {
        radius: 9
        color: !root.enabled ? Theme.border :
               root.pressed ? _pressedColor :
               root.hovered ? _hoverColor : _baseColor
        border.width: root.variant === "secondary" || root.variant === "ghost" ? 1 : 0
        border.color: root.variant === "secondary" ? (root.hovered ? Theme.borderHover : Theme.border) : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    readonly property color _baseColor: {
        switch (variant) {
            case "primary":   return Theme.primary
            case "secondary": return Theme.surface
            case "danger":    return Theme.danger
            case "ghost":     return "transparent"
            default:          return Theme.primary
        }
    }
    readonly property color _hoverColor: {
        switch (variant) {
            case "primary":   return "#047857"
            case "secondary": return Theme.surfaceHover
            case "danger":    return "#be123c"
            case "ghost":     return Theme.surfaceHover
            default:          return "#047857"
        }
    }
    readonly property color _pressedColor: {
        switch (variant) {
            case "primary":   return Theme.primaryPressed
            case "secondary": return Theme.surfacePressed
            case "danger":    return "#9f1239"
            case "ghost":     return Theme.surfacePressed
            default:          return Theme.primaryPressed
        }
    }
    readonly property color _textColor: {
        switch (variant) {
            case "primary":   return Theme.surface
            case "secondary": return Theme.textPrimary
            case "danger":    return Theme.surface
            case "ghost":     return Theme.textSecondary
            default:          return Theme.surface
        }
    }
    readonly property color _iconColor: {
        switch (variant) {
            case "primary":   return Theme.surface
            case "secondary": return Theme.textSecondary
            case "danger":    return Theme.surface
            case "ghost":     return Theme.textSecondary
            default:          return Theme.surface
        }
    }
}
