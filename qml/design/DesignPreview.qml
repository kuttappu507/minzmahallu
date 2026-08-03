import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0
import "../components"

// ============================================================================
// DesignPreview — Phase 3.1 — Realistic Minz Mahallu Dashboard
//
// LAYOUT STRUCTURE (deterministic, no anchor/layout conflicts):
//
// ApplicationWindow
// └─ RowLayout (fills parent)
//    ├─ DashboardSidebar (fixed width, fills height)
//    └─ ColumnLayout (fills remaining width)
//       ├─ TopBar (fixed height)
//       └─ ScrollView (fills remaining)
//          └─ Column (content)
//
// RULE: Items inside RowLayout/ColumnLayout use Layout.* properties.
//       Items inside Row/Column use anchors or explicit x/y.
//       NEVER mix anchors with Layout.* on the same item.
// ============================================================================

ApplicationWindow {
    id: window
    visible: true
    width: 1280
    height: 800
    minimumWidth: 1024
    minimumHeight: 680
    title: "Minz Mahallu — Design Preview"
    color: Theme.canvas

    property bool showNotifications: false
    property bool showFamilyDialog: false

    // ===== ROOT: RowLayout (sidebar + content) =====
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ===== Sidebar =====
        DashboardSidebar {
            id: sidebar
            Layout.fillHeight: true
            Layout.fillWidth: false
            implicitWidth: Theme.sidebarWidth
            onNavigated: function(index) {
                // Visual only
            }
        }

        // ===== Main content area =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ===== Topbar =====
            Rectangle {
                id: topbar
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                Layout.fillHeight: false
                color: Theme.surface

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.borderSubtle
                }

                // Topbar content — uses Row (NOT RowLayout) with anchors
                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 24
                    anchors.rightMargin: 20

                    // Greeting (left)
                    Column {
                        id: greetingCol
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        Text {
                            text: "Dashboard"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXl
                            font.weight: Font.DemiBold
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Good evening, Admin"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.textSecondary
                        }
                    }

                    // User avatar (right)
                    Rectangle {
                        id: avatar
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 38; height: 38; radius: 19
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

                    // Notification bell (left of avatar)
                    Rectangle {
                        id: bellBtn
                        anchors.right: avatar.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 38; height: 38; radius: Theme.radiusMd
                        color: bellMA.containsMouse ? Theme.surfaceHover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 8
                            anchors.rightMargin: 8
                            width: 8; height: 8; radius: 4
                            color: Theme.coral
                            border.width: 2
                            border.color: Theme.surface
                        }

                        Item {
                            width: 18; height: 18
                            anchors.centerIn: parent

                            Image {
                                id: bellIcon
                                source: "qrc:/icons/svg/bell.svg"
                                sourceSize: Qt.size(18, 18)
                                anchors.fill: parent
                                fillMode: Image.Pad
                                visible: false
                            }
                            MultiEffect {
                                anchors.fill: parent
                                source: bellIcon
                                colorizationColor: bellMA.containsMouse ? Theme.primary : Theme.textSecondary
                                colorization: 1.0
                                Behavior on colorizationColor { ColorAnimation { duration: Theme.animFast } }
                            }
                        }

                        MouseArea {
                            id: bellMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: showNotifications = !showNotifications
                        }
                    }

                    // Search field (left of bell)
                    AppTextField {
                        id: searchField
                        anchors.right: bellBtn.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        variant: "search"
                        placeholderText: "Search families, members..."
                        width: 280
                    }
                }
            }

            // ===== Scrollable content =====
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    id: contentCol
                    width: window.width - sidebar.width
                    spacing: 24
                    topPadding: 24
                    bottomPadding: 32
                    leftPadding: 24
                    rightPadding: 24

                    // ═══════════════════════════════════════
                    // KPI CARDS ROW
                    // ═══════════════════════════════════════
                    Row {
                        width: parent.width - 48
                        spacing: 16

                        KpiCard {
                            label: "Total Families"
                            value: "512"
                            trend: "+12"
                            trendUp: true
                            subtitle: "this month"
                            accentName: "emerald"
                            iconName: "families"
                            width: (parent.width - 48) / 4
                        }
                        KpiCard {
                            label: "Total Members"
                            value: "2,345"
                            trend: "+28"
                            trendUp: true
                            subtitle: "this month"
                            accentName: "blue"
                            iconName: "members"
                            width: (parent.width - 48) / 4
                        }
                        KpiCard {
                            label: "Nikahs This Year"
                            value: "48"
                            trend: "+8"
                            trendUp: true
                            subtitle: "this month"
                            accentName: "orange"
                            iconName: "marriage"
                            width: (parent.width - 48) / 4
                        }
                        KpiCard {
                            label: "Collections (Month)"
                            value: "₹48,750"
                            trend: "+15%"
                            trendUp: true
                            subtitle: "from last month"
                            accentName: "violet"
                            iconName: "donations"
                            width: (parent.width - 48) / 4
                        }
                    }

                    // ═══════════════════════════════════════
                    // ACTIVITY + EVENTS ROW
                    // ═══════════════════════════════════════
                    Row {
                        width: parent.width - 48
                        spacing: 16

                        // Recent Activities
                        Rectangle {
                            width: (parent.width - 16) * 0.6
                            height: 340
                            radius: Theme.radiusLg
                            color: Theme.surface
                            border.width: 1
                            border.color: Theme.border

                            Column {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 0

                                Text {
                                    text: "Recent Activities"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeLg
                                    font.weight: Font.DemiBold
                                    color: Theme.textPrimary
                                }
                                Text {
                                    text: "Latest updates across the mahallu"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSm
                                    color: Theme.textSecondary
                                    topPadding: 2
                                    bottomPadding: 12
                                }

                                ListView {
                                    width: parent.width
                                    height: parent.height - 56
                                    clip: true
                                    spacing: 14
                                    topMargin: 4
                                    model: ListModel {
                                        ListElement { title: "New Nikah Registered"; subtitle: "Faisal P. & Amina K."; time: "2 hours ago"; icon: "marriage"; accent: "orange" }
                                        ListElement { title: "New Member Added"; subtitle: "Rashid K."; time: "5 hours ago"; icon: "members"; accent: "blue" }
                                        ListElement { title: "Collection Received"; subtitle: "₹2,500 from Ibrahim K."; time: "1 day ago"; icon: "donations"; accent: "violet" }
                                        ListElement { title: "Certificate Generated"; subtitle: "Nikah Certificate #NK/2025/043"; time: "2 days ago"; icon: "certificates"; accent: "cyan" }
                                    }

                                    delegate: Row {
                                        width: ListView.view.width
                                        spacing: 12

                                        Rectangle {
                                            width: 36; height: 36; radius: Theme.radiusMd
                                            color: Theme.accent(model.accent).subtle
                                            border.width: 1
                                            border.color: Theme.accent(model.accent).subtleAlt

                                            Item {
                                                width: 16; height: 16
                                                anchors.centerIn: parent

                                                Image {
                                                    id: actIcon
                                                    source: "qrc:/icons/svg/" + model.icon + ".svg"
                                                    sourceSize: Qt.size(16, 16)
                                                    anchors.fill: parent
                                                    fillMode: Image.Pad
                                                    visible: false
                                                }
                                                MultiEffect {
                                                    anchors.fill: parent
                                                    source: actIcon
                                                    colorizationColor: Theme.accent(model.accent).main
                                                    colorization: 1.0
                                                }
                                            }
                                        }

                                        Column {
                                            width: parent.width - 36 - 12
                                            spacing: 1

                                            Text {
                                                text: model.title
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSizeMd
                                                font.weight: Font.Medium
                                                color: Theme.textPrimary
                                            }
                                            Text {
                                                text: model.subtitle
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSizeSm
                                                color: Theme.textSecondary
                                            }
                                            Text {
                                                text: model.time
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSizeXs
                                                color: Theme.textTertiary
                                                topPadding: 2
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Upcoming Events
                        Rectangle {
                            width: (parent.width - 16) * 0.4
                            height: 340
                            radius: Theme.radiusLg
                            color: Theme.surface
                            border.width: 1
                            border.color: Theme.border

                            Column {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 0

                                Text {
                                    text: "Upcoming Events"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeLg
                                    font.weight: Font.DemiBold
                                    color: Theme.textPrimary
                                }
                                Text {
                                    text: "Next 2 weeks"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSm
                                    color: Theme.textSecondary
                                    topPadding: 2
                                    bottomPadding: 16
                                }

                                ListView {
                                    width: parent.width
                                    height: parent.height - 56
                                    clip: true
                                    spacing: 12
                                    model: ListModel {
                                        ListElement { day: "24"; month: "MAY"; title: "Jumma Khutbah"; time: "12:30 PM"; accent: "emerald" }
                                        ListElement { day: "30"; month: "MAY"; title: "Mahallu Meeting"; time: "7:00 PM"; accent: "blue" }
                                        ListElement { day: "07"; month: "JUN"; title: "Quran Study Circle"; time: "6:30 PM"; accent: "violet" }
                                    }

                                    delegate: Row {
                                        width: ListView.view.width
                                        spacing: 12

                                        Rectangle {
                                            width: 48; height: 48; radius: Theme.radiusMd
                                            color: Theme.accent(model.accent).subtle
                                            border.width: 1
                                            border.color: Theme.accent(model.accent).subtleAlt

                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 0

                                                Text {
                                                    text: model.day
                                                    font.family: Theme.fontFamilyDisplay
                                                    font.pixelSize: 16
                                                    font.weight: Font.Bold
                                                    color: Theme.accent(model.accent).main
                                                    horizontalAlignment: Text.AlignHCenter
                                                }
                                                Text {
                                                    text: model.month
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: 9
                                                    font.weight: Font.Bold
                                                    color: Theme.accent(model.accent).main
                                                    horizontalAlignment: Text.AlignHCenter
                                                }
                                            }
                                        }

                                        Column {
                                            width: parent.width - 48 - 12
                                            spacing: 1
                                            y: (48 - height) / 2

                                            Text {
                                                text: model.title
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSizeMd
                                                font.weight: Font.Medium
                                                color: Theme.textPrimary
                                            }
                                            Text {
                                                text: model.time
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSizeSm
                                                color: Theme.textSecondary
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ═══════════════════════════════════════
                    // FAMILIES TABLE
                    // ═══════════════════════════════════════
                    Rectangle {
                        width: parent.width - 48
                        height: 480
                        radius: Theme.radiusLg
                        color: Theme.surface
                        border.width: 1
                        border.color: Theme.border

                        Column {
                            anchors.fill: parent
                            spacing: 0

                            // Table header
                            Rectangle {
                                width: parent.width
                                height: 64
                                color: "transparent"

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 1
                                    color: Theme.borderSubtle
                                }

                                // Header content — anchors only
                                Item {
                                    anchors.fill: parent
                                    anchors.leftMargin: 20
                                    anchors.rightMargin: 20

                                    Column {
                                        id: tableTitleCol
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 0

                                        Text {
                                            text: "Families"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeLg
                                            font.weight: Font.DemiBold
                                            color: Theme.textPrimary
                                        }
                                        Text {
                                            text: "Manage all registered families"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSm
                                            color: Theme.textSecondary
                                        }
                                    }

                                    AppButton {
                                        id: addFamilyBtn
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Add Family"
                                        variant: "primary"
                                        iconSource: "qrc:/icons/svg/plus.svg"
                                        onClicked: showFamilyDialog = true
                                    }

                                    AppComboBox {
                                        id: wardFilter
                                        anchors.right: addFamilyBtn.left
                                        anchors.rightMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        model: ["All Wards", "Ward 1", "Ward 2", "Ward 3"]
                                        width: 140
                                    }

                                    AppTextField {
                                        id: tableSearch
                                        anchors.right: wardFilter.left
                                        anchors.rightMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        variant: "search"
                                        placeholderText: "Search..."
                                        width: 200
                                    }
                                }
                            }

                            // Column headers
                            Rectangle {
                                width: parent.width
                                height: 40
                                color: Theme.surfaceSubtle

                                // Header row — uses Row with fixed widths, no anchors
                                Row {
                                    x: 20
                                    width: parent.width - 40
                                    spacing: 0

                                    Text { text: "FAMILY ID"; width: 90; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary }
                                    Text { text: "HOUSE NAME"; width: 160; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary }
                                    Text { text: "HEAD OF FAMILY"; width: 150; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary }
                                    Text { text: "WARD"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary }
                                    Text { text: "MEMBERS"; width: 70; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary }
                                    Text { text: "PHONE"; width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary }
                                    Text { text: "STATUS"; width: 100; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary }
                                    Item { width: parent.width - 90 - 160 - 150 - 80 - 70 - 120 - 100 - 80; height: 40 }
                                    Text { text: "ACTIONS"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary }
                                }
                            }

                            // Data rows
                            ListView {
                                id: familyTable
                                width: parent.width
                                height: parent.height - 64 - 40 - 48
                                clip: true
                                spacing: 0

                                model: ListModel {
                                    ListElement { famId: "KH-F-0001"; house: "Manzil Manzoor"; head: "Manzoor PP"; ward: "Ward 1"; members: 5; phone: "9847123456"; status: "active" }
                                    ListElement { famId: "KH-F-0002"; house: "Puthanpurayil"; head: "Rahim PT"; ward: "Ward 1"; members: 4; phone: "9847234567"; status: "active" }
                                    ListElement { famId: "KH-F-0003"; house: "Kizhakkepuram"; head: "Sulaiman K"; ward: "Ward 2"; members: 6; phone: "9847345678"; status: "active" }
                                    ListElement { famId: "KH-F-0004"; house: "Vadakke Veettil"; head: "Hameed V"; ward: "Ward 2"; members: 3; phone: "9847456789"; status: "overdue" }
                                    ListElement { famId: "KH-F-0005"; house: "Thekkepuram"; head: "Yusuf T"; ward: "Ward 3"; members: 7; phone: "9847567890"; status: "active" }
                                    ListElement { famId: "KH-F-0006"; house: "Purayil House"; head: "Jameel P"; ward: "Ward 3"; members: 4; phone: "9847678901"; status: "pending" }
                                    ListElement { famId: "KH-F-0007"; house: "Madappattu"; head: "Ansar M"; ward: "Ward 4"; members: 5; phone: "9847789012"; status: "archived" }
                                }

                                delegate: Rectangle {
                                    width: familyTable.width
                                    height: 44
                                    color: index % 2 === 0 ? Theme.surface : Theme.surfaceSubtle

                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 1
                                        color: Theme.borderSubtle
                                    }

                                    Row {
                                        x: 20
                                        width: parent.width - 40
                                        spacing: 0

                                        Text { text: model.famId; width: 90; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.Medium; color: Theme.textPrimary }
                                        Text { text: model.house; width: 160; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textPrimary; elide: Text.ElideRight }
                                        Text { text: model.head; width: 150; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary; elide: Text.ElideRight }
                                        Text { text: model.ward; width: 80; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary }
                                        Text { text: model.members; width: 70; height: 44; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textPrimary }
                                        Text { text: model.phone; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary }

                                        Item {
                                            width: 100; height: 44
                                            StatusBadge {
                                                x: 0
                                                y: (44 - height) / 2
                                                text: model.status.charAt(0).toUpperCase() + model.status.slice(1)
                                                variant: model.status
                                            }
                                        }

                                        Item { width: parent.width - 90 - 160 - 150 - 80 - 70 - 120 - 100 - 80; height: 44 }

                                        Row {
                                            width: 80; height: 44
                                            spacing: 4
                                            x: 0

                                            IconButton {
                                                y: (44 - height) / 2
                                                iconName: "edit"
                                                compact: true
                                                iconSize: 15
                                                tooltipText: "Edit"
                                            }
                                            IconButton {
                                                y: (44 - height) / 2
                                                iconName: "trash"
                                                compact: true
                                                iconSize: 15
                                                variant: "danger"
                                                tooltipText: "Delete"
                                            }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.NoButton
                                        onContainsMouseChanged: parent.color = containsMouse ? Theme.surfaceHover : (index % 2 === 0 ? Theme.surface : Theme.surfaceSubtle)
                                    }
                                }
                            }

                            // Pagination
                            Rectangle {
                                width: parent.width
                                height: 48
                                color: Theme.surfaceSubtle

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 1
                                    color: Theme.borderSubtle
                                }

                                Item {
                                    anchors.fill: parent
                                    anchors.leftMargin: 20
                                    anchors.rightMargin: 20

                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Showing 1-7 of 512 families"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        color: Theme.textSecondary
                                    }

                                    Row {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 8

                                        IconButton { iconName: "chevron-left"; compact: true; tooltipText: "Previous" }
                                        Text { text: "1"; height: 24; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; width: 24; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.Bold; color: Theme.primary }
                                        Text { text: "2"; height: 24; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; width: 24; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary }
                                        Text { text: "3"; height: 24; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; width: 24; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary }
                                        Text { text: "…"; height: 24; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; width: 24; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary }
                                        Text { text: "73"; height: 24; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; width: 24; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary }
                                        IconButton { iconName: "chevron-right"; compact: true; tooltipText: "Next" }
                                    }
                                }
                            }
                        }
                    }

                    // ═══════════════════════════════════════
                    // COMPONENT STATE EXAMPLES
                    // ═══════════════════════════════════════
                    Rectangle {
                        width: parent.width - 48
                        height: 280
                        radius: Theme.radiusLg
                        color: Theme.surface
                        border.width: 1
                        border.color: Theme.border

                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 16

                            Text {
                                text: "Component States"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeLg
                                font.weight: Font.DemiBold
                                color: Theme.textPrimary
                            }

                            // Buttons
                            Row {
                                spacing: 16
                                width: parent.width

                                Text { text: "Buttons"; width: 100; height: 36; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textTertiary }
                                AppButton { text: "Primary"; variant: "primary" }
                                AppButton { text: "Secondary"; variant: "secondary" }
                                AppButton { text: "Ghost"; variant: "ghost" }
                                AppButton { text: "Danger"; variant: "danger" }
                                AppButton { text: "Disabled"; variant: "primary"; enabled: false }
                            }

                            // Text fields
                            Row {
                                spacing: 16
                                width: parent.width

                                Text { text: "Fields"; width: 100; height: 60; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textTertiary }
                                AppTextField { label: "Normal"; placeholderText: "Type..."; width: 180 }
                                AppTextField { label: "With Icon"; placeholderText: "Phone"; leadingIcon: "user"; width: 180 }
                                AppTextField { label: "Error"; placeholderText: "123"; text: "123"; error: true; errorText: "Invalid"; width: 180 }
                            }

                            // Status badges
                            Row {
                                spacing: 16
                                width: parent.width

                                Text { text: "Badges"; width: 100; height: 24; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textTertiary }
                                StatusBadge { text: "Active"; variant: "active" }
                                StatusBadge { text: "Pending"; variant: "pending" }
                                StatusBadge { text: "Overdue"; variant: "overdue" }
                                StatusBadge { text: "Archived"; variant: "archived" }
                                StatusBadge { text: "Paid"; variant: "paid" }
                                StatusBadge { text: "Approved"; variant: "approved" }
                            }

                            // Icon buttons
                            Row {
                                spacing: 16
                                width: parent.width

                                Text { text: "Icons"; width: 100; height: 36; verticalAlignment: Text.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textTertiary }
                                IconButton { iconName: "edit"; compact: true; tooltipText: "Edit" }
                                IconButton { iconName: "trash"; compact: true; variant: "danger"; tooltipText: "Delete" }
                                IconButton { iconName: "check"; compact: true; variant: "primary"; tooltipText: "Approve" }
                                IconButton { iconName: "download"; compact: true; tooltipText: "Download" }
                                IconButton { iconName: "settings"; compact: true; variant: "selected"; tooltipText: "Settings" }
                                IconButton { iconName: "search"; compact: true; tooltipText: "Search" }
                            }
                        }
                    }
                }
            }
        }
    }

    // ===== Notification Popover =====
    Rectangle {
        id: notifPopover
        visible: showNotifications
        x: window.width - width - 20
        y: 64
        z: 100
        width: 360
        height: 400
        radius: Theme.radiusLg
        color: Theme.surface
        border.width: 1
        border.color: Theme.border

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0.02, 0.05, 0.15, Theme.shadowOpacityLarge)
            shadowBlur: 0.6
            shadowVerticalOffset: 6
        }

        Column {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                width: parent.width
                height: 52
                color: "transparent"

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.borderSubtle
                }

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Notifications"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        font.weight: Font.DemiBold
                        color: Theme.textPrimary
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Mark all read"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.primary

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {}
                        }
                    }
                }
            }

            ListView {
                width: parent.width
                height: parent.height - 52 - 48
                clip: true
                spacing: 0
                model: ListModel {
                    ListElement { title: "New Nikah Registered"; subtitle: "Faisal P. & Amina K."; time: "2h ago"; icon: "marriage"; accent: "orange" }
                    ListElement { title: "New Member Added"; subtitle: "Rashid K. added to KH-F-0003"; time: "5h ago"; icon: "members"; accent: "blue" }
                    ListElement { title: "Collection Received"; subtitle: "₹2,500 from Ibrahim K."; time: "1d ago"; icon: "donations"; accent: "violet" }
                    ListElement { title: "Certificate Generated"; subtitle: "Nikah Cert #NK/2025/043"; time: "2d ago"; icon: "certificates"; accent: "cyan" }
                }

                delegate: ItemDelegate {
                    width: parent.width
                    height: 64
                    padding: 0

                    background: Rectangle {
                        color: hovered ? Theme.surfaceHover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    contentItem: Row {
                        spacing: 12
                        leftPadding: 16
                        rightPadding: 16

                        Rectangle {
                            width: 32; height: 32; radius: Theme.radiusSm
                            color: Theme.accent(model.accent).subtle
                            border.width: 1
                            border.color: Theme.accent(model.accent).subtleAlt
                            y: (64 - 32) / 2

                            Item {
                                width: 14; height: 14
                                anchors.centerIn: parent

                                Image {
                                    id: notifIcon
                                    source: "qrc:/icons/svg/" + model.icon + ".svg"
                                    sourceSize: Qt.size(14, 14)
                                    anchors.fill: parent
                                    fillMode: Image.Pad
                                    visible: false
                                }
                                MultiEffect {
                                    anchors.fill: parent
                                    source: notifIcon
                                    colorizationColor: Theme.accent(model.accent).main
                                    colorization: 1.0
                                }
                            }
                        }

                        Column {
                            width: parent.width - 32 - 12 - 32 - 16 - 16
                            y: (64 - height) / 2
                            spacing: 1

                            Text {
                                text: model.title
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSm
                                font.weight: Font.Medium
                                color: Theme.textPrimary
                            }
                            Text {
                                text: model.subtitle
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeXs
                                color: Theme.textSecondary
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        Text {
                            text: model.time
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.textTertiary
                            y: (64 - height) / 2
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 48
                color: Theme.surfaceSubtle

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.borderSubtle
                }

                Text {
                    anchors.centerIn: parent
                    text: "View all notifications"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSm
                    font.weight: Font.Medium
                    color: Theme.primary

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: showNotifications = false
                    }
                }
            }
        }
    }

    // Click outside to close popover
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        enabled: showNotifications
        z: 99
        onClicked: showNotifications = false
    }

    // ===== Family Edit Dialog =====
    FamilyEditDialog {
        id: familyDlg
        visible: showFamilyDialog
        title: "Add Family"
        x: (window.width - width) / 2
        y: (window.height - height) / 2
        onAccepted: showFamilyDialog = false
        onRejected: showFamilyDialog = false
    }
}
