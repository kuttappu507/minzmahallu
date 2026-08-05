import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

// ============================================================================
// FamilyEditDialog — Add/Edit/View family form
// Matches DashboardV3 design: white card, #d2e5d8 borders, 9px radius, Poppins
// ============================================================================

ApplicationWindow {
    id: dialog
    visible: false
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"

    property int familyId: 0
    property bool readOnly: false
    signal saved()

    width: 520; height: 580; minimumWidth: 520; minimumHeight: 580

    // Form data
    property string _familyNumber: ""
    property string _houseName: ""
    property string _houseNumber: ""
    property string _ward: ""
    property string _area: ""
    property string _address: ""
    property string _pincode: ""
    property string _phone: ""
    property string _altPhone: ""
    property string _status: "Active"
    property string _notes: ""

    function show() {
        if (familyId > 0 && typeof Services !== "undefined") {
            var f = Services.getFamily(familyId)
            _familyNumber = f.familyNumber || ""
            _houseName = f.houseName || ""
            _houseNumber = f.houseNumber || ""
            _ward = f.ward || ""
            _area = f.area || ""
            _address = f.address || ""
            _pincode = f.pincode || ""
            _phone = f.phone || ""
            _altPhone = f.alternativePhone || ""
            _status = f.status || "Active"
            _notes = f.notes || ""
            titleText.text = readOnly ? "View Family" : "Edit Family"
        } else {
            _familyNumber = ""; _houseName = ""; _houseNumber = ""; _ward = ""
            _area = ""; _address = ""; _pincode = ""; _phone = ""
            _altPhone = ""; _status = "Active"; _notes = ""
            titleText.text = "Add Family"
        }
        // Center over the parent window
        var parentWin = dialog.transientParent
        if (parentWin) {
            dialog.x = parentWin.x + (parentWin.width - dialog.width) / 2
            dialog.y = parentWin.y + (parentWin.height - dialog.height) / 2
        }
        visible = true
    }

    Rectangle {
        anchors.fill: parent; color: Qt.rgba(0.02, 0.05, 0.15, 0.4)
    }

    Rectangle {
        anchors.fill: parent; color: "#ffffff"; radius: 12

        ColumnLayout {
            anchors.fill: parent; spacing: 0

            // Header
            Item {
                Layout.fillWidth: true; Layout.preferredHeight: 56
                Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#eef8f1" }

                Text {
                    id: titleText
                    text: "Add Family"
                    font.family: "Poppins"; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#12241b"
                    anchors.left: parent.left; anchors.leftMargin: 20; anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                    width: 28; height: 28; radius: 6
                    color: closeMA.containsMouse ? "#f2faf4" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text { anchors.centerIn: parent; text: "\×"; font.pixelSize: 18; font.weight: Font.Bold; color: closeMA.containsMouse ? "#12241b" : "#7e968a" }
                    MouseArea { id: closeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: dialog.visible = false }
                }
            }

            // Form
            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: parent.width - 40; x: 20; spacing: 14

                    AppTextField { Layout.fillWidth: true; label: "Family Number"; placeholderText: "Auto-generated"; text: dialog._familyNumber; readOnly: true }
                    AppTextField { Layout.fillWidth: true; label: "House Name"; placeholderText: "e.g. Manzil Manzoor"; text: dialog._houseName; readOnly: dialog.readOnly }
                    AppTextField { Layout.fillWidth: true; label: "House Number"; placeholderText: "e.g. 14A"; text: dialog._houseNumber; readOnly: dialog.readOnly }

                    RowLayout {
                        Layout.fillWidth: true; spacing: 12
                        AppComboBox { Layout.fillWidth: true; label: "Ward"; model: ["Ward 1", "Ward 2", "Ward 3", "Ward 4"]; currentIndex: Math.max(0, ["Ward 1", "Ward 2", "Ward 3", "Ward 4"].indexOf(dialog._ward)); onActivated: function(index) { dialog._ward = model[index] } }
                        AppTextField { Layout.fillWidth: true; label: "Phone"; placeholderText: "9847123456"; text: dialog._phone; readOnly: dialog.readOnly }
                    }

                    AppTextField { Layout.fillWidth: true; label: "Area"; placeholderText: "e.g. Kondotty"; text: dialog._area; readOnly: dialog.readOnly }

                    // Address (multiline)
                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: "ADDRESS"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Medium; color: "#7e968a" }
                        TextArea {
                            Layout.fillWidth: true; Layout.preferredHeight: 72
                            text: dialog._address; readOnly: dialog.readOnly
                            font.family: "Poppins"; font.pixelSize: 13; color: "#12241b"
                            placeholderText: "Enter full address..."; placeholderTextColor: "#7e968a"
                            selectByMouse: true; wrapMode: TextArea.Wrap
                            background: Rectangle { radius: 9; color: "#f2faf4"; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                            padding: 10
                            onTextChanged: dialog._address = text
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true; spacing: 12
                        AppTextField { Layout.fillWidth: true; label: "Pincode"; placeholderText: "673601"; text: dialog._pincode; readOnly: dialog.readOnly }
                        AppComboBox { Layout.fillWidth: true; label: "Status"; model: ["Active", "Inactive", "Archived"]; currentIndex: Math.max(0, ["Active", "Inactive", "Archived"].indexOf(dialog._status)); onActivated: function(index) { dialog._status = model[index] } }
                    }

                    Item { Layout.fillWidth: true; Layout.preferredHeight: 8 }
                }
            }

            // Footer
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 64; color: "#f2faf4"
                Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#eef8f1" }

                Row {
                    anchors.right: parent.right; anchors.rightMargin: 20; anchors.verticalCenter: parent.verticalCenter; spacing: 10

                    AppButton {
                        text: "Cancel"; variant: "secondary"
                        onClicked: dialog.visible = false
                    }

                    AppButton {
                        text: dialog.readOnly ? "Close" : (dialog.familyId > 0 ? "Save Changes" : "Add Family")
                        variant: "primary"; iconName: dialog.readOnly ? "" : "check"
                        visible: !dialog.readOnly || true
                        onClicked: {
                            if (dialog.readOnly) { dialog.visible = false; return }
                            var data = {
                                familyNumber: dialog._familyNumber,
                                houseName: dialog._houseName,
                                houseNumber: dialog._houseNumber,
                                ward: dialog._ward,
                                area: dialog._area,
                                address: dialog._address,
                                pincode: dialog._pincode,
                                phone: dialog._phone,
                                alternativePhone: dialog._altPhone,
                                status: dialog._status,
                                notes: dialog._notes
                            }
                            if (dialog.familyId > 0) {
                                Services.updateFamily(dialog.familyId, data)
                            } else {
                                Services.createFamily(data)
                            }
                            dialog.saved()
                            dialog.visible = false
                        }
                    }
                }
            }
        }
    }
}
