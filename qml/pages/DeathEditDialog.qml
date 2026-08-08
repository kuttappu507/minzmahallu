import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import "../components"

// ============================================================================
// DeathEditDialog — Add/Edit/View death record
// ============================================================================

ModalDialog {
    id: dialog
    modalWidth: 640; modalHeight: 600
    closeOnBackdrop: false; closeOnEscape: true

    property int deathId: 0
    property bool readOnly: false
    signal saved()
    property string _dialogTitle: "Add Death Record"

    property string _deathNumber: ""
    property string _deceasedName: ""
    property string _fatherName: ""
    property string _familyId: ""
    property string _gender: "Male"
    property string _dateOfDeath: ""
    property string _burialDate: ""
    property string _causeOfDeath: ""
    property string _burialPlace: ""
    property string _age: ""
    property string _remarks: ""

    property string _errorMessage: ""
    property string _errorField: ""
    property var _families: []

    function show() {
        _errorMessage = ""; _errorField = ""
        _families = DeathController.activeFamilies()

        if (deathId > 0) {
            var d = DeathController.get(deathId)
            if (d && d.id !== undefined) {
                _deathNumber = d.deathNumber || ""
                _deceasedName = d.deceasedName || ""
                _fatherName = d.fatherName || ""
                _familyId = d.familyId ? d.familyId.toString() : ""
                _gender = d.gender || "Male"
                _dateOfDeath = d.dateOfDeath || ""
                _burialDate = d.burialDate || ""
                _causeOfDeath = d.causeOfDeath || ""
                _burialPlace = d.burialPlace || ""
                _age = d.age ? d.age.toString() : ""
                _remarks = d.remarks || ""
                _dialogTitle = readOnly ? "View Death Record" : "Edit Death Record"
            } else { _errorMessage = "Could not load record"; _dialogTitle = "Edit Death Record" }
        } else {
            _deathNumber = ""; _deceasedName = ""; _fatherName = ""; _familyId = ""
            _gender = "Male"; _dateOfDeath = ""; _burialDate = ""; _causeOfDeath = ""
            _burialPlace = ""; _age = ""; _remarks = ""
            _dialogTitle = "Add Death Record"
        }
        visible = true
    }

    function validate() {
        _errorMessage = ""; _errorField = ""
        if (_deceasedName.trim() === "") { _errorMessage = "Deceased name is required."; _errorField = "deceasedName"; return false }
        if (_dateOfDeath.trim() === "") { _errorMessage = "Date of death is required."; _errorField = "dateOfDeath"; return false }
        return true
    }

    function submit() {
        if (readOnly) { dialog.visible = false; return }
        if (!validate()) return
        var data = {
            deathNumber: _deathNumber,
            deceasedName: _deceasedName,
            fatherName: _fatherName,
            familyId: parseInt(_familyId) || 0,
            gender: _gender,
            dateOfDeath: _dateOfDeath,
            burialDate: _burialDate,
            causeOfDeath: _causeOfDeath,
            burialPlace: _burialPlace,
            age: parseInt(_age) || 0,
            remarks: _remarks
        }
        var result = deathId > 0 ? DeathController.update(deathId, data) : DeathController.create(data)
        if (result.success) { _errorMessage = ""; _errorField = ""; dialog.saved(); dialog.visible = false }
        else { _errorMessage = result.error || "Operation failed."; _errorField = result.field || "" }
    }

    content: Component {
        Rectangle {
            anchors.fill: parent; color: Theme.surface; radius: 12; clip: true
            ColumnLayout {
                anchors.fill: parent; spacing: 0

                Item {
                    Layout.fillWidth: true; Layout.preferredHeight: 56
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                    Text { text: dialog._dialogTitle; font.family: Theme.activeFontFamily; font.pixelSize: 16; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 24; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; width: 28; height: 28; radius: 6; color: closeMA.containsMouse ? "#f2faf4" : "transparent"; Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "\u00D7"; font.pixelSize: 18; font.weight: Font.Bold; color: closeMA.containsMouse ? "#12241b" : "#7e968a" }
                        MouseArea { id: closeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: dialog.visible = false } }
                }

                Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 8; visible: dialog._errorMessage !== ""; height: 36; radius: 8; color: Theme.coralSubtle; border.width: 1; border.color: Theme.danger
                    Text { anchors.fill: parent; anchors.margins: 8; text: dialog._errorMessage; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: "#95102e"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight } }

                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ColumnLayout {
                        width: parent.width - 48; x: 24; spacing: 14

                        // Death Number (read-only)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "DEATH NUMBER"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: dialog._deathNumber || "Auto-generated on save"; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: dialog._deathNumber ? "#12241b" : "#7e968a" } } }

                        // Deceased Name | Father's Name
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Deceased Name *"; placeholderText: "Full name"; text: dialog._deceasedName; readOnly: dialog.readOnly; showError: dialog._errorField === "deceasedName"; errorText: dialog._errorMessage; onTextChanged: dialog._deceasedName = text }
                            AppTextField { Layout.fillWidth: true; label: "Father's Name"; placeholderText: "Father's name"; text: dialog._fatherName; readOnly: dialog.readOnly; onTextChanged: dialog._fatherName = text } }

                        // Family | Gender
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            ColumnLayout { Layout.fillWidth: true; spacing: 4
                                Text { text: "Family (optional)"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                                Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: familyMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } }
                                    MouseArea { id: familyMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: familyPopup.visible = !familyPopup.visible }
                                    Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                        text: { if (dialog._familyId === "") return "(none)"; for (var i = 0; i < dialog._families.length; i++) { if (dialog._families[i].id === parseInt(dialog._familyId)) return dialog._families[i].familyNumber + " - " + dialog._families[i].houseName } return "(none)" }
                                        font.family: Theme.activeFontFamily; font.pixelSize: 13; color: dialog._familyId !== "" ? "#12241b" : "#7e968a" }
                                    Popup { id: familyPopup; y: parent.height + 4; width: parent.width; implicitHeight: 280; padding: 4; background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                        ListView { anchors.fill: parent; clip: true; spacing: 2; model: dialog._families
                                            delegate: ItemDelegate { width: parent.width; height: 34; padding: 0
                                                contentItem: Text { text: modelData.familyNumber + " - " + modelData.houseName; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                                background: Rectangle { color: highlighted ? "#ecfdf5" : "transparent"; radius: 4 }
                                                onClicked: { dialog._familyId = modelData.id.toString(); familyPopup.visible = false } } } } } }
                            AppComboBox { Layout.fillWidth: true; label: "Gender"; model: ["Male", "Female", "Other"]; currentIndex: Math.max(0, ["Male", "Female", "Other"].indexOf(dialog._gender)); onActivated: function(index) { dialog._gender = model[index] } } }

                        // Date of Death | Burial Date
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Date of Death *"; placeholderText: "YYYY-MM-DD"; text: dialog._dateOfDeath; readOnly: dialog.readOnly; showError: dialog._errorField === "dateOfDeath"; errorText: dialog._errorMessage; onTextChanged: dialog._dateOfDeath = text }
                            AppTextField { Layout.fillWidth: true; label: "Burial Date"; placeholderText: "YYYY-MM-DD"; text: dialog._burialDate; readOnly: dialog.readOnly; onTextChanged: dialog._burialDate = text } }

                        // Age | Cause of Death
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Age"; placeholderText: "e.g. 72"; text: dialog._age; readOnly: dialog.readOnly; onTextChanged: dialog._age = text }
                            AppTextField { Layout.fillWidth: true; label: "Cause of Death"; placeholderText: "e.g. Old age"; text: dialog._causeOfDeath; readOnly: dialog.readOnly; onTextChanged: dialog._causeOfDeath = text } }

                        // Burial Place
                        AppTextField { Layout.fillWidth: true; label: "Burial Place"; placeholderText: "e.g. Paravur Kabarsthan"; text: dialog._burialPlace; readOnly: dialog.readOnly; onTextChanged: dialog._burialPlace = text }

                        // Remarks
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "REMARKS"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 56; text: dialog._remarks; readOnly: dialog.readOnly; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary; placeholderText: "Internal remarks..."; placeholderTextColor: "#7e968a"; selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                                padding: 10; onTextChanged: dialog._remarks = text } }

                        Item { Layout.fillWidth: true; Layout.preferredHeight: 4 }
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 64; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                    Row { anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                        AppButton { text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_cancel") } variant: "secondary"; onClicked: dialog.visible = false }
                        AppButton { text: dialog.readOnly ? "Close" : (dialog.deathId > 0 ? "Save Changes" : "Add Record"); variant: "primary"; iconName: dialog.readOnly ? "" : "check"; onClicked: dialog.submit() } } }
            }
        }
    }
}
