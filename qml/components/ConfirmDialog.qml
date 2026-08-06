import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

// ============================================================================
// ConfirmDialog — Compact delete confirmation dialog
//
// Uses ModalDialog for the modal shell (backdrop + card + shadow + ESC).
// Structure: warning icon + message + warning text, then Cancel + Delete.
// ============================================================================

ModalDialog {
    id: dialog
    modalWidth: 440
    modalHeight: 200
    closeOnBackdrop: true
    closeOnEscape: true

    property string message: "Are you sure?"
    property string warningText: "This action cannot be undone."

    signal accepted()
    signal rejected()

    content: Component {
        Rectangle {
            anchors.fill: parent
            color: "#ffffff"
            radius: 12
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                // ===== Warning icon + message =====
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    // Warning icon circle
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: "#fddfe5"
                        border.width: 1
                        border.color: "#e11d48"
                        Layout.alignment: Qt.AlignTop

                        Text {
                            anchors.centerIn: parent
                            text: "!"
                            font.family: "Poppins"
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            color: "#e11d48"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: dialog.message
                            font.family: "Poppins"
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: "#12241b"
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        Text {
                            text: dialog.warningText
                            font.family: "Poppins"
                            font.pixelSize: 12
                            font.weight: Font.Normal
                            color: "#7e968a"
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                    }
                }

                // ===== Spacer =====
                Item { Layout.fillHeight: true; Layout.fillWidth: true }

                // ===== Buttons =====
                Row {
                    Layout.fillWidth: true
                    spacing: 10
                    layoutDirection: Qt.RightToLeft

                    // Delete button
                    Rectangle {
                        width: 90; height: 36; radius: 9
                        color: deleteMA.containsMouse ? "#be123c" : "#e11d48"
                        border.width: 0
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Delete"
                            font.family: "Poppins"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: "#ffffff"
                        }

                        MouseArea {
                            id: deleteMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                dialog.accepted()
                                dialog.visible = false
                            }
                        }
                    }

                    // Cancel button
                    Rectangle {
                        width: 90; height: 36; radius: 9
                        color: cancelMA.containsMouse ? "#f2faf4" : "#ffffff"
                        border.width: 1
                        border.color: cancelMA.containsMouse ? "#b2cfbd" : "#d2e5d8"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.family: "Poppins"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: "#12241b"
                        }

                        MouseArea {
                            id: cancelMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
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
}
