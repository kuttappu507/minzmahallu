import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// AuditLogView — system audit trail
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Audit Log"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Complete audit trail of user actions"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search actions..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text } } }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 130; model: ["All Modules", "Families", "Members", "Donations", "Users"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 130; model: ["Today", "This Week", "This Month", "All"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 100
                Text { anchors.centerIn: parent; text: "↓ Export"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text } }
        }
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "TOTAL ENTRIES"; value: "1,248"; sub: "All time"; tint: "sl" }
                    ListElement { label: "TODAY"; value: "27"; sub: "Actions today"; tint: "em" }
                    ListElement { label: "THIS WEEK"; value: "184"; sub: "Last 7 days"; tint: "bl" }
                    ListElement { label: "USERS ACTIVE"; value: "5"; sub: "5/5 users"; tint: "vi" }
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
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 38; color: Theme.panelMuted
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                        Text { text: "TIMESTAMP"; Layout.preferredWidth: 160; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "USER"; Layout.preferredWidth: 140; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "MODULE"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "ACTION"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "DETAILS"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "IP"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: aModel
                    delegate: Rectangle { width: table.width; height: 40
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.timestamp; Layout.preferredWidth: 160; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
                            Text { text: model.user; Layout.preferredWidth: 140; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Bold; color: Theme.text }
                            Item { Layout.preferredWidth: 130; Layout.preferredHeight: 20
                                property var p: Theme.pillFor(model.module)
                                Rectangle { anchors.centerIn: parent; width: 90; height: 20; radius: 10; color: parent.p.sb; border.width: 1; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; color: parent.parent.p.st } } }
                            Text { text: model.action; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.text }
                            Text { text: model.details; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted; elide: Text.ElideRight }
                            Text { text: model.ip; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–15 of 1,248 entries"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
            Item { Layout.fillWidth: true }
            Rectangle { width: 26; height: 26; radius: 6; color: Theme.panel; border.width: 1; border.color: Theme.border; Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 14; color: Theme.muted } }
            Text { text: "1 of 84"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
            Rectangle { width: 26; height: 26; radius: 6; color: Theme.panel; border.width: 1; border.color: Theme.border; Text { anchors.centerIn: parent; text: "›"; font.pixelSize: 14; color: Theme.muted } }
        }
    }
    ListModel { id: aModel
        ListElement { timestamp: "02 Aug 2026 03:45 PM"; user: "admin"; module: "Active"; action: "CREATE"; details: "Added family KH-F-0249 (Manzil Manzoor)"; ip: "127.0.0.1" }
        ListElement { timestamp: "02 Aug 2026 03:28 PM"; user: "treasurer"; module: "Approved"; action: "RECEIVE"; details: "Donation D-2026-078 (Rs.5,000)"; ip: "127.0.0.1" }
        ListElement { timestamp: "02 Aug 2026 02:15 PM"; user: "admin"; module: "Issued"; action: "ISSUE"; details: "Marriage certificate M-2026-017"; ip: "127.0.0.1" }
        ListElement { timestamp: "02 Aug 2026 01:50 PM"; user: "secretary"; module: "Approved"; action: "OVERDUE"; details: "Marked 7 families overdue for July"; ip: "127.0.0.1" }
        ListElement { timestamp: "02 Aug 2026 12:30 PM"; user: "admin"; module: "Active"; action: "LOGIN"; details: "User logged in successfully"; ip: "127.0.0.1" }
        ListElement { timestamp: "02 Aug 2026 11:20 AM"; user: "treasurer"; module: "Active"; action: "LOGIN"; details: "User logged in successfully"; ip: "127.0.0.1" }
        ListElement { timestamp: "01 Aug 2026 04:55 PM"; user: "admin"; module: "Approved"; action: "BACKUP"; details: "Manual backup created (mms_backup_20260801.bak)"; ip: "127.0.0.1" }
    }
}
