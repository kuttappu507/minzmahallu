import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MMS.Theme 1.0
import "../components"

// ============================================================================
// FamilyEditDialog — Polished modal dialog
//
// Layout: ApplicationWindow → Rectangle (fills parent)
//   → Column (fills parent)
//     → Header (Item with anchors)
//     → ScrollView (fills remaining)
//     → Footer (Item with anchors)
// ============================================================================

ApplicationWindow {
    id: dialog
    visible: false
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"

    property string title: "Add Family"

    signal accepted()
    signal rejected()

    width: 520
    height: 580
    minimumWidth: 520
    minimumHeight: 580

    // Dimmed overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.05, 0.15, 0.4)
    }

    // Dialog surface
    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: Theme.radiusXl

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0.02, 0.05, 0.15, Theme.shadowOpacityLarge)
            shadowBlur: 0.6
            shadowVerticalOffset: 8
        }

        Column {
            anchors.fill: parent
            spacing: 0

            // ===== Header =====
            Item {
                width: parent.width
                height: 56

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.borderSubtle
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: dialog.title
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLg
                    font.weight: Font.DemiBold
                    color: Theme.textPrimary
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28; height: 28; radius: Theme.radiusSm
                    color: closeMA.containsMouse ? Theme.surfaceHover : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: closeMA.containsMouse ? Theme.textPrimary : Theme.textSecondary
                    }

                    MouseArea {
                        id: closeMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            dialog.rejected()
                            dialog.visible = false
                        }
                    }
                }
            }

            // ===== Form body =====
            ScrollView {
                width: parent.width
                height: parent.height - 56 - 72
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: parent.width - 40
                    x: 20
                    spacing: 14
                    topPadding: 20

                    AppTextField {
                        label: "House Name"
                        placeholderText: "e.g. Manzil Manzoor"
                        required: true
                        width: parent.width
                    }

                    AppTextField {
                        label: "Head of Family"
                        placeholderText: "e.g. Manzoor PP"
                        leadingIcon: "user"
                        width: parent.width
                    }

                    Row {
                        spacing: 12
                        width: parent.width

                        AppComboBox {
                            label: "Ward"
                            model: ["Ward 1", "Ward 2", "Ward 3", "Ward 4"]
                            width: (parent.width - 12) / 2
                        }

                        AppTextField {
                            label: "Phone"
                            placeholderText: "9847123456"
                            leadingIcon: "user"
                            width: (parent.width - 12) / 2
                        }
                    }

                    Column {
                        spacing: 4
                        width: parent.width

                        Text {
                            text: "ADDRESS"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            font.weight: Font.Medium
                            color: Theme.textSecondary
                        }

                        TextArea {
                            width: parent.width
                            implicitHeight: 72
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMd
                            color: Theme.textPrimary
                            placeholderText: "Enter full address..."
                            placeholderTextColor: Theme.textTertiary
                            selectByMouse: true
                            wrapMode: TextArea.Wrap

                            background: Rectangle {
                                radius: Theme.radiusMd
                                color: Theme.surface
                                border.width: 1
                                border.color: parent.activeFocus ? Theme.borderFocused :
                                              parent.hovered ? Theme.borderHover : Theme.border
                                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                            }

                            padding: 10
                        }
                    }

                    Row {
                        spacing: 12
                        width: parent.width

                        AppTextField {
                            label: "Area"
                            placeholderText: "e.g. Kondotty"
                            width: (parent.width - 12) / 2
                        }

                        AppTextField {
                            label: "Pincode"
                            placeholderText: "673601"
                            width: (parent.width - 12) / 2
                        }
                    }
                }
            }

            // ===== Footer =====
            Item {
                width: parent.width
                height: 72

                Rectangle {
                    anchors.fill: parent
                    color: Theme.surfaceSubtle
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.borderSubtle
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    AppButton {
                        text: "Cancel"
                        variant: "secondary"
                        onClicked: {
                            dialog.rejected()
                            dialog.visible = false
                        }
                    }

                    AppButton {
                        text: "Add Family"
                        variant: "primary"
                        iconSource: "qrc:/icons/svg/plus.svg"
                        onClicked: {
                            dialog.accepted()
                            dialog.visible = false
                        }
                    }
                }
            }
        }
    }
}
