import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Effects

// ============================================================================
// AppComboBox — Styled dropdown matching DashboardV3
// CSS: same border/radius as search field. Height: 38px.
// ============================================================================

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
            font.family: Theme.activeFontFamily
            font.pixelSize: Theme.fontSizeXs
            font.weight: Font.Medium
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
            font.family: Theme.activeFontFamily
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
                    font.family: Theme.activeFontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: combo.enabled ? "#12241b" : "#b2cfbd"
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
                        colorizationColor: combo.popup.visible ? "#059669" : "#7e968a"
                        colorization: 1.0
                        rotation: combo.popup.visible ? 180 : 0
                        Behavior on rotation { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    }
                }
            }

            background: Rectangle {
                radius: 9
                color: Theme.surfaceHover
                border.width: 1
                border.color: combo.popup.visible || combo.activeFocus ? "#059669" :
                              combo.hovered ? "#b2cfbd" : "#d2e5d8"
                Behavior on border.color { ColorAnimation { duration: 120 } }
            }

            popup: Popup {
                y: combo.height + 4
                width: combo.width
                implicitHeight: Math.min(listView.contentHeight + 8, 280)
                padding: 4

                background: Rectangle {
                    color: Theme.surface
                    border.width: 1
                    border.color: Theme.border
                    radius: 9
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
                    font.family: Theme.activeFontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: highlighted ? "#059669" : "#12241b"
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                }

                background: Rectangle {
                    color: highlighted ? "#ecfdf5" : "transparent"
                    radius: 4
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
            }
        }
    }
}
