import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// AccountingPage — Accounting/transactions management screen
// Uses TransactionListModel + AccountingController.
// ============================================================================

Item {
    id: page

    TransactionEditDialog {
        id: editDialog
        onSaved: transactionModel.refresh()
    }

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Transaction?"
        warningText: "This transaction will be permanently deleted."
        property int _txnId: 0
        onAccepted: {
            if (_txnId > 0) {
                var result = accountingController.remove(_txnId)
                if (!result.success) toast.show(result.error || "Delete failed", "#e11d48")
                else toast.show("Transaction deleted", "#059669")
            }
        }
    }

    Rectangle {
        id: toast
        property bool visible_: false
        property string message: ""
        property color bgColor: "#059669"
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: visible_ ? 18 : -60
        width: toastText.implicitWidth + 40; height: 40; radius: 9
        color: bgColor; z: 1000
        Behavior on anchors.topMargin { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: Theme.activeFontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: Theme.surface }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg, color) { message = msg; bgColor = color || "#059669"; visible_ = true; toastTimer.restart() }
    }

    Component.onCompleted: transactionModel.refresh()

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Column {
                Layout.fillWidth: true; spacing: 2
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_accounting") } font.family: Theme.activeFontFamily; font.pixelSize: 21; font.weight: Font.DemiBold; color: Theme.textPrimary }
                Text { text: "Manage ledger accounts and transactions"; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.Normal; color: Theme.textSecondary }
            }
            AppButton {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_add") + " " + I18NController.tr("nav_accounting") } variant: "primary"; iconName: "plus"
                Layout.alignment: Qt.AlignTop
                onClicked: { editDialog.transactionId = 0; editDialog.readOnly = false; editDialog.show() }
            }
        }

        // Summary cards — reference summaryRevision so they re-evaluate on data change
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            Rectangle { Layout.fillWidth: true; height: 60; radius: 9; color: Theme.primarySubtleAlt; border.width: 1; border.color: Theme.primary
                Column { anchors.centerIn: parent; spacing: 0
                    Text { text: "Total Income"; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: "#04543c"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: { var _r = accountingController.summaryRevision; return "₹" + accountingController.totalIncome("", "").toFixed(0); } font.family: Theme.activeFontFamily; font.pixelSize: 18; font.weight: Font.Bold; color: "#04543c"; anchors.horizontalCenter: parent.horizontalCenter } } }
            Rectangle { Layout.fillWidth: true; height: 60; radius: 9; color: Theme.coralSubtle; border.width: 1; border.color: Theme.danger
                Column { anchors.centerIn: parent; spacing: 0
                    Text { text: "Total Expense"; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: "#95102e"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: { var _r = accountingController.summaryRevision; return "₹" + accountingController.totalExpense("", "").toFixed(0); } font.family: Theme.activeFontFamily; font.pixelSize: 18; font.weight: Font.Bold; color: "#95102e"; anchors.horizontalCenter: parent.horizontalCenter } } }
            Rectangle { Layout.fillWidth: true; height: 60; radius: 9; color: Theme.violetSubtleAlt; border.width: 1; border.color: "#2563eb"
                Column { anchors.centerIn: parent; spacing: 0
                    Text { text: "Balance"; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: "#1e3fae"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: { var _r = accountingController.summaryRevision; return "₹" + accountingController.balance("", "").toFixed(0); } font.family: Theme.activeFontFamily; font.pixelSize: 18; font.weight: Font.Bold; color: "#1e3fae"; anchors.horizontalCenter: parent.horizontalCenter } } }
        }

        // Toolbar
        RowLayout {
            Layout.fillWidth: true; spacing: 10
            AppComboBox {
                model: ["All Types", "Income", "Expense"]
                implicitHeight: 38
                onActivated: function(index) {
                    transactionModel.typeFilter = index === 0 ? "" : model[index]
                }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "Showing " + transactionModel.rowCount + " of " + transactionModel.totalCount
                font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Table
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 40; color: Theme.surfaceHover
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    Row {
                        x: 16; width: parent.width - 32; spacing: 0
                        Text { text: "DATE"; width: 110; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "ACCOUNT"; width: 200; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "TYPE"; width: 90; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "AMOUNT"; width: 110; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "METHOD"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "DESCRIPTION"; width: parent.width - 110 - 200 - 90 - 110 - 100 - 80; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "ACTIONS"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                    }
                }

                ListView {
                    id: table
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 0; model: transactionModel

                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                        Row {
                            x: 16; width: parent.width - 32; spacing: 0
                            Text { text: model.txnDate || "—"; width: 110; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.Normal; color: Theme.textSecondary }
                            Text { text: (model.accountCode || "") + " - " + (model.accountName || "—"); width: 200; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.Normal; color: Theme.textPrimary; elide: Text.ElideRight }
                            Item { width: 90; height: 44; StatusBadge { anchors.centerIn: parent; text: model.type; variant: model.type.toLowerCase() === "income" ? "active" : "overdue" } }
                            Text { text: (model.type === "Expense" ? "-" : "+") + "₹" + model.amount.toFixed(0); width: 110; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: model.type === "Income" ? "#059669" : "#e11d48" }
                            Text { text: model.paymentMethod || "—"; width: 100; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.Normal; color: Theme.textSecondary }
                            Text { text: model.description || "—"; width: parent.width - 110 - 200 - 90 - 110 - 100 - 80; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.Normal; color: Theme.textSecondary; elide: Text.ElideRight }
                            Row {
                                width: 80; height: 44; spacing: 4; layoutDirection: Qt.RightToLeft
                                TableActionButton { iconSource: "qrc:/icons/svg/trash.svg"; variantColor: "#e11d48"; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { deleteDialog._txnId = model.id; deleteDialog.warningText = "Transaction will be permanently deleted."; deleteDialog.visible = true } }
                                TableActionButton { iconSource: "qrc:/icons/svg/edit.svg"; variantColor: "#059669"; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { editDialog.transactionId = model.id; editDialog.readOnly = false; editDialog.show() } }
                                TableActionButton { iconSource: "qrc:/icons/svg/search.svg"; variantColor: "#0284c7"; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { editDialog.transactionId = model.id; editDialog.readOnly = true; editDialog.show() } }
                            }
                        }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                    }
                }

                // Empty state
                Item {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    visible: transactionModel.rowCount === 0
                    Column {
                        anchors.centerIn: parent; spacing: 12
                        Rectangle { width: 56; height: 56; radius: 28; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border; anchors.horizontalCenter: parent.horizontalCenter
                            Item { width: 28; height: 28; anchors.centerIn: parent; Image { id: emptyIcon; source: "qrc:/icons/svg/accounting.svg"; sourceSize: Qt.size(28, 28); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: emptyIcon; colorizationColor: "#b2cfbd"; colorization: 1.0 } } }
                        Text { text: "No transactions found"; font.family: Theme.activeFontFamily; font.pixelSize: 14; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Click 'Add Transaction' to create your first record"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Normal; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }

                // Pagination
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 44; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                        Text { text: "Page " + transactionModel.currentPage + " of " + transactionModel.totalPages; font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary; Layout.alignment: Qt.AlignVCenter }
                        Item { Layout.fillWidth: true }
                        Rectangle { width: 28; height: 28; radius: 6; color: prevMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: prevMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: transactionModel.currentPage > 1 ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: prevIcon; source: "qrc:/icons/svg/chevron-left.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: prevIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: prevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (transactionModel.currentPage > 1) transactionModel.currentPage = transactionModel.currentPage - 1 } }
                        Rectangle { width: 28; height: 28; radius: 6; color: nextMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: nextMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: transactionModel.currentPage < transactionModel.totalPages ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: nextIcon; source: "qrc:/icons/svg/chevron-right.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: nextIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: nextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (transactionModel.currentPage < transactionModel.totalPages) transactionModel.currentPage = transactionModel.currentPage + 1 } }
                    }
                }
            }
        }
    }
}
