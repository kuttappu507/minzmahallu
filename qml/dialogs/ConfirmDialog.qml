import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ============================================================================
// ConfirmDialog - Confirmation modal for delete/archive/restore actions
// ============================================================================
Dialog {
    id: root
    title: "Confirm"
    width: 420
    height: 220
    acceptLabel: "Yes, Delete"
    rejectLabel: "Cancel"

    property string message: "Are you sure?"
    property string warningText: "This action cannot be undone."

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 20
        Layout.rightMargin: 20
        Layout.topMargin: 20
        Layout.bottomMargin: 20
        spacing: 10

        RowLayout {
            Layout.fillWidth: true; spacing: 12

            Rectangle {
                width: 40; height: 40; radius: 20
                color: Theme.tints.rd.sb
                border.width: 1.5; border.color: Theme.tints.rd.sc
                Text { anchors.centerIn: parent; text: "!"; color: Theme.tints.rd.st; font.pixelSize: 22; font.weight: Font.Bold }
            }

            ColumnLayout {
                Layout.fillWidth: true; spacing: 2
                Text {
                    text: root.message
                    font.family: Theme.fontDisplay
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: Theme.text
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
                Text {
                    text: root.warningText
                    font.family: Theme.fontPrimary
                    font.pixelSize: 11
                    color: Theme.muted
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
