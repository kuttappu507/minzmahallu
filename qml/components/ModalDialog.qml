import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

// Shared frameless modal window. Keeps the backdrop full-window while
// constraining the actual card to the usable viewport so dialogs remain
// centered and usable at high DPI and smaller window sizes.
ApplicationWindow {
    id: root
    visible: false
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"

    property int modalWidth: 440
    property int modalHeight: 220
    property bool closeOnBackdrop: true
    property bool closeOnEscape: true
    property int sidebarWidth: 260
    property Component content

    onVisibleChanged: {
        if (visible) {
            var parentWin = root.transientParent
            if (parentWin) {
                root.x = parentWin.x
                root.y = parentWin.y
                root.width = parentWin.width
                root.height = parentWin.height
            }
            // Keep a usable margin on small windows and never let the card
            // extend beyond the viewport.
            card.width = Math.min(root.modalWidth, Math.max(320, root.width - 32))
            card.height = Math.min(root.modalHeight, Math.max(160, root.height - 32))
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.05, 0.15, Theme.dark ? 0.55 : 0.35)
        MouseArea {
            anchors.fill: parent
            onClicked: if (root.closeOnBackdrop) root.visible = false
        }
    }

    Rectangle {
        id: card
        x: Math.max(16, root.sidebarWidth + (root.width - root.sidebarWidth - width) / 2)
        y: Math.max(16, (root.height - height) / 2)
        width: Math.min(root.modalWidth, Math.max(320, root.width - 32))
        height: Math.min(root.modalHeight, Math.max(160, root.height - 32))
        radius: Theme.radius2xl
        color: Theme.surface
        border.width: 1
        border.color: Theme.border
        clip: true

        MouseArea { anchors.fill: parent; onClicked: {} }
        Loader {
            anchors.fill: parent
            sourceComponent: root.content
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.visible && root.closeOnEscape
        onActivated: root.visible = false
    }
}
