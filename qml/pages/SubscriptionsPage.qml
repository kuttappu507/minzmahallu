import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// SubscriptionsPage — Subscription management screen
// Uses SubscriptionListModel + SubscriptionController.
// Pattern follows FamiliesPage (reference implementation).
// ============================================================================

Item {
    id: page

    SubscriptionEditDialog {
        id: editDialog
        onSaved: subscriptionModel.refresh()
    }

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Subscription?"
        warningText: "This subscription record will be permanently deleted."
        property int _subId: 0
        onAccepted: {
            if (_subId > 0) {
                var result = subscriptionController.remove(_subId)
                if (!result.success) {
                    toast.show(result.error || "Delete failed", Theme.danger)
                } else {
                    toast.show("Subscription deleted", Theme.primary)
                }
            }
        }
    }

    // Toast
    Rectangle {
        id: toast
        property bool visible_: false
        visible: visible_
        property string message: ""
        property color bgColor: Theme.primary
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: visible_ ? 18 : -60
        width: toastText.implicitWidth + 40; height: 40; radius: 9
        color: bgColor; z: 1000
        Behavior on anchors.topMargin { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; font.weight: Font.DemiBold; color: Theme.surface }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg, color) { message = msg; bgColor = color || Theme.primary; visible_ = true; toastTimer.restart() }
    }

    Component.onCompleted: subscriptionModel.refresh()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Column {
                Layout.fillWidth: true; spacing: 2
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_subscriptions") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXl; font.weight: Font.DemiBold; color: Theme.textPrimary }
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_subtitle") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textSecondary }
            }
            AppButton {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_add") + " " + I18NController.tr("nav_subscriptions") } variant: "primary"; iconName: "plus"
                Layout.alignment: Qt.AlignTop
                onClicked: { editDialog.subscriptionId = 0; editDialog.readOnly = false; editDialog.show() }
            }
        }

        // Toolbar
        RowLayout {
            Layout.fillWidth: true; spacing: 10

            // Summary cards — fixed width so they don't compete with filter combo
            Rectangle { Layout.preferredWidth: 180; height: 48; radius: 9; color: Theme.primarySubtleAlt; border.width: 1; border.color: Theme.primary
                Column { anchors.centerIn: parent; spacing: 0
                    Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_title") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: "#04543c"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: { var _r = subscriptionController.summaryRevision; return "₹" + subscriptionController.totalCollected("", "").toFixed(0); } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeLg; font.weight: Font.Bold; color: "#04543c"; anchors.horizontalCenter: parent.horizontalCenter } } }
            Rectangle { Layout.preferredWidth: 180; height: 48; radius: 9; color: Theme.warningSubtle; border.width: 1; border.color: Theme.warning
                Column { anchors.centerIn: parent; spacing: 0
                    Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_pending") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: "#7c4403"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: { var _r = subscriptionController.summaryRevision; return "₹" + subscriptionController.totalPending().toFixed(0); } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeLg; font.weight: Font.Bold; color: "#7c4403"; anchors.horizontalCenter: parent.horizontalCenter } } }

            AppComboBox {
                model: ["All Status", "Paid", "Pending", "Overdue", "Partial"]
                implicitHeight: 38
                onActivated: function(index) {
                    subscriptionModel.statusFilter = index === 0 ? "" : model[index]
                }
            }

            AppButton {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_mark_overdue") } variant: "secondary"; iconName: "alert"
                onClicked: {
                    var count = subscriptionController.markOverdue()
                    subscriptionModel.refresh()
                    toast.show(count + " subscriptions marked overdue", Theme.warning)
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("ui_records") + ": " + subscriptionModel.rowCount + " / " + subscriptionModel.totalCount }
                font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.textTertiary
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
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_receipt") } width: 130; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_families") } width: 150; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_members") } width: 140; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_plan") } width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_amount") } width: 90; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_amount_paid") } width: 90; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_period_start") } width: 180; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("family_status") } width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Item { width: parent.width - 130 - 150 - 140 - 120 - 90 - 90 - 180 - 100 - 80; height: 40 }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_edit") } width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                    }
                }

                ListView {
                    id: table
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 0
                    model: subscriptionModel

                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: rowMA.containsMouse ? Theme.surfaceHover : (index % 2 === 0 ? Theme.surface : Theme.surfaceSubtle)
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                        Row {
                            x: 16; width: parent.width - 32; spacing: 0
                            Text { text: model.receiptNumber; width: 130; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.DemiBold; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: model.familyNumber; width: 150; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textSecondary; elide: Text.ElideRight }
                            Text { text: model.memberName || "—"; width: 140; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textSecondary; elide: Text.ElideRight }
                            Text { text: model.planName || "—"; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textSecondary; elide: Text.ElideRight }
                            Text { text: "₹" + model.amount.toFixed(0); width: 90; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.DemiBold; color: Theme.textPrimary }
                            Text { text: "₹" + model.amountPaid.toFixed(0); width: 90; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textSecondary }
                            Text { text: (model.periodStart || "—") + " to " + (model.periodEnd || "—"); width: 180; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Normal; color: Theme.textTertiary; elide: Text.ElideRight }
                            Item { width: 100; height: 44; StatusBadge { anchors.centerIn: parent; text: model.status; variant: model.status.toLowerCase() } }
                            Item { width: parent.width - 130 - 150 - 140 - 120 - 90 - 90 - 180 - 100 - 80; height: 44 }
                            Row {
                                width: 80; height: 44; spacing: 4; layoutDirection: Qt.RightToLeft
                                TableActionButton { iconSource: "qrc:/icons/svg/trash.svg"; variantColor: Theme.danger; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { deleteDialog._subId = model.id; deleteDialog.warningText = "Subscription " + model.receiptNumber + " will be permanently deleted."; deleteDialog.visible = true } }
                                TableActionButton { iconSource: "qrc:/icons/svg/edit.svg"; variantColor: Theme.primary; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { editDialog.subscriptionId = model.id; editDialog.readOnly = false; editDialog.show() } }
                                TableActionButton { iconSource: "qrc:/icons/svg/search.svg"; variantColor: Theme.blue; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { editDialog.subscriptionId = model.id; editDialog.readOnly = true; editDialog.show() } }
                            }
                        }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                    }
                }

                // Empty state
                Item {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    visible: subscriptionModel.rowCount === 0
                    Column {
                        anchors.centerIn: parent; spacing: 12
                        Rectangle { width: 56; height: 56; radius: 28; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border; anchors.horizontalCenter: parent.horizontalCenter
                            Item { width: 28; height: 28; anchors.centerIn: parent; Image { id: emptyIcon; source: "qrc:/icons/svg/subscriptions.svg"; sourceSize: Qt.size(28, 28); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: emptyIcon; colorizationColor: Theme.borderHover; colorization: 1.0 } } }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("ui_no_records") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("ui_click_add_to_create") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Normal; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }

                // Pagination
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 44; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                        Text { text: "Page " + subscriptionModel.currentPage + " of " + subscriptionModel.totalPages; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.textTertiary; Layout.alignment: Qt.AlignVCenter }
                        Item { Layout.fillWidth: true }
                        Rectangle { width: 28; height: 28; radius: 6; color: prevMA.containsMouse ? Theme.surface : "transparent"; border.width: 1; border.color: prevMA.containsMouse ? Theme.borderHover : Theme.border; Layout.alignment: Qt.AlignVCenter; opacity: subscriptionModel.currentPage > 1 ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: prevIcon; source: "qrc:/icons/svg/chevron-left.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: prevIcon; colorizationColor: Theme.textSecondary; colorization: 1.0 } }
                            MouseArea { id: prevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (subscriptionModel.currentPage > 1) subscriptionModel.currentPage = subscriptionModel.currentPage - 1 } }
                        Rectangle { width: 28; height: 28; radius: 6; color: nextMA.containsMouse ? Theme.surface : "transparent"; border.width: 1; border.color: nextMA.containsMouse ? Theme.borderHover : Theme.border; Layout.alignment: Qt.AlignVCenter; opacity: subscriptionModel.currentPage < subscriptionModel.totalPages ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: nextIcon; source: "qrc:/icons/svg/chevron-right.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: nextIcon; colorizationColor: Theme.textSecondary; colorization: 1.0 } }
                            MouseArea { id: nextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (subscriptionModel.currentPage < subscriptionModel.totalPages) subscriptionModel.currentPage = subscriptionModel.currentPage + 1 } }
                    }
                }
            }
        }
    }
}
