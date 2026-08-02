import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ============================================================================
// Dialog - Reusable modal dialog wrapper with title bar + content + buttons
// Usage:
//   Dialog {
//     title: "Add Family"
//     width: 600; height: 500
//     onAccepted: { /* save */ }
//     onRejected: { /* cancel */ }
//     ColumnLayout { /* form fields */ }
//   }
// ============================================================================
Window {
    id: root
    property string title: ""
    property string acceptLabel: "Save"
    property string rejectLabel: "Cancel"
    property bool primaryAction: true
    default property alias content: contentLayout.children

    signal accepted()
    signal rejected()

    flags: Qt.Dialog | Qt.FramelessWindowHint
    color: "transparent"
    modality: Qt.ApplicationModal

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        radius: 12
        border.width: 1
        border.color: Theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            // Title bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                color: Theme.sidebar
                radius: 12

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 12
                    color: Theme.sidebar
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: root.title
                        font.family: Theme.fontDisplay
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: "#ffffff"
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 28; height: 28; radius: 6
                        color: closeMA.containsMouse ? Qt.rgba(1,1,1,0.2) : "transparent"
                        Text { anchors.centerIn: parent; text: "×"; color: "#ffffff"; font.pixelSize: 18; font.weight: Font.Bold }
                        MouseArea { id: closeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.rejected(); root.close() } }
                    }
                }
            }

            // Content area
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    id: contentLayout
                    width: parent ? parent.width : 600
                    spacing: 12
                }
            }

            // Button bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: Theme.panelMuted

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.border
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.rightMargin: 18
                    spacing: 10

                    Item { Layout.fillWidth: true }

                    // Cancel
                    Rectangle {
                        Layout.preferredHeight: 34
                        Layout.preferredWidth: 100
                        radius: 8
                        color: cancelMA.containsMouse ? Theme.panelMuted : Theme.panel
                        border.width: 1.5
                        border.color: Theme.border
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            anchors.centerIn: parent
                            text: root.rejectLabel
                            font.family: Theme.fontPrimary
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.text
                        }
                        MouseArea { id: cancelMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.rejected(); root.close() } }
                    }

                    // Accept (primary)
                    Rectangle {
                        Layout.preferredHeight: 34
                        Layout.preferredWidth: 100
                        radius: 8
                        color: acceptMA.containsMouse ? "#04543c" : Theme.sidebar
                        border.width: 0
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            anchors.centerIn: parent
                            text: root.acceptLabel
                            font.family: Theme.fontPrimary
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                        MouseArea { id: acceptMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.accepted(); root.close() } }
                    }
                }
            }
        }
    }
}
