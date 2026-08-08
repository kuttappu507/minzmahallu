import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import "../components"

// ============================================================================
// MemberEditDialog — Add/Edit/View member form (2-column, responsive)
//
// PRODUCTION-READY: calls MemberController.create/update.
// Closes ONLY on success. Shows error banner on failure.
// Pattern follows FamilyEditDialog (reference implementation).
// ============================================================================

ModalDialog {
    id: dialog
    modalWidth: 680
    modalHeight: 620
    closeOnBackdrop: false
    closeOnEscape: true

    property int memberId: 0
    property bool readOnly: false
    signal saved()

    property string _dialogTitle: "Add Member"

    // ===== Form data =====
    property string _memberCode: ""
    property string _name: ""
    property string _familyId: ""
    property string _gender: "Male"
    property string _dateOfBirth: ""
    property string _bloodGroup: ""
    property string _occupation: ""
    property string _education: ""
    property string _maritalStatus: "Single"
    property string _mobile: ""
    property string _email: ""
    property string _nationality: "Indian"
    property string _emergencyContact: ""
    property string _relationship: "Head"
    property string _status: "Active"
    property string _address: ""

    property string _errorMessage: ""
    property string _errorField: ""

    function show() {
        _errorMessage = ""
        _errorField = ""

        if (memberId > 0 && typeof MemberController !== "undefined") {
            var m = MemberController.get(memberId)
            if (m && m.id !== undefined) {
                _memberCode = m.memberCode || ""
                _name = m.name || ""
                _familyId = m.familyId ? m.familyId.toString() : ""
                _gender = m.gender || "Male"
                _dateOfBirth = m.dateOfBirth || ""
                _bloodGroup = m.bloodGroup || ""
                _occupation = m.occupation || ""
                _education = m.education || ""
                _maritalStatus = m.maritalStatus || "Single"
                _mobile = m.mobile || ""
                _email = m.email || ""
                _nationality = m.nationality || "Indian"
                _emergencyContact = m.emergencyContact || ""
                _relationship = m.relationship || "Head"
                _status = m.status || "Active"
                _address = m.address || ""
                _dialogTitle = readOnly ? "View Member" : "Edit Member"
            } else {
                _errorMessage = "Could not load member (id: " + memberId + ")"
                _dialogTitle = "Edit Member"
            }
        } else {
            _memberCode = ""; _name = ""; _familyId = ""; _gender = "Male"
            _dateOfBirth = ""; _bloodGroup = ""; _occupation = ""; _education = ""
            _maritalStatus = "Single"; _mobile = ""; _email = ""; _nationality = "Indian"
            _emergencyContact = ""; _relationship = "Head"; _status = "Active"; _address = ""
            _dialogTitle = "Add Member"
        }
        visible = true
    }

    function validate() {
        _errorMessage = ""
        _errorField = ""

        if (_name.trim() === "") {
            _errorMessage = "Member name is required."
            _errorField = "name"
            return false
        }
        if (_familyId === "" || parseInt(_familyId) <= 0) {
            _errorMessage = "Family must be selected."
            _errorField = "familyId"
            return false
        }
        if (_mobile.trim() !== "" && !/^(\+?\d{1,3}[-\s]?)?\d{10}$/.test(_mobile.trim())) {
            _errorMessage = "Mobile number format is invalid. Expected 10 digits."
            _errorField = "mobile"
            return false
        }
        if (_email.trim() !== "" && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(_email.trim())) {
            _errorMessage = "Email format is invalid."
            _errorField = "email"
            return false
        }
        return true
    }

    function submit() {
        if (readOnly) { dialog.visible = false; return }
        if (!validate()) return

        var data = {
            memberCode: dialog._memberCode,
            name: dialog._name,
            familyId: parseInt(dialog._familyId) || 0,
            gender: dialog._gender,
            dateOfBirth: dialog._dateOfBirth,
            bloodGroup: dialog._bloodGroup,
            occupation: dialog._occupation,
            education: dialog._education,
            maritalStatus: dialog._maritalStatus,
            mobile: dialog._mobile,
            email: dialog._email,
            nationality: dialog._nationality,
            emergencyContact: dialog._emergencyContact,
            relationship: dialog._relationship,
            status: dialog._status,
            address: dialog._address
        }

        var result
        if (dialog.memberId > 0) {
            result = MemberController.update(dialog.memberId, data)
        } else {
            result = MemberController.create(data)
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

    // ===== Family combo data (loaded once) =====
    property var _families: []
    Component.onCompleted: {
        if (typeof MemberController !== "undefined") {
            _families = MemberController.activeFamilies()
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

                // Header
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

                // Error banner
                Rectangle {
                    Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 8
                    visible: dialog._errorMessage !== ""
                    height: 36; radius: 8; color: Theme.coralSubtle; border.width: 1; border.color: Theme.danger
                    Text {
                        anchors.fill: parent; anchors.margins: 8
                        text: dialog._errorMessage
                        font.family: Theme.activeFontFamily; font.pixelSize: 12; color: "#95102e"
                        verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
                    }
                }

                // Form (scrollable)
                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: parent.width - 48; x: 24; spacing: 14

                        // Member Code (read-only)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "MEMBER CODE"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            Rectangle {
                                Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border
                                Text {
                                    anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                    text: dialog._memberCode || "Auto-generated on save"
                                    font.family: Theme.activeFontFamily; font.pixelSize: 13; color: dialog._memberCode ? "#12241b" : "#7e968a"
                                }
                            }
                        }

                        // Row 1: Name | Family
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16

                            AppTextField {
                                Layout.fillWidth: true; label: "Name *"; placeholderText: "Full name"
                                text: dialog._name; readOnly: dialog.readOnly
                                showError: dialog._errorField === "name"; errorText: dialog._errorMessage
                                onTextChanged: dialog._name = text
                            }

                            // Family combo (custom — needs id+label)
                            ColumnLayout { Layout.fillWidth: true; spacing: 4
                                Text { text: "Family *"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: dialog._errorField === "familyId" ? "#e11d48" : "#7e968a" }
                                Rectangle {
                                    Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1
                                    border.color: dialog._errorField === "familyId" ? "#e11d48" : (familyMA.containsMouse ? "#b2cfbd" : "#d2e5d8")
                                    Behavior on border.color { ColorAnimation { duration: 120 } }
                                    MouseArea { id: familyMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: familyPopup.visible = !familyPopup.visible }
                                    Text {
                                        anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                        text: {
                                            if (dialog._familyId === "") return "Select family..."
                                            for (var i = 0; i < dialog._families.length; i++) {
                                                if (dialog._families[i].id === parseInt(dialog._familyId))
                                                    return dialog._families[i].familyNumber + " - " + dialog._families[i].houseName
                                            }
                                            return "Select family..."
                                        }
                                        font.family: Theme.activeFontFamily; font.pixelSize: 13
                                        color: dialog._familyId !== "" ? "#12241b" : "#7e968a"
                                    }
                                    // Family popup
                                    Popup {
                                        id: familyPopup
                                        y: parent.height + 4; width: parent.width; implicitHeight: 280; padding: 4
                                        background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                        ListView {
                                            anchors.fill: parent; clip: true; spacing: 2
                                            model: dialog._families
                                            delegate: ItemDelegate {
                                                width: parent.width; height: 34; padding: 0
                                                contentItem: Text {
                                                    text: modelData.familyNumber + " - " + modelData.houseName + (modelData.ward ? " (Ward " + modelData.ward + ")" : "")
                                                    font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary
                                                    anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
                                                }
                                                background: Rectangle { color: highlighted ? "#ecfdf5" : "transparent"; radius: 4 }
                                                onClicked: { dialog._familyId = modelData.id.toString(); familyPopup.visible = false }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Row 2: Gender | Date of Birth
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            AppComboBox {
                                Layout.fillWidth: true; label: "Gender *"
                                model: ["Male", "Female", "Other"]
                                currentIndex: Math.max(0, ["Male", "Female", "Other"].indexOf(dialog._gender))
                                onActivated: function(index) { dialog._gender = model[index] }
                            }
                            AppTextField {
                                Layout.fillWidth: true; label: "Date of Birth"; placeholderText: "YYYY-MM-DD"
                                text: dialog._dateOfBirth; readOnly: dialog.readOnly
                                onTextChanged: dialog._dateOfBirth = text
                            }
                        }

                        // Row 3: Blood Group | Occupation
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            AppComboBox {
                                Layout.fillWidth: true; label: "Blood Group"
                                model: ["", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
                                currentIndex: Math.max(0, ["", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"].indexOf(dialog._bloodGroup))
                                onActivated: function(index) { dialog._bloodGroup = model[index] }
                            }
                            AppTextField {
                                Layout.fillWidth: true; label: "Occupation"; placeholderText: "e.g. Engineer"
                                text: dialog._occupation; readOnly: dialog.readOnly
                                onTextChanged: dialog._occupation = text
                            }
                        }

                        // Row 4: Education | Marital Status
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            AppTextField {
                                Layout.fillWidth: true; label: "Education"; placeholderText: "e.g. B.Tech"
                                text: dialog._education; readOnly: dialog.readOnly
                                onTextChanged: dialog._education = text
                            }
                            AppComboBox {
                                Layout.fillWidth: true; label: "Marital Status"
                                model: ["Single", "Married", "Divorced", "Widowed"]
                                currentIndex: Math.max(0, ["Single", "Married", "Divorced", "Widowed"].indexOf(dialog._maritalStatus))
                                onActivated: function(index) { dialog._maritalStatus = model[index] }
                            }
                        }

                        // Row 5: Mobile | Email
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            AppTextField {
                                Layout.fillWidth: true; label: "Mobile"; placeholderText: "9847123456"
                                text: dialog._mobile; readOnly: dialog.readOnly
                                showError: dialog._errorField === "mobile"; errorText: dialog._errorMessage
                                onTextChanged: dialog._mobile = text
                            }
                            AppTextField {
                                Layout.fillWidth: true; label: "Email"; placeholderText: "name@example.com"
                                text: dialog._email; readOnly: dialog.readOnly
                                showError: dialog._errorField === "email"; errorText: dialog._errorMessage
                                onTextChanged: dialog._email = text
                            }
                        }

                        // Row 6: Relationship | Status
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            AppComboBox {
                                Layout.fillWidth: true; label: "Relationship"
                                model: MemberController ? MemberController.relationships() : ["Head","Spouse","Son","Daughter","Parent","Sibling","Other"]
                                currentIndex: Math.max(0, (MemberController ? MemberController.relationships() : ["Head","Spouse","Son","Daughter","Parent","Sibling","Other"]).indexOf(dialog._relationship))
                                onActivated: function(index) { dialog._relationship = model[index] }
                            }
                            AppComboBox {
                                Layout.fillWidth: true; label: "Status"
                                model: ["Active", "Inactive", "Deceased"]
                                currentIndex: Math.max(0, ["Active", "Inactive", "Deceased"].indexOf(dialog._status))
                                onActivated: function(index) { dialog._status = model[index] }
                            }
                        }

                        // Row 7: Nationality | Emergency Contact
                        RowLayout {
                            Layout.fillWidth: true; spacing: 16
                            AppTextField {
                                Layout.fillWidth: true; label: "Nationality"; placeholderText: "Indian"
                                text: dialog._nationality; readOnly: dialog.readOnly
                                onTextChanged: dialog._nationality = text
                            }
                            AppTextField {
                                Layout.fillWidth: true; label: "Emergency Contact"; placeholderText: "9847123456"
                                text: dialog._emergencyContact; readOnly: dialog.readOnly
                                onTextChanged: dialog._emergencyContact = text
                            }
                        }

                        // Address (full width)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "ADDRESS"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea {
                                Layout.fillWidth: true; Layout.preferredHeight: 56
                                text: dialog._address; readOnly: dialog.readOnly
                                font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary
                                placeholderText: "Member address (if different from family)..."; placeholderTextColor: "#7e968a"
                                selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                                padding: 10
                                onTextChanged: dialog._address = text
                            }
                        }

                        Item { Layout.fillWidth: true; Layout.preferredHeight: 4 }
                    }
                }

                // Footer
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 64; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                    Row {
                        anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                        AppButton { text: "Cancel"; variant: "secondary"; onClicked: dialog.visible = false }
                        AppButton {
                            text: dialog.readOnly ? "Close" : (dialog.memberId > 0 ? "Save Changes" : "Add Member")
                            variant: "primary"; iconName: dialog.readOnly ? "" : "check"
                            onClicked: dialog.submit()
                        }
                    }
                }
            }
        }
    }
}
