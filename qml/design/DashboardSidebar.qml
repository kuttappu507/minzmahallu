import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// DashboardSidebar — Deep navy sidebar with navigation
//
// Layout: Rectangle root → Column (fills parent)
//   - Logo header (fixed height)
//   - Section label (fixed height)
//   - Nav ListView (fills remaining)
//   - User profile card (fixed height)
// ============================================================================

Rectangle {
    id: sidebar

    property int currentIndex: 0
    signal navigated(int index)

    // ===== Sizing — controlled by parent RowLayout =====
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
                        color: Theme.sidebarTextMuted
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
                color: Theme.sidebarTextMuted
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ===== Nav items =====
        ListView {
            id: navList
            width: parent.width
            height: parent.height - 64 - 36 - 76   // logo + label + user card
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

                background: Rectangle {
                    radius: Theme.radiusMd
                    color: ListView.isCurrentItem ? Theme.sidebarActive :
                           (hovered ? Theme.sidebarHover : "transparent")
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3; height: 20
                        radius: 2
                        color: Theme.primary
                        visible: ListView.isCurrentItem
                    }
                }

                contentItem: Row {
                    spacing: 10
                    leftPadding: 12

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
                            colorizationColor: ListView.isCurrentItem ?
                                Theme.sidebarTextActive :
                                (hovered ? Theme.sidebarTextActive : Theme.sidebarText)
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
                            (hovered ? Theme.sidebarTextActive : Theme.sidebarText)
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
            height: 76

            Rectangle {
                anchors.fill: parent
                anchors.margins: 8
                radius: Theme.radiusMd
                color: Theme.sidebarHover
                opacity: 0.5
                border.width: 1
                border.color: Theme.sidebarBorder

                Row {
                    anchors.centerIn: parent
                    spacing: 10

                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: Theme.primary

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

                    Item {
                        width: 18; height: 18

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
}
