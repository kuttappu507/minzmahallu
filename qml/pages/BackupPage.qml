import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// BackupPage — Create/Restore/Verify/Delete/Prune backups
// ============================================================================

Item {
    id: page

    property var backups: []

    Component.onCompleted: refresh()

    function refresh() {
        backups = BackupController.listBackups()
    }

    ConfirmDialog {
        id: restoreDialog
        message: "Restore Backup?"
        warningText: "This will REPLACE the current database. All current data will be lost. Continue?"
        property string _path: ""
        onAccepted: {
            if (_path.length > 0) {
                var ok = BackupController.restoreBackup(_path)
                toast.show(ok ? "Restored. Please restart the application." : "Restore failed", ok ? "#059669" : "#e11d48")
                if (ok) page.refresh()
            }
        }
    }

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Backup?"
        warningText: "This backup file will be permanently deleted."
        property string _path: ""
        onAccepted: {
            if (_path.length > 0) {
                var ok = BackupController.deleteBackup(_path)
                toast.show(ok ? "Backup deleted" : "Delete failed", ok ? "#059669" : "#e11d48")
                if (ok) page.refresh()
            }
        }
    }

    Rectangle {
        id: toast
        property bool visible_: false
        property string message: ""
        property color bgColor: "#059669"
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: visible_ ? 18 : -60
        width: toastText.implicitWidth + 40; height: 40; radius: 9
        color: bgColor; z: 1000
        Behavior on anchors.topMargin { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: Theme.activeFontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: Theme.surface }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg, color) { message = msg; bgColor = color || "#059669"; visible_ = true; toastTimer.restart() }
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Column { Layout.fillWidth: true; spacing: 2
                Text { text: "Backup & Restore"; font.family: Theme.activeFontFamily; font.pixelSize: 21; font.weight: Font.DemiBold; color: Theme.textPrimary }
                Text { text: "Database backup and restore (" + backups.length + " backups)"; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary } }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true; spacing: 10
            AppButton { text: "Create Backup"; variant: "primary"; iconName: "backup"; onClicked: {
                var path = BackupController.createBackup()
                toast.show(path && path.length > 0 ? "Backup created: " + path : "Backup failed", path && path.length > 0 ? "#059669" : "#e11d48")
                if (path && path.length > 0) page.refresh()
            } }
            AppButton { text: "Prune Old (keep 10)"; variant: "secondary"; iconName: "trash"; onClicked: {
                var n = BackupController.pruneOldBackups(10)
                toast.show("Removed " + n + " old backup(s)", "#059669")
                page.refresh()
            } }
            AppButton { text: "Refresh"; variant: "secondary"; iconName: "refresh"; onClicked: page.refresh() }
            Item { Layout.fillWidth: true }
        }

        // Table
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 40; color: Theme.surfaceHover
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    Row { x: 16; width: parent.width - 32; spacing: 0
                        Text { text: "FILE"; width: 200; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "CREATED"; width: 160; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "SIZE"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "PATH"; width: parent.width - 200 - 160 - 100 - 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "ACTIONS"; width: 120; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary } } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: page.backups
                    delegate: Rectangle { width: table.width; height: 44; color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                        Row { x: 16; width: parent.width - 32; spacing: 0
                            Text { text: modelData.fileName; width: 200; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: modelData.created; width: 160; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary }
                            Text { text: modelData.sizeDisplay; width: 100; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary }
                            Text { text: modelData.fullPath; width: parent.width - 200 - 160 - 100 - 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary; elide: Text.ElideRight }
                            Row { width: 120; height: 44; spacing: 4; layoutDirection: Qt.RightToLeft
                                TableActionButton { iconSource: "qrc:/icons/svg/trash.svg"; variantColor: "#e11d48"; anchors.verticalCenter: parent.verticalCenter; onClicked: { deleteDialog._path = modelData.fullPath; deleteDialog.warningText = "Backup file " + modelData.fileName + " will be permanently deleted."; deleteDialog.visible = true } }
                                TableActionButton { iconSource: "qrc:/icons/svg/check.svg"; variantColor: "#059669"; anchors.verticalCenter: parent.verticalCenter; onClicked: { var ok = BackupController.verifyBackup(modelData.fullPath); toast.show(ok ? "Backup is valid" : "Invalid backup", ok ? "#059669" : "#e11d48") } }
                                TableActionButton { iconSource: "qrc:/icons/svg/backup.svg"; variantColor: "#7c3aed"; anchors.verticalCenter: parent.verticalCenter; onClicked: { restoreDialog._path = modelData.fullPath; restoreDialog.visible = true } } }
                        }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton } } }
                Item { Layout.fillWidth: true; Layout.fillHeight: true; visible: page.backups.length === 0
                    Column { anchors.centerIn: parent; spacing: 8
                        Text { text: "No backups found"; font.family: Theme.activeFontFamily; font.pixelSize: 14; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Click 'Create Backup' to create your first backup"; font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter } } }
            }
        }
    }
}
