import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import "../components"

// ============================================================================
// TransactionEditDialog — Add/Edit/View accounting transaction form
// Calls AccountingController.create/update. Closes ONLY on success.
// ============================================================================

ModalDialog {
    id: dialog
    modalWidth: 560; modalHeight: 480
    closeOnBackdrop: false; closeOnEscape: true

    property int transactionId: 0
    property bool readOnly: false
    signal saved()
    property string _dialogTitle: "Add Transaction"

    property string _txnDate: ""
    property string _accountId: ""
    property string _amount: ""
    property string _paymentMethod: "Cash"
    property string _reference: ""
    property string _description: ""

    property string _errorMessage: ""
    property string _errorField: ""
    property var _accounts: []

    function show() {
        _errorMessage = ""; _errorField = ""
        _accounts = AccountingController.accounts("")

        if (transactionId > 0) {
            var t = AccountingController.get(transactionId)
            if (t && t.id !== undefined) {
                _txnDate = t.txnDate || ""
                _accountId = t.accountId ? t.accountId.toString() : ""
                _amount = t.amount ? t.amount.toString() : ""
                _paymentMethod = t.paymentMethod || "Cash"
                _reference = t.reference || ""
                _description = t.description || ""
                _dialogTitle = readOnly ? "View Transaction" : "Edit Transaction"
            } else { _errorMessage = "Could not load transaction"; _dialogTitle = "Edit Transaction" }
        } else {
            _txnDate = ""; _accountId = ""; _amount = ""; _paymentMethod = "Cash"
            _reference = ""; _description = ""
            _dialogTitle = "Add Transaction"
        }
        visible = true
    }

    function validate() {
        _errorMessage = ""; _errorField = ""
        if (_accountId === "" || parseInt(_accountId) <= 0) { _errorMessage = "Account is required."; _errorField = "accountId"; return false }
        if (_amount === "" || parseFloat(_amount) <= 0) { _errorMessage = "Amount must be greater than zero."; _errorField = "amount"; return false }
        return true
    }

    function submit() {
        if (readOnly) { dialog.visible = false; return }
        if (!validate()) return

        // Find account type to derive transaction type
        var accType = "Income"
        for (var i = 0; i < _accounts.length; i++) {
            if (_accounts[i].id === parseInt(_accountId)) { accType = _accounts[i].type; break }
        }

        var data = {
            txnDate: _txnDate,
            accountId: parseInt(_accountId) || 0,
            type: accType === "Expense" ? "Expense" : "Income",
            amount: parseFloat(_amount) || 0,
            paymentMethod: _paymentMethod,
            reference: _reference,
            description: _description
        }

        var result = transactionId > 0 ? AccountingController.update(transactionId, data) : AccountingController.create(data)
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
                    Text { text: dialog._dialogTitle; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeLg; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 24; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; width: 28; height: 28; radius: 6; color: closeMA.containsMouse ? "#f2faf4" : "transparent"; Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "\u00D7"; font.pixelSize: Theme.fontSizeXl; font.weight: Font.Bold; color: closeMA.containsMouse ? "#12241b" : "#7e968a" }
                        MouseArea { id: closeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: dialog.visible = false } }
                }

                Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 8; visible: dialog._errorMessage !== ""; height: 36; radius: 8; color: Theme.coralSubtle; border.width: 1; border.color: Theme.danger
                    Text { anchors.fill: parent; anchors.margins: 8; text: dialog._errorMessage; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: "#95102e"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight } }

                ColumnLayout {
                    Layout.fillWidth: true; Layout.fillHeight: true; Layout.margins: 24; spacing: 14

                    // Account selector (popup)
                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: "Account *"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: dialog._errorField === "accountId" ? "#e11d48" : "#7e968a" }
                        Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: dialog._errorField === "accountId" ? "#e11d48" : (accMA.containsMouse ? "#b2cfbd" : "#d2e5d8"); Behavior on border.color { ColorAnimation { duration: 120 } }
                            MouseArea { id: accMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: accPopup.visible = !accPopup.visible }
                            Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                text: { if (dialog._accountId === "") return "Select account..."; for (var i = 0; i < dialog._accounts.length; i++) { if (dialog._accounts[i].id === parseInt(dialog._accountId)) return dialog._accounts[i].code + " - " + dialog._accounts[i].name + " (" + dialog._accounts[i].type + ")" } return "Select account..." }
                                font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: dialog._accountId !== "" ? "#12241b" : "#7e968a" }
                            Popup { id: accPopup; y: parent.height + 4; width: parent.width; implicitHeight: 280; padding: 4; background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                ListView { anchors.fill: parent; clip: true; spacing: 2; model: dialog._accounts
                                    delegate: ItemDelegate { width: parent.width; height: 34; padding: 0
                                        contentItem: Text { text: modelData.code + " - " + modelData.name + " (" + modelData.type + ")"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                        background: Rectangle { color: highlighted ? "#ecfdf5" : "transparent"; radius: 4 }
                                        onClicked: { dialog._accountId = modelData.id.toString(); accPopup.visible = false } } } } } }

                    // Amount | Date
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        AppTextField { Layout.fillWidth: true; label: "Amount *"; placeholderText: "0.00"; text: dialog._amount; readOnly: dialog.readOnly; showError: dialog._errorField === "amount"; errorText: dialog._errorMessage; onTextChanged: dialog._amount = text }
                        AppTextField { Layout.fillWidth: true; label: "Date"; placeholderText: "YYYY-MM-DD"; text: dialog._txnDate; readOnly: dialog.readOnly; onTextChanged: dialog._txnDate = text } }

                    // Payment Method | Reference
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        AppComboBox { Layout.fillWidth: true; label: "Payment Method"; model: ["Cash", "Cheque", "UPI", "Bank Transfer", "Card", "Other"]; currentIndex: Math.max(0, ["Cash", "Cheque", "UPI", "Bank Transfer", "Card", "Other"].indexOf(dialog._paymentMethod)); onActivated: function(index) { dialog._paymentMethod = model[index] } }
                        AppTextField { Layout.fillWidth: true; label: "Reference"; placeholderText: "Optional"; text: dialog._reference; readOnly: dialog.readOnly; onTextChanged: dialog._reference = text } }

                    // Description
                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("acc_description") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        TextArea { Layout.fillWidth: true; Layout.preferredHeight: 56; text: dialog._description; readOnly: dialog.readOnly; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; placeholderText: "Transaction description..."; placeholderTextColor: "#7e968a"; selectByMouse: true; wrapMode: TextArea.Wrap
                            background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                            padding: 10; onTextChanged: dialog._description = text } }

                    Item { Layout.fillWidth: true; Layout.fillHeight: true }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 64; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                    Row { anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                        AppButton { text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_cancel") } variant: "secondary"; onClicked: dialog.visible = false }
                        AppButton { text: dialog.readOnly ? "Close" : (dialog.transactionId > 0 ? "Save Changes" : "Add Transaction"); variant: "primary"; iconName: dialog.readOnly ? "" : "check"; onClicked: dialog.submit() } } }
            }
        }
    }
}
