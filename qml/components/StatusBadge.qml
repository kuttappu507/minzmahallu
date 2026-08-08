import QtQuick
import "../theme"

// Shared soft status badge. Semantic colors remain consistent while the
// background tint follows the active light/dark palette.
Rectangle {
    id: root

    property string text: ""
    property string variant: "active"
    property color customColor: Theme.primary
    property color customBg: Theme.primarySubtleAlt

    implicitHeight: 22
    implicitWidth: badgeText.implicitWidth + 16
    radius: 99
    color: _bgColor
    border.width: 1
    border.color: Qt.rgba(_mainColor.r, _mainColor.g, _mainColor.b, Theme.dark ? 0.35 : 0.18)

    readonly property color _mainColor: {
        switch (variant) {
            case "active":   return Theme.success
            case "inactive": return Theme.textTertiary
            case "archived": return Theme.textTertiary
            case "overdue":  return Theme.coral
            case "paid":     return Theme.success
            case "pending":  return Theme.warning
            case "custom":   return customColor
            default:         return Theme.primary
        }
    }

    readonly property color _bgColor: {
        switch (variant) {
            case "active":   return Theme.successSubtle
            case "inactive": return Theme.surfaceSubtle
            case "archived": return Theme.surfaceSubtle
            case "overdue":  return Theme.dangerSubtle
            case "paid":     return Theme.successSubtle
            case "pending":  return Theme.warningSubtle
            case "custom":   return customBg
            default:         return Theme.primarySubtle
        }
    }

    Text {
        id: badgeText
        anchors.centerIn: parent
        text: root.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeXs
        font.weight: Theme.fontWeightMedium
        color: root._mainColor
        elide: Text.ElideRight
    }
}
