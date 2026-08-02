import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// AppButton — Polished desktop button with 4 variants
//
// Variants:
//   "primary"   — filled emerald, white text (main actions)
//   "secondary" — white surface with border (default actions)
//   "ghost"     — transparent, text only (subtle actions)
//   "danger"    — filled red (destructive actions)
//
// States: normal, hover, pressed, focused, disabled
// All transitions use subtle color animations (100ms).
// ============================================================================

Button {
    id: root

    // ===== Public API =====
    property string variant: "primary"     // primary | secondary | ghost | danger
    property string iconSource: ""         // optional SVG path (qrc: or file:)
    property int iconSize: Theme.iconSizeSm
    property bool showError: false         // red outline for validation errors

    // ===== Sizing =====
    implicitHeight: Theme.controlHeightMd
    implicitWidth: Math.max(80, contentRow.implicitWidth + leftPadding + rightPadding)
    leftPadding: iconSource !== "" ? 10 : 16
    rightPadding: 16
    topPadding: 0
    bottomPadding: 0

    // ===== Content (icon + text) =====
    contentItem: Row {
        id: contentRow
        spacing: 6

        Item {
            id: iconContainer
            width: root.iconSource !== "" ? root.iconSize : 0
            height: root.iconSize
            anchors.verticalCenter: parent.verticalCenter
            visible: root.iconSource !== ""

            Image {
                id: iconImage
                source: root.iconSource
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
            }
        }

        Text {
            text: root.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd
            font.weight: Theme.fontWeightMedium
            color: root.enabled ? _textColor : Theme.textDisabled
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
        }
    }

    // ===== Background =====
    background: Rectangle {
        radius: Theme.radiusMd
        color: !root.enabled ? _disabledColor :
               root.pressed ? _pressedColor :
               root.hovered ? _hoverColor :
               _baseColor
        border.width: root.variant === "secondary" ? 1 : 0
        border.color: !root.enabled ? Theme.border :
                      root.variant === "secondary" ?
                          (root.hovered ? Theme.borderHover : Theme.border) :
                      "transparent"

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }

    // ===== Focus ring =====
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: parent ? parent.radius + 2 : Theme.radiusMd + 2
        color: "transparent"
        border.width: 2
        border.color: root.showError ? Qt.rgba(0.86, 0.15, 0.15, 0.35) :
                                      Qt.rgba(0.02, 0.59, 0.41, 0.35)
        visible: root.activeFocus && root.enabled
        z: -1
    }

    // ===== Color resolution by variant =====
    readonly property color _baseColor: {
        switch (variant) {
            case "primary":   return Theme.primary
            case "secondary": return Theme.surface
            case "ghost":     return "transparent"
            case "danger":    return Theme.danger
            default:          return Theme.primary
        }
    }
    readonly property color _hoverColor: {
        switch (variant) {
            case "primary":   return Theme.primaryHover
            case "secondary": return Theme.surfaceHover
            case "ghost":     return Theme.surfaceHover
            case "danger":    return Theme.dangerHover
            default:          return Theme.primaryHover
        }
    }
    readonly property color _pressedColor: {
        switch (variant) {
            case "primary":   return Theme.primaryPressed
            case "secondary": return Theme.surfacePressed
            case "ghost":     return Theme.surfacePressed
            case "danger":    return Theme.dangerPressed
            default:          return Theme.primaryPressed
        }
    }
    readonly property color _disabledColor: {
        switch (variant) {
            case "primary":   return Qt.rgba(0.02, 0.59, 0.41, 0.35)
            case "secondary": return Theme.surfaceSubtle
            case "ghost":     return "transparent"
            case "danger":    return Qt.rgba(0.86, 0.15, 0.15, 0.35)
            default:          return Qt.rgba(0.02, 0.59, 0.41, 0.35)
        }
    }
    readonly property color _textColor: {
        switch (variant) {
            case "primary":   return Theme.textOnPrimary
            case "secondary": return Theme.textPrimary
            case "ghost":     return Theme.textSecondary
            case "danger":    return Theme.textOnPrimary
            default:          return Theme.textOnPrimary
        }
    }
    readonly property color _iconColor: {
        switch (variant) {
            case "primary":   return Theme.textOnPrimary
            case "secondary": return Theme.textSecondary
            case "ghost":     return Theme.textSecondary
            case "danger":    return Theme.textOnPrimary
            default:          return Theme.textOnPrimary
        }
    }
}
