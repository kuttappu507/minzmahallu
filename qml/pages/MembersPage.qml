import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// MembersPage — Member management screen
//
// Uses MemberListModel (QAbstractListModel) as the ListView model.
// Uses MemberController for create/update/delete operations.
// Pattern follows FamiliesPage (reference implementation).
// ============================================================================

Item {
    id: page

    MemberEditDialog {
        id: editDialog
        onSaved: memberModel.refresh()
    }

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Member?"
        warningText: "This member record will be permanently deleted."
        property int _memberId: 0
        onAccepted: {
            if (_memberId > 0) {
                var result = memberController.remove(_memberId)
                if (!result.success) {
                    toast.show(result.error || "Delete failed", "#e11d48")
                } else {
                    toast.show("Member deleted", "#059669")
                }
            }
        }
    }

    // ===== Toast notification =====
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

        Text {
            id: toastText
            anchors.centerIn: parent
            text: toast.message
            font.family: "Poppins"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#ffffff"
        }

        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }

        function show(msg, color) {
            message = msg
            bgColor = color || "#059669"
            visible_ = true
            toastTimer.restart()
        }
    }

    Component.onCompleted: memberModel.refresh()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // ===== Page header =====
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Column {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "Members"
                    font.family: "Poppins"; font.pixelSize: 21; font.weight: Font.DemiBold; color: "#12241b"
                }
                Text {
                    text: "Manage all registered members in the mahallu"
                    font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c"
                }
            }

            AppButton {
                text: "Add Member"; variant: "primary"; iconName: "plus"
                Layout.alignment: Qt.AlignTop
                onClicked: { editDialog.memberId = 0; editDialog.readOnly = false; editDialog.show() }
            }
        }

        // ===== Toolbar =====
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.fillWidth: true; Layout.minimumWidth: 180
                height: 38; radius: 9
                color: "#f2faf4"; border.width: 1
                border.color: searchField.activeFocus ? "#059669" : (searchHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                Behavior on border.color { ColorAnimation { duration: 120 } }
                HoverHandler { id: searchHover; cursorShape: Qt.IBeamCursor }
                Item {
                    width: 16; height: 16
                    anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                    Image { id: memSearchIcon; source: "qrc:/icons/svg/search.svg"; sourceSize: Qt.size(16, 16); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                    MultiEffect { anchors.fill: parent; source: memSearchIcon; colorizationColor: searchField.activeFocus ? "#059669" : "#7e968a"; colorization: 1.0; Behavior on colorizationColor { ColorAnimation { duration: 120 } } }
                }
                TextField {
                    id: searchField
                    anchors.left: parent.left; anchors.leftMargin: 32
                    anchors.right: parent.right; anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    placeholderText: "Search by name, member code, mobile..."
                    placeholderTextColor: "#7e968a"
                    font.family: "Poppins"; font.pixelSize: 13; color: "#12241b"
                    background: Item {} verticalAlignment: Text.AlignVCenter
                    onTextEdited: searchDebounce.restart()
                }
                Timer {
                    id: searchDebounce
                    interval: 300
                    onTriggered: memberModel.searchTerm = searchField.text
                }
            }

            AppComboBox {
                model: ["All Gender", "Male", "Female", "Other"]
                implicitHeight: 38
                onActivated: function(index) {
                    memberModel.genderFilter = index === 0 ? "" : model[index]
                }
            }

            AppComboBox {
                model: ["All Status", "Active", "Inactive", "Deceased"]
                implicitHeight: 38
                onActivated: function(index) {
                    memberModel.statusFilter = index === 0 ? "" : model[index]
                }
            }

            Text {
                text: "Showing " + memberModel.rowCount + " of " + memberModel.totalCount
                font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a"
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // ===== Data table =====
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: "#ffffff"; border.width: 1; border.color: "#d2e5d8"

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                // Table header
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 40; color: "#f2faf4"
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#d2e5d8" }
                    Row {
                        x: 16; width: parent.width - 32; spacing: 0
                        Text { text: "CODE"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "NAME"; width: 180; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "FAMILY"; width: 150; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "GENDER"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "AGE"; width: 50; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "RELATION"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "MOBILE"; width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "STATUS"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Item { width: parent.width - 100 - 180 - 150 - 80 - 50 - 100 - 120 - 100 - 80; height: 40 }
                        Text { text: "ACTIONS"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                    }
                }

                // Table rows
                ListView {
                    id: table
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 0
                    model: memberModel

                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#eef8f1" }
                        Row {
                            x: 16; width: parent.width - 32; spacing: 0
                            Text { text: model.memberCode; width: 100; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#12241b"; elide: Text.ElideRight }
                            Text { text: model.name; width: 180; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#12241b"; elide: Text.ElideRight }
                            Text { text: (model.familyNumber || "") + " " + (model.houseName || ""); width: 150; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c"; elide: Text.ElideRight }
                            Text { text: model.gender || "—"; width: 80; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c" }
                            Text { text: model.age || "—"; width: 50; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#12241b" }
                            Text { text: model.relationship || "—"; width: 100; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c" }
                            Text { text: model.mobile; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c" }
                            Item { width: 100; height: 44; StatusBadge { anchors.centerIn: parent; text: model.status; variant: model.status.toLowerCase() } }
                            Item { width: parent.width - 100 - 180 - 150 - 80 - 50 - 100 - 120 - 100 - 80; height: 44 }
                            Row {
                                width: 80; height: 44; spacing: 4
                                layoutDirection: Qt.RightToLeft
                                TableActionButton {
                                    iconSource: "qrc:/icons/svg/trash.svg"; variantColor: "#e11d48"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: {
                                        deleteDialog._memberId = model.id
                                        deleteDialog.warningText = "Member \"" + model.name + "\" (" + model.memberCode + ") will be permanently deleted."
                                        deleteDialog.visible = true
                                    }
                                }
                                TableActionButton {
                                    iconSource: "qrc:/icons/svg/edit.svg"; variantColor: "#059669"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { editDialog.memberId = model.id; editDialog.readOnly = false; editDialog.show() }
                                }
                                TableActionButton {
                                    iconSource: "qrc:/icons/svg/search.svg"; variantColor: "#0284c7"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { editDialog.memberId = model.id; editDialog.readOnly = true; editDialog.show() }
                                }
                            }
                        }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                    }
                }

                // Empty state
                Item {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    visible: memberModel.rowCount === 0
                    Column {
                        anchors.centerIn: parent; spacing: 12
                        Rectangle {
                            width: 56; height: 56; radius: 28; color: "#f2faf4"; border.width: 1; border.color: "#d2e5d8"
                            anchors.horizontalCenter: parent.horizontalCenter
                            Item {
                                width: 28; height: 28; anchors.centerIn: parent
                                Image { id: emptyIcon; source: "qrc:/icons/svg/members.svg"; sourceSize: Qt.size(28, 28); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                                MultiEffect { anchors.fill: parent; source: emptyIcon; colorizationColor: "#b2cfbd"; colorization: 1.0 }
                            }
                        }
                        Text { text: "No members found"; font.family: "Poppins"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#12241b"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Click 'Add Member' to create your first member record"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Normal; color: "#7e968a"; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }

                // Pagination
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 44; color: "#f2faf4"
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#d2e5d8" }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                        Text { text: "Page " + memberModel.currentPage + " of " + memberModel.totalPages; font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a"; Layout.alignment: Qt.AlignVCenter }
                        Item { Layout.fillWidth: true }
                        Rectangle { width: 28; height: 28; radius: 6; color: prevMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: prevMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: memberModel.currentPage > 1 ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: prevIcon; source: "qrc:/icons/svg/chevron-left.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: prevIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: prevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (memberModel.currentPage > 1) memberModel.currentPage = memberModel.currentPage - 1 }
                        }
                        Rectangle { width: 28; height: 28; radius: 6; color: nextMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: nextMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: memberModel.currentPage < memberModel.totalPages ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: nextIcon; source: "qrc:/icons/svg/chevron-right.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: nextIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: nextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (memberModel.currentPage < memberModel.totalPages) memberModel.currentPage = memberModel.currentPage + 1 }
                        }
                    }
                }
            }
        }
    }
}
