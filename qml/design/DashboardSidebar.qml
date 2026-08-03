import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// DashboardSidebar — Deep navy sidebar (Phase 3.2 polished)
//
// Fixes:
// - Icon contrast: muted light/slate normal, white hover, emerald-white selected
// - Selected state: emerald-tinted navy bg + emerald left indicator + white text
// - Profile area: clearer contrast on name/role/logout
// ============================================================================

Rectangle {
    id: sidebar

    property int currentIndex: 0
    signal navigated(int index)

    implicitWidth: Theme.sidebarWidth
    Layout.fillHeight: true
    Layout.fillWidth: false

    color: Theme.sidebarBg
    border.width: 0

    // Right edge separator
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Theme.sidebarBorder
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // ===== Logo / Brand =====
        Item {
            width: parent.width
            height: 64

            Row {
                anchors.centerIn: parent
                spacing: 10

                Rectangle {
                    width: 32; height: 32; radius: Theme.radiusMd
                    color: Theme.primary

                    Text {
                        anchors.centerIn: parent
                        text: "M"
                        font.family: Theme.fontFamilyDisplay
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.textOnPrimary
                    }
                }

                Column {
                    spacing: 0

                    Text {
                        text: "Minz Mahallu"
                        font.family: Theme.fontFamilyDisplay
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: Theme.sidebarLogo
                    }
                    Text {
                        text: "Management System"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: "#94a3b8"
                    }
                }
            }
        }

        // ===== Nav section label =====
        Item {
            width: parent.width
            height: 36

            Text {
                text: "MENU"
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.weight: Font.Bold
                color: "#64748b"
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ===== Nav items =====
        ListView {
            id: navList
            width: parent.width
            height: parent.height - 64 - 36 - 80
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
                height: 40
                x: 8
                padding: 0

                background: Rectangle {
                    radius: Theme.radiusMd
                    // Selected: emerald-tinted navy (slightly lighter than sidebar bg)
                    // Hover: lighter navy
                    // Normal: transparent
                    color: ListView.isCurrentItem ? "#1a3a2e" :
                           (hovered ? Theme.sidebarHover : "transparent")
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    // Emerald left indicator (selected only)
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3; height: 22
                        radius: 2
                        color: Theme.primary
                        visible: ListView.isCurrentItem
                    }
                }

                contentItem: Row {
                    spacing: 10
                    leftPadding: 14

                    // Icon
                    Item {
                        width: Theme.iconSizeMd
                        height: Theme.iconSizeMd
                        y: (parent.height - height) / 2

                        Image {
                            id: navIcon
                            source: "qrc:/icons/svg/" + model.icon + ".svg"
                            sourceSize: Qt.size(Theme.iconSizeMd, Theme.iconSizeMd)
                            anchors.fill: parent
                            fillMode: Image.Pad
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: parent
                            source: navIcon
                            // Selected: white, Hover: white, Normal: muted light slate
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
                        font.pixelSize: Theme.fontSizeMd
                        font.weight: ListView.isCurrentItem ? Font.Medium : Font.Normal
                        // Selected: white, Hover: white, Normal: muted light slate
                        color: ListView.isCurrentItem ?
                            "#ffffff" :
                            (hovered ? "#ffffff" : "#94a3b8")
                        y: (parent.height - height) / 2
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
            height: 80

            Rectangle {
                anchors.fill: parent
                anchors.margins: 8
                radius: Theme.radiusMd
                color: "#1e293b"
                border.width: 1
                border.color: "#334155"

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    // Avatar
                    Rectangle {
                        width: 34; height: 34; radius: 17
                        color: Theme.primary

                        Text {
                            anchors.centerIn: parent
                            text: "A"
                            font.family: Theme.fontFamilyDisplay
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: Theme.textOnPrimary
                        }
                    }

                    Column {
                        spacing: 1

                        Text {
                            text: "Admin User"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: "#e2e8f0"
                        }
                        Text {
                            text: "Administrator"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: "#94a3b8"
                        }
                    }

                    // Logout icon
                    Item {
                        width: 18; height: 18
                        y: (34 - 18) / 2

                        Image {
                            id: logoutIcon
                            source: "qrc:/icons/svg/log-out.svg"
                            sourceSize: Qt.size(16, 16)
                            anchors.fill: parent
                            fillMode: Image.Pad
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: parent
                            source: logoutIcon
                            colorizationColor: "#94a3b8"
                            colorization: 1.0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                        }
                    }
                }
            }
        }
    }
}
