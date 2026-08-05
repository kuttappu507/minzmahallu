import QtQuick
import QtQuick.Controls

// ============================================================================
// ConfirmDialog — Delete confirmation matching DashboardV3 design
// ============================================================================

ApplicationWindow {
    id: dialog
    visible: false
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"

    property string message: "Are you sure?"
    property string warningText: "This action cannot be undone."

    signal accepted()
    signal rejected()

    width: 400
    height: 200
    minimumWidth: 400
    minimumHeight: 200

    onVisibleChanged: {
        if (visible) {
            var parentWin = dialog.transientParent
            if (parentWin) {
                dialog.x = parentWin.x + (parentWin.width - dialog.width) / 2
                dialog.y = parentWin.y + (parentWin.height - dialog.height) / 2
            }
        }
    }

    // White card fills the window. radius:12 + clip:true gives clean rounded
    // corners. No dark scrim — modality (Qt.ApplicationModal) handles blocking.
    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        radius: 12
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Row {
                spacing: 14

                Rectangle {
                    width: 40; height: 40; radius: 20
                    color: "#fddfe5"
                    border.width: 1
                    border.color: "#e11d48"

                    Text {
                        anchors.centerIn: parent
                        text: "!"
                        font.family: "Poppins"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: "#e11d48"
                    }
                }

                Column {
                    spacing: 4

                    Text {
                        text: dialog.message
                        font.family: "Poppins"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: "#12241b"
                    }
                    Text {
                        text: dialog.warningText
                        font.family: "Poppins"
                        font.pixelSize: 12
                        font.weight: Font.Normal
                        color: "#7e968a"
                        width: 280
                        wrapMode: Text.Wrap
                    }
                }
            }

            Item { height: 1; width: 1 }

            Row {
                spacing: 10
                anchors.right: parent.right

                Rectangle {
                    width: 90; height: 36; radius: 9
                    color: cancelMA.containsMouse ? "#f2faf4" : "#ffffff"
                    border.width: 1
                    border.color: "#d2e5d8"
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
                        onClicked: { dialog.rejected(); dialog.visible = false }
                    }
                }

                Rectangle {
                    width: 90; height: 36; radius: 9
                    color: deleteMA.containsMouse ? "#be123c" : "#e11d48"
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
                        onClicked: { dialog.accepted(); dialog.visible = false }
                    }
                }
            }
        }
    }
}
