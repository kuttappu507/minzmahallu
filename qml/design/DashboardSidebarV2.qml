import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// DashboardSidebarV2 — Compact navy sidebar (230px)
//
// Fixes from V1:
// - Width reduced to 230px (was 248)
// - Compact nav rows (36px height, was 40)
// - Clear selected state: emerald-tinted bg + 3px indicator + white icon/text
// - Normal icons: #94a3b8 (clearly visible on navy)
// - Content-driven height via Column layout
// ============================================================================

Rectangle {
    id: sidebar

    property int currentIndex: 0
    signal navigated(int index)

    implicitWidth: 260
    Layout.fillHeight: true
    Layout.fillWidth: false

    // Green gradient sidebar (matches HTML: linear-gradient(180deg, #0a7f5d 0%, #065f46 42%, #044633 100%))
    gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.0; color: Theme.sidebarTop }
        GradientStop { position: 0.42; color: Theme.sidebarMid }
        GradientStop { position: 1.0; color: Theme.sidebarBot }
    }

    // Right edge separator
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Qt.rgba(255,255,255,0.14)
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // ===== Logo / Brand (compact) =====
        Item {
            width: parent.width
            height: 56

            Row {
                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    width: 28; height: 28; radius: Theme.radiusSm
                    color: "#f2c14e"   // Gold logo bg
                    border.width: 2
                    border.color: "#b98317"

                    Text {
                        anchors.centerIn: parent
                        text: "M"
                        font.family: Theme.fontFamilyDisplay
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: Theme.textOnPrimary
                    }
                }

                Column {
                    spacing: 0

                    Text {
                        text: "Minz Mahallu"
                        font.family: Theme.fontFamilyDisplay
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    Text {
                        text: "Management System"
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        color: "#a5dcc6"
                    }
                }
            }
        }

        // ===== Nav section label =====
        Text {
            text: "MENU"
            font.family: Theme.fontFamily
            font.pixelSize: 9
            font.weight: Font.Bold
            color: Qt.rgba(214,240,228,0.42)
            leftPadding: 20
            topPadding: 8
            bottomPadding: 6
            width: parent.width
        }

        // ===== Nav items =====
        ListView {
            id: navList
            width: parent.width
            height: parent.height - 56 - 32 - 76   // logo + label + profile
            clip: true
            spacing: 2
            currentIndex: sidebar.currentIndex
            model: ListModel {
                ListElement { label: "Dashboard";     icon: "dashboard" }
                ListElement { label: "Families";      icon: "families" }
                ListElement { label: "Members";       icon: "members" }
                ListElement { label: "Nikah";         icon: "marriage" }
                ListElement { label: "Collections";   icon: "donations" }
                ListElement { label: "Events";        icon: "token" }
                ListElement { label: "Certificates";  icon: "certificates" }
                ListElement { label: "Reports";       icon: "reports" }
                ListElement { label: "Settings";      icon: "settings" }
            }

            delegate: ItemDelegate {
                width: navList.width - 16
                height: 36
                x: 8
                padding: 0

                background: Rectangle {
                    radius: Theme.radiusSm
                    // Selected: emerald-tinted navy
                    color: ListView.isCurrentItem ? Qt.rgba(255,255,255,0.14) :
                           (hovered ? Qt.rgba(255,255,255,0.09) : "transparent")
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    // Emerald left indicator
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3; height: 20
                        radius: 2
                        color: "#f2c14e"   // Gold indicator (matches HTML)
                        visible: ListView.isCurrentItem
                    }
                }

                contentItem: Row {
                    spacing: 10
                    leftPadding: 12

                    // Icon
                    Item {
                        width: 16; height: 16
                        y: (36 - 16) / 2

                        Image {
                            id: navIcon
                            source: "qrc:/icons/svg/" + model.icon + ".svg"
                            sourceSize: Qt.size(16, 16)
                            anchors.fill: parent
                            fillMode: Image.Pad
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: parent
                            source: navIcon
                            // Normal: #94a3b8, Hover: white, Selected: white
                            colorizationColor: ListView.isCurrentItem ?
                                "#ffffff" :
                                (hovered ? "#ffffff" : "#94a3b8")
                            colorization: 1.0
                            Behavior on colorizationColor { ColorAnimation { duration: Theme.animFast } }
                        }
                    }

                    // Label
                    Text {
                        text: model.label
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.weight: ListView.isCurrentItem ? Font.Medium : Font.Normal
                        color: ListView.isCurrentItem ?
                            "#ffffff" :
                            (hovered ? "#ffffff" : "#c4e7d7")
                        y: (36 - height) / 2
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }
                }

                onClicked: {
                    navList.currentIndex = index
                    sidebar.navigated(index)
                }
            }
        }

        // ===== User profile card =====
        Item {
            width: parent.width
            height: 76

            Rectangle {
                anchors.fill: parent
                anchors.margins: 8
                radius: Theme.radiusSm
                color: "transparent"
                border.width: 0

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Rectangle {
                        width: 30; height: 30; radius: 15
                        color: "#f2c14e"   // Gold avatar (matches HTML)
                        border.width: 2
                        border.color: "#b98317"

                        Text {
                            anchors.centerIn: parent
                            text: "A"
                            font.family: Theme.fontFamilyDisplay
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#4a3606"   // Brown text on gold (matches HTML)
                        }
                    }

                    Column {
                        spacing: 0

                        Text {
                            text: "Admin User"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: "#ffffff"
                        }
                        Text {
                            text: "Administrator"
                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                            color: "#9fd8c3"
                        }
                    }

                    Item {
                        width: 16; height: 16
                        y: (30 - 16) / 2

                        Image {
                            id: logoutIcon
                            source: "qrc:/icons/svg/log-out.svg"
                            sourceSize: Qt.size(14, 14)
                            anchors.fill: parent
                            fillMode: Image.Pad
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: parent
                            source: logoutIcon
                            colorizationColor: "#bfe6d6"
                            colorization: 1.0
                        }
                    }
                }
            }
        }
    }
}
