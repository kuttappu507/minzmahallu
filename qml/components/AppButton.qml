import QtQuick
import QtQuick.Controls
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
    horizontalAlignment: Qt.AlignHCenter

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
                    colorizationColor: root.enabled ? _iconColor : "#b2cfbd"
                    colorization: 1.0
                }
            }

            Text {
                text: root.text
                font.family: "Poppins"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: root.enabled ? _textColor : "#b2cfbd"
                visible: root.text !== ""
            }
        }
    }

    background: Rectangle {
        radius: 9
        color: !root.enabled ? "#d2e5d8" :
               root.pressed ? _pressedColor :
               root.hovered ? _hoverColor : _baseColor
        border.width: root.variant === "secondary" || root.variant === "ghost" ? 1 : 0
        border.color: root.variant === "secondary" ? (root.hovered ? "#b2cfbd" : "#d2e5d8") : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    readonly property color _baseColor: {
        switch (variant) {
            case "primary":   return "#059669"
            case "secondary": return "#ffffff"
            case "danger":    return "#e11d48"
            case "ghost":     return "transparent"
            default:          return "#059669"
        }
    }
    readonly property color _hoverColor: {
        switch (variant) {
            case "primary":   return "#047857"
            case "secondary": return "#f2faf4"
            case "danger":    return "#be123c"
            case "ghost":     return "#f2faf4"
            default:          return "#047857"
        }
    }
    readonly property color _pressedColor: {
        switch (variant) {
            case "primary":   return "#065f46"
            case "secondary": return "#eef8f1"
            case "danger":    return "#9f1239"
            case "ghost":     return "#eef8f1"
            default:          return "#065f46"
        }
    }
    readonly property color _textColor: {
        switch (variant) {
            case "primary":   return "#ffffff"
            case "secondary": return "#12241b"
            case "danger":    return "#ffffff"
            case "ghost":     return "#4f6b5c"
            default:          return "#ffffff"
        }
    }
    readonly property color _iconColor: {
        switch (variant) {
            case "primary":   return "#ffffff"
            case "secondary": return "#4f6b5c"
            case "danger":    return "#ffffff"
            case "ghost":     return "#4f6b5c"
            default:          return "#ffffff"
        }
    }
}
