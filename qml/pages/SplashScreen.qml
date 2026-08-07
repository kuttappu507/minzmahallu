import QtQuick
import QtQuick.Controls

// ============================================================================
// SplashScreen — shown for 2 seconds on startup, then transitions to main app
// ============================================================================

Rectangle {
    id: splash
    anchors.fill: parent
    color: "#044633"

    gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.0;  color: "#0a7f5d" }
        GradientStop { position: 0.42; color: "#065f46" }
        GradientStop { position: 1.0;  color: "#044633" }
    }

    // Logo + app name centered
    Column {
        anchors.centerIn: parent; spacing: 16

        Rectangle {
            width: 80; height: 80; radius: 28; color: Qt.rgba(255,255,255,0.14)
            anchors.horizontalCenter: parent.horizontalCenter
            Text { anchors.centerIn: parent; text: "M"; font.family: "Poppins"; font.pixelSize: 36; font.weight: Font.Bold; color: "#ffffff" }
        }

        Text {
            text: "Minz Mahallu"
            font.family: "Anek Malayalam"; font.pixelSize: 24; font.weight: Font.Bold; color: "#ffffff"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Management System"
            font.family: "Poppins"; font.pixelSize: 12; font.weight: Font.Medium; color: "#a5dcc6"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Loading indicator
        BusyIndicator {
            running: true; anchors.horizontalCenter: parent.horizontalCenter
            visible: true
            contentItem: Item {
                implicitWidth: 24; implicitHeight: 24
                Rectangle {
                    width: 24; height: 24; radius: 12; color: "transparent"
                    border.width: 2; border.color: Qt.rgba(255,255,255,0.2)
                    Rectangle {
                        width: 24; height: 12; color: "transparent"
                        clip: true
                        Rectangle {
                            width: 24; height: 24; radius: 12; color: "transparent"
                            border.width: 2; border.color: "#f2c14e"
                            anchors.bottom: parent.bottom
                        }
                    }
                    RotationAnimator on rotation { running: true; from: 0; to: 360; duration: 1000; loops: Animation.Infinite }
                }
            }
        }
    }

    // Version at bottom
    Text {
        text: "v1.0.0"
        font.family: "Poppins"; font.pixelSize: 10; color: "#a5dcc6"
        anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
    }

    // Auto-dismiss after 2 seconds
    Timer {
        interval: 2000; running: true; repeat: false
        onTriggered: splash.visible = false
    }
}
