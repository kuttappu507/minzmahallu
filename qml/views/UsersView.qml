import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// UsersView — admin user management
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Users"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Manage user accounts and permissions"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search users..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text } } }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 130; model: ["All Roles", "Administrator", "Secretary", "Treasurer", "User"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 110
                Text { anchors.centerIn: parent; text: "+ Add User"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
        }
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "TOTAL USERS"; value: "5"; sub: "Active accounts"; tint: "bl" }
                    ListElement { label: "ADMINS"; value: "1"; sub: "Full access"; tint: "rd" }
                    ListElement { label: "ACTIVE SESSIONS"; value: "2"; sub: "Currently logged in"; tint: "em" }
                    ListElement { label: "LOCKED"; value: "0"; sub: "No locked accounts"; tint: "sl" }
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
                        Text { text: "USERNAME"; Layout.preferredWidth: 140; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "FULL NAME"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "ROLE"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "LAST LOGIN"; Layout.preferredWidth: 160; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "STATUS"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "ACTIONS"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: uModel
                    delegate: Rectangle { width: table.width; height: 44
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            RowLayout { Layout.preferredWidth: 140; spacing: 8
                                Rectangle { width: 28; height: 28; radius: 14; color: Theme.tints.bl.sb; border.width: 1; border.color: Theme.tints.bl.sc
                                    Text { anchors.centerIn: parent; text: model.username.charAt(0).toUpperCase(); font.family: Theme.fontDisplay; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.tints.bl.st } }
                                Text { text: model.username; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            }
                            Text { text: model.fullName; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; elide: Text.ElideRight }
                            Item { Layout.preferredWidth: 130; Layout.preferredHeight: 22
                                property var p: Theme.pillFor(model.role)
                                Rectangle { anchors.centerIn: parent; width: 95; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                            Text { text: model.lastLogin; Layout.preferredWidth: 160; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Item { Layout.preferredWidth: 110; Layout.preferredHeight: 22
                                property var p: Theme.pillFor(model.status)
                                Rectangle { anchors.centerIn: parent; width: 70; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                            RowLayout { Layout.preferredWidth: 130; spacing: 4
                                Rectangle { width: 28; height: 26; radius: 6; color: Theme.tints.sl.sb; border.width: 1; border.color: Theme.tints.sl.sc; Text { anchors.centerIn: parent; text: "✎"; font.pixelSize: 11; color: Theme.tints.sl.st } }
                                Rectangle { width: 28; height: 26; radius: 6; color: Theme.tints.am.sb; border.width: 1; border.color: Theme.tints.am.sc; Text { anchors.centerIn: parent; text: "🔑"; font.pixelSize: 11; color: Theme.tints.am.st } }
                                Rectangle { width: 28; height: 26; radius: 6; color: Theme.tints.rd.sb; border.width: 1; border.color: Theme.tints.rd.sc; Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 11; color: Theme.tints.rd.st } }
                            }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–5 of 5 users"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
        }
    }
    ListModel { id: uModel
        ListElement { username: "admin"; fullName: "Mahallu Administrator"; role: "Approved"; lastLogin: "Today, 03:45 PM"; status: "Active" }
        ListElement { username: "treasurer"; fullName: "Rahim PT (Treasurer)"; role: "Approved"; lastLogin: "Today, 11:20 AM"; status: "Active" }
        ListElement { username: "secretary"; fullName: "Sulaiman K (Secretary)"; role: "Approved"; lastLogin: "Yesterday, 04:30 PM"; status: "Active" }
        ListElement { username: "auditor"; fullName: "Yusuf T (Auditor)"; role: "Approved"; lastLogin: "27 Jul 2026"; status: "Inactive" }
        ListElement { username: "user1"; fullName: "Jameel P (Clerk)"; role: "Approved"; lastLogin: "25 Jul 2026"; status: "Inactive" }
    }
}
