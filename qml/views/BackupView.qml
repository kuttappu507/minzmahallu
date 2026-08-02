import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// BackupView — database backup/restore interface
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Backup"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Backup and restore the database"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 140
                Text { anchors.centerIn: parent; text: "⚡ Create Backup"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 140
                Text { anchors.centerIn: parent; text: "↻ Restore..."; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text } }
        }
        // Stats
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "LAST BACKUP"; value: "01 Aug 2026"; sub: "Yesterday at 04:55 PM"; tint: "em" }
                    ListElement { label: "TOTAL BACKUPS"; value: "42"; sub: "Stored locally"; tint: "bl" }
                    ListElement { label: "DATABASE SIZE"; value: "12.4 MB"; sub: "Grows ~50KB/week"; tint: "vi" }
                    ListElement { label: "AUTO BACKUP"; value: "ON"; sub: "Every 6 hours"; tint: "am" }
                }
                delegate: Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 90; radius: 10
                    property var t: Theme.tint(model.tint)
                    color: t.sb; border.width: 1.5; border.color: t.sc
                    ColumnLayout { anchors.fill: parent; anchors.margins: 14; spacing: 4
                        Text { text: model.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: t.st }
                        Text { text: model.value; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: t.st }
                        Text { text: model.sub; font.family: Theme.fontPrimary; font.pixelSize: 9; color: t.st; opacity: 0.7 }
                    }
                }
            }
        }
        // Auto-backup config
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 120; radius: 10
            color: Theme.panel; border.width: 1.5; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                Text { text: "Automatic Backup"; font.family: Theme.fontDisplay; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text }
                RowLayout { Layout.fillWidth: true; spacing: 12
                    Text { text: "Enable automatic backups"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                    Switch { checked: true }
                    Item { Layout.fillWidth: true }
                    Text { text: "Interval"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                    ComboBox { implicitHeight: 30; Layout.preferredWidth: 140; model: ["Every 3 hours", "Every 6 hours", "Every 12 hours", "Daily"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
                    Text { text: "Keep last"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                    SpinBox { from: 1; to: 100; value: 10; font.family: Theme.fontPrimary; font.pixelSize: 11 }
                }
            }
        }
        // Backups table
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 38; color: Theme.panelMuted
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                        Text { text: "FILENAME"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "CREATED"; Layout.preferredWidth: 160; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "SIZE"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignRight }
                        Text { text: "TYPE"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "ACTIONS"; Layout.preferredWidth: 200; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: bModel
                    delegate: Rectangle { width: table.width; height: 42
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            RowLayout { Layout.fillWidth: true; spacing: 8
                                Text { text: "💾"; font.pixelSize: 14 }
                                Text { text: model.filename; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text; elide: Text.ElideRight }
                            }
                            Text { text: model.created; Layout.preferredWidth: 160; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.size; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; horizontalAlignment: Text.AlignRight }
                            Item { Layout.preferredWidth: 100; Layout.preferredHeight: 22
                                property var p: Theme.pillFor(model.type)
                                Rectangle { anchors.centerIn: parent; width: 75; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                            RowLayout { Layout.preferredWidth: 200; spacing: 4
                                Rectangle { width: 60; height: 26; radius: 6; color: Theme.tints.em.sb; border.width: 1; border.color: Theme.tints.em.sc; Text { anchors.centerIn: parent; text: "Restore"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: Theme.tints.em.st } }
                                Rectangle { width: 60; height: 26; radius: 6; color: Theme.tints.bl.sb; border.width: 1; border.color: Theme.tints.bl.sc; Text { anchors.centerIn: parent; text: "Verify"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: Theme.tints.bl.st } }
                                Rectangle { width: 60; height: 26; radius: 6; color: Theme.tints.am.sb; border.width: 1; border.color: Theme.tints.am.sc; Text { anchors.centerIn: parent; text: "↓ Save"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: Theme.tints.am.st } }
                            }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–10 of 42 backups"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
            Item { Layout.fillWidth: true }
            Rectangle { width: 26; height: 26; radius: 6; color: Theme.panel; border.width: 1; border.color: Theme.border; Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 14; color: Theme.muted } }
            Text { text: "1 of 5"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
            Rectangle { width: 26; height: 26; radius: 6; color: Theme.panel; border.width: 1; border.color: Theme.border; Text { anchors.centerIn: parent; text: "›"; font.pixelSize: 14; color: Theme.muted } }
        }
    }
    ListModel { id: bModel
        ListElement { filename: "mms_backup_20260801_165500.bak"; created: "01 Aug 2026 04:55 PM"; size: "12.4 MB"; type: "Issued" }
        ListElement { filename: "mms_backup_20260801_105500.bak"; created: "01 Aug 2026 10:55 AM"; size: "12.3 MB"; type: "Approved" }
        ListElement { filename: "mms_backup_20260801_045500.bak"; created: "01 Aug 2026 04:55 AM"; size: "12.3 MB"; type: "Approved" }
        ListElement { filename: "mms_backup_20260731_225500.bak"; created: "31 Jul 2026 10:55 PM"; size: "12.2 MB"; type: "Approved" }
        ListElement { filename: "mms_backup_20260731_165500.bak"; created: "31 Jul 2026 04:55 PM"; size: "12.2 MB"; type: "Approved" }
        ListElement { filename: "mms_backup_20260731_105500.bak"; created: "31 Jul 2026 10:55 AM"; size: "12.2 MB"; type: "Approved" }
        ListElement { filename: "mms_backup_20260731_045500.bak"; created: "31 Jul 2026 04:55 AM"; size: "12.1 MB"; type: "Approved" }
        ListElement { filename: "mms_backup_20260730_225500.bak"; created: "30 Jul 2026 10:55 PM"; size: "12.1 MB"; type: "Approved" }
        ListElement { filename: "mms_backup_20260730_165500.bak"; created: "30 Jul 2026 04:55 PM"; size: "12.0 MB"; type: "Approved" }
        ListElement { filename: "mms_backup_20260730_105500.bak"; created: "30 Jul 2026 10:55 AM"; size: "12.0 MB"; type: "Approved" }
    }
}
