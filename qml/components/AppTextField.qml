import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// AppTextField — Polished desktop input
//
// Features:
//   - Optional label above
//   - Optional leading icon
//   - Helper/error text below
//   - States: normal, hover, focused, error, disabled
//   - Search variant (with search icon + clear button)
//
// Usage:
//   AppTextField { label: "House Name"; placeholderText: "Enter..." }
//   AppTextField { variant: "search"; placeholderText: "Search..." }
//   AppTextField { leadingIcon: "user"; label: "Phone" }
//   AppTextField { error: true; errorText: "Invalid number" }
// ============================================================================

FocusScope {
    id: root

    property string label: ""
    property string placeholderText: ""
    property string helperText: ""
    property string errorText: ""
    property bool required: false
    property bool error: false
    property string variant: "default"    // default | search
    property string leadingIcon: ""       // SVG icon name
    property bool showClearButton: false

    property alias text: input.text
    property alias echoMode: input.echoMode
    property alias readOnly: input.readOnly
    property alias validator: input.validator
    property alias maximumLength: input.maximumLength

    signal editingFinished()
    signal textEdited(string newText)

    implicitHeight: column.implicitHeight
    implicitWidth: variant === "search" ? 280 : 240

    property bool hovered: false

    Column {
        id: column
        anchors.fill: parent
        spacing: 4

        // Label
        Row {
            spacing: 2
            visible: root.label !== "" && root.variant !== "search"
            height: visible ? label.implicitHeight : 0

            Text {
                id: label
                text: root.label
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSm
                font.weight: Theme.fontWeightMedium
                color: root.error ? Theme.coral : Theme.textSecondary
            }
            Text {
                text: "*"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSm
                font.weight: Theme.fontWeightBold
                color: Theme.coral
                visible: root.required
            }
        }

        // Input container
        Rectangle {
            id: inputContainer
            width: parent.width
            height: Theme.controlHeightLg
            radius: Theme.radiusMd
            color: !root.enabled ? Theme.surfaceSubtle : Theme.surface
            border.width: 1
            border.color: !root.enabled ? Theme.border :
                          root.error ? Theme.coral :
                          input.activeFocus ? Theme.borderFocused :
                          root.hovered ? Theme.borderHover :
                          Theme.border

            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            // Focus glow (subtle)
            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                radius: parent.radius
                color: "transparent"
                border.width: input.activeFocus && !root.error ? 3 : 0
                border.color: Qt.rgba(0.02, 0.59, 0.41, 0.12)
                visible: border.width > 0
                z: -1
            }

            Row {
                anchors.fill: parent
                spacing: 0

                // Leading icon
                Item {
                    width: root.leadingIcon !== "" || root.variant === "search" ? 36 : 0
                    height: parent.height
                    visible: root.leadingIcon !== "" || root.variant === "search"

                    Item {
                        width: Theme.iconSizeMd
                        height: Theme.iconSizeMd
                        anchors.centerIn: parent

                        Image {
                            id: leadingImg
                            source: root.variant === "search" ? "qrc:/icons/svg/search.svg" : (root.leadingIcon !== "" ? "qrc:/icons/svg/" + root.leadingIcon + ".svg" : "")
                            sourceSize: Qt.size(Theme.iconSizeMd, Theme.iconSizeMd)
                            anchors.fill: parent
                            fillMode: Image.Pad
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: parent
                            source: leadingImg
                            colorizationColor: input.activeFocus ?
                                Theme.primary : Theme.textTertiary
                            colorization: 1.0
                            Behavior on colorizationColor { ColorAnimation { duration: Theme.animFast } }
                        }
                    }
                }

                // Text field
                TextField {
                    id: input
                    width: parent.width - leadingIconSlot.width - clearBtnSlot.width
                    height: parent.height
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMd
                    color: root.enabled ? Theme.textPrimary : Theme.textDisabled
                    placeholderText: root.placeholderText
                    placeholderTextColor: Theme.textTertiary
                    selectByMouse: true
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: root.leadingIcon !== "" || root.variant === "search" ? 0 : 12
                    rightPadding: 8
                    background: Item {}

                    onEditingFinished: root.editingFinished()
                    onTextEdited: root.textEdited(newText)
                }

                Item {
                    id: leadingIconSlot
                    width: 0
                    height: 0
                }

                // Clear button (search variant)
                Item {
                    id: clearBtnSlot
                    width: root.variant === "search" && input.text !== "" ? 32 : 0
                    height: parent.height
                    visible: width > 0

                    Rectangle {
                        width: 18; height: 18; radius: 9
                        anchors.centerIn: parent
                        color: clearMA.containsMouse ? Theme.surfacePressed : Theme.surfaceHover
                        visible: parent.visible
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: Theme.textSecondary
                        }

                        MouseArea {
                            id: clearMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: input.text = ""
                        }
                    }
                }
            }
        }

        // Helper / error text
        Text {
            visible: root.error ? root.errorText !== "" : root.helperText !== ""
            text: root.error && root.errorText !== "" ? root.errorText : root.helperText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            color: root.error ? Theme.coral : Theme.textTertiary
        }
    }
}
