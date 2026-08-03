import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0
import "../components"

// ============================================================================
// FamilyEditDialog — Polished modal dialog (Phase 3.2 fixed layout)
//
// Layout: ApplicationWindow → Rectangle → ColumnLayout
//   ├─ Header (Item, fixed height)
//   ├─ Form body (ScrollView → ColumnLayout)
//   └─ Footer (Item, fixed height)
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
    height: 560
    minimumWidth: 520
    minimumHeight: 560

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

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ===== Header =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: "transparent"

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.borderSubtle
                }

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 12

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: dialog.title
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLg
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                    }

                    Rectangle {
                        anchors.right: parent.right
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
            }

            // ===== Form body =====
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: parent.width - 40
                    x: 20
                    spacing: 16

                    // House Name (full width)
                    AppTextField {
                        Layout.fillWidth: true
                        label: "House Name"
                        placeholderText: "e.g. Manzil Manzoor"
                        required: true
                    }

                    // Head of Family (full width)
                    AppTextField {
                        Layout.fillWidth: true
                        label: "Head of Family"
                        placeholderText: "e.g. Manzoor PP"
                        leadingIcon: "user"
                    }

                    // Ward + Phone (side by side)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        AppComboBox {
                            Layout.fillWidth: true
                            label: "Ward"
                            model: ["Ward 1", "Ward 2", "Ward 3", "Ward 4"]
                        }

                        AppTextField {
                            Layout.fillWidth: true
                            label: "Phone"
                            placeholderText: "9847123456"
                            leadingIcon: "user"
                        }
                    }

                    // Address (multiline)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "ADDRESS"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            font.weight: Font.Medium
                            color: Theme.textSecondary
                        }

                        TextArea {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 72
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

                    // Pincode (half width)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        AppTextField {
                            Layout.fillWidth: true
                            label: "Pincode"
                            placeholderText: "673601"
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    // Bottom padding
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 8
                    }
                }
            }

            // ===== Footer =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                color: Theme.surfaceSubtle

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.borderSubtle
                }

                Item {
                    anchors.fill: parent
                    anchors.rightMargin: 20

                    Row {
                        anchors.right: parent.right
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
}
