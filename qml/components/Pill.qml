import QtQuick

Rectangle {
    property string status: "Active"
    readonly property var p: Theme.pillFor(status)

    radius: 99
    color: p.bg
    border.width: 1.5
    border.color: p.border
    implicitHeight: 22
    implicitWidth: pillText.implicitWidth + 20

    Text {
        id: pillText
        anchors.centerIn: parent
        text: parent.status
        font.family: Theme.fontPrimary
        font.pixelSize: 10
        font.weight: Font.Black
        color: p.fg
    }

    // Pulsing dot for overdue/revoked
    Rectangle {
        visible: parent.status === "Overdue" || parent.status === "Revoked"
        width: 6; height: 6; radius: 3
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
        color: p.fg
        SequentialAnimation on opacity {
            running: visible
            loops: Animation.Infinite
            NumberAnimation { to: 0.35; duration: 700 }
            NumberAnimation { to: 1.0; duration: 700 }
        }
    }
}
