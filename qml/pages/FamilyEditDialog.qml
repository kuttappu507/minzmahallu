import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import "../components"

// ============================================================================
// FamilyEditDialog — Add/Edit/View family form (2-column, responsive)
//
// PRODUCTION-READY:
//   - Calls FamilyController.create/update which return QVariantMap
//     { success, id, error, field }
//   - Dialog closes ONLY on success
//   - Shows error banner with backend message + highlights offending field
//   - Client-side validation mirrors C++ rules
//   - Ward combo populated from backend (real DB data)
//
// Layout: 2-column form for short fields, full-width for Address + Notes.
// Uses ModalDialog for the modal shell (backdrop + card + shadow + ESC).
// ============================================================================

ModalDialog {
    id: dialog
    modalWidth: 640
    modalHeight: 580
    closeOnBackdrop: false      // don't close on backdrop click — prevent accidental data loss
    closeOnEscape: true

    property int familyId: 0
    property bool readOnly: false
    signal saved()

    // Title text — property so show() can set it and the Component's Text can bind to it.
    // (ids declared inside a Component are NOT accessible from outside it.)
    property string _dialogTitle: "Add Family"

    // ===== Form data properties =====
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

    // ===== Error state =====
    property string _errorMessage: ""
    property string _errorField: ""

    function show() {
        _errorMessage = ""
        _errorField = ""

        if (familyId > 0 && typeof FamilyController !== "undefined") {
            var f = FamilyController.get(familyId)
            if (f && f.id !== undefined) {
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
                _dialogTitle = readOnly ? "View Family" : "Edit Family"
            } else {
                _errorMessage = "Could not load family (id: " + familyId + ")"
                _dialogTitle = "Edit Family"
            }
        } else {
            _familyNumber = ""; _houseName = ""; _houseNumber = ""; _ward = ""
            _area = ""; _address = ""; _pincode = ""; _phone = ""
            _altPhone = ""; _status = "Active"; _notes = ""
            _dialogTitle = "Add Family"
        }
        visible = true
    }

    // ===== Client-side validation — mirrors FamilyService::createFamily rules =====
    function validate() {
        _errorMessage = ""
        _errorField = ""

        if (_houseName.trim() === "" && _address.trim() === "") {
            _errorMessage = "Either House Name or Address is required."
            _errorField = "houseName"
            return false
        }
        if (_phone.trim() === "" && _altPhone.trim() === "") {
            _errorMessage = "At least one phone number is required."
            _errorField = "phone"
            return false
        }
        if (_phone.trim() !== "" && !/^(\+?\d{1,3}[-\s]?)?\d{10}$/.test(_phone.trim())) {
            _errorMessage = "Phone number format is invalid. Expected 10 digits, optional +country code."
            _errorField = "phone"
            return false
        }
        if (_pincode.trim() !== "" && !/^\d{6}$/.test(_pincode.trim())) {
            _errorMessage = "Pincode must be a 6-digit number."
            _errorField = "pincode"
            return false
        }
        return true
    }

    function submit() {
        if (readOnly) { dialog.visible = false; return }
        if (!validate()) return

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

        var result
        if (dialog.familyId > 0) {
            result = FamilyController.update(dialog.familyId, data)
        } else {
            result = FamilyController.create(data)
        }

        if (result.success) {
            _errorMessage = ""
            _errorField = ""
            dialog.saved()
            dialog.visible = false
        } else {
            _errorMessage = result.error || "Operation failed."
            _errorField = result.field || ""
        }
    }

    content: Component {
        Rectangle {
            anchors.fill: parent
            color: Theme.surface
            radius: 12
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // ===== Header =====
                Item {
                    Layout.fillWidth: true; Layout.preferredHeight: 56
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }

                    Text {
                        text: dialog._dialogTitle
                        font.family: Theme.activeFontFamily; font.pixelSize: 16; font.weight: Font.DemiBold; color: Theme.textPrimary
                        anchors.left: parent.left; anchors.leftMargin: 24; anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
                        width: 28; height: 28; radius: 6
                        color: closeMA.containsMouse ? "#f2faf4" : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "\u00D7"; font.pixelSize: 18; font.weight: Font.Bold; color: closeMA.containsMouse ? "#12241b" : "#7e968a" }
                        MouseArea { id: closeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: dialog.visible = false }
                    }
                }

                // ===== Error banner =====
                Rectangle {
                    Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 8
                    visible: dialog._errorMessage !== ""
                    height: 36
                    radius: 8
                    color: Theme.coralSubtle
                    border.width: 1; border.color: Theme.danger

                    Text {
                        anchors.fill: parent; anchors.margins: 8
                        text: dialog._errorMessage
                        font.family: Theme.activeFontFamily; font.pixelSize: 12; color: "#95102e"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                // ===== Form (scrollable) =====
                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: parent.width - 48; x: 24; spacing: 14

                        // ===== Family Number (read-only) =====
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "FAMILY NUMBER"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            Rectangle {
                                Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border
                                Text {
                                    anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                    text: dialog._familyNumber || "Auto-generated on save"
                                    font.family: Theme.activeFontFamily; font.pixelSize: 13; color: dialog._familyNumber ? "#12241b" : "#7e968a"
                                }
                            }
                        }

                        // ===== 2-column row: House Name | House Number =====
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            AppTextField {
                                Layout.fillWidth: true; label: "House Name *"; placeholderText: "e.g. Manzil Manzoor"
                                text: dialog._houseName; readOnly: dialog.readOnly
                                showError: dialog._errorField === "houseName"; errorText: dialog._errorMessage
                                onTextChanged: dialog._houseName = text
                            }
                            AppTextField {
                                Layout.fillWidth: true; label: "House Number"; placeholderText: "e.g. 14A"
                                text: dialog._houseNumber; readOnly: dialog.readOnly
                                onTextChanged: dialog._houseNumber = text
                            }
                        }

                        // ===== 2-column row: Ward | Phone =====
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16

                            AppComboBox {
                                Layout.fillWidth: true; label: "Ward"
                                model: {
                                    var w = ["(none)"]
                                    if (typeof FamilyController !== "undefined") {
                                        var wards = FamilyController.wards()
                                        for (var i = 0; i < wards.length; i++) w.push(wards[i])
                                    }
                                    return w
                                }
                                currentIndex: {
                                    if (dialog._ward === "") return 0
                                    var w = ["(none)"]
                                    if (typeof FamilyController !== "undefined") {
                                        var wards = FamilyController.wards()
                                        for (var i = 0; i < wards.length; i++) w.push(wards[i])
                                    }
                                    var idx = w.indexOf(dialog._ward)
                                    return idx >= 0 ? idx : 0
                                }
                                onActivated: function(index) {
                                    dialog._ward = index === 0 ? "" : model[index]
                                }
                            }

                            AppTextField {
                                Layout.fillWidth: true; label: "Phone *"; placeholderText: "9847123456"
                                text: dialog._phone; readOnly: dialog.readOnly
                                showError: dialog._errorField === "phone"; errorText: dialog._errorMessage
                                onTextChanged: dialog._phone = text
                            }
                        }

                        // ===== 2-column row: Area | Pincode =====
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            AppTextField {
                                Layout.fillWidth: true; label: "Area"; placeholderText: "e.g. Kondotty"
                                text: dialog._area; readOnly: dialog.readOnly
                                onTextChanged: dialog._area = text
                            }
                            AppTextField {
                                Layout.fillWidth: true; label: "Pincode"; placeholderText: "673601"
                                text: dialog._pincode; readOnly: dialog.readOnly
                                showError: dialog._errorField === "pincode"; errorText: dialog._errorMessage
                                onTextChanged: dialog._pincode = text
                            }
                        }

                        // ===== 2-column row: Status | Alternative Phone =====
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            AppComboBox {
                                Layout.fillWidth: true; label: "Status"
                                model: ["Active", "Inactive", "Archived"]
                                currentIndex: Math.max(0, ["Active", "Inactive", "Archived"].indexOf(dialog._status))
                                onActivated: function(index) { dialog._status = model[index] }
                            }
                            AppTextField {
                                Layout.fillWidth: true; label: "Alternative Phone"; placeholderText: "Optional second number"
                                text: dialog._altPhone; readOnly: dialog.readOnly
                                onTextChanged: dialog._altPhone = text
                            }
                        }

                        // ===== Address (full width) =====
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "ADDRESS"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea {
                                Layout.fillWidth: true; Layout.preferredHeight: 64
                                text: dialog._address; readOnly: dialog.readOnly
                                font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary
                                placeholderText: "Enter full address..."; placeholderTextColor: "#7e968a"
                                selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle {
                                    radius: 9; color: Theme.surfaceHover; border.width: 1
                                    border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"
                                    Behavior on border.color { ColorAnimation { duration: 120 } }
                                }
                                padding: 10
                                onTextChanged: dialog._address = text
                            }
                        }

                        // ===== Notes (full width) =====
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "NOTES"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea {
                                Layout.fillWidth: true; Layout.preferredHeight: 56
                                text: dialog._notes; readOnly: dialog.readOnly
                                font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary
                                placeholderText: "Internal notes (optional)..."; placeholderTextColor: "#7e968a"
                                selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle {
                                    radius: 9; color: Theme.surfaceHover; border.width: 1
                                    border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"
                                    Behavior on border.color { ColorAnimation { duration: 120 } }
                                }
                                padding: 10
                                onTextChanged: dialog._notes = text
                            }
                        }

                        Item { Layout.fillWidth: true; Layout.preferredHeight: 4 }
                    }
                }

                // ===== Footer =====
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 64; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }

                    Row {
                        anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter; spacing: 10

                        AppButton {
                            text: "Cancel"; variant: "secondary"
                            onClicked: dialog.visible = false
                        }

                        AppButton {
                            text: dialog.readOnly ? "Close" : (dialog.familyId > 0 ? "Save Changes" : "Add Family")
                            variant: "primary"; iconName: dialog.readOnly ? "" : "check"
                            onClicked: dialog.submit()
                        }
                    }
                }
            }
        }
    }
}
