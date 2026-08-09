import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0

// ============================================================================
// SplashScreen — small centered box (not full window)
// Shows for 2 seconds then disappears.
// ============================================================================

Item {
    id: splash
    anchors.fill: parent
    visible: true

    // Small centered box only — no full-window backdrop
    Rectangle {
        id: splashCard
        anchors.centerIn: parent
        width: 320; height: 200
        radius: Theme.radiusXl
        color: Theme.sidebarBot

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Theme.sidebarTop }
            GradientStop { position: 1.0; color: Theme.sidebarBot }
        }

        Column {
            anchors.centerIn: parent; spacing: 12

            // Logo circle
            Rectangle {
                width: 48; height: 48; radius: 18; color: Qt.rgba(255, 255, 255, 0.14)
                anchors.horizontalCenter: parent.horizontalCenter
                Text { anchors.centerIn: parent; text: "M"; font.family: Theme.activeFontFamily; font.pixelSize: 22; font.weight: Font.Bold; color: "#ffffff" }
            }

            // App name
            Text {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("app_name") }
                font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; font.weight: Font.Bold; color: "#ffffff"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Loading spinner
            BusyIndicator {
                running: splash.visible; anchors.horizontalCenter: parent.horizontalCenter
                width: 24; height: 24
                contentItem: Item {
                    implicitWidth: 24; implicitHeight: 24
                    Rectangle {
                        width: 24; height: 24; radius: 12; color: "transparent"
                        border.width: 2; border.color: Qt.rgba(255, 255, 255, 0.2)
                        Rectangle {
                            width: 24; height: 12; color: "transparent"; clip: true
                            Rectangle {
                                width: 24; height: 24; radius: 12; color: "transparent"
                                border.width: 2; border.color: Theme.gold
                                anchors.bottom: parent.bottom
                            }
                        }
                        RotationAnimator on rotation { running: splash.visible; from: 0; to: 360; duration: 1000; loops: Animation.Infinite }
                    }
                }
            }
        }

        // Entrance animation
        scale: 0.9
        opacity: 0
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Component.onCompleted: { scale = 1; opacity = 1 }
    }

    // Auto-dismiss after 2 seconds
    Timer {
        interval: 2000; running: true; repeat: false
        onTriggered: {
            splashCard.scale = 0.9
            splashCard.opacity = 0
            dismissTimer.start()
        }
    }
    Timer {
        id: dismissTimer
        interval: 200; onTriggered: splash.visible = false
    }
}
