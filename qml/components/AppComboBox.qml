import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// AppComboBox — Styled dropdown for desktop
//
// Features:
//   - Custom background with hover/focus states
//   - Custom popup with styled items
//   - Chevron-down SVG icon (tinted)
//   - States: normal, hover, focused, disabled
//
// Usage:
//   AppComboBox {
//       label: "Status"
//       model: ["Active", "Inactive", "Archived"]
//       onActivated: console.log("Selected:", index)
//   }
// ============================================================================

FocusScope {
    id: root

    // ===== Public API =====
    property string label: ""
    property var model: []
    property int currentIndex: 0
    property string currentText: model[currentIndex] || ""
    property string helperText: ""
    property bool error: false

    signal activated(int index)

    implicitHeight: column.implicitHeight
    implicitWidth: 240

    Column {
        id: column
        anchors.fill: parent
        spacing: 4

        // ===== Label =====
        Text {
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            font.weight: Theme.fontWeightMedium
            color: root.error ? Theme.danger : Theme.textSecondary
            visible: root.label !== ""
        }

        // ===== Combo button =====
        ComboBox {
            id: combo
            width: parent.width
            implicitHeight: Theme.controlHeightMd
            model: root.model
            currentIndex: root.currentIndex
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd

            onActivated: function(index) {
                root.currentIndex = index
                root.activated(index)
            }

            // ===== Content (text + chevron) =====
            contentItem: Row {
                spacing: 6
                leftPadding: 10

                Text {
                    text: combo.displayText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: combo.enabled ? Theme.textPrimary : Theme.textDisabled
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Chevron-down icon
                Item {
                    width: 16; height: 16
                    anchors.verticalCenter: parent.verticalCenter

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
                        colorizationColor: combo.enabled ? Theme.textSecondary : Theme.textDisabled
                        colorization: 1.0
                    }
                }
            }

            // ===== Background =====
            background: Rectangle {
                radius: Theme.radiusMd
                color: !combo.enabled ? Theme.surfaceSubtle :
                       combo.pressed ? Theme.surfacePressed :
                       combo.hovered ? Theme.surfaceHover :
                       Theme.surface
                border.width: 1
                border.color: !combo.enabled ? Theme.border :
                              root.error ? Theme.danger :
                              combo.pressed || combo.popup.visible ? Theme.borderFocused :
                              combo.activeFocus ? Theme.borderFocused :
                              combo.hovered ? Theme.borderHover :
                              Theme.border

                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
            }

            // ===== Popup =====
            popup: Popup {
                y: combo.height + 2
                width: combo.width
                implicitHeight: Math.min(contentItem.implicitHeight + 2, 280)
                padding: 1
                margins: 0

                background: Rectangle {
                    color: Theme.surface
                    border.width: 1
                    border.color: Theme.border
                    radius: Theme.radiusMd
                }

                contentItem: ListView {
                    id: listView
                    clip: true
                    implicitHeight: contentHeight
                    model: combo.popup.visible ? combo.delegateModel : null
                    currentIndex: combo.highlightedIndex
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        implicitWidth: 6
                    }
                }
            }

            // ===== Delegate (each item in the dropdown) =====
            delegate: ItemDelegate {
                width: combo.width - 2
                implicitHeight: 32

                contentItem: Text {
                    text: modelData
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: highlighted ? Theme.primary : Theme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }

                background: Rectangle {
                    color: highlighted ? Theme.primarySubtle : "transparent"
                    radius: Theme.radiusXs
                }
            }
        }

        // ===== Helper / Error text =====
        Text {
            text: root.helperText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            color: root.error ? Theme.danger : Theme.textTertiary
            visible: root.helperText !== ""
        }
    }
}
