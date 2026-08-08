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
    property color customColor: "#059669"
    property color customBg: "#ecfdf5"

    implicitHeight: 22
    implicitWidth: badgeText.implicitWidth + 16
    radius: 99
    color: _bgColor
    border.width: 0

    readonly property color _mainColor: {
        switch (variant) {
            case "active":   return "#059669"
            case "inactive": return "#64748b"
            case "archived": return "#64748b"
            case "overdue":  return "#e11d48"
            case "paid":     return "#059669"
            case "pending":  return "#d97706"
            case "custom":   return customColor
            default:         return "#059669"
        }
    }

    readonly property color _bgColor: {
        switch (variant) {
            case "active":   return "#d3f5e6"
            case "inactive": return "#e6ebf2"
            case "archived": return "#e6ebf2"
            case "overdue":  return "#fddfe5"
            case "paid":     return "#d3f5e6"
            case "pending":  return "#fcebc8"
            case "custom":   return customBg
            default:         return "#d3f5e6"
        }
    }

    Text {
        id: badgeText
        anchors.centerIn: parent
        text: root.text
        font.family: Theme.activeFontFamily
        font.pixelSize: 10
        font.weight: Font.Medium
        color: root._mainColor
    }
}
