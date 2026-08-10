import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import "../components"

// ============================================================================
// MarriageEditDialog — Add/Edit/View marriage record
// 16 fields: bride/groom names, fathers, addresses, 4 witnesses, mahar,
// nikah date, registration date, imam, place, remarks
// ============================================================================

ModalDialog {
    id: dialog
    modalWidth: 680; modalHeight: 640
    closeOnBackdrop: false; closeOnEscape: true

    property int marriageId: 0
    property bool readOnly: false
    signal saved()
    property string _dialogTitle: "Add Marriage Record"

    property string _marriageNumber: ""
    property string _brideName: ""
    property string _brideFather: ""
    property string _brideAddress: ""
    property string _groomName: ""
    property string _groomFather: ""
    property string _groomAddress: ""
    property string _witness1: ""
    property string _witness2: ""
    property string _witness3: ""
    property string _witness4: ""
    property string _mahar: ""
    property string _nikahDate: ""
    property string _registrationDate: ""
    property string _place: ""
    property string _remarks: ""

    property string _errorMessage: ""
    property string _errorField: ""

    function show() {
        _errorMessage = ""; _errorField = ""
        if (marriageId > 0) {
            var m = MarriageController.get(marriageId)
            if (m && m.id !== undefined) {
                _marriageNumber = m.marriageNumber || ""
                _brideName = m.brideName || ""; _brideFather = m.brideFather || ""; _brideAddress = m.brideAddress || ""
                _groomName = m.groomName || ""; _groomFather = m.groomFather || ""; _groomAddress = m.groomAddress || ""
                _witness1 = m.witness1 || ""; _witness2 = m.witness2 || ""; _witness3 = m.witness3 || ""; _witness4 = m.witness4 || ""
                _mahar = m.mahar || ""; _nikahDate = m.nikahDate || ""; _registrationDate = m.registrationDate || ""
                _place = m.place || ""; _remarks = m.remarks || ""
                _dialogTitle = readOnly ? "View Marriage Record" : "Edit Marriage Record"
            } else { _errorMessage = "Could not load record"; _dialogTitle = "Edit Marriage Record" }
        } else {
            _marriageNumber = ""; _brideName = ""; _brideFather = ""; _brideAddress = ""
            _groomName = ""; _groomFather = ""; _groomAddress = ""
            _witness1 = ""; _witness2 = ""; _witness3 = ""; _witness4 = ""
            _mahar = ""; _nikahDate = ""; _registrationDate = ""; _place = ""; _remarks = ""
            _dialogTitle = "Add Marriage Record"
        }
        visible = true
    }

    function validate() {
        _errorMessage = ""; _errorField = ""
        if (_brideName.trim() === "") { _errorMessage = "Bride name is required."; _errorField = "brideName"; return false }
        if (_groomName.trim() === "") { _errorMessage = "Groom name is required."; _errorField = "groomName"; return false }
        if (_nikahDate.trim() === "") { _errorMessage = "Nikah date is required."; _errorField = "nikahDate"; return false }
        return true
    }

    function submit() {
        if (readOnly) { dialog.visible = false; return }
        if (!validate()) return
        var data = {
            marriageNumber: _marriageNumber,
            brideName: _brideName, brideFather: _brideFather, brideAddress: _brideAddress,
            groomName: _groomName, groomFather: _groomFather, groomAddress: _groomAddress,
            witness1: _witness1, witness2: _witness2, witness3: _witness3, witness4: _witness4,
            mahar: _mahar, nikahDate: _nikahDate, registrationDate: _registrationDate,
            place: _place, remarks: _remarks
        }
        var result = marriageId > 0 ? MarriageController.update(marriageId, data) : MarriageController.create(data)
        if (result.success) { _errorMessage = ""; _errorField = ""; dialog.saved(); dialog.visible = false }
        else { _errorMessage = result.error || "Operation failed."; _errorField = result.field || "" }
    }

    content: Component {
        Rectangle {
            anchors.fill: parent; color: Theme.surface; radius: 12; clip: true
            ColumnLayout {
                anchors.fill: parent; spacing: 0

                // Header
                Item {
                    Layout.fillWidth: true; Layout.preferredHeight: 56
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                    Text { text: dialog._dialogTitle; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeLg; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 24; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; width: 28; height: 28; radius: 6; color: closeMA.containsMouse ? Theme.surfaceHover : "transparent"; Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "\u00D7"; font.pixelSize: Theme.fontSizeXl; font.weight: Font.Bold; color: closeMA.containsMouse ? "#12241b" : "#7e968a" }
                        MouseArea { id: closeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: dialog.visible = false } }
                }

                // Error banner
                Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 8; visible: dialog._errorMessage !== ""; height: 36; radius: 8; color: Theme.coralSubtle; border.width: 1; border.color: Theme.danger
                    Text { anchors.fill: parent; anchors.margins: 8; text: dialog._errorMessage; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: "#95102e"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight } }

                // Form (scrollable)
                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ColumnLayout {
                        width: parent.width - 48; x: 24; spacing: 14

                        // Marriage Number (read-only)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("mrg_number") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                            Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: dialog._marriageNumber || "Auto-generated on save"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: dialog._marriageNumber ? "#12241b" : "#7e968a" } } }

                        // Bride section
                        Text { text: "BRIDE DETAILS"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.DemiBold; color: "#db2777" }
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Bride Name *"; placeholderText: "Full name"; text: dialog._brideName; readOnly: dialog.readOnly; showError: dialog._errorField === "brideName"; errorText: dialog._errorMessage; onTextChanged: dialog._brideName = text }
                            AppTextField { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("dth_father") } placeholderText: "Father's name"; text: dialog._brideFather; readOnly: dialog.readOnly; onTextChanged: dialog._brideFather = text } }
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "ADDRESS"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 56; text: dialog._brideAddress; readOnly: dialog.readOnly; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; placeholderText: "Bride's address..."; placeholderTextColor: "#7e968a"; selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                                padding: 10; onTextChanged: dialog._brideAddress = text } }

                        // Groom section
                        Text { text: "GROOM DETAILS"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.DemiBold; color: Theme.blue }
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Groom Name *"; placeholderText: "Full name"; text: dialog._groomName; readOnly: dialog.readOnly; showError: dialog._errorField === "groomName"; errorText: dialog._errorMessage; onTextChanged: dialog._groomName = text }
                            AppTextField { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("dth_father") } placeholderText: "Father's name"; text: dialog._groomFather; readOnly: dialog.readOnly; onTextChanged: dialog._groomFather = text } }
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "ADDRESS"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 56; text: dialog._groomAddress; readOnly: dialog.readOnly; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; placeholderText: "Groom's address..."; placeholderTextColor: "#7e968a"; selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                                padding: 10; onTextChanged: dialog._groomAddress = text } }

                        // Witnesses
                        Text { text: "WITNESSES"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.DemiBold; color: Theme.textTertiary }
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Witness 1"; placeholderText: "Name"; text: dialog._witness1; readOnly: dialog.readOnly; onTextChanged: dialog._witness1 = text }
                            AppTextField { Layout.fillWidth: true; label: "Witness 2"; placeholderText: "Name"; text: dialog._witness2; readOnly: dialog.readOnly; onTextChanged: dialog._witness2 = text } }
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Witness 3"; placeholderText: "Name"; text: dialog._witness3; readOnly: dialog.readOnly; onTextChanged: dialog._witness3 = text }
                            AppTextField { Layout.fillWidth: true; label: "Witness 4"; placeholderText: "Name"; text: dialog._witness4; readOnly: dialog.readOnly; onTextChanged: dialog._witness4 = text } }

                        // Mahar | Nikah Date
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Mahar"; placeholderText: "e.g. 10000"; text: dialog._mahar; readOnly: dialog.readOnly; onTextChanged: dialog._mahar = text }
                            AppTextField { Layout.fillWidth: true; label: "Nikah Date *"; placeholderText: "YYYY-MM-DD"; text: dialog._nikahDate; readOnly: dialog.readOnly; showError: dialog._errorField === "nikahDate"; errorText: dialog._errorMessage; onTextChanged: dialog._nikahDate = text } }

                        // Registration Date | Place
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Registration Date"; placeholderText: "YYYY-MM-DD (auto)"; text: dialog._registrationDate; readOnly: dialog.readOnly; onTextChanged: dialog._registrationDate = text }
                            AppTextField { Layout.fillWidth: true; label: "Place"; placeholderText: "Nikah place"; text: dialog._place; readOnly: dialog.readOnly; onTextChanged: dialog._place = text } }

                        // Remarks
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "REMARKS"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 56; text: dialog._remarks; readOnly: dialog.readOnly; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; placeholderText: "Internal remarks..."; placeholderTextColor: "#7e968a"; selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                                padding: 10; onTextChanged: dialog._remarks = text } }

                        Item { Layout.fillWidth: true; Layout.preferredHeight: 4 }
                    }
                }

                // Footer
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 64; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                    Row { anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                        AppButton { text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_cancel") } variant: "secondary"; onClicked: dialog.visible = false }
                        AppButton { text: dialog.readOnly ? "Close" : (dialog.marriageId > 0 ? "Save Changes" : "Add Record"); variant: "primary"; iconName: dialog.readOnly ? "" : "check"; onClicked: dialog.submit() } } }
            }
        }
    }
}
