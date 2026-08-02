import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ============================================================================
// FormField - Reusable labeled form field with consistent styling
// ============================================================================
ColumnLayout {
    id: root
    property string label: ""
    property string helperText: ""
    property bool required: false

    property alias textField: input
    property alias text: input.text
    property alias placeholderText: input.placeholderText
    property alias echoMode: input.echoMode

    spacing: 4
    Layout.fillWidth: true

    RowLayout {
        Layout.fillWidth: true
        spacing: 4

        Text {
            text: root.label
            font.family: Theme.fontPrimary
            font.pixelSize: 10
            font.weight: Font.Black
            color: Theme.muted
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            visible: root.required
            text: "*"
            color: Theme.danger
            font.pixelSize: 10
            font.weight: Font.Bold
        }
        Item { Layout.fillWidth: true }
    }

    TextField {
        id: input
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        font.family: Theme.fontPrimary
        font.pixelSize: 12
        color: Theme.text
        background: Rectangle {
            color: Theme.panel
            border.width: 1
            border.color: input.activeFocus ? Theme.sidebar : Theme.border
            radius: 6
            Behavior on border.color { ColorAnimation { duration: 100 } }
        }
        padding: 10
    }

    Text {
        visible: root.helperText !== ""
        text: root.helperText
        font.family: Theme.fontPrimary
        font.pixelSize: 9
        color: Theme.muted
    }
}
