import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../dialogs"

// ============================================================================
// DonationsView - functional donation management
// ============================================================================
Item {
    id: root
    property var services: typeof Services !== "undefined" ? Services : null

    ListModel { id: donationModel }

    Component.onCompleted: refresh()

    function refresh() {
        donationModel.clear()
        if (!services) return
        var dons = services.searchDonations(searchField.text, 1, 50)
        for (var i = 0; i < dons.length; i++) {
            donationModel.append(dons[i])
        }
        footerText.text = "Showing 1-" + donationModel.count + " donations"
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14

        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Donations"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Track all donations by category"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { id: searchField; Layout.fillWidth: true; placeholderText: "Search donations..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text; onTextEdited: refreshTimer.restart() }
                }
            }
            Timer { id: refreshTimer; interval: 300; onTriggered: refresh() }
            IconBtn { icon: "plus"; label: "Add Donation"; primary: true; onClicked: openAddDialog() }
        }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 38; color: Theme.panelMuted
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                        Text { text: "RECEIPT #"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "DONOR"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "CATEGORY"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "AMOUNT"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignRight }
                        Text { text: "DATE"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "METHOD"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "ACTIONS"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    } }
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true; color: Theme.panel
                    visible: donationModel.count === 0
                    ColumnLayout { anchors.centerIn: parent; spacing: 8
                        Text { text: "💰"; font.pixelSize: 36; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "No donations yet"; font.family: Theme.fontDisplay; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Click 'Add Donation' to record your first donation"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted; Layout.alignment: Qt.AlignHCenter }
                    }
                }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: donationModel; visible: donationModel.count > 0
                    delegate: Rectangle {
                        width: table.width; height: 42
                        color: rowMA.containsMouse ? Theme.panelMuted : (index % 2 === 0 ? Theme.panel : Theme.panelMuted)
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.receiptNumber; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            Text { text: model.donorName; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; elide: Text.ElideRight }
                            Text { text: model.categoryName || "General"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            Text { text: "Rs." + Number(model.amount).toLocaleString(); Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.tints.em.st; horizontalAlignment: Text.AlignRight }
                            Text { text: model.donationDate; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.paymentMethod; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            RowLayout { Layout.preferredWidth: 100; spacing: 4
                                IconBtn { icon: "edit"; compact: true; onClicked: openEditDialog(model.id) }
                                IconBtn { icon: "trash"; compact: true; onClicked: openDeleteDialog(model.id, model.receiptNumber) }
                            }
                        }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                    } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { id: footerText; text: "Loading..."; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
            Item { Layout.fillWidth: true }
            IconBtn { icon: "refresh"; compact: true; onClicked: refresh() }
        }
    }

    function openAddDialog() {
        var dlg = Qt.createQmlObject('import QtQuick\nimport QtQuick.Controls\nimport "../dialogs"\nDonationEditDialog { services: root.services; onSaved: function(id) { root.refresh() } }', root, "DonationAddDialog")
        dlg.show()
    }
    function openEditDialog(id) {
        // For edit, we'd need to load the existing donation — for now, use Add dialog
        var dlg = Qt.createQmlObject('import QtQuick\nimport QtQuick.Controls\nimport "../dialogs"\nDonationEditDialog { donationId: ' + id + '; services: root.services; onSaved: function(id) { root.refresh() } }', root, "DonationEditDialog")
        dlg.show()
    }
    function openDeleteDialog(id, receipt) {
        var dlg = Qt.createQmlObject('import QtQuick\nimport QtQuick.Controls\nimport "../dialogs"\nConfirmDialog { message: "Delete donation?"; warningText: "Receipt \\"' + receipt + '\\" will be permanently deleted."; acceptLabel: "Yes, Delete" }', root, "ConfirmDelete")
        dlg.accepted.connect(function() { root.services.deleteDonation(id); root.refresh() })
        dlg.show()
    }
}
