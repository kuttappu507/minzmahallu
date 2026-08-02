import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// AppButton — Polished desktop button
//
// Variants:
//   "primary"   — filled emerald (main actions)
//   "secondary" — white surface with border (default actions)
//   "ghost"     — transparent (subtle actions)
//   "danger"    — filled coral/red (destructive actions)
//   "subtle"    — tinted background (tertiary actions)
//
// Height: 32-36px (desktop compact)
// Animations: 100-150ms color transitions
// ============================================================================

Button {
    id: root

    property string variant: "primary"
    property string iconSource: ""
    property int iconSize: Theme.iconSizeSm
    property bool showError: false
    property color accentColor: Theme.primary  // for "subtle" variant

    implicitHeight: Theme.controlHeightLg
    implicitWidth: Math.max(72, contentRow.implicitWidth + leftPadding + rightPadding)
    leftPadding: iconSource !== "" ? 12 : 16
    rightPadding: 16
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: true

    contentItem: Row {
        id: contentRow
        spacing: 6

        Item {
            width: root.iconSource !== "" ? root.iconSize : 0
            height: root.iconSize
            anchors.verticalCenter: parent.verticalCenter
            visible: root.iconSource !== ""

            Image {
                id: btnIcon
                source: root.iconSource
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
            font.weight: Theme.fontWeightMedium
            color: root.enabled ? _textColor : Theme.textDisabled
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
        }
    }

    background: Rectangle {
        id: bg
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

        // Subtle elevation for primary/danger
        layer.enabled: root.enabled && (root.variant === "primary" || root.variant === "danger") && !root.pressed
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: root.variant === "primary" ?
                Qt.rgba(0.02, 0.59, 0.41, Theme.shadowOpacitySmall) :
                Qt.rgba(0.96, 0.25, 0.37, Theme.shadowOpacitySmall)
            shadowBlur: 0.4
            shadowVerticalOffset: 2
        }
    }

    // Focus ring
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: bg.radius + 2
        color: "transparent"
        border.width: 2
        border.color: root.showError ?
            Qt.rgba(0.96, 0.25, 0.37, 0.4) :
            Qt.rgba(0.02, 0.59, 0.41, 0.35)
        visible: root.activeFocus && root.enabled
        z: -1
    }

    // ===== Color resolution =====
    readonly property color _baseColor: {
        switch (variant) {
            case "primary":   return Theme.primary
            case "secondary": return Theme.surface
            case "ghost":     return "transparent"
            case "danger":    return Theme.coral
            case "subtle":    return Theme.primarySubtle
            default:          return Theme.primary
        }
    }
    readonly property color _hoverColor: {
        switch (variant) {
            case "primary":   return Theme.primaryHover
            case "secondary": return Theme.surfaceHover
            case "ghost":     return Theme.surfaceHover
            case "danger":    return Theme.coralHover
            case "subtle":    return Theme.primarySubtleAlt
            default:          return Theme.primaryHover
        }
    }
    readonly property color _pressedColor: {
        switch (variant) {
            case "primary":   return Theme.primaryPressed
            case "secondary": return Theme.surfacePressed
            case "ghost":     return Theme.surfacePressed
            case "danger":    return Theme.coralHover
            case "subtle":    return Theme.primarySubtleAlt
            default:          return Theme.primaryPressed
        }
    }
    readonly property color _disabledColor: {
        switch (variant) {
            case "primary":   return Qt.rgba(0.02, 0.59, 0.41, 0.35)
            case "secondary": return Theme.surfaceSubtle
            case "ghost":     return "transparent"
            case "danger":    return Qt.rgba(0.96, 0.25, 0.37, 0.35)
            case "subtle":    return Theme.surfaceSubtle
            default:          return Qt.rgba(0.02, 0.59, 0.41, 0.35)
        }
    }
    readonly property color _textColor: {
        switch (variant) {
            case "primary":   return Theme.textOnPrimary
            case "secondary": return Theme.textPrimary
            case "ghost":     return Theme.textSecondary
            case "danger":    return Theme.textOnPrimary
            case "subtle":    return Theme.primary
            default:          return Theme.textOnPrimary
        }
    }
    readonly property color _iconColor: {
        switch (variant) {
            case "primary":   return Theme.textOnPrimary
            case "secondary": return Theme.textSecondary
            case "ghost":     return Theme.textSecondary
            case "danger":    return Theme.textOnPrimary
            case "subtle":    return Theme.primary
            default:          return Theme.textOnPrimary
        }
    }
}
