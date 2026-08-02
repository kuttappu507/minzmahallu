import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// DashboardSidebar — Deep navy sidebar with navigation
//
// Features:
//   - Deep navy background (#0f172a)
//   - Application logo + name at top
//   - Nav items with SVG icons
//   - Hover: subtle lighter navy background
//   - Active: emerald left indicator + white text
//   - User profile area at bottom
// ============================================================================

Rectangle {
    id: sidebar

    property int currentIndex: 0
    signal navigated(int index)

    width: Theme.sidebarWidth
    color: Theme.sidebarBg
    border.width: 0

    // Subtle right edge to separate from content
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

            RowLayout {
                anchors.centerIn: parent
                spacing: 10

                // Logo icon container
                Rectangle {
                    width: 32; height: 32; radius: Theme.radiusMd
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter

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
                    anchors.verticalCenter: parent.verticalCenter

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
                        color: Theme.sidebarTextMuted
                    }
                }
            }
        }

        // ===== Nav section label =====
        Text {
            text: "MENU"
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            color: Theme.sidebarTextMuted
            leftPadding: 20
            topPadding: 12
            bottomPadding: 8
        }

        // ===== Nav items =====
        ListView {
            id: navList
            width: parent.width
            height: parent.height - 64 - 40 - 80   // logo + section label + user card
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
                height: 38
                x: 8
                padding: 0
                leftPadding: 12

                background: Rectangle {
                    radius: Theme.radiusMd
                    color: ListView.isCurrentItem ? Theme.sidebarActive :
                           (hovered ? Theme.sidebarHover : "transparent")
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    // Emerald active indicator (left bar)
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3; height: 20
                        radius: 2
                        color: Theme.primary
                        visible: ListView.isCurrentItem
                    }
                }

                contentItem: RowLayout {
                    spacing: 10

                    Item {
                        width: Theme.iconSizeMd; height: Theme.iconSizeMd
                        anchors.verticalCenter: parent.verticalCenter

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
                            colorizationColor: ListView.isCurrentItem ?
                                Theme.sidebarTextActive :
                                (parent.parent.hovered ? Theme.sidebarTextActive : Theme.sidebarText)
                            colorization: 1.0
                            Behavior on colorizationColor { ColorAnimation { duration: Theme.animFast } }
                        }
                    }

                    Text {
                        text: model.label
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        font.weight: ListView.isCurrentItem ? Font.Medium : Font.Normal
                        color: ListView.isCurrentItem ?
                            Theme.sidebarTextActive :
                            (parent.parent.hovered ? Theme.sidebarTextActive : Theme.sidebarText)
                        anchors.verticalCenter: parent.verticalCenter
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
        Rectangle {
            width: parent.width - 16
            height: 64
            x: 8
            radius: Theme.radiusMd
            color: "transparent"
            border.width: 1
            border.color: Theme.sidebarBorder

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Theme.sidebarHover
                opacity: 0.5
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 10

                // Avatar
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "A"
                        font.family: Theme.fontFamilyDisplay
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: Theme.textOnPrimary
                    }
                }

                Column {
                    spacing: 0
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "Admin User"
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: Theme.sidebarTextActive
                    }
                    Text {
                        text: "Administrator"
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.sidebarTextMuted
                    }
                }

                Item { width: 1; height: 1 }

                // Logout icon
                Item {
                    width: 18; height: 18
                    anchors.verticalCenter: parent.verticalCenter

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
                        colorizationColor: Theme.sidebarTextMuted
                        colorization: 1.0
                    }
                }
            }
        }
    }
}
