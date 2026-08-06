import QtQuick
import QtQuick.Controls
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
                    toast.show(result.error || "Delete failed", "#e11d48")
                } else {
                    toast.show("Subscription deleted", "#059669")
                }
            }
        }
    }

    // Toast
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
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: "Poppins"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#ffffff" }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg, color) { message = msg; bgColor = color || "#059669"; visible_ = true; toastTimer.restart() }
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
                Text { text: "Subscriptions"; font.family: "Poppins"; font.pixelSize: 21; font.weight: Font.DemiBold; color: "#12241b" }
                Text { text: "Manage recurring contributions and collections"; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c" }
            }
            AppButton {
                text: "Add Subscription"; variant: "primary"; iconName: "plus"
                Layout.alignment: Qt.AlignTop
                onClicked: { editDialog.subscriptionId = 0; editDialog.readOnly = false; editDialog.show() }
            }
        }

        // Toolbar
        RowLayout {
            Layout.fillWidth: true; spacing: 10

            // Summary cards — reference summaryRevision so they re-evaluate on data change
            Rectangle { Layout.fillWidth: true; height: 48; radius: 9; color: "#d3f5e6"; border.width: 1; border.color: "#059669"
                Column { anchors.centerIn: parent; spacing: 0
                    Text { text: "Total Collected"; font.family: "Poppins"; font.pixelSize: 9; font.weight: Font.Medium; color: "#04543c"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: { var _r = subscriptionController.summaryRevision; return "₹" + subscriptionController.totalCollected("", "").toFixed(0); } font.family: "Poppins"; font.pixelSize: 16; font.weight: Font.Bold; color: "#04543c"; anchors.horizontalCenter: parent.horizontalCenter } } }
            Rectangle { Layout.fillWidth: true; height: 48; radius: 9; color: "#fcebc8"; border.width: 1; border.color: "#d97706"
                Column { anchors.centerIn: parent; spacing: 0
                    Text { text: "Total Pending"; font.family: "Poppins"; font.pixelSize: 9; font.weight: Font.Medium; color: "#7c4403"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: { var _r = subscriptionController.summaryRevision; return "₹" + subscriptionController.totalPending().toFixed(0); } font.family: "Poppins"; font.pixelSize: 16; font.weight: Font.Bold; color: "#7c4403"; anchors.horizontalCenter: parent.horizontalCenter } } }

            AppComboBox {
                model: ["All Status", "Paid", "Pending", "Overdue", "Partial"]
                implicitHeight: 38
                onActivated: function(index) {
                    subscriptionModel.statusFilter = index === 0 ? "" : model[index]
                }
            }

            AppButton {
                text: "Mark Overdue"; variant: "secondary"; iconName: "alert"
                onClicked: {
                    var count = subscriptionController.markOverdue()
                    subscriptionModel.refresh()
                    toast.show(count + " subscriptions marked overdue", "#d97706")
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Showing " + subscriptionModel.rowCount + " of " + subscriptionModel.totalCount
                font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a"
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Table
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: "#ffffff"; border.width: 1; border.color: "#d2e5d8"

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 40; color: "#f2faf4"
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#d2e5d8" }
                    Row {
                        x: 16; width: parent.width - 32; spacing: 0
                        Text { text: "RECEIPT #"; width: 130; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "FAMILY"; width: 150; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "MEMBER"; width: 140; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "PLAN"; width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "AMOUNT"; width: 90; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "PAID"; width: 90; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "PERIOD"; width: 180; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "STATUS"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Item { width: parent.width - 130 - 150 - 140 - 120 - 90 - 90 - 180 - 100 - 80; height: 40 }
                        Text { text: "ACTIONS"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                    }
                }

                ListView {
                    id: table
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 0
                    model: subscriptionModel

                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#eef8f1" }
                        Row {
                            x: 16; width: parent.width - 32; spacing: 0
                            Text { text: model.receiptNumber; width: 130; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#12241b"; elide: Text.ElideRight }
                            Text { text: model.familyNumber; width: 150; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c"; elide: Text.ElideRight }
                            Text { text: model.memberName || "—"; width: 140; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c"; elide: Text.ElideRight }
                            Text { text: model.planName || "—"; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c"; elide: Text.ElideRight }
                            Text { text: "₹" + model.amount.toFixed(0); width: 90; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#12241b" }
                            Text { text: "₹" + model.amountPaid.toFixed(0); width: 90; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Normal; color: "#4f6b5c" }
                            Text { text: (model.periodStart || "—") + " to " + (model.periodEnd || "—"); width: 180; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Normal; color: "#7e968a"; elide: Text.ElideRight }
                            Item { width: 100; height: 44; StatusBadge { anchors.centerIn: parent; text: model.status; variant: model.status.toLowerCase() } }
                            Item { width: parent.width - 130 - 150 - 140 - 120 - 90 - 90 - 180 - 100 - 80; height: 44 }
                            Row {
                                width: 80; height: 44; spacing: 4; layoutDirection: Qt.RightToLeft
                                TableActionButton { iconSource: "qrc:/icons/svg/trash.svg"; variantColor: "#e11d48"; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { deleteDialog._subId = model.id; deleteDialog.warningText = "Subscription " + model.receiptNumber + " will be permanently deleted."; deleteDialog.visible = true } }
                                TableActionButton { iconSource: "qrc:/icons/svg/edit.svg"; variantColor: "#059669"; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { editDialog.subscriptionId = model.id; editDialog.readOnly = false; editDialog.show() } }
                                TableActionButton { iconSource: "qrc:/icons/svg/search.svg"; variantColor: "#0284c7"; anchors.verticalCenter: parent.verticalCenter
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
                        Rectangle { width: 56; height: 56; radius: 28; color: "#f2faf4"; border.width: 1; border.color: "#d2e5d8"; anchors.horizontalCenter: parent.horizontalCenter
                            Item { width: 28; height: 28; anchors.centerIn: parent; Image { id: emptyIcon; source: "qrc:/icons/svg/subscriptions.svg"; sourceSize: Qt.size(28, 28); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: emptyIcon; colorizationColor: "#b2cfbd"; colorization: 1.0 } } }
                        Text { text: "No subscriptions found"; font.family: "Poppins"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#12241b"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Click 'Add Subscription' to create your first record"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Normal; color: "#7e968a"; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }

                // Pagination
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 44; color: "#f2faf4"
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#d2e5d8" }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                        Text { text: "Page " + subscriptionModel.currentPage + " of " + subscriptionModel.totalPages; font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a"; Layout.alignment: Qt.AlignVCenter }
                        Item { Layout.fillWidth: true }
                        Rectangle { width: 28; height: 28; radius: 6; color: prevMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: prevMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: subscriptionModel.currentPage > 1 ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: prevIcon; source: "qrc:/icons/svg/chevron-left.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: prevIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: prevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (subscriptionModel.currentPage > 1) subscriptionModel.currentPage = subscriptionModel.currentPage - 1 } }
                        Rectangle { width: 28; height: 28; radius: 6; color: nextMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: nextMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: subscriptionModel.currentPage < subscriptionModel.totalPages ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: nextIcon; source: "qrc:/icons/svg/chevron-right.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: nextIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: nextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (subscriptionModel.currentPage < subscriptionModel.totalPages) subscriptionModel.currentPage = subscriptionModel.currentPage + 1 } }
                    }
                }
            }
        }
    }
}
