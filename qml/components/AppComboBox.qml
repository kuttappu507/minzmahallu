import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// AppComboBox — Styled desktop dropdown
//
// Features:
//   - Single clean custom chevron-down indicator (no duplicate arrow)
//   - Styled popup with hover/selected item states
//   - States: normal, hover, focused, disabled, error
//   - Optional label and helper text
// ============================================================================

FocusScope {
    id: root

    property string label: ""
    property var model: []
    property int currentIndex: 0
    property string currentText: model[currentIndex] || ""
    property string helperText: ""
    property bool error: false

    signal activated(int index)

    implicitHeight: column.implicitHeight
    implicitWidth: 220

    Column {
        id: column
        anchors.fill: parent
        spacing: 4

        // Label
        Text {
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            font.weight: Theme.fontWeightMedium
            color: root.error ? Theme.coral : Theme.textSecondary
            visible: root.label !== ""
        }

        // Combo
        ComboBox {
            id: combo
            width: parent.width
            implicitHeight: Theme.controlHeightLg
            model: root.model
            currentIndex: root.currentIndex
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd
            padding: 0

            onActivated: function(index) {
                root.currentIndex = index
                root.activated(index)
            }

            // Content: text + single chevron
            contentItem: Row {
                width: parent.width
                height: parent.height
                spacing: 0

                Text {
                    text: combo.displayText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: combo.enabled ? Theme.textPrimary : Theme.textDisabled
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 12
                    rightPadding: 8
                    elide: Text.ElideRight
                    width: parent.width - 36
                }

                // Single clean chevron-down indicator
                Item {
                    width: 36
                    height: parent.height

                    Item {
                        width: 16; height: 16
                        anchors.centerIn: parent

                        Image {
                            id: chevronIcon
                            source: "qrc:/icons/svg/chevron-down.svg"
                            sourceSize: Qt.size(16, 16)
                            anchors.fill: parent
                            fillMode: Image.Pad
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: parent
                            source: chevronIcon
                            colorizationColor: combo.enabled ?
                                (combo.popup.visible ? Theme.primary : Theme.textSecondary) :
                                Theme.textDisabled
                            colorization: 1.0
                            Behavior on colorizationColor { ColorAnimation { duration: Theme.animFast } }

                            rotation: combo.popup.visible ? 180 : 0
                            Behavior on rotation { NumberAnimation { duration: Theme.animNormal; easing.type: Theme.easingStandard } }
                        }
                    }
                }
            }

            // Background
            background: Rectangle {
                radius: Theme.radiusMd
                color: !combo.enabled ? Theme.surfaceSubtle :
                       combo.pressed ? Theme.surfacePressed :
                       combo.hovered ? Theme.surfaceHover :
                       Theme.surface
                border.width: 1
                border.color: !combo.enabled ? Theme.border :
                              root.error ? Theme.coral :
                              combo.popup.visible || combo.activeFocus ? Theme.borderFocused :
                              combo.hovered ? Theme.borderHover :
                              Theme.border

                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
            }

            // Styled popup
            popup: Popup {
                y: combo.height + 4
                width: combo.width
                implicitHeight: Math.min(listView.contentHeight + 8, 280)
                padding: 4
                margins: 0

                background: Rectangle {
                    color: Theme.surface
                    border.width: 1
                    border.color: Theme.border
                    radius: Theme.radiusMd

                    // Subtle shadow
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Qt.rgba(0.15, 0.23, 0.42, Theme.shadowOpacityMedium)
                        shadowBlur: 0.5
                        shadowVerticalOffset: 4
                    }
                }

                contentItem: ListView {
                    id: listView
                    clip: true
                    implicitHeight: contentHeight
                    model: combo.popup.visible ? combo.delegateModel : null
                    currentIndex: combo.highlightedIndex
                    spacing: 2

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        implicitWidth: 6
                        contentItem: Rectangle {
                            color: Theme.textTertiary
                            radius: 3
                            opacity: parent.hovered ? 0.8 : 0.4
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                        }
                    }
                }
            }

            // Item delegate
            delegate: ItemDelegate {
                width: combo.width - 8
                implicitHeight: 34
                padding: 0

                contentItem: Row {
                    spacing: 8

                    // Selected check indicator
                    Item {
                        width: 16; height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        visible: index === combo.currentIndex

                        Image {
                            id: checkIcon
                            source: "qrc:/icons/svg/check.svg"
                            sourceSize: Qt.size(14, 14)
                            anchors.fill: parent
                            fillMode: Image.Pad
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: parent
                            source: checkIcon
                            colorizationColor: Theme.primary
                            colorization: 1.0
                        }
                    }

                    Text {
                        text: modelData
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        color: highlighted ? Theme.primary : Theme.textPrimary
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 8
                    }
                }

                background: Rectangle {
                    color: highlighted ? Theme.primarySubtle : "transparent"
                    radius: Theme.radiusSm
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
            }
        }

        // Helper text
        Text {
            text: root.helperText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            color: root.error ? Theme.coral : Theme.textTertiary
            visible: root.helperText !== ""
        }
    }
}
