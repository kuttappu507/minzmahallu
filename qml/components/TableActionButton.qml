import QtQuick
import QtQuick.Controls
import QtQuick.Effects

// ============================================================================
// TableActionButton — Momentary action button for table rows
//
// States:
//   NORMAL:  neutral grey icon, transparent background, light border
//   HOVER:   colored icon (variantColor), tinted background, colored border
//   PRESSED: slightly stronger tint
//   RELEASE: immediately returns to NORMAL
//
// This is a MOMENTARY action button, NOT a toggle.
// - checkable: false (never checked)
// - No persistent color after click
// - No activeFocus/focus-based styling
// - Hover state only active while pointer is over the button
//
// Usage:
//   TableActionButton {
//       iconSource: "qrc:/icons/svg/edit.svg"
//       variantColor: "#059669"   // emerald for Edit, blue for View, red for Delete
//       onClicked: { ... }
//   }
// ============================================================================

Item {
    id: root

    property string iconSource: ""
    property color variantColor: "#059669"
    property int iconSize: 14
    property int buttonSize: 28

    signal clicked()

    width: buttonSize
    height: buttonSize

    // Never checkable, never focus-styled
    opacity: enabled ? 1.0 : 0.4

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 6
        border.width: 1

        // Background color: pressed > hover > normal
        color: ma.pressed ? Qt.darker(root.variantColor, 1.15) :
               ma.containsMouse ? Qt.rgba(
                   root.variantColor.r, root.variantColor.g, root.variantColor.b, 0.10) :
               "transparent"

        // Border color: pressed > hover > normal
        border.color: ma.pressed ? root.variantColor :
                      ma.containsMouse ? root.variantColor :
                      "#d2e5d8"

        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
    }

    // Icon — color changes on hover/pressed, neutral grey otherwise
    Item {
        width: root.iconSize; height: root.iconSize
        anchors.centerIn: parent

        Image {
            id: btnIcon
            source: root.iconSource
            sourceSize: Qt.size(root.iconSize, root.iconSize)
            anchors.fill: parent
            fillMode: Image.Pad
            visible: false
        }
        MultiEffect {
            anchors.fill: parent
            source: btnIcon
            // Icon color: pressed/hover = variant color, normal = neutral grey
            colorizationColor: ma.pressed ? root.variantColor :
                               ma.containsMouse ? root.variantColor :
                               "#7e968a"
            colorization: 1.0
            Behavior on colorizationColor { ColorAnimation { duration: 100 } }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // Accept click on press, not on release — but standard onClicked is fine
        // for momentary action. The visual state is driven by containsMouse/pressed.
        onClicked: root.clicked()
    }
}
