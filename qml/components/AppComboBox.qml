import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../theme"

FocusScope {
    id: root
    property string label: ""
    property var model: []
    property int currentIndex: 0
    property string currentText: model[currentIndex] || ""
    signal activated(int index)

    implicitHeight: label !== "" ? labelItem.implicitHeight + 4 + 38 : 38
    implicitWidth: 180

    Column {
        anchors.fill: parent
        spacing: 4
        Text {
            id: labelItem
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm - 1
            font.weight: Theme.fontWeightMedium
            color: Theme.textTertiary
            visible: root.label !== ""
            height: root.label !== "" ? implicitHeight : 0
        }
        ComboBox {
            id: combo
            width: parent.width
            implicitHeight: 38
            model: root.model
            currentIndex: root.currentIndex
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd
            padding: 0
            indicator: Item { width: 0; height: 0; visible: false }
            onActivated: function(index) {
                root.currentIndex = index
                root.activated(index)
            }
            contentItem: Item {
                width: parent.width
                height: parent.height
                Text {
                    text: combo.displayText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: combo.enabled ? Theme.textPrimary : Theme.textDisabled
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 36
                    elide: Text.ElideRight
                }
                Item {
                    width: 16; height: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: chevron
                        source: "qrc:/icons/svg/chevron-down.svg"
                        sourceSize: Qt.size(16, 16)
                        anchors.fill: parent
                        fillMode: Image.Pad
                        visible: false
                    }
                    MultiEffect {
                        anchors.fill: parent
                        source: chevron
                        colorizationColor: combo.popup.visible ? Theme.primary : Theme.textTertiary
                        colorization: 1.0
                        rotation: combo.popup.visible ? 180 : 0
                        Behavior on rotation { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                    }
                }
            }
            background: Rectangle {
                radius: Theme.radiusXl
                color: Theme.surfaceSubtle
                border.width: 1
                border.color: combo.popup.visible || combo.activeFocus ? Theme.borderFocused : combo.hovered ? Theme.borderHover : Theme.border
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
            }
            popup: Popup {
                y: combo.height + 4
                width: combo.width
                implicitHeight: Math.min(listView.contentHeight + 8, 280)
                padding: 4
                background: Rectangle {
                    color: Theme.surfaceRaised
                    border.width: 1
                    border.color: Theme.border
                    radius: Theme.radiusXl
                }
                contentItem: ListView {
                    id: listView
                    clip: true
                    implicitHeight: contentHeight
                    model: combo.popup.visible ? combo.delegateModel : null
                    currentIndex: combo.highlightedIndex
                    spacing: 2
                }
            }
            delegate: ItemDelegate {
                width: combo.width - 8
                implicitHeight: 34
                padding: 0
                contentItem: Text {
                    text: modelData
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: highlighted ? Theme.primary : Theme.textPrimary
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                }
                background: Rectangle {
                    color: highlighted ? Theme.primarySubtle : "transparent"
                    radius: Theme.radiusSm
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
            }
        }
    }
}
