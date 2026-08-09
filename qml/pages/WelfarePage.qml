import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// Welfare page — uses WelfareController + WelfareListModel
Item {
    id: page

    Component.onCompleted: welfareModel.refresh()

    WelfareEditDialog {
        id: editDialog
        onSaved: welfareModel.refresh()
    }

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Welfare Request?"
        warningText: "This welfare request will be permanently deleted."
        property int _id: 0
        onAccepted: {
            if (_id > 0) {
                var r = welfareController.remove(_id)
                toast.show(r.success ? "Request deleted" : (r.error || "Delete failed"), r.success ? "#059669" : "#e11d48")
            }
        }
    }

    Rectangle {
        id: toast
        property bool visible_: false
        visible: visible_
        property string message: ""
        property color bgColor: "#059669"
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: visible_ ? 18 : -60
        width: toastText.implicitWidth + 40; height: 40; radius: 9
        color: bgColor; z: 1000
        Behavior on anchors.topMargin { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; font.weight: Font.DemiBold; color: Theme.surface }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg, color) { message = msg; bgColor = color || "#059669"; visible_ = true; toastTimer.restart() }
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Column { Layout.fillWidth: true; spacing: 2
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_welfare") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXl; font.weight: Font.DemiBold; color: Theme.textPrimary }
                Text { text: "Assistance requests and disbursements"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary } }
            AppButton {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_add") } variant: "primary"; iconName: "plus"
                Layout.alignment: Qt.AlignTop
                onClicked: { editDialog.requestId = 0; editDialog.readOnly = false; editDialog.show() }
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 10
            Rectangle { Layout.fillWidth: true; Layout.minimumWidth: 180; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: searchField.activeFocus ? "#059669" : (searchHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                HoverHandler { id: searchHover; cursorShape: Qt.IBeamCursor }
                Item { width: 16; height: 16; anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                    Image { id: searchIcon; source: "qrc:/icons/svg/search.svg"; sourceSize: Qt.size(16, 16); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                    MultiEffect { anchors.fill: parent; source: searchIcon; colorizationColor: searchField.activeFocus ? "#059669" : "#7e968a"; colorization: 1.0 } }
                TextField { id: searchField; anchors.left: parent.left; anchors.leftMargin: 32; anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; placeholderText: "Search by applicant, number..."; placeholderTextColor: "#7e968a"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; background: Item {} verticalAlignment: Text.AlignVCenter; onTextEdited: searchDebounce.restart() }
                Timer { id: searchDebounce; interval: 300; onTriggered: welfareModel.searchTerm = searchField.text } }
            AppComboBox { model: ["All Status", "Pending", "Approved", "Rejected", "Disbursed", "Closed"]; implicitHeight: 38; onActivated: function(index) { welfareModel.statusFilter = index === 0 ? "" : model[index] } }
            AppComboBox { model: ["All Categories", "Medical Aid", "Education Aid", "Marriage Assistance", "Financial Assistance"]; implicitHeight: 38; onActivated: function(index) { welfareModel.categoryFilter = index === 0 ? "" : model[index] } }
            Text { text: "Showing " + welfareModel.rowCount + " of " + welfareModel.totalCount; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.textTertiary; Layout.alignment: Qt.AlignVCenter }
        }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 40; color: Theme.surfaceHover
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    Row { x: 16; width: parent.width - 32; spacing: 0
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("family_number") } width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("wel_applicant") } width: 180; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("ui_category") } width: 160; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("wel_amount_requested") } width: 100; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("wel_amount_approved") } width: 100; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("family_status") } width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("wel_reason") } width: parent.width - 120 - 180 - 160 - 100 - 100 - 100 - 80; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_edit") } width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary } } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: welfareModel
                    delegate: Rectangle { width: table.width; height: 44; color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                        Row { x: 16; width: parent.width - 32; spacing: 0
                            Text { text: model.requestNumber; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.DemiBold; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: model.applicantName; width: 180; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: model.category || "—"; width: 160; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary; elide: Text.ElideRight }
                            Text { text: "₹" + model.amountRequested.toFixed(0); width: 100; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.DemiBold; color: Theme.textPrimary }
                            Text { text: model.amountApproved > 0 ? "₹" + model.amountApproved.toFixed(0) : "—"; width: 100; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary }
                            Item { width: 100; height: 44; StatusBadge { anchors.centerIn: parent; text: model.status; variant: { var s = model.status.toLowerCase(); if (s === "approved" || s === "disbursed") return "active"; if (s === "rejected") return "overdue"; if (s === "pending") return "pending"; return "inactive" } } }
                            Text { text: model.reason || "—"; width: parent.width - 120 - 180 - 160 - 100 - 100 - 100 - 80; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary; elide: Text.ElideRight }
                            Row { width: 80; height: 44; spacing: 4; layoutDirection: Qt.RightToLeft
                                TableActionButton { iconSource: "qrc:/icons/svg/trash.svg"; variantColor: "#e11d48"; anchors.verticalCenter: parent.verticalCenter; onClicked: { deleteDialog._id = model.id; deleteDialog.warningText = "Welfare request " + model.requestNumber + " will be permanently deleted."; deleteDialog.visible = true } }
                                TableActionButton { iconSource: "qrc:/icons/svg/edit.svg"; variantColor: "#059669"; anchors.verticalCenter: parent.verticalCenter; onClicked: { editDialog.requestId = model.id; editDialog.readOnly = false; editDialog.show() } }
                                TableActionButton { iconSource: "qrc:/icons/svg/search.svg"; variantColor: "#0284c7"; anchors.verticalCenter: parent.verticalCenter; onClicked: { editDialog.requestId = model.id; editDialog.readOnly = true; editDialog.show() } } } }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton } } }
                Item { Layout.fillWidth: true; Layout.fillHeight: true; visible: welfareModel.rowCount === 0
                    Column { anchors.centerIn: parent; spacing: 8
                        Text { text: "No welfare requests found"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Requests will appear here once added"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter } } }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 44; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                        Text { text: "Page " + welfareModel.currentPage + " of " + welfareModel.totalPages; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.textTertiary; Layout.alignment: Qt.AlignVCenter }
                        Item { Layout.fillWidth: true }
                        Rectangle { width: 28; height: 28; radius: 6; color: prevMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: prevMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: welfareModel.currentPage > 1 ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: prevIcon; source: "qrc:/icons/svg/chevron-left.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: prevIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: prevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (welfareModel.currentPage > 1) welfareModel.currentPage = welfareModel.currentPage - 1 } }
                        Rectangle { width: 28; height: 28; radius: 6; color: nextMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: nextMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: welfareModel.currentPage < welfareModel.totalPages ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: nextIcon; source: "qrc:/icons/svg/chevron-right.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: nextIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: nextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (welfareModel.currentPage < welfareModel.totalPages) welfareModel.currentPage = welfareModel.currentPage + 1 } } } }
            }
        }
    }
}
