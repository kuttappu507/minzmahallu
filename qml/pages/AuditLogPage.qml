import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// Audit Log page — read-only list of all audit entries
Item {
    id: page

    property var entries: []
    property int currentPage: 1
    property int pageSize: 50
    property string actionFilter: ""

    Component.onCompleted: refresh()

    function refresh() {
        AuditLogController.refresh()  // bump summaryRevision so countToday re-evaluates
        entries = AuditLogController.list(currentPage, pageSize, actionFilter, "", "")
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Column { Layout.fillWidth: true; spacing: 2
                Text { text: "Audit Log"; font.family: Theme.activeFontFamily; font.pixelSize: 21; font.weight: Font.DemiBold; color: Theme.textPrimary }
                Text { text: { var _r = AuditLogController.summaryRevision; return "System activity history (" + AuditLogController.countToday() + " actions today)"; } font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary } }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 10
            AppComboBox { model: ["All Actions", "LOGIN", "LOGOUT", "ADD", "EDIT", "DELETE", "PRINT", "EXPORT", "BACKUP", "RESTORE"]; implicitHeight: 38; onActivated: function(index) { actionFilter = index === 0 ? "" : model[index]; currentPage = 1; refresh() } }
            Item { Layout.fillWidth: true }
            Text { text: "Showing " + entries.length + " entries"; font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary; Layout.alignment: Qt.AlignVCenter }
        }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 40; color: Theme.surfaceHover
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    Row { x: 16; width: parent.width - 32; spacing: 0
                        Text { text: "TIMESTAMP"; width: 180; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "USER"; width: 150; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "ACTION"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "MODULE"; width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "DESCRIPTION"; width: parent.width - 180 - 150 - 100 - 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary } } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: page.entries
                    delegate: Rectangle { width: table.width; height: 44; color: index % 2 === 0 ? "#ffffff" : "#fafdfa"
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                        Row { x: 16; width: parent.width - 32; spacing: 0
                            Text { text: modelData.createdAt; width: 180; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textSecondary }
                            Text { text: modelData.username; width: 150; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.textPrimary; elide: Text.ElideRight }
                            Item { width: 100; height: 44; StatusBadge { anchors.centerIn: parent; text: modelData.action; variant: { var a = modelData.action.toLowerCase(); if (a === "delete") return "overdue"; if (a === "add") return "active"; if (a === "login" || a === "logout") return "pending"; return "inactive" } } }
                            Text { text: modelData.module || "—"; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary }
                            Text { text: modelData.description; width: parent.width - 180 - 150 - 100 - 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary; elide: Text.ElideRight } } } }
                Item { Layout.fillWidth: true; Layout.fillHeight: true; visible: page.entries.length === 0
                    Column { anchors.centerIn: parent; spacing: 8
                        Text { text: "No audit entries found"; font.family: Theme.activeFontFamily; font.pixelSize: 14; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter } } }
            }
        }
    }
}
