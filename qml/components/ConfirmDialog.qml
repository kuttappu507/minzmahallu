import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

ModalDialog {
    id: dialog
    modalWidth: 440
    modalHeight: 220
    closeOnBackdrop: true
    closeOnEscape: true

    property string message: "Are you sure?"
    property string warningText: "This action cannot be undone."

    signal accepted()
    signal rejected()

    content: Component {
        Rectangle {
            anchors.fill: parent
            color: Theme.surface
            radius: Theme.radius2xl
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: Theme.dangerSubtle
                        border.width: 1
                        border.color: Theme.danger
                        Layout.alignment: Qt.AlignVCenter
                        Text {
                            anchors.centerIn: parent
                            text: "!"
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                            font.weight: Theme.fontWeightBold
                            color: Theme.danger
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: dialog.message
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeLg
                            font.weight: Theme.fontWeightSemiBold
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        Text {
                            text: dialog.warningText
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.textSecondary
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                    }
                }

                Item { Layout.fillHeight: true; Layout.fillWidth: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    layoutDirection: Qt.RightToLeft

                    AppButton {
                        text: "Delete"
                        variant: "danger"
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: {
                            dialog.accepted()
                            dialog.visible = false
                        }
                    }
                    AppButton {
                        text: "Cancel"
                        variant: "secondary"
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: {
                            dialog.rejected()
                            dialog.visible = false
                        }
                    }
                }
            }
        }
    }
}
