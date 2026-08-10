import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0

// ============================================================================
// SplashScreen — small centered box, NOT full window
// The Item does NOT fill parent — only the card is shown.
// ============================================================================

Item {
    id: splash
    visible: true
    // Do NOT anchors.fill: parent — this Item only contains the card
    // positioned at center of the window

    Rectangle {
        id: splashCard
        x: (splash.parent ? splash.parent.width : 1600) / 2 - width / 2
        y: (splash.parent ? splash.parent.height : 900) / 2 - height / 2
        width: 320; height: 200
        radius: Theme.radiusXl
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Theme.sidebarTop }
            GradientStop { position: 1.0; color: Theme.sidebarBot }
        }

        Column {
            anchors.centerIn: parent; spacing: 12

            Rectangle {
                width: 48; height: 48; radius: 18; color: Qt.rgba(255, 255, 255, 0.14)
                anchors.horizontalCenter: parent.horizontalCenter
                Text { anchors.centerIn: parent; text: "M"; font.family: Theme.activeFontFamily; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.surface }
            }

            Text {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("app_name") }
                font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; font.weight: Font.Bold; color: Theme.surface
                anchors.horizontalCenter: parent.horizontalCenter
            }

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

        scale: 0.9; opacity: 0
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Component.onCompleted: { scale = 1; opacity = 1 }
    }

    Timer {
        interval: 2000; running: true; repeat: false
        onTriggered: { splashCard.scale = 0.9; splashCard.opacity = 0; dismissTimer.start() }
    }
    Timer { id: dismissTimer; interval: 200; onTriggered: splash.visible = false }
}
