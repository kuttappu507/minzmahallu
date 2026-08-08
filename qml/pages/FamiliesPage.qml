import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// FamiliesPage — Family management screen (PRODUCTION)
//
// Uses FamilyListModel (QAbstractListModel) as the ListView model.
// Uses FamilyController for create/update/delete operations.
// The model auto-refreshes when the controller emits created/updated/deleted.
//
// NO manual clear/append. NO QML-side SQL. All persistence via C++ backend.
// ============================================================================

Item {
    id: page

    FamilyEditDialog {
        id: editDialog
        onSaved: familyModel.refresh()
    }

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Family?"
        warningText: "This family record will be permanently deleted."
        property int _familyId: 0
        onAccepted: {
            if (_familyId > 0) {
                var result = familyController.remove(_familyId)
                if (!result.success) {
                    toast.show(result.error || "Delete failed", "#e11d48")
                } else {
                    toast.show("Family deleted", "#059669")
                }
            }
        }
    }

    // ===== Toast notification =====
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

        Text {
            id: toastText
            anchors.centerIn: parent
            text: toast.message
            font.family: Theme.activeFontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: Theme.surface
        }

        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }

        function show(msg, color) {
            message = msg
            bgColor = color || "#059669"
            visible_ = true
            toastTimer.restart()
        }
    }

    Component.onCompleted: familyModel.refresh()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // ===== Page header — title+subtitle left, Add button right =====
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Column {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_families") }
                    font.family: Theme.activeFontFamily; font.pixelSize: 21; font.weight: Font.DemiBold; color: Theme.textPrimary
                }
                Text {
                    text: "Manage all registered families in the mahallu"
                    font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.Normal; color: Theme.textSecondary
                }
            }

            AppButton {
                text: "Add Family"; variant: "primary"; iconName: "plus"
                Layout.alignment: Qt.AlignTop
                onClicked: { editDialog.familyId = 0; editDialog.readOnly = false; editDialog.show() }
            }
        }

        // ===== Toolbar — search + filters + count =====
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Search field
            Rectangle {
                Layout.fillWidth: true; Layout.minimumWidth: 180
                height: 38; radius: 9
                color: Theme.surfaceHover; border.width: 1
                border.color: searchField.activeFocus ? "#059669" : (searchHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                Behavior on border.color { ColorAnimation { duration: 120 } }
                HoverHandler { id: searchHover; cursorShape: Qt.IBeamCursor }
                Item {
                    width: 16; height: 16
                    anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                    Image { id: famSearchIcon; source: "qrc:/icons/svg/search.svg"; sourceSize: Qt.size(16, 16); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                    MultiEffect { anchors.fill: parent; source: famSearchIcon; colorizationColor: searchField.activeFocus ? "#059669" : "#7e968a"; colorization: 1.0; Behavior on colorizationColor { ColorAnimation { duration: 120 } } }
                }
                TextField {
                    id: searchField
                    anchors.left: parent.left; anchors.leftMargin: 32
                    anchors.right: parent.right; anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    placeholderText: "Search by family #, house name, phone..."
                    placeholderTextColor: "#7e968a"
                    font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary
                    background: Item {} verticalAlignment: Text.AlignVCenter
                    onTextEdited: searchDebounce.restart()
                }
                Timer {
                    id: searchDebounce
                    interval: 300
                    onTriggered: familyModel.searchTerm = searchField.text
                }
            }

            // Status filter
            AppComboBox {
                model: ["All Status", "Active", "Inactive", "Archived"]
                implicitHeight: 38
                onActivated: function(index) {
                    familyModel.statusFilter = index === 0 ? "" : model[index]
                }
            }

            // Ward filter
            AppComboBox {
                id: wardCombo
                implicitHeight: 38
                model: {
                    var w = ["All Wards"]
                    if (typeof familyController !== "undefined") {
                        var wards = familyController.wards()
                        for (var i = 0; i < wards.length; i++) w.push(wards[i])
                    }
                    return w
                }
                onActivated: function(index) {
                    familyModel.wardFilter = index === 0 ? "" : model[index]
                }
            }

            // Count label
            Text {
                text: "Showing " + familyModel.rowCount + " of " + familyModel.totalCount
                font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // ===== Data table =====
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                // ===== Table header =====
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 40; color: Theme.surfaceHover
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    Row {
                        x: 16; width: parent.width - 32; spacing: 0
                        Text { text: "FAMILY #"; width: 110; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "HOUSE NAME"; width: 160; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "HEAD"; width: 140; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "WARD"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "MEMBERS"; width: 70; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "PHONE"; width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "STATUS"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Item { width: parent.width - 110 - 160 - 140 - 80 - 70 - 120 - 100 - 100; height: 40 }
                        Text { text: "ACTIONS"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                    }
                }

                // ===== Table rows =====
                ListView {
                    id: table
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 0
                    model: familyModel

                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                        Row {
                            x: 16; width: parent.width - 32; spacing: 0
                            Text { text: model.familyNumber; width: 110; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: model.houseName; width: 160; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.Normal; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: model.headName || "—"; width: 140; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.Normal; color: Theme.textSecondary; elide: Text.ElideRight }
                            Text { text: model.ward || "—"; width: 80; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.Normal; color: Theme.textSecondary }
                            Text { text: model.memberCount; width: 70; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.textPrimary }
                            Text { text: model.phone; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.Normal; color: Theme.textSecondary }
                            Item { width: 100; height: 44; StatusBadge { anchors.centerIn: parent; text: model.status; variant: model.status.toLowerCase() } }
                            Item { width: parent.width - 110 - 160 - 140 - 80 - 70 - 120 - 100 - 100; height: 44 }
                            Row {
                                width: 100; height: 44; spacing: 4
                                layoutDirection: Qt.RightToLeft
                                // Delete — momentary action, red only on hover
                                TableActionButton {
                                    iconSource: "qrc:/icons/svg/trash.svg"
                                    variantColor: "#e11d48"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: {
                                        deleteDialog._familyId = model.id
                                        deleteDialog.warningText = "Family \"" + model.houseName + "\" (" + model.familyNumber + ") will be permanently deleted."
                                        deleteDialog.visible = true
                                    }
                                }
                                // Edit — momentary action, emerald only on hover
                                TableActionButton {
                                    iconSource: "qrc:/icons/svg/edit.svg"
                                    variantColor: "#059669"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: {
                                        editDialog.familyId = model.id
                                        editDialog.readOnly = false
                                        editDialog.show()
                                    }
                                }
                                // View — momentary action, blue only on hover
                                TableActionButton {
                                    iconSource: "qrc:/icons/svg/search.svg"
                                    variantColor: "#0284c7"
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: {
                                        editDialog.familyId = model.id
                                        editDialog.readOnly = true
                                        editDialog.show()
                                    }
                                }
                            }
                        }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                    }
                }

                // ===== Empty state =====
                Item {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    visible: familyModel.rowCount === 0
                    Column {
                        anchors.centerIn: parent; spacing: 12
                        Rectangle {
                            width: 56; height: 56; radius: 28; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border
                            anchors.horizontalCenter: parent.horizontalCenter
                            Item {
                                width: 28; height: 28; anchors.centerIn: parent
                                Image { id: emptyIcon; source: "qrc:/icons/svg/families.svg"; sourceSize: Qt.size(28, 28); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                                MultiEffect { anchors.fill: parent; source: emptyIcon; colorizationColor: "#b2cfbd"; colorization: 1.0 }
                            }
                        }
                        Text { text: "No families found"; font.family: Theme.activeFontFamily; font.pixelSize: 14; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Click 'Add Family' to create your first family record"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Normal; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }

                // ===== Pagination =====
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 44; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                        Text { text: "Page " + familyModel.currentPage + " of " + familyModel.totalPages; font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary; Layout.alignment: Qt.AlignVCenter }
                        Item { Layout.fillWidth: true }
                        Rectangle { width: 28; height: 28; radius: 6; color: prevMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: prevMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: familyModel.currentPage > 1 ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: prevIcon; source: "qrc:/icons/svg/chevron-left.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: prevIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: prevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (familyModel.currentPage > 1) familyModel.currentPage = familyModel.currentPage - 1 }
                        }
                        Rectangle { width: 28; height: 28; radius: 6; color: nextMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: nextMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: familyModel.currentPage < familyModel.totalPages ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: nextIcon; source: "qrc:/icons/svg/chevron-right.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: nextIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: nextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (familyModel.currentPage < familyModel.totalPages) familyModel.currentPage = familyModel.currentPage + 1 }
                        }
                    }
                }
            }
        }
    }
}
