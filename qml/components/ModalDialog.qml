import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ============================================================================
// ModalDialog — Shared modal shell for all dialogs
//
// Provides:
//   - Semi-transparent backdrop covering the entire window
//   - White modal card centered in the content area (right of sidebar)
//   - Rounded corners (radius 12)
//   - ESC key closes (when closeOnEscape is true)
//   - Click on backdrop closes (when closeOnBackdrop is true)
//
// CRITICAL: The card's background MouseArea is declared BEFORE the Loader
// so the Loader content (form fields, buttons) is painted ON TOP and
// receives mouse events. The background MouseArea only catches clicks on
// empty card areas (preventing backdrop close).
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
    property int sidebarWidth: 260
    property Component content

    // ===== Size window to match parent (for full backdrop coverage) =====
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

    // ===== Semi-transparent backdrop (full window) =====
    // Clicking the backdrop closes the dialog (if closeOnBackdrop is true).
    // The card sits ON TOP of this and has its own MouseArea to prevent
    // backdrop clicks from firing when clicking on the card.
    Rectangle {
        id: backdrop
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
    Rectangle {
        id: card
        x: root.sidebarWidth + (root.width - root.sidebarWidth - root.modalWidth) / 2
        y: (root.height - root.modalHeight) / 2
        width: root.modalWidth
        height: root.modalHeight
        radius: 12
        color: "#ffffff"
        clip: true

        // Background MouseArea — swallows clicks on the card background
        // so they don't reach the backdrop. Declared BEFORE the Loader so
        // the Loader's content (buttons, text fields) is painted ON TOP
        // and receives mouse events normally.
        MouseArea {
            anchors.fill: parent
            onClicked: {}   // swallow — prevent backdrop close
        }

        // Content loader — painted on top of the background MouseArea.
        // Form fields, buttons, etc. inside receive mouse events.
        Loader {
            anchors.fill: parent
            sourceComponent: root.content
        }
    }

    // ===== ESC to close =====
    Shortcut {
        sequence: "Escape"
        enabled: root.visible && root.closeOnEscape
        onActivated: root.visible = false
    }
}
