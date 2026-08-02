import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0

// ============================================================================
// AppTextField — Labeled text input with validation states
//
// Features:
//   - Optional label above the field
//   - Optional helper/error text below
//   - States: normal, focused, error, disabled
//   - Focus changes border color to emerald (100ms animation)
//   - Error state shows red border + red helper text
//
// Usage:
//   AppTextField {
//       label: "House Name"
//       placeholderText: "e.g. Manzil Manzoor"
//       required: true
//   }
//   AppTextField {
//       label: "Phone"
//       error: true
//       errorText: "Enter a valid 10-digit number"
//   }
// ============================================================================

FocusScope {
    id: root

    // ===== Public API =====
    property string label: ""
    property string placeholderText: ""
    property string helperText: ""
    property string errorText: ""
    property bool required: false
    property bool error: false
    property bool showHelper: helperText !== "" || (error && errorText !== "")

    property alias text: input.text
    property alias echoMode: input.echoMode
    property alias readOnly: input.readOnly
    property alias inputMask: input.inputMask
    property alias validator: input.validator
    property alias maximumLength: input.maximumLength

    signal editingFinished()
    signal textEdited(string newText)

    // ===== Layout =====
    implicitHeight: column.implicitHeight
    implicitWidth: 280

    Column {
        id: column
        anchors.fill: parent
        spacing: 4

        // ===== Label =====
        Row {
            spacing: 2
            visible: root.label !== ""
            height: root.label !== "" ? label.implicitHeight : 0

            Text {
                id: label
                text: root.label
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSm
                font.weight: Theme.fontWeightMedium
                color: root.error ? Theme.danger : Theme.textSecondary
            }
            Text {
                text: "*"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSm
                font.weight: Theme.fontWeightBold
                color: Theme.danger
                visible: root.required
            }
        }

        // ===== Input =====
        TextField {
            id: input
            width: parent.width
            implicitHeight: Theme.controlHeightMd
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMd
            color: root.enabled ? Theme.textPrimary : Theme.textDisabled
            placeholderText: root.placeholderText
            placeholderTextColor: Theme.textTertiary
            selectByMouse: true
            verticalAlignment: Text.AlignVCenter
            leftPadding: 10
            rightPadding: 10

            background: Rectangle {
                radius: Theme.radiusMd
                color: !root.enabled ? Theme.surfaceSubtle :
                       Theme.surface
                border.width: 1
                border.color: !root.enabled ? Theme.border :
                              root.error ? Theme.danger :
                              input.activeFocus ? Theme.borderFocused :
                              root.hovered ? Theme.borderHover :
                              Theme.border

                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }

            onEditingFinished: root.editingFinished()
            onTextEdited: root.textEdited(newText)

            // Hover detection (TextField doesn't have hovered by default)
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton  // don't steal clicks from TextField
                hoverEnabled: true
                propagateComposedEvents: true
                onContainsMouseChanged: root.hovered = containsMouse
            }
        }

        property bool hovered: false

        // ===== Helper / Error text =====
        Text {
            visible: root.showHelper
            text: root.error && root.errorText !== "" ? root.errorText : root.helperText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            color: root.error ? Theme.danger : Theme.textTertiary
        }
    }

    // Expose hovered for the MouseArea
    property bool hovered: false
}
