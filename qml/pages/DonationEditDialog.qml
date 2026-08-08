import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import "../components"

// ============================================================================
// DonationEditDialog — Add/Edit/View donation form
// Calls DonationController.create/update. Closes ONLY on success.
// ============================================================================

ModalDialog {
    id: dialog
    modalWidth: 640; modalHeight: 580
    closeOnBackdrop: false; closeOnEscape: true

    property int donationId: 0
    property bool readOnly: false
    signal saved()
    property string _dialogTitle: "Add Donation"

    property string _receiptNumber: ""
    property string _donorName: ""
    property string _donorPhone: ""
    property string _donorAddress: ""
    property string _categoryId: ""
    property string _amount: ""
    property string _donationDate: ""
    property string _paymentMethod: "Cash"
    property string _purpose: ""
    property string _remarks: ""

    property string _errorMessage: ""
    property string _errorField: ""
    property var _categories: []

    function show() {
        _errorMessage = ""; _errorField = ""
        _categories = DonationController.categories()

        if (donationId > 0) {
            var d = DonationController.get(donationId)
            if (d && d.id !== undefined) {
                _receiptNumber = d.receiptNumber || ""
                _donorName = d.donorName || ""
                _donorPhone = d.donorPhone || ""
                _donorAddress = d.donorAddress || ""
                _categoryId = d.categoryId ? d.categoryId.toString() : ""
                _amount = d.amount ? d.amount.toString() : ""
                _donationDate = d.donationDate || ""
                _paymentMethod = d.paymentMethod || "Cash"
                _purpose = d.purpose || ""
                _remarks = d.remarks || ""
                _dialogTitle = readOnly ? "View Donation" : "Edit Donation"
            } else { _errorMessage = "Could not load donation"; _dialogTitle = "Edit Donation" }
        } else {
            _receiptNumber = ""; _donorName = ""; _donorPhone = ""; _donorAddress = ""
            _categoryId = ""; _amount = ""; _donationDate = ""; _paymentMethod = "Cash"
            _purpose = ""; _remarks = ""
            _dialogTitle = "Add Donation"
        }
        visible = true
    }

    function validate() {
        _errorMessage = ""; _errorField = ""
        if (_donorName.trim() === "") { _errorMessage = "Donor name is required."; _errorField = "donorName"; return false }
        if (_amount === "" || parseFloat(_amount) <= 0) { _errorMessage = "Amount must be greater than zero."; _errorField = "amount"; return false }
        if (_categoryId === "" || parseInt(_categoryId) <= 0) { _errorMessage = "Category is required."; _errorField = "categoryId"; return false }
        return true
    }

    function submit() {
        if (readOnly) { dialog.visible = false; return }
        if (!validate()) return

        var data = {
            donorName: _donorName, donorPhone: _donorPhone, donorAddress: _donorAddress,
            categoryId: parseInt(_categoryId) || 0,
            amount: parseFloat(_amount) || 0,
            donationDate: _donationDate, paymentMethod: _paymentMethod,
            purpose: _purpose, remarks: _remarks
        }

        var result = donationId > 0 ? DonationController.update(donationId, data) : DonationController.create(data)
        if (result.success) {
            _errorMessage = ""; _errorField = ""
            dialog.saved(); dialog.visible = false
        } else {
            _errorMessage = result.error || "Operation failed."
            _errorField = result.field || ""
        }
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

                        // Receipt # (read-only)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "RECEIPT NUMBER"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: dialog._receiptNumber || "Auto-generated on save"; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: dialog._receiptNumber ? "#12241b" : "#7e968a" } } }

                        // Donor Name | Donor Phone
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Donor Name *"; placeholderText: "Full name"; text: dialog._donorName; readOnly: dialog.readOnly; showError: dialog._errorField === "donorName"; errorText: dialog._errorMessage; onTextChanged: dialog._donorName = text }
                            AppTextField { Layout.fillWidth: true; label: "Donor Phone"; placeholderText: "9847123456"; text: dialog._donorPhone; readOnly: dialog.readOnly; onTextChanged: dialog._donorPhone = text } }

                        // Category selector (popup) | Amount
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            ColumnLayout { Layout.fillWidth: true; spacing: 4
                                Text { text: "Category *"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: dialog._errorField === "categoryId" ? "#e11d48" : "#7e968a" }
                                Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: dialog._errorField === "categoryId" ? "#e11d48" : (catMA.containsMouse ? "#b2cfbd" : "#d2e5d8"); Behavior on border.color { ColorAnimation { duration: 120 } }
                                    MouseArea { id: catMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: catPopup.visible = !catPopup.visible }
                                    Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                        text: { if (dialog._categoryId === "") return "Select category..."; for (var i = 0; i < dialog._categories.length; i++) { if (dialog._categories[i].id === parseInt(dialog._categoryId)) return dialog._categories[i].name } return "Select category..." }
                                        font.family: Theme.activeFontFamily; font.pixelSize: 13; color: dialog._categoryId !== "" ? "#12241b" : "#7e968a" }
                                    Popup { id: catPopup; y: parent.height + 4; width: parent.width; implicitHeight: 280; padding: 4; background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                        ListView { anchors.fill: parent; clip: true; spacing: 2; model: dialog._categories
                                            delegate: ItemDelegate { width: parent.width; height: 34; padding: 0
                                                contentItem: Text { text: modelData.name; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                                background: Rectangle { color: highlighted ? "#ecfdf5" : "transparent"; radius: 4 }
                                                onClicked: { dialog._categoryId = modelData.id.toString(); catPopup.visible = false } } } } } }
                            AppTextField { Layout.fillWidth: true; label: "Amount *"; placeholderText: "0.00"; text: dialog._amount; readOnly: dialog.readOnly; showError: dialog._errorField === "amount"; errorText: dialog._errorMessage; onTextChanged: dialog._amount = text } }

                        // Donation Date | Payment Method
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: "Donation Date"; placeholderText: "YYYY-MM-DD"; text: dialog._donationDate; readOnly: dialog.readOnly; onTextChanged: dialog._donationDate = text }
                            AppComboBox { Layout.fillWidth: true; label: "Payment Method"; model: ["Cash", "Cheque", "UPI", "Bank Transfer", "Card", "Other"]; currentIndex: Math.max(0, ["Cash", "Cheque", "UPI", "Bank Transfer", "Card", "Other"].indexOf(dialog._paymentMethod)); onActivated: function(index) { dialog._paymentMethod = model[index] } } }

                        // Donor Address (full width)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "DONOR ADDRESS"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 56; text: dialog._donorAddress; readOnly: dialog.readOnly; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary; placeholderText: "Donor address (optional)..."; placeholderTextColor: "#7e968a"; selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                                padding: 10; onTextChanged: dialog._donorAddress = text } }

                        // Purpose
                        AppTextField { Layout.fillWidth: true; label: "Purpose"; placeholderText: "e.g. Ramadan contribution"; text: dialog._purpose; readOnly: dialog.readOnly; onTextChanged: dialog._purpose = text }

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
                        AppButton { text: dialog.readOnly ? "Close" : (dialog.donationId > 0 ? "Save Changes" : "Add Donation"); variant: "primary"; iconName: dialog.readOnly ? "" : "check"; onClicked: dialog.submit() } } }
            }
        }
    }
}
