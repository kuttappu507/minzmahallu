import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// Marriage register page — uses MarriageController + MarriageListModel
Item {
    id: page

    Component.onCompleted: marriageModel.refresh()

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Marriage Record?"
        warningText: "This marriage record will be permanently deleted."
        property int _id: 0
        onAccepted: {
            if (_id > 0) {
                var r = marriageController.remove(_id)
                toast.show(r.success ? "Record deleted" : (r.error || "Delete failed"), r.success ? "#059669" : "#e11d48")
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
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: "Poppins"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#ffffff" }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg, color) { message = msg; bgColor = color || "#059669"; visible_ = true; toastTimer.restart() }
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Column { Layout.fillWidth: true; spacing: 2
                Text { text: "Marriage Register"; font.family: "Poppins"; font.pixelSize: 21; font.weight: Font.DemiBold; color: "#12241b" }
                Text { text: "Nikah records and registrations"; font.family: "Poppins"; font.pixelSize: 12; color: "#4f6b5c" } }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 10
            Rectangle { Layout.fillWidth: true; Layout.minimumWidth: 180; height: 38; radius: 9; color: "#f2faf4"; border.width: 1; border.color: searchField.activeFocus ? "#059669" : (searchHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                HoverHandler { id: searchHover; cursorShape: Qt.IBeamCursor }
                Item { width: 16; height: 16; anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                    Image { id: searchIcon; source: "qrc:/icons/svg/search.svg"; sourceSize: Qt.size(16, 16); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                    MultiEffect { anchors.fill: parent; source: searchIcon; colorizationColor: searchField.activeFocus ? "#059669" : "#7e968a"; colorization: 1.0 } }
                TextField { id: searchField; anchors.left: parent.left; anchors.leftMargin: 32; anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; placeholderText: "Search by bride, groom, number..."; placeholderTextColor: "#7e968a"; font.family: "Poppins"; font.pixelSize: 13; color: "#12241b"; background: Item {}; verticalAlignment: Text.AlignVCenter; onTextEdited: searchDebounce.restart() }
                Timer { id: searchDebounce; interval: 300; onTriggered: marriageModel.searchTerm = searchField.text } }
            Text { text: "Showing " + marriageModel.rowCount + " of " + marriageModel.totalCount; font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a"; Layout.alignment: Qt.AlignVCenter }
        }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: "#ffffff"; border.width: 1; border.color: "#d2e5d8"
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 40; color: "#f2faf4"
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#d2e5d8" }
                    Row { x: 16; width: parent.width - 32; spacing: 0
                        Text { text: "NUMBER"; width: 140; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "BRIDE"; width: 180; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "GROOM"; width: 180; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "NIKAH DATE"; width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "PLACE"; width: 150; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Text { text: "IMAM"; width: 150; height: 40; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" }
                        Item { width: parent.width - 140 - 180 - 180 - 120 - 150 - 150 - 80; height: 40 }
                        Text { text: "ACTIONS"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.Medium; color: "#7e968a" } } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: marriageModel
                    delegate: Rectangle { width: table.width; height: 44; color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#eef8f1" }
                        Row { x: 16; width: parent.width - 32; spacing: 0
                            Text { text: model.marriageNumber; width: 140; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#12241b"; elide: Text.ElideRight }
                            Text { text: model.brideName; width: 180; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; color: "#12241b"; elide: Text.ElideRight }
                            Text { text: model.groomName; width: 180; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; color: "#12241b"; elide: Text.ElideRight }
                            Text { text: model.nikahDate || "—"; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; color: "#4f6b5c" }
                            Text { text: model.place || "—"; width: 150; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; color: "#4f6b5c"; elide: Text.ElideRight }
                            Text { text: model.imamName || "—"; width: 150; height: 44; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; color: "#4f6b5c"; elide: Text.ElideRight }
                            Item { width: parent.width - 140 - 180 - 180 - 120 - 150 - 150 - 80; height: 44 }
                            Row { width: 80; height: 44; spacing: 4; layoutDirection: Qt.RightToLeft
                                TableActionButton { iconSource: "qrc:/icons/svg/trash.svg"; variantColor: "#e11d48"; anchors.verticalCenter: parent.verticalCenter; onClicked: { deleteDialog._id = model.id; deleteDialog.warningText = "Marriage record " + model.marriageNumber + " will be permanently deleted."; deleteDialog.visible = true } }
                                TableActionButton { iconSource: "qrc:/icons/svg/search.svg"; variantColor: "#0284c7"; anchors.verticalCenter: parent.verticalCenter; onClicked: toast.show("View dialog - coming soon", "#7e968a") } } }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton } } }
                Item { Layout.fillWidth: true; Layout.fillHeight: true; visible: marriageModel.rowCount === 0
                    Column { anchors.centerIn: parent; spacing: 8
                        Text { text: "No marriage records found"; font.family: "Poppins"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#12241b"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Records will appear here once added"; font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a"; anchors.horizontalCenter: parent.horizontalCenter } } }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 44; color: "#f2faf4"
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#d2e5d8" }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 8
                        Text { text: "Page " + marriageModel.currentPage + " of " + marriageModel.totalPages; font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a"; Layout.alignment: Qt.AlignVCenter }
                        Item { Layout.fillWidth: true }
                        Rectangle { width: 28; height: 28; radius: 6; color: prevMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: prevMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: marriageModel.currentPage > 1 ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: prevIcon; source: "qrc:/icons/svg/chevron-left.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: prevIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: prevMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (marriageModel.currentPage > 1) marriageModel.currentPage = marriageModel.currentPage - 1 } }
                        Rectangle { width: 28; height: 28; radius: 6; color: nextMA.containsMouse ? "#ffffff" : "transparent"; border.width: 1; border.color: nextMA.containsMouse ? "#b2cfbd" : "#d2e5d8"; Layout.alignment: Qt.AlignVCenter; opacity: marriageModel.currentPage < marriageModel.totalPages ? 1 : 0.4
                            Item { width: 14; height: 14; anchors.centerIn: parent; Image { id: nextIcon; source: "qrc:/icons/svg/chevron-right.svg"; sourceSize: Qt.size(14, 14); anchors.fill: parent; fillMode: Image.Pad; visible: false } MultiEffect { anchors.fill: parent; source: nextIcon; colorizationColor: "#4f6b5c"; colorization: 1.0 } }
                            MouseArea { id: nextMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (marriageModel.currentPage < marriageModel.totalPages) marriageModel.currentPage = marriageModel.currentPage + 1 } } } }
            }
        }
    }
}
