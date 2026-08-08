import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../theme"

// Momentary action button for table rows. Theme-aware and never checkable.
Item {
    id: root
    property string iconSource: ""
    property color variantColor: Theme.primary
    property int iconSize: 14
    property int buttonSize: 28
    signal clicked()

    width: buttonSize
    height: buttonSize
    opacity: enabled ? 1.0 : 0.4

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.radiusMd
        border.width: 1
        color: ma.pressed ? Qt.darker(root.variantColor, 1.15) :
               ma.containsMouse ? Qt.rgba(root.variantColor.r, root.variantColor.g, root.variantColor.b, 0.10) :
               "transparent"
        border.color: ma.pressed ? root.variantColor : ma.containsMouse ? root.variantColor : Theme.border
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }

    Item {
        width: root.iconSize
        height: root.iconSize
        anchors.centerIn: parent
        Image {
            id: btnIcon
            source: root.iconSource
            sourceSize: Qt.size(root.iconSize, root.iconSize)
            anchors.fill: parent
            fillMode: Image.Pad
            visible: false
        }
        MultiEffect {
            anchors.fill: parent
            source: btnIcon
            colorizationColor: ma.pressed || ma.containsMouse ? root.variantColor : Theme.textTertiary
            colorization: 1.0
            Behavior on colorizationColor { ColorAnimation { duration: Theme.animFast } }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
