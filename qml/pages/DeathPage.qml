import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// Death register page — uses DeathController + DeathListModel
Item {
    id: page

    Component.onCompleted: deathModel.refresh()

    DeathEditDialog {
        id: editDialog
        onSaved: deathModel.refresh()
    }

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Death Record?"
        warningText: "This death record will be permanently deleted."
        property int _id: 0
        onAccepted: {
            if (_id > 0) {
                var r = deathController.remove(_id)
                toast.show(r.success ? "Record deleted" : (r.error || "Delete failed"), r.success ? "#059669" : "#e11d48")
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
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("dth_title") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXl; font.weight: Font.DemiBold; color: Theme.textPrimary }
                Text { text: "Death and burial records"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary } }
            AppButton {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_add") } variant: "primary"; iconName: "plus"
                Layout.alignment: Qt.AlignTop
                onClicked: { editDialog.deathId = 0; editDialog.readOnly = false; editDialog.show() }
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 10
            Rectangle { Layout.fillWidth: true; Layout.minimumWidth: 180; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: searchField.activeFocus ? "#059669" : (searchHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                HoverHandler { id: searchHover; cursorShape: Qt.IBeamCursor }
                Item { width: 16; height: 16; anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                    Image { id: searchIcon; source: "qrc:/icons/svg/search.svg"; sourceSize: Qt.size(16, 16); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                    MultiEffect { anchors.fill: parent; source: searchIcon; colorizationColor: searchField.activeFocus ? "#059669" : "#7e968a"; colorization: 1.0 } }
                TextField { id: searchField; anchors.left: parent.left; anchors.leftMargin: 32; anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; placeholderText: "Search by name, number..."; placeholderTextColor: "#7e968a"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; background: Item {} verticalAlignment: Text.AlignVCenter; onTextEdited: searchDebounce.restart() }
                Timer { id: searchDebounce; interval: 300; onTriggered: deathModel.searchTerm = searchField.text } }
            Text { text: "Showing " + deathModel.rowCount + " of " + deathModel.totalCount; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.textTertiary; Layout.alignment: Qt.AlignVCenter }
        }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 40; color: Theme.surfaceHover
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    Row { x: 16; width: parent.width - 32; spacing: 0
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("family_number") } width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("dth_deceased") } width: 180; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("dth_father") } width: 160; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("member_gender") } width: 80; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("member_age") } width: 50; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("dth_date_of_death") } width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("dth_burial_date") } width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_families") } width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary }
                        Item { width: parent.width - 120 - 180 - 160 - 80 - 50 - 120 - 120 - 120 - 80; height: 40 }
                        Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_edit") } width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary } } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: deathModel
                    delegate: Rectangle { width: table.width; height: 44; color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                        Row { x: 16; width: parent.width - 32; spacing: 0
                            Text { text: model.deathNumber; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.DemiBold; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: model.deceasedName; width: 180; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: model.fatherName || "—"; width: 160; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary; elide: Text.ElideRight }
                            Text { text: model.gender || "—"; width: 80; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary }
                            Text { text: model.age || "—"; width: 50; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.DemiBold; color: Theme.textPrimary }
                            Text { text: model.dateOfDeath || "—"; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary }
                            Text { text: model.burialDate || "—"; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary }
                            Text { text: model.familyNumber || "—"; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary }
                            Item { width: parent.width - 120 - 180 - 160 - 80 - 50 - 120 - 120 - 120 - 80; height: 44 }
                            Row { width: 80; height: 44; spacing: 4; layoutDirection: Qt.RightToLeft
                                TableActionButton { iconSource: "qrc:/icons/svg/trash.svg"; variantColor: "#e11d48"; anchors.verticalCenter: parent.verticalCenter; onClicked: { deleteDialog._id = model.id; deleteDialog.warningText = "Death record " + model.deathNumber + " will be permanently deleted."; deleteDialog.visible = true } }
                                TableActionButton { iconSource: "qrc:/icons/svg/edit.svg"; variantColor: "#059669"; anchors.verticalCenter: parent.verticalCenter; onClicked: { editDialog.deathId = model.id; editDialog.readOnly = false; editDialog.show() } }
                                TableActionButton { iconSource: "qrc:/icons/svg/search.svg"; variantColor: "#0284c7"; anchors.verticalCenter: parent.verticalCenter; onClicked: { editDialog.deathId = model.id; editDialog.readOnly = true; editDialog.show() } } } }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton } } }
                Item { Layout.fillWidth: true; Layout.fillHeight: true; visible: deathModel.rowCount === 0
                    Column { anchors.centerIn: parent; spacing: 8
                        Text { text: "No death records found"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Records will appear here once added"; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter } } }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 44; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                        Text { text: "Page " + deathModel.currentPage + " of " + deathModel.totalPages; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; color: Theme.textTertiary; Layout.alignment: Qt.AlignVCenter }
                        Item { Layout.fillWidth: true }
                        Rectangle { width: 28; height: 28; radius: 6; color: prevMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: prevMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: deathModel.currentPage > 1 ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: prevIcon; source: "qrc:/icons/svg/chevron-left.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: prevIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: prevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (deathModel.currentPage > 1) deathModel.currentPage = deathModel.currentPage - 1 } }
                        Rectangle { width: 28; height: 28; radius: 6; color: nextMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: nextMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: deathModel.currentPage < deathModel.totalPages ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: nextIcon; source: "qrc:/icons/svg/chevron-right.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: nextIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: nextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (deathModel.currentPage < deathModel.totalPages) deathModel.currentPage = deathModel.currentPage + 1 } } } }
            }
        }
    }
}
