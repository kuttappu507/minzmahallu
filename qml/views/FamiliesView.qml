import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

// ============================================================================
// FamiliesView — table with search, status filter, ward filter, add/edit/delete
// ============================================================================
Item {
    id: root

    // ----- Top header + actions -----
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 14

        RowLayout {
            Layout.fillWidth: true; spacing: 12

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Families"
                    font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold
                    color: Theme.text
                }
                Text {
                    text: "Manage all registered families in the mahallu"
                    font.family: Theme.fontPrimary; font.pixelSize: 11
                    color: Theme.muted
                }
            }
            Item { Layout.fillWidth: true }

            // Search
            Rectangle {
                radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout {
                    anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "Search by family #, house, phone..."
                        font.family: Theme.fontPrimary; font.pixelSize: 11
                        background: Item {}
                        color: Theme.text
                        onTextEdited: familyModel.filter(text, statusFilter.currentText, wardFilter.currentText)
                    }
                }
            }

            // Status filter
            ComboBox {
                id: statusFilter
                implicitHeight: 34; Layout.preferredWidth: 110
                model: ["All", "Active", "Inactive", "Archived"]
                font.family: Theme.fontPrimary; font.pixelSize: 11
                onCurrentIndexChanged: familyModel.filter(searchField.text, currentText, wardFilter.currentText)
            }

            // Ward filter
            ComboBox {
                id: wardFilter
                implicitHeight: 34; Layout.preferredWidth: 120
                model: ["All Wards", "Ward 1", "Ward 2", "Ward 3", "Ward 4"]
                font.family: Theme.fontPrimary; font.pixelSize: 11
                onCurrentIndexChanged: familyModel.filter(searchField.text, statusFilter.currentText, currentText)
            }

            // Add button
            Rectangle {
                radius: 8; color: Theme.sidebar; border.width: 0
                implicitHeight: 34; Layout.preferredWidth: 110
                Text {
                    anchors.centerIn: parent
                    text: "+ Add Family"
                    font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold
                    color: "#ffffff"
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
            }
        }

        // ----- Table -----
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                // Header row
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 38
                    color: Theme.panelMuted
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                        Text { text: "FAMILY #"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "HOUSE NAME"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "WARD"; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "PHONE"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "MEMBERS"; Layout.preferredWidth: 70; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "STATUS"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "ACTIONS"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    }
                }

                // Data rows
                ListView {
                    id: table
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 0
                    model: familyModel
                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.familyNumber; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 1
                                Text { text: model.houseName; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: model.headName; font.family: Theme.fontPrimary; font.pixelSize: 9; color: Theme.muted }
                            }
                            Text { text: model.ward; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            Text { text: model.phone; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.memberCount; Layout.preferredWidth: 70; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; horizontalAlignment: Text.AlignHCenter }
                            // Status pill
                            Item {
                                Layout.preferredWidth: 110; Layout.preferredHeight: 26
                                property var p: Theme.pillFor(model.status)
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 78; height: 22; radius: 11
                                    color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.parent.p.label
                                        font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold
                                        color: parent.parent.p.st
                                    }
                                }
                            }
                            // Actions
                            RowLayout {
                                Layout.preferredWidth: 100; spacing: 4
                                Rectangle { width: 26; height: 26; radius: 6; color: Theme.tints.bl.sb; border.width: 1; border.color: Theme.tints.bl.sc; Text { anchors.centerIn: parent; text: "✎"; font.pixelSize: 11; color: Theme.tints.bl.st } }
                                Rectangle { width: 26; height: 26; radius: 6; color: Theme.tints.sl.sb; border.width: 1; border.color: Theme.tints.sl.sc; Text { anchors.centerIn: parent; text: "↗"; font.pixelSize: 11; color: Theme.tints.sl.st } }
                                Rectangle { width: 26; height: 26; radius: 6; color: Theme.tints.rd.sb; border.width: 1; border.color: Theme.tints.rd.sc; Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 11; color: Theme.tints.rd.st } }
                            }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                    }
                }
            }
        }

        // Footer
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Text {
                text: "Showing 1–248 of 248 families"
                font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted
            }
            Item { Layout.fillWidth: true }
            Rectangle { width: 26; height: 26; radius: 6; color: Theme.panel; border.width: 1; border.color: Theme.border; Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 14; color: Theme.muted } }
            Text { text: "1"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
            Rectangle { width: 26; height: 26; radius: 6; color: Theme.panel; border.width: 1; border.color: Theme.border; Text { anchors.centerIn: parent; text: "›"; font.pixelSize: 14; color: Theme.muted } }
        }
    }

    // Inline list model (placeholder; will be replaced with C++ backend when wired)
    ListModel {
        id: familyModel

        function filter(term, status, ward) {
            // Placeholder — just keeps current rows
        }

        ListElement { familyNumber: "KH-F-0001"; houseName: "Manzil Manzoor"; headName: "Manzoor PP"; ward: "Ward 1"; phone: "9847123456"; memberCount: 5; status: "Active" }
        ListElement { familyNumber: "KH-F-0002"; houseName: "Puthanpurayil"; headName: "Rahim PT"; ward: "Ward 1"; phone: "9847234567"; memberCount: 4; status: "Active" }
        ListElement { familyNumber: "KH-F-0003"; houseName: "Kizhakkepuram"; headName: "Sulaiman K"; ward: "Ward 2"; phone: "9847345678"; memberCount: 6; status: "Active" }
        ListElement { familyNumber: "KH-F-0004"; houseName: "Vadakke Veettil"; headName: "Hameed V"; ward: "Ward 2"; phone: "9847456789"; memberCount: 3; status: "Active" }
        ListElement { familyNumber: "KH-F-0005"; houseName: "Thekkepuram"; headName: "Yusuf T"; ward: "Ward 3"; phone: "9847567890"; memberCount: 7; status: "Active" }
        ListElement { familyNumber: "KH-F-0006"; houseName: "Purayil House"; headName: "Jameel P"; ward: "Ward 3"; phone: "9847678901"; memberCount: 4; status: "Active" }
        ListElement { familyNumber: "KH-F-0007"; houseName: "Madappattu"; headName: "Ansar M"; ward: "Ward 4"; phone: "9847789012"; memberCount: 5; status: "Inactive" }
        ListElement { familyNumber: "KH-F-0008"; houseName: "Kunnumpuram"; headName: "Nisar K"; ward: "Ward 4"; phone: "9847890123"; memberCount: 3; status: "Active" }
        ListElement { familyNumber: "KH-F-0009"; houseName: "Puthanveettil"; headName: "Sajna P"; ward: "Ward 1"; phone: "9847901234"; memberCount: 4; status: "Active" }
        ListElement { familyNumber: "KH-F-0010"; houseName: "Chalil House"; headName: "Hamsa C"; ward: "Ward 2"; phone: "9847012345"; memberCount: 6; status: "Archived" }
        ListElement { familyNumber: "KH-F-0011"; houseName: "Puzhaypuram"; headName: "Rasheed P"; ward: "Ward 1"; phone: "9847123457"; memberCount: 5; status: "Active" }
        ListElement { familyNumber: "KH-F-0012"; houseName: "Velichappuram"; headName: "Suhara V"; ward: "Ward 2"; phone: "9847234568"; memberCount: 4; status: "Active" }
    }
}
