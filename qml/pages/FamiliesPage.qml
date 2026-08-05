import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// FamiliesPage — Family management screen
// Reuses DashboardV3 design language: colors, spacing, typography, borders
//
// Features: search, ward/status filters, data table, pagination,
// Add/Edit/Delete via dialog, View detail.
// ============================================================================

Item {
    id: page

    property int currentPage: 1
    property int pageSize: 25
    property int totalRecords: 0
    property int totalPages: Math.max(1, Math.ceil(totalRecords / pageSize))
    property string searchTerm: ""
    property string statusFilter: ""
    property string wardFilter: ""

    ListModel { id: familyModel }

    FamilyEditDialog {
        id: editDialog
        onSaved: page.refresh()
    }

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Family?"
        warningText: "This family record will be permanently deleted."
        onAccepted: {
            if (deleteDialog._familyId > 0) {
                Services.deleteFamily(deleteDialog._familyId)
                page.refresh()
            }
        }
        property int _familyId: 0
    }

    Component.onCompleted: refresh()

    function refresh() {
        familyModel.clear()
        if (typeof Services === "undefined") return
        var families = Services.searchFamilies(searchTerm, currentPage, pageSize, statusFilter, wardFilter)
        for (var i = 0; i < families.length; i++) {
            familyModel.append(families[i])
        }
        totalRecords = Services.totalFamilies
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 16

        // Page header
        Row {
            Layout.fillWidth: true
            spacing: 14

            Column {
                spacing: 2
                Text {
                    text: "Families"
                    font.family: "Poppins"; font.pixelSize: 21; font.weight: Font.DemiBold; color: "#12241b"
                }
                Text {
                    text: "Manage all registered families in the mahallu"
                    font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c"
                }
            }
            Item { width: 1; height: 1; Layout.fillWidth: true }
            AppButton {
                text: "Add Family"; variant: "primary"; iconName: "plus"
                onClicked: { editDialog.familyId = 0; editDialog.readOnly = false; editDialog.show() }
            }
        }

        // Toolbar
        Row {
            Layout.fillWidth: true; spacing: 10

            Rectangle {
                width: 260; height: 38; radius: 9
                color: "#f2faf4"; border.width: 1
                border.color: searchField.activeFocus ? "#059669" : (searchHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                Behavior on border.color { ColorAnimation { duration: 120 } }
                HoverHandler { id: searchHover; cursorShape: Qt.IBeamCursor }
                Item {
                    width: 16; height: 16
                    anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                    Image { id: famSearchIcon; source: "qrc:/icons/svg/search.svg"; sourceSize: Qt.size(16, 16); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                    MultiEffect { anchors.fill: parent; source: famSearchIcon; colorizationColor: searchField.activeFocus ? "#059669" : "#7e968a"; colorization: 1.0; Behavior on colorizationColor { ColorAnimation { duration: 120 } } }
                }
                TextField {
                    id: searchField
                    anchors.left: parent.left; anchors.leftMargin: 32
                    anchors.right: parent.right; anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    placeholderText: "Search by family #, house name, phone..."
                    placeholderTextColor: "#7e968a"
                    font.family: "Poppins"; font.pixelSize: 13; color: "#12241b"
                    background: Item {} verticalAlignment: Text.AlignVCenter
                    onTextEdited: { page.searchTerm = text; page.currentPage = 1; searchTimer.restart() }
                }
                Timer { id: searchTimer; interval: 300; onTriggered: page.refresh() }
            }

            AppComboBox {
                model: ["All Status", "Active", "Inactive", "Archived"]
                implicitHeight: 38
                onActivated: function(index) { page.statusFilter = index === 0 ? "" : model[index]; page.currentPage = 1; page.refresh() }
            }

            AppComboBox {
                id: wardCombo
                model: ["All Wards"].concat(typeof Services !== "undefined" ? Services.wards : [])
                implicitHeight: 38
                onActivated: function(index) { page.wardFilter = index === 0 ? "" : model[index]; page.currentPage = 1; page.refresh() }
            }

            Item { width: 1; height: 1; Layout.fillWidth: true }
            Text {
                text: "Showing " + familyModel.count + " of " + totalRecords + " families"
                font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Normal; color: "#7e968a"
                y: (38 - height) / 2
            }
        }

        // Data table
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: "#ffffff"; border.width: 1; border.color: "#d2e5d8"

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                // Headers
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 40; color: "#f2faf4"
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#d2e5d8" }
                    Row {
                        x: 16; width: parent.width - 32; spacing: 0
                        Text { text: "FAMILY #"; width: 110; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Bold; color: "#7e968a" }
                        Text { text: "HOUSE NAME"; width: 160; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Bold; color: "#7e968a" }
                        Text { text: "HEAD"; width: 140; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Bold; color: "#7e968a" }
                        Text { text: "WARD"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Bold; color: "#7e968a" }
                        Text { text: "MEMBERS"; width: 70; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Bold; color: "#7e968a" }
                        Text { text: "PHONE"; width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Bold; color: "#7e968a" }
                        Text { text: "STATUS"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Bold; color: "#7e968a" }
                        Item { width: parent.width - 110 - 160 - 140 - 80 - 70 - 120 - 100 - 80; height: 40 }
                        Text { text: "ACTIONS"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Bold; color: "#7e968a" }
                    }
                }

                // Rows
                ListView {
                    id: table
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 0; model: familyModel

                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#eef8f1" }
                        Row {
                            x: 16; width: parent.width - 32; spacing: 0
                            Text { text: model.familyNumber; width: 110; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#12241b"; elide: Text.ElideRight }
                            Text { text: model.houseName; width: 160; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#12241b"; elide: Text.ElideRight }
                            Text { text: model.headName; width: 140; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c"; elide: Text.ElideRight }
                            Text { text: model.ward; width: 80; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c" }
                            Text { text: model.memberCount; width: 70; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#12241b" }
                            Text { text: model.phone; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c" }
                            Item { width: 100; height: 44; StatusBadge { y: (44 - height) / 2; text: model.status; variant: model.status.toLowerCase() } }
                            Item { width: parent.width - 110 - 160 - 140 - 80 - 70 - 120 - 100 - 80; height: 44 }
                            Row {
                                width: 80; height: 44; spacing: 4
                                // View
                                Rectangle { width: 28; height: 28; radius: 6; color: viewMA.containsMouse ? "#d7edfb" : "transparent"; border.width: 1; border.color: viewMA.containsMouse ? "#0284c7" : "#d2e5d8"; y: (44 - 28) / 2; Behavior on color { ColorAnimation { duration: 120 } }
                                    Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: viewIcon; source: "qrc:/icons/svg/search.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: viewIcon; colorizationColor: "#0284c7"; colorization: 1.0 } }
                                    MouseArea { id: viewMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { editDialog.familyId = model.id; editDialog.readOnly = true; editDialog.show() } }
                                }
                                // Edit
                                Rectangle { width: 28; height: 28; radius: 6; color: editMA.containsMouse ? "#ecfdf5" : "transparent"; border.width: 1; border.color: editMA.containsMouse ? "#059669" : "#d2e5d8"; y: (44 - 28) / 2; Behavior on color { ColorAnimation { duration: 120 } }
                                    Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: editIcon; source: "qrc:/icons/svg/edit.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: editIcon; colorizationColor: "#059669"; colorization: 1.0 } }
                                    MouseArea { id: editMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { editDialog.familyId = model.id; editDialog.readOnly = false; editDialog.show() } }
                                }
                                // Delete
                                Rectangle { width: 28; height: 28; radius: 6; color: delMA.containsMouse ? "#fddfe5" : "transparent"; border.width: 1; border.color: delMA.containsMouse ? "#e11d48" : "#d2e5d8"; y: (44 - 28) / 2; Behavior on color { ColorAnimation { duration: 120 } }
                                    Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: delIcon; source: "qrc:/icons/svg/trash.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: delIcon; colorizationColor: "#e11d48"; colorization: 1.0 } }
                                    MouseArea { id: delMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { deleteDialog._familyId = model.id; deleteDialog.warningText = "Family \"" + model.houseName + "\" (" + model.familyNumber + ") will be permanently deleted."; deleteDialog.visible = true } }
                                }
                            }
                        }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                    }
                }

                // Empty state
                Item {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    visible: familyModel.count === 0
                    Column {
                        anchors.centerIn: parent; spacing: 12
                        // Icon circle (replaces emoji that didn't render)
                        Rectangle {
                            width: 56; height: 56; radius: 28; color: "#f2faf4"; border.width: 1; border.color: "#d2e5d8"
                            anchors.horizontalCenter: parent.horizontalCenter
                            Item {
                                width: 28; height: 28; anchors.centerIn: parent
                                Image { id: emptyIcon; source: "qrc:/icons/svg/families.svg"; sourceSize: Qt.size(28, 28); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                                MultiEffect { anchors.fill: parent; source: emptyIcon; colorizationColor: "#b2cfbd"; colorization: 1.0 }
                            }
                        }
                        Text { text: "No families found"; font.family: "Poppins"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#12241b"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Click 'Add Family' to create your first family record"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Normal; color: "#7e968a"; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }

                // Pagination
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 44; color: "#f2faf4"
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#d2e5d8" }
                    Row {
                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                        Text { text: "Page " + currentPage + " of " + totalPages; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Normal; color: "#7e968a"; y: (44 - height) / 2 }
                        Item { width: 1; height: 1; Layout.fillWidth: true }
                        Rectangle { width: 28; height: 28; radius: 6; color: prevMA.containsMouse ? "#f2faf4" : "transparent"; border.width: 1; border.color: "#d2e5d8"; y: (44 - 28) / 2; opacity: currentPage > 1 ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { source: "qrc:/icons/svg/chevron-left.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false; MultiEffect { anchors.fill: parent; source: parent; colorizationColor: "#4f6b5c"; colorization: 1.0 } } }
                            MouseArea { id: prevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (currentPage > 1) { currentPage--; refresh() } }
                        }
                        Rectangle { width: 28; height: 28; radius: 6; color: nextMA.containsMouse ? "#f2faf4" : "transparent"; border.width: 1; border.color: "#d2e5d8"; y: (44 - 28) / 2; opacity: currentPage < totalPages ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { source: "qrc:/icons/svg/chevron-right.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false; MultiEffect { anchors.fill: parent; source: parent; colorizationColor: "#4f6b5c"; colorization: 1.0 } } }
                            MouseArea { id: nextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (currentPage < totalPages) { currentPage++; refresh() } }
                        }
                    }
                }
            }
        }
    }
}
