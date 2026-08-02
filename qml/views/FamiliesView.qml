import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../dialogs"

// ============================================================================
// FamiliesView - functional family management with Add/Edit/Delete
// ============================================================================
Item {
    id: root

    property var services: typeof Services !== "undefined" ? Services : null

    // Data model (populated from C++ backend)
    ListModel { id: familyModel }

    Component.onCompleted: refresh()

    function refresh() {
        familyModel.clear()
        if (!services) return
        var families = services.searchFamilies(searchField.text, 1, 50, statusFilter.currentText === "All" ? "" : statusFilter.currentText, wardFilter.currentText === "All Wards" ? "" : wardFilter.currentText)
        for (var i = 0; i < families.length; i++) {
            familyModel.append(families[i])
        }
        footerText.text = "Showing 1-" + familyModel.count + " of " + (services.totalFamilies()) + " families"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 14

        // Header
        RowLayout {
            Layout.fillWidth: true; spacing: 12

            ColumnLayout {
                spacing: 2
                Text {
                    text: "Families"
                    font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold
                    color: Theme.text
                }
                Text {
                    text: "Manage all registered families in the mahallu"
                    font.family: Theme.fontPrimary; font.pixelSize: 11
                    color: Theme.muted
                }
            }
            Item { Layout.fillWidth: true }

            // Search
            Rectangle {
                radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout {
                    anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search families..."
                        font.family: Theme.fontPrimary; font.pixelSize: 11
                        background: Item {}
                        color: Theme.text
                        onTextEdited: refreshTimer.restart()
                    }
                }
            }

            Timer { id: refreshTimer; interval: 300; onTriggered: refresh() }

            // Status filter
            ComboBox {
                id: statusFilter
                implicitHeight: 34; Layout.preferredWidth: 110
                model: ["All", "Active", "Inactive", "Archived"]
                font.family: Theme.fontPrimary; font.pixelSize: 11
                onCurrentIndexChanged: refresh()
            }

            // Ward filter
            ComboBox {
                id: wardFilter
                implicitHeight: 34; Layout.preferredWidth: 120
                model: ["All Wards", "Ward 1", "Ward 2", "Ward 3", "Ward 4"]
                font.family: Theme.fontPrimary; font.pixelSize: 11
                onCurrentIndexChanged: refresh()
            }

            // Add button (functional!)
            IconBtn {
                icon: "plus"
                label: "Add Family"
                primary: true
                onClicked: openAddDialog()
            }
        }

        // Table
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 38; color: Theme.panelMuted
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                        Text { text: "FAMILY #"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "HOUSE NAME"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "WARD"; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "PHONE"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "MEMBERS"; Layout.preferredWidth: 70; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "STATUS"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "ACTIONS"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    }
                }

                // Empty state
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    color: Theme.panel
                    visible: familyModel.count === 0
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 8
                        Text { text: "🏠"; font.pixelSize: 36; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "No families found"; font.family: Theme.fontDisplay; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Click 'Add Family' to create your first family record"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                // Data rows
                ListView {
                    id: table
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 0
                    model: familyModel
                    visible: familyModel.count > 0
                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: rowMA.containsMouse ? Theme.panelMuted : (index % 2 === 0 ? Theme.panel : Theme.panelMuted)
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.familyNumber; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 1
                                Text { text: model.houseName; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; Layout.fillWidth: true; elide: Text.ElideRight }
                                Text { text: model.headName; font.family: Theme.fontPrimary; font.pixelSize: 9; color: Theme.muted }
                            }
                            Text { text: model.ward; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            Text { text: model.phone; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.memberCount; Layout.preferredWidth: 70; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; horizontalAlignment: Text.AlignHCenter }
                            // Status pill
                            Item {
                                Layout.preferredWidth: 110; Layout.preferredHeight: 26
                                property var p: Theme.pillFor(model.status)
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 78; height: 22; radius: 11
                                    color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st }
                                }
                            }
                            // Actions (functional!)
                            RowLayout {
                                Layout.preferredWidth: 120; spacing: 4
                                IconBtn { icon: "edit"; compact: true; onClicked: openEditDialog(model.id) }
                                IconBtn { icon: "trash"; compact: true; bgColor: Theme.tints.rd.sb; bgColorHover: Theme.tints.rd.sc; onClicked: openDeleteDialog(model.id, model.houseName) }
                            }
                        }

                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                    }
                }
            }
        }

        // Footer
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Text {
                id: footerText
                text: "Loading..."
                font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted
            }
            Item { Layout.fillWidth: true }
            IconBtn { icon: "refresh"; compact: true; onClicked: refresh() }
        }
    }

    // ===== Dialogs =====
    function openAddDialog() {
        var dlg = Qt.createQmlObject('import QtQuick\nimport QtQuick.Controls\nimport "../dialogs"\nFamilyEditDialog { services: root.services; onSaved: function(id) { root.refresh() } }', root, "FamilyAddDialog")
        dlg.show()
    }

    function openEditDialog(id) {
        var dlg = Qt.createQmlObject('import QtQuick\nimport QtQuick.Controls\nimport "../dialogs"\nFamilyEditDialog { familyId: ' + id + '; services: root.services; onSaved: function(id) { root.refresh() } }', root, "FamilyEditDialog")
        dlg.show()
    }

    function openDeleteDialog(id, name) {
        var dlg = Qt.createQmlObject('import QtQuick\nimport QtQuick.Controls\nimport "../dialogs"\nConfirmDialog { message: "Delete family?"; warningText: "Family \\"' + name + '\\" will be permanently deleted. This action cannot be undone."; acceptLabel: "Yes, Delete" }', root, "ConfirmDelete")
        dlg.accepted.connect(function() {
            root.services.deleteFamily(id)
            root.refresh()
        })
        dlg.show()
    }
}
