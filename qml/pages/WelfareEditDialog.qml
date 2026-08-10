import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import "../components"

// ============================================================================
// WelfareEditDialog — Add/Edit/View welfare request + approve/reject/disburse
// ============================================================================

ModalDialog {
    id: dialog
    modalWidth: 640; modalHeight: 620
    closeOnBackdrop: false; closeOnEscape: true

    property int requestId: 0
    property bool readOnly: false
    signal saved()
    property string _dialogTitle: "Add Welfare Request"

    // Form data
    property string _requestNumber: ""
    property string _applicantName: ""
    property string _familyId: ""
    property string _category: "Medical Aid"
    property string _amountRequested: ""
    property string _amountApproved: ""
    property string _reason: ""
    property string _status: "Pending"
    property string _disbursedDate: ""
    property string _remarks: ""

    property string _errorMessage: ""
    property string _errorField: ""
    property var _families: []
    property var _categories: WelfareController ? WelfareController.categories() : ["Medical Aid", "Education Aid", "Marriage Assistance", "Financial Assistance"]

    function show() {
        _errorMessage = ""
        _errorField = ""
        _families = WelfareController.activeFamilies()

        if (requestId > 0) {
            var w = WelfareController.get(requestId)
            if (w && w.id !== undefined) {
                _requestNumber = w.requestNumber || ""
                _applicantName = w.applicantName || ""
                _familyId = w.familyId ? w.familyId.toString() : ""
                _category = w.category || "Medical Aid"
                _amountRequested = w.amountRequested ? w.amountRequested.toString() : ""
                _amountApproved = w.amountApproved ? w.amountApproved.toString() : ""
                _reason = w.reason || ""
                _status = w.status || "Pending"
                _disbursedDate = w.disbursedDate || ""
                _remarks = w.remarks || ""
                _dialogTitle = readOnly ? "View Welfare Request" : "Edit Welfare Request"
            } else { _errorMessage = "Could not load request"; _dialogTitle = "Edit Welfare Request" }
        } else {
            _requestNumber = ""; _applicantName = ""; _familyId = ""; _category = "Medical Aid"
            _amountRequested = ""; _amountApproved = ""; _reason = ""; _status = "Pending"
            _disbursedDate = ""; _remarks = ""
            _dialogTitle = "Add Welfare Request"
        }
        visible = true
    }

    function validate() {
        _errorMessage = ""; _errorField = ""
        if (_applicantName.trim() === "") { _errorMessage = "Applicant name is required."; _errorField = "applicantName"; return false }
        if (_amountRequested === "" || parseFloat(_amountRequested) <= 0) { _errorMessage = "Amount requested must be greater than zero."; _errorField = "amountRequested"; return false }
        return true
    }

    function submit() {
        if (readOnly) { dialog.visible = false; return }
        if (!validate()) return

        var data = {
            applicantName: _applicantName,
            familyId: parseInt(_familyId) || 0,
            category: _category,
            amountRequested: parseFloat(_amountRequested) || 0,
            amountApproved: parseFloat(_amountApproved) || 0,
            reason: _reason,
            status: _status,
            disbursedDate: _disbursedDate,
            remarks: _remarks
        }

        var result = requestId > 0 ? WelfareController.update(requestId, data) : WelfareController.create(data)
        if (result.success) {
            _errorMessage = ""; _errorField = ""
            dialog.saved(); dialog.visible = false
        } else {
            _errorMessage = result.error || "Operation failed."
            _errorField = result.field || ""
        }
    }

    function doApprove() {
        var amt = parseFloat(approveAmountField.text) || 0
        if (amt <= 0) { _errorMessage = "Approved amount must be greater than zero."; _errorField = "amountApproved"; return }
        var result = WelfareController.approve(requestId, amt, approveRemarksField.text)
        if (result.success) { dialog.saved(); dialog.visible = false }
        else { _errorMessage = result.error || "Approve failed." }
    }

    function doReject() {
        var result = WelfareController.reject(requestId, rejectReasonField.text)
        if (result.success) { dialog.saved(); dialog.visible = false }
        else { _errorMessage = result.error || "Reject failed." }
    }

    function doDisburse() {
        var today = new Date().toISOString().slice(0, 10)
        var result = WelfareController.disburse(requestId, today)
        if (result.success) { dialog.saved(); dialog.visible = false }
        else { _errorMessage = result.error || "Disburse failed." }
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

                // Status badge (when editing)
                Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 8; visible: dialog.requestId > 0; height: 32; radius: 6; color: { var s = dialog._status.toLowerCase(); if (s === "approved" || s === "disbursed") return "#d3f5e6"; if (s === "rejected") return "#fddfe5"; return "#fcebc8" }
                    Text { anchors.centerIn: parent; text: "Status: " + dialog._status; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.DemiBold; color: { var s = dialog._status.toLowerCase(); if (s === "approved" || s === "disbursed") return "#04543c"; if (s === "rejected") return "#95102e"; return "#7c4403" } } }

                // Error banner
                Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 8; visible: dialog._errorMessage !== ""; height: 36; radius: 8; color: Theme.coralSubtle; border.width: 1; border.color: Theme.danger
                    Text { anchors.fill: parent; anchors.margins: 8; text: dialog._errorMessage; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: "#95102e"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight } }

                // Form (scrollable)
                ScrollView {
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: parent.width - 48; x: 24; spacing: 14

                        // Request Number (read-only)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("wel_request_no") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                            Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: dialog._requestNumber || "Auto-generated on save"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: dialog._requestNumber ? "#12241b" : "#7e968a" } } }

                        // Applicant Name | Family
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppTextField { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("wel_applicant") + " *" } placeholderText: "Full name"; text: dialog._applicantName; readOnly: dialog.readOnly; showError: dialog._errorField === "applicantName"; errorText: dialog._errorMessage; onTextChanged: dialog._applicantName = text }
                            ColumnLayout { Layout.fillWidth: true; spacing: 4
                                Text { text: "Family (optional)"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                                Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: familyMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } }
                                    MouseArea { id: familyMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: familyPopup.visible = !familyPopup.visible }
                                    Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                        text: { if (dialog._familyId === "") return "(none)"; for (var i = 0; i < dialog._families.length; i++) { if (dialog._families[i].id === parseInt(dialog._familyId)) return dialog._families[i].familyNumber + " - " + dialog._families[i].houseName } return "(none)" }
                                        font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: dialog._familyId !== "" ? "#12241b" : "#7e968a" }
                                    Popup { id: familyPopup; y: parent.height + 4; width: parent.width; implicitHeight: 280; padding: 4; background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                        ListView { anchors.fill: parent; clip: true; spacing: 2; model: dialog._families
                                            delegate: ItemDelegate { width: parent.width; height: 34; padding: 0
                                                contentItem: Text { text: modelData.familyNumber + " - " + modelData.houseName; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                                background: Rectangle { color: highlighted ? "#ecfdf5" : "transparent"; radius: 4 }
                                                onClicked: { dialog._familyId = modelData.id.toString(); familyPopup.visible = false } } } } } }

                        // Category | Amount Requested
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            AppComboBox { Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("ui_category") + " *" } model: dialog._categories; currentIndex: Math.max(0, dialog._categories.indexOf(dialog._category)); onActivated: function(index) { dialog._category = model[index] } }
                            AppTextField { Layout.fillWidth: true; label: "Amount Requested *"; placeholderText: "0.00"; text: dialog._amountRequested; readOnly: dialog.readOnly; showError: dialog._errorField === "amountRequested"; errorText: dialog._errorMessage; onTextChanged: dialog._amountRequested = text } }

                        // Amount Approved (read-only unless approving)
                        AppTextField { Layout.fillWidth: true; label: "Amount Approved"; placeholderText: "0.00"; text: dialog._amountApproved; readOnly: dialog.readOnly; onTextChanged: dialog._amountApproved = text }

                        // Reason (full width)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("wel_reason") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 64; text: dialog._reason; readOnly: dialog.readOnly; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; placeholderText: "Reason for request..."; placeholderTextColor: "#7e968a"; selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                                padding: 10; onTextChanged: dialog._reason = text } }

                        // Remarks
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "REMARKS"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                            TextArea { Layout.fillWidth: true; Layout.preferredHeight: 56; text: dialog._remarks; readOnly: dialog.readOnly; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; placeholderText: "Internal remarks..."; placeholderTextColor: "#7e968a"; selectByMouse: true; wrapMode: TextArea.Wrap
                                background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                                padding: 10; onTextChanged: dialog._remarks = text } }

                        // ===== Workflow actions (visible when status=Pending and editing) =====
                        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surfacePressed; visible: dialog.requestId > 0 && dialog._status === "Pending" && !dialog.readOnly }

                        // Approve section
                        ColumnLayout { Layout.fillWidth: true; spacing: 4; visible: dialog.requestId > 0 && dialog._status === "Pending" && !dialog.readOnly
                            Text { text: "APPROVE REQUEST"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.DemiBold; color: "#04543c" }
                            RowLayout { Layout.fillWidth: true; spacing: 12
                                AppTextField { id: approveAmountField; Layout.fillWidth: true; label: { var _l = I18NController.currentLanguage; return I18NController.tr("wel_amount_approved") } placeholderText: "0.00"; text: dialog._amountRequested }
                                AppTextField { id: approveRemarksField; Layout.fillWidth: true; label: "Approval Remarks"; placeholderText: "Optional" } }
                            AppButton { text: "Approve Request"; variant: "primary"; iconName: "check"; onClicked: dialog.doApprove() } }

                        // Reject section
                        ColumnLayout { Layout.fillWidth: true; spacing: 4; visible: dialog.requestId > 0 && dialog._status === "Pending" && !dialog.readOnly
                            Text { text: "REJECT REQUEST"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.DemiBold; color: "#95102e" }
                            AppTextField { id: rejectReasonField; Layout.fillWidth: true; label: "Rejection Reason"; placeholderText: "Reason for rejection" }
                            AppButton { text: "Reject Request"; variant: "danger"; iconName: "alert"; onClicked: dialog.doReject() } }

                        // Disburse section (visible when status=Approved)
                        ColumnLayout { Layout.fillWidth: true; spacing: 4; visible: dialog.requestId > 0 && dialog._status === "Approved" && !dialog.readOnly
                            Text { text: "DISBURSE FUNDS"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.DemiBold; color: "#7c4403" }
                            Text { text: "Click below to mark this request as disbursed with today's date."; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.textTertiary; Layout.fillWidth: true; wrapMode: Text.Wrap }
                            AppButton { text: "Mark as Disbursed"; variant: "primary"; iconName: "dollar"; onClicked: dialog.doDisburse() } }

                        Item { Layout.fillWidth: true; Layout.preferredHeight: 4 }
                    }
                }

                // Footer
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 64; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                    Row { anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                        AppButton { text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_cancel") } variant: "secondary"; onClicked: dialog.visible = false }
                        AppButton { text: dialog.readOnly ? "Close" : (dialog.requestId > 0 ? "Save Changes" : "Add Request"); variant: "primary"; iconName: dialog.readOnly ? "" : "check"; visible: !dialog.readOnly || true; onClicked: dialog.submit() } } }
            }
        }
    }
}
}
