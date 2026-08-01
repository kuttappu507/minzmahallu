import QtQuick
import QtQuick.Controls
import Theme

Button {
    id: control
    padding: 9
    spacing: 7
    font.family: Theme.fontPrimary
    font.pixelSize: 13
    font.weight: Font.Bold

    background: Rectangle {
        radius: 12
        color: control.down ? Qt.darker(control.palette.button, 1.1) :
               control.hovered ? Qt.darker(control.palette.button, 1.05) :
               control.palette.button
        // Hard-edge bottom shadow
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: -3
            height: 3
            radius: 12
            color: Qt.darker(parent.color, 1.3)
            visible: !control.down
        }
    }

    contentItem: RowLayout {
        spacing: control.spacing
        Text {
            text: control.text
            font: control.font
            color: control.palette.buttonText
            verticalAlignment: Text.AlignVCenter
        }
    }
}
