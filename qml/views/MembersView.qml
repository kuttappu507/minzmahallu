import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ============================================================================
// MembersView — member directory with photo, search, family link, gender filter
// ============================================================================
Item {
    id: root
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14

        // Header
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout {
                spacing: 2
                Text { text: "Members"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "All registered members across families"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                implicitHeight: 34; Layout.preferredWidth: 260
                RowLayout {
                    anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search by name, member #, phone..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text }
                }
            }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 110; model: ["All Gender", "Male", "Female"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 120; model: ["All Status", "Active", "Inactive"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle {
                radius: 8; color: Theme.sidebar
                implicitHeight: 34; Layout.preferredWidth: 110
                Text { anchors.centerIn: parent; text: "+ Add Member"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
            }
        }

        // Table
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
            ColumnLayout {
                anchors.fill: parent; spacing: 0
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 38; color: Theme.panelMuted
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                        Text { text: "MEMBER #"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "NAME"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "FAMILY"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "GENDER"; Layout.preferredWidth: 80; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "AGE"; Layout.preferredWidth: 60; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "PHONE"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "STATUS"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "ACTIONS"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    }
                }
                ListView {
                    id: table
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 0; model: memberModel
                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.memberNumber; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            RowLayout { Layout.fillWidth: true; spacing: 8
                                Rectangle { width: 30; height: 30; radius: 15; color: model.gender === "Male" ? Theme.tints.bl.sb : Theme.tints.pk.sb; border.width: 1; border.color: model.gender === "Male" ? Theme.tints.bl.sc : Theme.tints.pk.sc
                                    Text { anchors.centerIn: parent; text: model.name.charAt(0); font.family: Theme.fontDisplay; font.pixelSize: 12; font.weight: Font.Bold; color: model.gender === "Male" ? Theme.tints.bl.st : Theme.tints.pk.st } }
                                Text { text: model.name; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; Layout.fillWidth: true; elide: Text.ElideRight }
                            }
                            Text { text: model.familyName; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.gender; Layout.preferredWidth: 80; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            Text { text: model.age; Layout.preferredWidth: 60; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; horizontalAlignment: Text.AlignHCenter }
                            Text { text: model.phone; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Item {
                                Layout.preferredWidth: 100; Layout.preferredHeight: 26
                                property var p: Theme.pillFor(model.status)
                                Rectangle { anchors.centerIn: parent; width: 70; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } }
                            }
                            RowLayout { Layout.preferredWidth: 100; spacing: 4
                                Rectangle { width: 26; height: 26; radius: 6; color: Theme.tints.bl.sb; border.width: 1; border.color: Theme.tints.bl.sc; Text { anchors.centerIn: parent; text: "✎"; font.pixelSize: 11; color: Theme.tints.bl.st } }
                                Rectangle { width: 26; height: 26; radius: 6; color: Theme.tints.rd.sb; border.width: 1; border.color: Theme.tints.rd.sc; Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 11; color: Theme.tints.rd.st } }
                            }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–1,142 of 1,142 members"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
            Item { Layout.fillWidth: true }
            Rectangle { width: 26; height: 26; radius: 6; color: Theme.panel; border.width: 1; border.color: Theme.border; Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 14; color: Theme.muted } }
            Text { text: "1 of 23"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
            Rectangle { width: 26; height: 26; radius: 6; color: Theme.panel; border.width: 1; border.color: Theme.border; Text { anchors.centerIn: parent; text: "›"; font.pixelSize: 14; color: Theme.muted } }
        }
    }
    ListModel {
        id: memberModel
        ListElement { memberNumber: "KH-M-0001"; name: "Manzoor PP"; familyName: "Manzil Manzoor"; gender: "Male"; age: 45; phone: "9847123456"; status: "Active" }
        ListElement { memberNumber: "KH-M-0002"; name: "Suhara M"; familyName: "Manzil Manzoor"; gender: "Female"; age: 40; phone: "9847123457"; status: "Active" }
        ListElement { memberNumber: "KH-M-0003"; name: "Rahim PT"; familyName: "Puthanpurayil"; gender: "Male"; age: 52; phone: "9847234567"; status: "Active" }
        ListElement { memberNumber: "KH-M-0004"; name: "Jameela R"; familyName: "Puthanpurayil"; gender: "Female"; age: 47; phone: "9847234568"; status: "Active" }
        ListElement { memberNumber: "KH-M-0005"; name: "Sulaiman K"; familyName: "Kizhakkepuram"; gender: "Male"; age: 38; phone: "9847345678"; status: "Active" }
        ListElement { memberNumber: "KH-M-0006"; name: "Fathima S"; familyName: "Kizhakkepuram"; gender: "Female"; age: 35; phone: "9847345679"; status: "Active" }
        ListElement { memberNumber: "KH-M-0007"; name: "Hameed V"; familyName: "Vadakke Veettil"; gender: "Male"; age: 60; phone: "9847456789"; status: "Inactive" }
        ListElement { memberNumber: "KH-M-0008"; name: "Yusuf T"; familyName: "Thekkepuram"; gender: "Male"; age: 33; phone: "9847567890"; status: "Active" }
        ListElement { memberNumber: "KH-M-0009"; name: "Jameel P"; familyName: "Purayil House"; gender: "Male"; age: 41; phone: "9847678901"; status: "Active" }
        ListElement { memberNumber: "KH-M-0010"; name: "Sajna P"; familyName: "Puthanveettil"; gender: "Female"; age: 28; phone: "9847901234"; status: "Active" }
    }
}
