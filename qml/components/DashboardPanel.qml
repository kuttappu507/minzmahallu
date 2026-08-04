import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MMS.Theme 1.0

// ============================================================================
// DashboardPanel — Reusable content panel with EXPLICIT sizing contract
//
// SIZING CONTRACT:
//   implicitHeight = internalLayout.implicitHeight + 2 * panelPadding
//
// The panel does NOT use Layout.fillHeight. Its height is driven entirely
// by its content (title + subtitle + children).
//
// Usage:
//   DashboardPanel {
//       title: "Recent Activities"
//       subtitle: "Latest updates"
//       // Add content as children — they go into the internal ColumnLayout
//   }
// ============================================================================

Rectangle {
    id: panel
    
    property string title: ""
    property string subtitle: ""
    property int panelPadding: 16
    property string panelName: "dashboardPanel"

    // EXPLICIT sizing contract — implicitHeight driven by content
    implicitHeight: internalLayout.implicitHeight + 2 * panelPadding
    objectName: panelName
    // NO Layout.fillHeight — natural height only
    Layout.fillWidth: true

    radius: Theme.radiusLg
    color: Theme.surface
    border.width: 1
    border.color: Theme.border

    // Internal layout — fills the panel, content drives implicitHeight
    ColumnLayout {
        id: internalLayout
        objectName: panelName + "Internal"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: panelPadding
        spacing: 0

        // Title
        Text {
            objectName: panelName + "Title"
            text: panel.title
            font.family: Theme.fontFamily
            font.pixelSize: 15
            font.weight: Font.DemiBold
            color: Theme.textPrimary
            Layout.fillWidth: true
        }

        // Subtitle
        Text {
            objectName: panelName + "Subtitle"
            text: panel.subtitle
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.textSecondary
            Layout.fillWidth: true
            Layout.topMargin: 2
            Layout.bottomMargin: 12
        }

        // Content slot — children are reparented here
        ColumnLayout {
            id: contentSlot
            objectName: panelName + "Content"
            Layout.fillWidth: true
            spacing: 10
        }
    }

    // Reparent children into the content slot
    default property alias content: contentSlot.children
}
