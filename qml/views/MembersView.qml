import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../dialogs"

// ============================================================================
// MembersView - functional member management
// ============================================================================
Item {
    id: root
    property var services: typeof Services !== "undefined" ? Services : null

    ListModel { id: memberModel }

    Component.onCompleted: refresh()

    function refresh() {
        memberModel.clear()
        if (!services) return
        var members = services.searchMembers(searchField.text, 1, 50, genderFilter.currentText === "All Gender" ? "" : genderFilter.currentText, statusFilter.currentText === "All Status" ? "" : statusFilter.currentText)
        for (var i = 0; i < members.length; i++) {
            memberModel.append(members[i])
        }
        footerText.text = "Showing 1-" + memberModel.count + " of " + (services.totalMembers()) + " members"
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14

        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Members"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "All registered members across families"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                implicitHeight: 34; Layout.preferredWidth: 260
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { id: searchField; Layout.fillWidth: true; placeholderText: "Search members..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text; onTextEdited: refreshTimer.restart() }
                }
            }
            Timer { id: refreshTimer; interval: 300; onTriggered: refresh() }
            ComboBox { id: genderFilter; implicitHeight: 34; Layout.preferredWidth: 110; model: ["All Gender", "Male", "Female"]; font.family: Theme.fontPrimary; font.pixelSize: 11; onCurrentIndexChanged: refresh() }
            ComboBox { id: statusFilter; implicitHeight: 34; Layout.preferredWidth: 120; model: ["All Status", "Active", "Inactive"]; font.family: Theme.fontPrimary; font.pixelSize: 11; onCurrentIndexChanged: refresh() }
            IconBtn { icon: "plus"; label: "Add Member"; primary: true; onClicked: openAddDialog() }
        }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 38; color: Theme.panelMuted
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                        Text { text: "MEMBER #"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "NAME"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "FAMILY"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "GENDER"; Layout.preferredWidth: 80; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "AGE"; Layout.preferredWidth: 60; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "PHONE"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "STATUS"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "ACTIONS"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    } }
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true; color: Theme.panel
                    visible: memberModel.count === 0
                    ColumnLayout { anchors.centerIn: parent; spacing: 8
                        Text { text: "👤"; font.pixelSize: 36; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "No members found"; font.family: Theme.fontDisplay; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Click 'Add Member' to create your first member record"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted; Layout.alignment: Qt.AlignHCenter }
                    }
                }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: memberModel; visible: memberModel.count > 0
                    delegate: Rectangle {
                        width: table.width; height: 44
                        color: rowMA.containsMouse ? Theme.panelMuted : (index % 2 === 0 ? Theme.panel : Theme.panelMuted)
                        Behavior on color { ColorAnimation { duration: 80 } }
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.memberCode || ("KH-M-" + String(model.id).padStart(4, '0')); Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            RowLayout { Layout.fillWidth: true; spacing: 8
                                Rectangle { width: 30; height: 30; radius: 15; color: model.gender === "Male" ? Theme.tints.bl.sb : Theme.tints.pk.sb; border.width: 1; border.color: model.gender === "Male" ? Theme.tints.bl.sc : Theme.tints.pk.sc
                                    Text { anchors.centerIn: parent; text: (model.name || "?").charAt(0).toUpperCase(); font.family: Theme.fontDisplay; font.pixelSize: 12; font.weight: Font.Bold; color: model.gender === "Male" ? Theme.tints.bl.st : Theme.tints.pk.st } }
                                Text { text: model.name; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; Layout.fillWidth: true; elide: Text.ElideRight }
                            }
                            Text { text: model.houseName || model.familyNumber; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.gender; Layout.preferredWidth: 80; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            Text { text: model.age; Layout.preferredWidth: 60; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; horizontalAlignment: Text.AlignHCenter }
                            Text { text: model.mobile; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Item { Layout.preferredWidth: 100; Layout.preferredHeight: 26
                                property var p: Theme.pillFor(model.status)
                                Rectangle { anchors.centerIn: parent; width: 70; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                            RowLayout { Layout.preferredWidth: 100; spacing: 4
                                IconBtn { icon: "edit"; compact: true; onClicked: openEditDialog(model.id) }
                                IconBtn { icon: "trash"; compact: true; bgColor: Theme.tints.rd.sb; onClicked: openDeleteDialog(model.id, model.name) }
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
        var dlg = Qt.createQmlObject('import QtQuick\nimport QtQuick.Controls\nimport "../dialogs"\nMemberEditDialog { services: root.services; onSaved: function(id) { root.refresh() } }', root, "MemberAddDialog")
        dlg.show()
    }
    function openEditDialog(id) {
        var dlg = Qt.createQmlObject('import QtQuick\nimport QtQuick.Controls\nimport "../dialogs"\nMemberEditDialog { memberId: ' + id + '; services: root.services; onSaved: function(id) { root.refresh() } }', root, "MemberEditDialog")
        dlg.show()
    }
    function openDeleteDialog(id, name) {
        var dlg = Qt.createQmlObject('import QtQuick\nimport QtQuick.Controls\nimport "../dialogs"\nConfirmDialog { message: "Delete member?"; warningText: "Member \\"' + name + '\\" will be permanently deleted."; acceptLabel: "Yes, Delete" }', root, "ConfirmDelete")
        dlg.accepted.connect(function() { root.services.deleteMember(id); root.refresh() })
        dlg.show()
    }
}
