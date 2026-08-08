import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import "../theme"

FocusScope {
    id: root
    property string label: ""
    property string placeholderText: ""
    property string iconName: ""
    property bool showError: false
    property string errorText: ""
    property alias text: input.text
    property alias echoMode: input.echoMode
    property alias readOnly: input.readOnly
    property alias validator: input.validator
    signal editingFinished()

    implicitHeight: label !== "" ? labelItem.implicitHeight + 4 + 38 : 38
    implicitWidth: 240

    Column {
        anchors.fill: parent
        spacing: 4
        Text {
            id: labelItem
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm - 1
            font.weight: Theme.fontWeightMedium
            color: root.showError ? Theme.coral : Theme.textTertiary
            visible: root.label !== ""
            height: root.label !== "" ? implicitHeight : 0
        }
        Rectangle {
            width: parent.width
            height: 38
            radius: Theme.radiusXl
            color: Theme.surfaceSubtle
            border.width: 1
            border.color: root.showError ? Theme.coral : input.activeFocus ? Theme.borderFocused : (hoverMA.containsMouse ? Theme.borderHover : Theme.border)
            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                radius: parent.radius + 2
                color: "transparent"
                border.width: 2
                border.color: Qt.rgba(5/255, 150/255, 105/255, 0.12)
                visible: input.activeFocus && !root.showError
            }
            Item {
                width: 16; height: 16
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                visible: root.iconName !== ""
                Image {
                    id: fieldIcon
                    source: root.iconName !== "" ? "qrc:/icons/svg/" + root.iconName + ".svg" : ""
                    sourceSize: Qt.size(16, 16)
                    anchors.fill: parent
                    fillMode: Image.Pad
                    visible: false
                }
                MultiEffect {
                    anchors.fill: parent
                    source: fieldIcon
                    colorizationColor: input.activeFocus ? Theme.primary : Theme.textTertiary
                    colorization: 1.0
                    Behavior on colorizationColor { ColorAnimation { duration: Theme.animFast } }
                }
            }
            TextField {
                id: input
                anchors.left: parent.left
                anchors.leftMargin: root.iconName !== "" ? 32 : 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: root.placeholderText
                placeholderTextColor: Theme.textTertiary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMd
                color: Theme.textPrimary
                background: Item {}
                verticalAlignment: Text.AlignVCenter
                cursorDelegate: Rectangle { visible: input.activeFocus; color: Theme.primary; width: 1 }
                onEditingFinished: root.editingFinished()
            }
            MouseArea {
                id: hoverMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.NoButton
            }
        }
        Text {
            text: root.errorText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            color: Theme.coral
            visible: root.showError && root.errorText !== ""
            height: visible ? implicitHeight : 0
        }
    }
}
