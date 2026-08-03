import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// AppComboBox — Styled desktop dropdown (Phase 3.2 fixed)
//
// Fixes:
// - Single clean SVG chevron (no native Qt indicator underneath)
// - Chevron rotates 180° when popup opens
// - Styled popup with shadow + hover states
// - Proper label/helper text
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

    implicitHeight: label !== "" ? 60 : 36
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
            font.weight: Font.Medium
            color: root.error ? Theme.coral : Theme.textSecondary
            visible: root.label !== ""
            height: root.label !== "" ? implicitHeight : 0
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

            // CRITICAL: Disable the native indicator by setting indicator to null
            // and using our own custom contentItem
            indicator: Item { width: 0; height: 0; visible: false }

            onActivated: function(index) {
                root.currentIndex = index
                root.activated(index)
            }

            // Custom content: text + single chevron (no native indicator)
            contentItem: Item {
                width: parent.width
                height: parent.height

                Text {
                    id: comboText
                    text: combo.displayText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: combo.enabled ? Theme.textPrimary : Theme.textDisabled
                    x: 12
                    y: (parent.height - height) / 2
                    width: parent.width - 40
                    elide: Text.ElideRight
                }

                // Single clean chevron-down (right side)
                Item {
                    width: 16; height: 16
                    x: parent.width - 28
                    y: (parent.height - 16) / 2

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
                    x: 8

                    // Selected check indicator
                    Item {
                        width: 16; height: 16
                        y: (34 - 16) / 2
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
                        y: (34 - height) / 2
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
            height: root.helperText !== "" ? implicitHeight : 0
        }
    }
}
