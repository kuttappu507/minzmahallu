import QtQuick

import MMS.Theme 1.0
// ============================================================================
// StatusBadge — Soft tinted status badge
// Matches HTML .pill / .stat .delta style
// ============================================================================

Rectangle {
    id: root

    property string text: ""
    property string variant: "active"    // active|inactive|archived|overdue|paid|pending|custom
    property color customColor: Theme.primary
    property color customBg: Theme.primarySubtle

    implicitHeight: 22
    implicitWidth: badgeText.implicitWidth + 16
    radius: 99
    color: _bgColor
    border.width: 0

    readonly property color _mainColor: {
        switch (variant) {
            case "active":   return Theme.primary
            case "inactive": return Theme.textTertiary
            case "archived": return Theme.textTertiary
            case "overdue":  return Theme.danger
            case "paid":     return Theme.primary
            case "pending":  return Theme.warning
            case "custom":   return customColor
            default:         return Theme.primary
        }
    }

    readonly property color _bgColor: {
        switch (variant) {
            case "active":   return Theme.primarySubtleAlt
            case "inactive": return Theme.surfaceHover
            case "archived": return Theme.surfaceHover
            case "overdue":  return Theme.coralSubtle
            case "paid":     return Theme.primarySubtleAlt
            case "pending":  return Theme.warningSubtle
            case "custom":   return customBg
            default:         return Theme.primarySubtleAlt
        }
    }

    Text {
        id: badgeText
        anchors.centerIn: parent
        text: root.text
        font.family: Theme.activeFontFamily
        font.pixelSize: Theme.fontSizeXs
        font.weight: Font.Medium
        color: root._mainColor
    }
}
