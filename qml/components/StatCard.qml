import QtQuick
import QtQuick.Layouts
import Theme

Rectangle {
    id: card
    property string tintName: "em"
    property string iconText: "▦"
    property string valueText: "0"
    property string labelText: "Label"
    property string deltaText: ""
    property bool deltaUp: true

    readonly property var t: Theme.tint(tintName)

    radius: 10
    color: t.sb
    border.width: 1.5
    border.color: t.sc
    implicitHeight: 120

    // Decorative circle (bottom-right, semi-transparent)
    Rectangle {
        width: 56; height: 56; radius: 28
        anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.rightMargin: -14; anchors.bottomMargin: -14
        color: t.sc
        opacity: 0.14
    }

    // Hover lift effect
    Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: card.y = -4
        onExited: card.y = 0
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 6

        // Top row: icon + delta
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Solid icon square
            Rectangle {
                width: 37; height: 37; radius: 9
                color: t.sc
                Text {
                    anchors.centerIn: parent
                    text: iconText
                    font.pixelSize: 18
                    color: "#ffffff"
                }
            }
            Item { Layout.fillWidth: true }
            // Delta badge
            Rectangle {
                visible: deltaText !== ""
                radius: 99
                color: Theme.panel
                border.width: 1.5; border.color: t.sc
                implicitHeight: 22
                Text {
                    anchors.centerIn: parent
                    anchors.margins: 8
                    text: (deltaUp ? "▲ " : "▼ ") + deltaText
                    font.family: Theme.fontPrimary
                    font.pixelSize: 9
                    font.weight: Font.Black
                    color: t.st
                }
            }
        }

        // Value
        Text {
            text: valueText
            font.family: Theme.fontDisplay
            font.pixelSize: 24
            font.weight: Font.Bold
            color: t.st
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        // Label
        Text {
            text: labelText
            font.family: Theme.fontPrimary
            font.pixelSize: 10
            font.weight: Font.Black
            color: t.st
            opacity: 0.75
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }
}
