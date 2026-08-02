import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ============================================================================
// IconBtn - Reusable button with SVG icon + label + hover animation
// ============================================================================
Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property color bgColor: Theme.panel
    property color bgColorHover: Theme.panelMuted
    property color fgColor: Theme.text
    property bool compact: false
    property bool primary: false
    property int iconSize: 16

    signal clicked()

    implicitHeight: 34
    implicitWidth: compact ? 34 : (label ? labelItem.implicitWidth + iconItem.width + 28 : 34)
    radius: 8

    color: primary ? (mouseArea.containsMouse ? "#04543c" : Theme.sidebar)
                   : (mouseArea.containsMouse ? bgColorHover : bgColor)
    border.width: primary ? 0 : 1.5
    border.color: primary ? "transparent" : Theme.border

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 100 } }

    scale: mouseArea.containsMouse ? 1.04 : 1.0

    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Image {
            id: iconItem
            source: root.icon ? "qrc:/resources/icons/svg/" + root.icon + ".svg" : ""
            visible: root.icon !== ""
            sourceSize.width: root.iconSize
            sourceSize.height: root.iconSize
            Layout.alignment: Qt.AlignVCenter
            fillMode: Image.Pad
        }

        Text {
            id: labelItem
            text: root.label
            visible: !root.compact && root.label !== ""
            font.family: Theme.fontPrimary
            font.pixelSize: 11
            font.weight: Font.Bold
            color: root.primary ? "#ffffff" : root.fgColor
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
