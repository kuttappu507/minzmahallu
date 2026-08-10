import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import "../components"

// ============================================================================
// SubscriptionEditDialog — Add/Edit/View subscription form
// Calls SubscriptionController.create/update. Closes ONLY on success.
// Pattern follows FamilyEditDialog (reference implementation).
// ============================================================================

ModalDialog {
    id: dialog
    modalWidth: 640
    modalHeight: 580
    closeOnBackdrop: false
    closeOnEscape: true

    property int subscriptionId: 0
    property bool readOnly: false
    signal saved()

    property string _dialogTitle: "Add Subscription"

    // Form data
    property string _receiptNumber: ""
    property string _familyId: ""
    property string _memberId: ""
    property string _planId: ""
    property string _amount: ""
    property string _amountPaid: ""
    property string _periodStart: ""
    property string _periodEnd: ""
    property string _paymentDate: ""
    property string _paymentMethod: "Cash"
    property string _transactionRef: ""
    property string _status: "Pending"
    property string _remarks: ""

    property string _errorMessage: ""
    property string _errorField: ""

    property var _families: []
    property var _members: []
    property var _plans: []

    function show() {
        _errorMessage = ""
        _errorField = ""
        _families = SubscriptionController.activeFamilies()
        _plans = SubscriptionController.plans()
        _members = []

        if (subscriptionId > 0) {
            var s = SubscriptionController.get(subscriptionId)
            if (s && s.id !== undefined) {
                _receiptNumber = s.receiptNumber || ""
                _familyId = s.familyId ? s.familyId.toString() : ""
                _memberId = s.memberId ? s.memberId.toString() : ""
                _planId = s.planId ? s.planId.toString() : ""
                _amount = s.amount ? s.amount.toString() : ""
                _amountPaid = s.amountPaid ? s.amountPaid.toString() : "0"
                _periodStart = s.periodStart || ""
                _periodEnd = s.periodEnd || ""
                _paymentDate = s.paymentDate || ""
                _paymentMethod = s.paymentMethod || "Cash"
                _transactionRef = s.transactionRef || ""
                _status = s.status || "Pending"
                _remarks = s.remarks || ""
                if (_familyId !== "") _members = SubscriptionController.familyMembers(parseInt(_familyId))
                _dialogTitle = readOnly ? "View Subscription" : "Edit Subscription"
            } else {
                _errorMessage = "Could not load subscription"
                _dialogTitle = "Edit Subscription"
            }
        } else {
            _receiptNumber = ""; _familyId = ""; _memberId = ""; _planId = ""
            _amount = ""; _amountPaid = "0"; _periodStart = ""; _periodEnd = ""
            _paymentDate = ""; _paymentMethod = "Cash"; _transactionRef = ""
            _status = "Pending"; _remarks = ""
            _dialogTitle = "Add Subscription"
        }
        visible = true
    }

    function validate() {
        _errorMessage = ""
        _errorField = ""
        if (_familyId === "" || parseInt(_familyId) <= 0) { _errorMessage = "Family is required."; _errorField = "familyId"; return false }
        if (_planId === "" || parseInt(_planId) <= 0) { _errorMessage = "Subscription plan is required."; _errorField = "planId"; return false }
        if (_amount === "" || parseFloat(_amount) <= 0) { _errorMessage = "Amount must be greater than zero."; _errorField = "amount"; return false }
        if (_amountPaid !== "" && parseFloat(_amountPaid) > parseFloat(_amount)) { _errorMessage = "Amount paid cannot exceed total amount."; _errorField = "amountPaid"; return false }
        return true
    }

    function submit() {
        if (readOnly) { dialog.visible = false; return }
        if (!validate()) return

        var data = {
            familyId: parseInt(_familyId) || 0,
            memberId: parseInt(_memberId) || 0,
            planId: parseInt(_planId) || 0,
            amount: parseFloat(_amount) || 0,
            amountPaid: parseFloat(_amountPaid) || 0,
            periodStart: _periodStart,
            periodEnd: _periodEnd,
            paymentDate: _paymentDate,
            paymentMethod: _paymentMethod,
            transactionRef: _transactionRef,
            status: _status,
            remarks: _remarks
        }

        var result = subscriptionId > 0 ? SubscriptionController.update(subscriptionId, data) : SubscriptionController.create(data)
        if (result.success) {
            _errorMessage = ""; _errorField = ""
            dialog.saved()
            dialog.visible = false
        } else {
            _errorMessage = result.error || "Operation failed."
            _errorField = result.field || ""
        }
    }

    function onFamilyChanged(fid) {
        _familyId = fid
        _memberId = ""
        if (fid !== "") _members = SubscriptionController.familyMembers(parseInt(fid))
    }

    function onPlanChanged(pid) {
        _planId = pid
        // Auto-fill amount from plan default if amount is empty
        if (_amount === "" && _plans.length > 0) {
            for (var i = 0; i < _plans.length; i++) {
                if (_plans[i].id === parseInt(pid) && _plans[i].defaultAmount > 0) {
                    _amount = _plans[i].defaultAmount.toString()
                    break
                }
            }
        }
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
                        Text { anchors.centerIn: parent; text: "\u00D7"; font.pixelSize: Theme.fontSizeXl; font.weight: Font.Bold; color: closeMA.containsMouse ? Theme.textPrimary : Theme.textTertiary }
                        MouseArea { id: closeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: dialog.visible = false } }
                }

                // Error banner
                Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 8; visible: dialog._errorMessage !== ""; height: 36; radius: 8; color: Theme.coralSubtle; border.width: 1; border.color: Theme.danger
                    Text { anchors.fill: parent; anchors.margins: 8; text: dialog._errorMessage; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: "#95102e"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight } }

                // Form
                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: parent.width - 48; x: 24; spacing: 14

                        // Receipt # (read-only)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_receipt") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                            Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: dialog._receiptNumber || "Auto-generated on save"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: dialog._receiptNumber ? Theme.textPrimary : Theme.textTertiary } } }

                        // Family selector (custom popup)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "Family *"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: dialog._errorField === "familyId" ? Theme.danger : Theme.textTertiary }
                            Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: dialog._errorField === "familyId" ? Theme.danger : (familyMA.containsMouse ? Theme.borderHover : Theme.border); Behavior on border.color { ColorAnimation { duration: 120 } }
                                MouseArea { id: familyMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: familyPopup.visible = !familyPopup.visible }
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                    text: { if (dialog._familyId === "") return "Select family..."; for (var i = 0; i < dialog._families.length; i++) { if (dialog._families[i].id === parseInt(dialog._familyId)) return dialog._families[i].familyNumber + " - " + dialog._families[i].houseName } return "Select family..." }
                                    font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: dialog._familyId !== "" ? Theme.textPrimary : Theme.textTertiary }
                                Popup { id: familyPopup; y: parent.height + 4; width: parent.width; implicitHeight: 280; padding: 4; background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                    ListView { anchors.fill: parent; clip: true; spacing: 2; model: dialog._families
                                        delegate: ItemDelegate { width: parent.width; height: 34; padding: 0
                                            contentItem: Text { text: modelData.familyNumber + " - " + modelData.houseName; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                            background: Rectangle { color: highlighted ? Theme.primarySubtle : "transparent"; radius: 4 }
                                            onClicked: { dialog.onFamilyChanged(modelData.id.toString()); familyPopup.visible = false } } } } } }

                        // Member selector (depends on family)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4; enabled: dialog._familyId !== ""
                            Text { text: "Member (optional)"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                            Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: memberMA.containsMouse ? Theme.borderHover : Theme.border; Behavior on border.color { ColorAnimation { duration: 120 } } opacity: enabled ? 1 : 0.5
                                MouseArea { id: memberMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: memberPopup.visible = !memberPopup.visible }
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                    text: { if (dialog._memberId === "") return "(any member)"; for (var i = 0; i < dialog._members.length; i++) { if (dialog._members[i].id === parseInt(dialog._memberId)) return dialog._members[i].name + " (" + dialog._members[i].relationship + ")" } return "(any member)" }
                                    font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: dialog._memberId !== "" ? Theme.textPrimary : Theme.textTertiary }
                                Popup { id: memberPopup; y: parent.height + 4; width: parent.width; implicitHeight: 280; padding: 4; background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                    ListView { anchors.fill: parent; clip: true; spacing: 2; model: dialog._members
                                        delegate: ItemDelegate { width: parent.width; height: 34; padding: 0
                                            contentItem: Text { text: modelData.name + " (" + modelData.relationship + ")"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                            background: Rectangle { color: highlighted ? Theme.primarySubtle : "transparent"; radius: 4 }
                                            onClicked: { dialog._memberId = modelData.id.toString(); memberPopup.visible = false } } } } } }

                        // Plan selector
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "Plan *"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: dialog._errorField === "planId" ? Theme.danger : Theme.textTertiary }
                            Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: dialog._errorField === "planId" ? Theme.danger : (planMA.containsMouse ? Theme.borderHover : Theme.border); Behavior on border.color { ColorAnimation { duration: 120 } }
                                MouseArea { id: planMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: planPopup.visible = !planPopup.visible }
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                    text: { if (dialog._planId === "") return "Select plan..."; for (var i = 0; i < dialog._plans.length; i++) { if (dialog._plans[i].id === parseInt(dialog._planId)) return dialog._plans[i].name + " (₹" + dialog._plans[i].defaultAmount + ")" } return "Select plan..." }
                                    font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: dialog._planId !== "" ? Theme.textPrimary : Theme.textTertiary }
                                Popup { id: planPopup; y: parent.height + 4; width: parent.width; implicitHeight: 280; padding: 4; background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                    ListView { anchors.fill: parent; clip: true; spacing: 2; model: dialog._plans
                                        delegate: ItemDelegate { width: parent.width; height: 34; padding: 0
                                            contentItem: Text { text: modelData.name + " (₹" + modelData.defaultAmount + ", " + modelData.frequency + ")"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                            background: Rectangle { color: highlighted ? Theme.primarySubtle : "transparent"; radius: 4 }
                                            onClicked: { dialog.onPlanChanged(modelData.id.toString()); planPopup.visible = false } } } } } }

                        // Amount | Amount Paid
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_amount") + " *" } placeholderText: "0.00"; text: dialog._amount; readOnly: dialog.readOnly; showError: dialog._errorField === "amount"; errorText: dialog._errorMessage; onTextChanged: dialog._amount = text }
                            AppTextField { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_amount_paid") } placeholderText: "0.00"; text: dialog._amountPaid; readOnly: dialog.readOnly; showError: dialog._errorField === "amountPaid"; errorText: dialog._errorMessage; onTextChanged: dialog._amountPaid = text } }

                        // Period Start | Period End
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_period_start") } placeholderText: "YYYY-MM-DD"; text: dialog._periodStart; readOnly: dialog.readOnly; onTextChanged: dialog._periodStart = text }
                            AppTextField { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_period_end") } placeholderText: "YYYY-MM-DD"; text: dialog._periodEnd; readOnly: dialog.readOnly; onTextChanged: dialog._periodEnd = text } }

                        // Status | Payment Method
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppComboBox { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("family_status") } model: ["Pending", "Paid", "Partial", "Overdue"]; currentIndex: Math.max(0, ["Pending", "Paid", "Partial", "Overdue"].indexOf(dialog._status)); onActivated: function(index) { dialog._status = model[index] } }
                            AppComboBox { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_method") } model: ["Cash", "Cheque", "UPI", "Bank Transfer", "Card", "Other"]; currentIndex: Math.max(0, ["Cash", "Cheque", "UPI", "Bank Transfer", "Card", "Other"].indexOf(dialog._paymentMethod)); onActivated: function(index) { dialog._paymentMethod = model[index] } } }

                        // Payment Date | Transaction Ref
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_payment_date") } placeholderText: "YYYY-MM-DD"; text: dialog._paymentDate; readOnly: dialog.readOnly; onTextChanged: dialog._paymentDate = text }
                            AppTextField { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("acc_reference") } placeholderText: "Optional"; text: dialog._transactionRef; readOnly: dialog.readOnly; onTextChanged: dialog._transactionRef = text } }

                        // Remarks
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "REMARKS"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 56; text: dialog._remarks; readOnly: dialog.readOnly; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; placeholderText: "Internal remarks..."; placeholderTextColor: Theme.textTertiary; selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? Theme.primary : parent.hovered ? Theme.borderHover : Theme.border; Behavior on border.color { ColorAnimation { duration: 120 } } }
                                padding: 10; onTextChanged: dialog._remarks = text } }

                        Item { Layout.fillWidth: true; Layout.preferredHeight: 4 }
                    }
                }

                // Footer
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 64; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                    Row { anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                        AppButton { text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_cancel") } variant: "secondary"; onClicked: dialog.visible = false }
                        AppButton { text: dialog.readOnly ? "Close" : (dialog.subscriptionId > 0 ? "Save Changes" : "Add Subscription"); variant: "primary"; iconName: dialog.readOnly ? "" : "check"; onClicked: dialog.submit() } } }
            }
        }
    }
}
