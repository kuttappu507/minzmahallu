import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
import "../pages"

ApplicationWindow {
    id: window
    visible: true
    width: 1600; height: 900
    minimumWidth: 1024; minimumHeight: 640
    title: "Minz Mahallu Management System"
    color: "#e7f4ea"

    property int currentNavIndex: 0
    readonly property int contentWidth: width - 260

    // Responsive column count for dashboard grids.
    // Bound to contentWidth (window width minus 260px sidebar).
    // 5 cards × 180px min + 4 × 12px gap + 36px margins = 984px needed for 5 cols.
    // At default 1600px window → contentWidth 1340 → 5 columns.
    // At 1920px full screen → contentWidth 1660 → 5 columns.
    readonly property int responsiveColumns: {
        var cw = contentWidth
        if (cw >= 1000) return 5
        if (cw >= 800)  return 4
        if (cw >= 600)  return 3
        if (cw >= 400)  return 2
        return 1
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ===== SIDEBAR =====
        Rectangle {
            Layout.fillHeight: true; Layout.fillWidth: false; implicitWidth: 260
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0;  color: "#0a7f5d" }
                GradientStop { position: 0.42; color: "#065f46" }
                GradientStop { position: 1.0;  color: "#044633" }
            }

            Column {
                anchors.fill: parent; spacing: 0

                Item {
                    width: parent.width; height: 72
                    Row {
                        x: 18; y: 18; spacing: 11
                        Rectangle {
                            width: 38; height: 38; radius: 14; color: Qt.rgba(255,255,255,0.14)
                            Text { anchors.centerIn: parent; text: "M"; font.family: "Poppins"; font.pixelSize: 16; font.weight: Font.Bold; color: "#ffffff" }
                        }
                        Column {
                            spacing: 0
                            Text { text: "MMS"; font.family: "Poppins"; font.pixelSize: 17; font.weight: Font.Bold; color: "#ffffff" }
                            Text { text: "Minz Mahallu"; font.family: "Poppins"; font.pixelSize: 10; font.weight: Font.DemiBold; color: "#a5dcc6" }
                        }
                    }
                }

                Text {
                    text: "OVERVIEW"; font.family: "Poppins"; font.pixelSize: 9; font.weight: Font.Bold
                    color: Qt.rgba(214/255, 240/255, 228/255, 0.42)
                    leftPadding: 24; topPadding: 15; bottomPadding: 5
                }

                ListView {
                    id: navList
                    width: parent.width; height: parent.height - 72 - 36 - 80
                    clip: true; spacing: 2; interactive: false
                    currentIndex: window.currentNavIndex
                    model: ListModel {
                        ListElement { label: "Dashboard";     icon: "dashboard" }
                        ListElement { label: "Families";      icon: "families" }
                        ListElement { label: "Members";       icon: "members" }
                        ListElement { label: "Subscriptions"; icon: "subscriptions" }
                        ListElement { label: "Donations";     icon: "donations" }
                        ListElement { label: "Accounting";    icon: "accounting" }
                        ListElement { label: "Marriage";      icon: "marriage" }
                        ListElement { label: "Death";         icon: "death" }
                        ListElement { label: "Welfare";       icon: "welfare" }
                        ListElement { label: "Certificates";  icon: "certificates" }
                        ListElement { label: "Tokens";        icon: "token" }
                        ListElement { label: "Reports";       icon: "reports" }
                        ListElement { label: "Settings";      icon: "settings" }
                        ListElement { label: "Users";         icon: "users" }
                        ListElement { label: "Audit Log";     icon: "audit" }
                        ListElement { label: "Backup";        icon: "backup" }
                    }

                    delegate: Item {
                        width: navList.width - 20; height: 40; x: 10

                        // Background: selected = stronger tint + gold indicator;
                        //             hover (non-selected) = subtle tint only
                        Rectangle {
                            id: navRect; anchors.fill: parent; radius: 9
                            color: ListView.isCurrentItem
                                   ? Qt.rgba(255,255,255,0.14)
                                   : (navMA.containsMouse ? Qt.rgba(255,255,255,0.06) : "transparent")
                            Behavior on color { ColorAnimation { duration: 140 } }
                            // Gold indicator ONLY on selected item
                            Rectangle {
                                x: -10; y: (40 - 22) / 2; width: 4; height: 22; radius: 4
                                color: "#f2c14e"; visible: ListView.isCurrentItem
                            }
                        }

                        Row {
                            x: 13; y: 0; height: 40; spacing: 12
                            Item { width: 18; height: 18; y: (40 - 18) / 2
                                Image { id: navIcon; source: "qrc:/icons/svg/" + model.icon + ".svg"; sourceSize: Qt.size(18, 18); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                                MultiEffect {
                                    anchors.fill: parent; source: navIcon
                                    // Selected = white; hover (non-selected) = light green; normal = muted green
                                    colorizationColor: ListView.isCurrentItem ? "#ffffff" : (navMA.containsMouse ? "#d6f5e7" : "#a5dcc6")
                                    colorization: 1.0
                                    Behavior on colorizationColor { ColorAnimation { duration: 140 } }
                                }
                            }
                            Text {
                                text: model.label; font.family: "Poppins"; font.pixelSize: 13
                                // Selected = DemiBold + white; hover = Medium + light green; normal = Medium + muted green
                                font.weight: ListView.isCurrentItem ? Font.DemiBold : Font.Medium
                                color: ListView.isCurrentItem ? "#ffffff" : (navMA.containsMouse ? "#d6f5e7" : "#a5dcc6")
                                y: (40 - height) / 2
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                        }
                        MouseArea { id: navMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { navList.currentIndex = index; window.currentNavIndex = index } }
                    }
                }

                Item {
                    width: parent.width; height: 80
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Qt.rgba(255/255,255/255,255/255,0.14) }
                    Rectangle { x: 10; y: 9; width: profileRow.width + 8; height: profileRow.height + 8; radius: 9; color: Qt.rgba(255/255,255/255,255/255, profileHover.containsMouse ? 0.06 : 0); Behavior on color { ColorAnimation { duration: 120 } } z: -1 }
                    HoverHandler { id: profileHover; cursorShape: Qt.PointingHandCursor }
                    Row {
                        id: profileRow; x: 14; y: 13; spacing: 10
                        Rectangle { width: 36; height: 36; radius: 9; color: "#f2c14e"; border.width: 2; border.color: "#b98317"
                            Text { anchors.centerIn: parent; text: "AK"; font.family: "Poppins"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#4a3606" } }
                        Column { spacing: 0
                            Text { text: "Abdul Kareem"; font.family: "Poppins"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#ffffff" }
                            Text { text: "Administrator"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Normal; color: "#9fd8c3" }
                        }
                    }
                }
            }
        }

        // ===== MAIN CONTENT =====
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

            // ===== Topbar — breadcrumb left, search right. Nothing in center. =====
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 58; color: "#ffffff"
                Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#d2e5d8" }

                // Breadcrumb (left)
                Row {
                    anchors.left: parent.left; anchors.leftMargin: 24; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                    Text { text: "MINZ MAHALLU /"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Bold; color: "#7e968a"; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: navList.model.get(navList.currentIndex) ? navList.model.get(navList.currentIndex).label : "Dashboard"; font.family: "Poppins"; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#12241b"; anchors.verticalCenter: parent.verticalCenter }
                }

                // Search field (right)
                Rectangle {
                    anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter
                    width: 250; height: 38; radius: 9
                    color: "#f2faf4"; border.width: 1
                    border.color: searchInput.activeFocus ? "#059669" : (searchHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    HoverHandler { id: searchHover; cursorShape: Qt.IBeamCursor }
                    Item {
                        width: 16; height: 16
                        anchors.left: parent.left; anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        Image { id: shellSearchIcon; source: "qrc:/icons/svg/search.svg"; sourceSize: Qt.size(16, 16); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                        MultiEffect { anchors.fill: parent; source: shellSearchIcon; colorizationColor: searchInput.activeFocus ? "#059669" : "#7e968a"; colorization: 1.0; Behavior on colorizationColor { ColorAnimation { duration: 120 } } }
                    }
                    TextField {
                        id: searchInput
                        anchors.left: parent.left; anchors.leftMargin: 32
                        anchors.right: parent.right; anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        placeholderText: "Search records..."
                        placeholderTextColor: "#7e968a"
                        font.family: "Poppins"; font.pixelSize: 13; color: "#12241b"
                        background: Item {}
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Page content — switches based on nav
            StackLayout {
                id: pageStack
                Layout.fillWidth: true; Layout.fillHeight: true
                currentIndex: window.currentNavIndex

                // 0 - Dashboard
                Loader { source: "qrc:/qml/design/DashboardPage.qml" }

                // 1 - Families
                FamiliesPage {}

                // 2 - Members
                MembersPage {}

                // 3 - Subscriptions
                SubscriptionsPage {}

                // 4-15 - Placeholder pages
                Repeater {
                    model: 12
                    delegate: Item {
                        Column {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: navList.model.get(index + 4) ? navList.model.get(index + 4).label : ""; font.family: "Poppins"; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#7e968a"; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "Coming soon"; font.family: "Poppins"; font.pixelSize: 12; color: "#7e968a"; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }
                }
            }
        }
    }
}
