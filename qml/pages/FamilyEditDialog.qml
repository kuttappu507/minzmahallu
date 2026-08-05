import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

// ============================================================================
// FamilyEditDialog — Add/Edit/View family form
//
// PRODUCTION-READY: calls FamilyController.create/update which return
// QVariantMap { success, id, error, field }. The dialog closes ONLY on
// success. On failure it shows an error banner with the backend message
// and highlights the offending field.
//
// Client-side validation mirrors the C++ rules (FamilyService::createFamily)
// for instant UX feedback — but the C++ service is the source of truth.
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

    // Window IS the card — no dark overlay. Modality handles blocking.
    width: 520; height: 620; minimumWidth: 520; minimumHeight: 620

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
                titleText.text = readOnly ? "View Family" : "Edit Family"
            } else {
                _errorMessage = "Could not load family (id: " + familyId + ")"
                titleText.text = "Edit Family"
            }
        } else {
            _familyNumber = ""; _houseName = ""; _houseNumber = ""; _ward = ""
            _area = ""; _address = ""; _pincode = ""; _phone = ""
            _altPhone = ""; _status = "Active"; _notes = ""
            // Preview the next family number (read-only display, backend generates the real one)
            if (typeof FamilyController !== "undefined") {
                familyNumberPreview.text = FamilyController.nextFamilyNumber() + " (auto)"
            }
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

    // ===== Client-side validation — mirrors FamilyService::createFamily rules =====
    function validate() {
        _errorMessage = ""
        _errorField = ""

        // Rule 1: houseName OR address required
        if (_houseName.trim() === "" && _address.trim() === "") {
            _errorMessage = "Either House Name or Address is required."
            _errorField = "houseName"
            return false
        }
        // Rule 2: at least one phone required
        if (_phone.trim() === "" && _altPhone.trim() === "") {
            _errorMessage = "At least one phone number is required."
            _errorField = "phone"
            return false
        }
        // Rule 3: phone format (if provided) — ^(\+?\d{1,3}[-\s]?)?\d{10}$
        if (_phone.trim() !== "" && !/^(\+?\d{1,3}[-\s]?)?\d{10}$/.test(_phone.trim())) {
            _errorMessage = "Phone number format is invalid. Expected 10 digits, optional +country code."
            _errorField = "phone"
            return false
        }
        // Rule 4: pincode 6 digits (if provided)
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
            familyNumber: dialog._familyNumber,  // empty for new → backend auto-generates
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
            // Backend rejected — show error, keep dialog open, preserve user input
            _errorMessage = result.error || "Operation failed."
            _errorField = result.field || ""
        }
    }

    // ===== White card fills the window =====
    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        radius: 12
        clip: true

        ColumnLayout {
            anchors.fill: parent; spacing: 0

            // ===== Header =====
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
                    Text { anchors.centerIn: parent; text: "\u00D7"; font.pixelSize: 18; font.weight: Font.Bold; color: closeMA.containsMouse ? "#12241b" : "#7e968a" }
                    MouseArea { id: closeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: dialog.visible = false }
                }
            }

            // ===== Error banner (visible only when _errorMessage is set) =====
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 20; Layout.rightMargin: 20; Layout.topMargin: 8
                visible: dialog._errorMessage !== ""
                height: errorRow.implicitHeight + 16
                radius: 8
                color: "#fddfe5"
                border.width: 1; border.color: "#e11d48"
                Behavior on height { NumberAnimation { duration: 150 } }

                Row {
                    id: errorRow
                    anchors.fill: parent; anchors.margins: 8; spacing: 8
                    Item {
                        width: 16; height: 16; anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: "!"; color: "#e11d48"; font.pixelSize: 14; font.weight: Font.Bold }
                    }
                    Text {
                        text: dialog._errorMessage
                        font.family: "Poppins"; font.pixelSize: 12; color: "#95102e"
                        wrapMode: Text.Wrap; verticalAlignment: Text.AlignVCenter
                        width: parent.width - 24
                    }
                }
            }

            // ===== Form (scrollable) =====
            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: parent.width - 40; x: 20; spacing: 14

                    // Family Number — auto-generated, read-only display
                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: "FAMILY NUMBER"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Medium; color: "#7e968a" }
                        Rectangle {
                            Layout.fillWidth: true; height: 38; radius: 9; color: "#f2faf4"; border.width: 1; border.color: "#d2e5d8"
                            Text {
                                id: familyNumberPreview
                                anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                text: dialog._familyNumber || "Auto-generated on save"
                                font.family: "Poppins"; font.pixelSize: 13; color: dialog._familyNumber ? "#12241b" : "#7e968a"
                            }
                        }
                    }

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

                    RowLayout {
                        Layout.fillWidth: true; spacing: 12

                        // Ward — populated from backend (Services.wards), with a free-text fallback
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

                    AppTextField {
                        Layout.fillWidth: true; label: "Area"; placeholderText: "e.g. Kondotty"
                        text: dialog._area; readOnly: dialog.readOnly
                        onTextChanged: dialog._area = text
                    }

                    // Address (multiline)
                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: "ADDRESS"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Medium; color: "#7e968a" }
                        TextArea {
                            Layout.fillWidth: true; Layout.preferredHeight: 72
                            text: dialog._address; readOnly: dialog.readOnly
                            font.family: "Poppins"; font.pixelSize: 13; color: "#12241b"
                            placeholderText: "Enter full address..."; placeholderTextColor: "#7e968a"
                            selectByMouse: true; wrapMode: TextArea.Wrap
                            background: Rectangle {
                                radius: 9; color: "#f2faf4"; border.width: 1
                                border.color: dialog._errorField === "houseName"
                                    ? "#e11d48"
                                    : (parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8")
                                Behavior on border.color { ColorAnimation { duration: 120 } }
                            }
                            padding: 10
                            onTextChanged: dialog._address = text
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true; spacing: 12
                        AppTextField {
                            Layout.fillWidth: true; label: "Pincode"; placeholderText: "673601"
                            text: dialog._pincode; readOnly: dialog.readOnly
                            showError: dialog._errorField === "pincode"; errorText: dialog._errorMessage
                            onTextChanged: dialog._pincode = text
                        }
                        AppComboBox {
                            Layout.fillWidth: true; label: "Status"
                            model: ["Active", "Inactive", "Archived"]
                            currentIndex: Math.max(0, ["Active", "Inactive", "Archived"].indexOf(dialog._status))
                            onActivated: function(index) { dialog._status = model[index] }
                        }
                    }

                    // Alternative Phone
                    AppTextField {
                        Layout.fillWidth: true; label: "Alternative Phone"; placeholderText: "Optional second number"
                        text: dialog._altPhone; readOnly: dialog.readOnly
                        onTextChanged: dialog._altPhone = text
                    }

                    // Notes (multiline)
                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: "NOTES"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Medium; color: "#7e968a" }
                        TextArea {
                            Layout.fillWidth: true; Layout.preferredHeight: 60
                            text: dialog._notes; readOnly: dialog.readOnly
                            font.family: "Poppins"; font.pixelSize: 13; color: "#12241b"
                            placeholderText: "Internal notes (optional)..."; placeholderTextColor: "#7e968a"
                            selectByMouse: true; wrapMode: TextArea.Wrap
                            background: Rectangle { radius: 9; color: "#f2faf4"; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                            padding: 10
                            onTextChanged: dialog._notes = text
                        }
                    }

                    Item { Layout.fillWidth: true; Layout.preferredHeight: 8 }
                }
            }

            // ===== Footer =====
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
                        onClicked: dialog.submit()
                    }
                }
            }
        }
    }
}
