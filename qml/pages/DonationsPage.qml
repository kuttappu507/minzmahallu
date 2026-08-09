import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// DonationsPage — Donation management screen
// Uses DonationListModel + DonationController.
// Pattern follows FamiliesPage (reference implementation).
// ============================================================================

Item {
    id: page

    DonationEditDialog {
        id: editDialog
        onSaved: donationModel.refresh()
    }

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Donation?"
        warningText: "This donation record will be permanently deleted."
        property int _donationId: 0
        onAccepted: {
            if (_donationId > 0) {
                var result = donationController.remove(_donationId)
                if (!result.success) toast.show(result.error || "Delete failed", "#e11d48")
                else toast.show("Donation deleted", "#059669")
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

    Component.onCompleted: donationModel.refresh()

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Column {
                Layout.fillWidth: true; spacing: 2
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_donations") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXl; font.weight: Font.DemiBold; color: Theme.textPrimary }
                Text { text: "Manage one-off donations and contributions"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textSecondary }
            }
            AppButton {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_add") + " " + I18NController.tr("nav_donations") } variant: "primary"; iconName: "plus"
                Layout.alignment: Qt.AlignTop
                onClicked: { editDialog.donationId = 0; editDialog.readOnly = false; editDialog.show() }
            }
        }

        // Toolbar
        RowLayout {
            Layout.fillWidth: true; spacing: 10

            // Summary card — Total Donations (auto-refreshes via summaryRevision)
            Rectangle { Layout.fillWidth: true; height: 48; radius: 9; color: Theme.pinkSubtle; border.width: 1; border.color: Theme.pink
                Column { anchors.centerIn: parent; spacing: 0
                    Text { text: "Total Donations"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: "#93184f"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: { var _r = donationController.summaryRevision; return "₹" + donationController.totalDonations("", "").toFixed(0); } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeLg; font.weight: Font.Bold; color: "#93184f"; anchors.horizontalCenter: parent.horizontalCenter } } }

            Rectangle {
                Layout.fillWidth: true; Layout.minimumWidth: 180
                height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1
                border.color: searchField.activeFocus ? "#059669" : (searchHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                Behavior on border.color { ColorAnimation { duration: 120 } }
                HoverHandler { id: searchHover; cursorShape: Qt.IBeamCursor }
                Item {
                    width: 16; height: 16; anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                    Image { id: donSearchIcon; source: "qrc:/icons/svg/search.svg"; sourceSize: Qt.size(16, 16); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                    MultiEffect { anchors.fill: parent; source: donSearchIcon; colorizationColor: searchField.activeFocus ? "#059669" : "#7e968a"; colorization: 1.0; Behavior on colorizationColor { ColorAnimation { duration: 120 } } }
                }
                TextField {
                    id: searchField
                    anchors.left: parent.left; anchors.leftMargin: 32; anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter
                    placeholderText: "Search by donor, receipt #..."; placeholderTextColor: "#7e968a"
                    font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary
                    background: Item {} verticalAlignment: Text.AlignVCenter
                    onTextEdited: searchDebounce.restart()
                }
                Timer { id: searchDebounce; interval: 300; onTriggered: donationModel.searchTerm = searchField.text }
            }

            AppComboBox {
                id: categoryCombo
                implicitHeight: 38
                model: {
                    var c = ["All Categories"]
                    if (typeof donationController !== "undefined") {
                        var cats = donationController.categories()
                        for (var i = 0; i < cats.length; i++) c.push(cats[i].name)
                    }
                    return c
                }
                onActivated: function(index) {
                    if (index === 0) { donationModel.categoryFilter = "" }
                    else {
                        var cats = donationController.categories()
                        if (index - 1 < cats.length) donationModel.categoryFilter = cats[index-1].id.toString()
                    }
                }
            }

            Item { Layout.fillWidth: true }
            Text {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("ui_records") + ": " + donationModel.rowCount + " / " + donationModel.totalCount }
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
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_receipt") } width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("don_donor_name") } width: 180; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("ui_category") } width: 140; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_amount") } width: 100; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("don_date") } width: 110; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("sub_method") } width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("don_purpose") } width: 160; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Item { width: parent.width - 120 - 180 - 140 - 100 - 110 - 100 - 160 - 80; height: 40 }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_edit") } width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                    }
                }

                ListView {
                    id: table
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 0; model: donationModel

                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                        Row {
                            x: 16; width: parent.width - 32; spacing: 0
                            Text { text: model.receiptNumber; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.DemiBold; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: model.donorName; width: 180; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: model.categoryName || "—"; width: 140; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textSecondary; elide: Text.ElideRight }
                            Text { text: "₹" + model.amount.toFixed(0); width: 100; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.DemiBold; color: Theme.textPrimary }
                            Text { text: model.donationDate || "—"; width: 110; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textSecondary }
                            Text { text: model.paymentMethod || "—"; width: 100; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textSecondary }
                            Text { text: model.purpose || "—"; width: 160; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Normal; color: Theme.textSecondary; elide: Text.ElideRight }
                            Item { width: parent.width - 120 - 180 - 140 - 100 - 110 - 100 - 160 - 80; height: 44 }
                            Row {
                                width: 80; height: 44; spacing: 4; layoutDirection: Qt.RightToLeft
                                TableActionButton { iconSource: "qrc:/icons/svg/trash.svg"; variantColor: "#e11d48"; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { deleteDialog._donationId = model.id; deleteDialog.warningText = "Donation " + model.receiptNumber + " will be permanently deleted."; deleteDialog.visible = true } }
                                TableActionButton { iconSource: "qrc:/icons/svg/edit.svg"; variantColor: "#059669"; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { editDialog.donationId = model.id; editDialog.readOnly = false; editDialog.show() } }
                                TableActionButton { iconSource: "qrc:/icons/svg/search.svg"; variantColor: "#0284c7"; anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { editDialog.donationId = model.id; editDialog.readOnly = true; editDialog.show() } }
                            }
                        }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                    }
                }

                // Empty state
                Item {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    visible: donationModel.rowCount === 0
                    Column {
                        anchors.centerIn: parent; spacing: 12
                        Rectangle { width: 56; height: 56; radius: 28; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border; anchors.horizontalCenter: parent.horizontalCenter
                            Item { width: 28; height: 28; anchors.centerIn: parent; Image { id: emptyIcon; source: "qrc:/icons/svg/donations.svg"; sourceSize: Qt.size(28, 28); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: emptyIcon; colorizationColor: "#b2cfbd"; colorization: 1.0 } } }
                        Text { text: "No donations found"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Click 'Add Donation' to create your first record"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Normal; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }

                // Pagination
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 44; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                        Text { text: "Page " + donationModel.currentPage + " of " + donationModel.totalPages; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.textTertiary; Layout.alignment: Qt.AlignVCenter }
                        Item { Layout.fillWidth: true }
                        Rectangle { width: 28; height: 28; radius: 6; color: prevMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: prevMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: donationModel.currentPage > 1 ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: prevIcon; source: "qrc:/icons/svg/chevron-left.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: prevIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: prevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (donationModel.currentPage > 1) donationModel.currentPage = donationModel.currentPage - 1 } }
                        Rectangle { width: 28; height: 28; radius: 6; color: nextMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: nextMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: donationModel.currentPage < donationModel.totalPages ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: nextIcon; source: "qrc:/icons/svg/chevron-right.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: nextIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: nextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (donationModel.currentPage < donationModel.totalPages) donationModel.currentPage = donationModel.currentPage + 1 } }
                    }
                }
            }
        }
    }
}
