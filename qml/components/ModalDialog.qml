import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

// ============================================================================
// ModalDialog — Shared modal shell for all dialogs
//
// Provides:
//   - Semi-transparent backdrop covering the entire window
//   - White modal card centered in the content area (right of sidebar)
//   - Rounded corners (radius 12) + drop shadow
//   - ESC key closes (when closeOnEscape is true)
//   - Click on backdrop closes (when closeOnBackdrop is true)
//
// Usage:
//   ModalDialog {
//       modalWidth: 440; modalHeight: 200
//       content: Component {
//           ColumnLayout { ... }
//       }
//   }
//
// The content Component is loaded inside the white card.
// ============================================================================

ApplicationWindow {
    id: root
    visible: false
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"

    // ===== Configurable properties =====
    property int modalWidth: 440
    property int modalHeight: 200
    property bool closeOnBackdrop: true
    property bool closeOnEscape: true
    property int sidebarWidth: 260      // offset card right of sidebar
    property Component content

    // ===== Center the window over the parent and size it to match =====
    onVisibleChanged: {
        if (visible) {
            var parentWin = root.transientParent
            if (parentWin) {
                root.x = parentWin.x
                root.y = parentWin.y
                root.width = parentWin.width
                root.height = parentWin.height
            }
        }
    }

    // ===== Semi-transparent backdrop =====
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.05, 0.15, 0.35)
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.closeOnBackdrop) root.visible = false
            }
        }
    }

    // ===== Modal card — centered in content area =====
    Item {
        anchors.fill: parent

        // Card with shadow
        Rectangle {
            id: card
            x: root.sidebarWidth + (root.width - root.sidebarWidth - root.modalWidth) / 2
            y: (root.height - root.modalHeight) / 2
            width: root.modalWidth
            height: root.modalHeight
            radius: 12
            color: "#ffffff"
            clip: true

            // Drop shadow via layer + MultiEffect
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.18)
                shadowBlur: 0.6
                shadowVerticalOffset: 6
                shadowHorizontalOffset: 0
            }

            // Content loader
            Loader {
                anchors.fill: parent
                sourceComponent: root.content
            }
        }

        // Prevent clicks from passing through the card to the backdrop
        MouseArea {
            x: card.x; y: card.y; width: card.width; height: card.height
            acceptedButtons: Qt.AllButtons
            onClicked: {}   // swallow
            onWheel: {}
        }
    }

    // ===== ESC to close =====
    Shortcut {
        sequence: "Escape"
        enabled: root.visible && root.closeOnEscape
        onActivated: root.visible = false
    }
}
