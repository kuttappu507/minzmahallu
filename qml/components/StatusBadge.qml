import QtQuick
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// StatusBadge — Modern soft badge with dot indicator
//
// Variants:
//   "active"    — soft green
//   "pending"   — soft amber
//   "overdue"   — soft coral/red
//   "archived"  — soft gray
//   "paid"      — soft emerald
//   "approved"  — soft blue
//   "custom"    — use customColor + customSubtle
//
// Usage:
//   StatusBadge { text: "Active"; variant: "active" }
//   StatusBadge { text: "Overdue"; variant: "overdue" }
// ============================================================================

Rectangle {
    id: root

    property string text: ""
    property string variant: "active"
    property color customColor: Theme.success
    property color customSubtle: Theme.successSubtle

    implicitHeight: 22
    implicitWidth: row.implicitWidth + 16
    radius: Theme.radiusSm

    color: _subtleColor
    border.width: 0

    readonly property color _mainColor: {
        switch (variant) {
            case "active":   return Theme.success
            case "pending":  return Theme.warning
            case "overdue":  return Theme.coral
            case "archived": return Theme.textTertiary
            case "paid":     return Theme.primary
            case "approved": return Theme.blue
            case "custom":   return customColor
            default:         return Theme.success
        }
    }

    readonly property color _subtleColor: {
        switch (variant) {
            case "active":   return Theme.successSubtle
            case "pending":  return Theme.warningSubtle
            case "overdue":  return Theme.coralSubtle
            case "archived": return Theme.surfacePressed
            case "paid":     return Theme.primarySubtle
            case "approved": return Theme.blueSubtle
            case "custom":   return customSubtle
            default:         return Theme.successSubtle
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        // Dot indicator
        Rectangle {
            width: 6; height: 6; radius: 3
            color: root._mainColor
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            font.weight: Theme.fontWeightSemiBold
            color: root._mainColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
