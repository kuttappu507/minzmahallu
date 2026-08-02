import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0
import "../components"



// ============================================================================
// DesignPreview — Phase 3.1 — Realistic Minz Mahallu Dashboard
//
// This is a VISUAL PROTOTYPE only. No backend connection.
// Shows what the real application should look like:
//   - Navy sidebar with navigation
//   - Topbar with greeting, search, notifications, user
//   - 4 colorful KPI cards
//   - Recent activities + upcoming events
//   - Families data table with status badges + row actions
//   - Component state examples
//   - Modal dialog + notification popover
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

    // ===== State =====
    property bool showNotifications: false
    property bool showFamilyDialog: false

    // ===== Main layout: sidebar + content =====
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        DashboardSidebar {
            id: sidebar
            height: parent.height
            onNavigated: function(index) {
                // Visual only — no actual navigation
            }
        }

        // Content area
        Column {
            width: parent.width - sidebar.width
            height: parent.height
            spacing: 0

            // ===== Topbar =====
            Rectangle {
                width: parent.width
                height: 64
                color: Theme.surface

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Theme.borderSubtle
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 16

                    Column {
                        spacing: 0
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "Dashboard"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeXl
                            font.weight: Font.SemiBold
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Good evening, Admin"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.textSecondary
                        }
                    }

                    Item { Layout.fillWidth: true; height: 1 }

                    // Search field
                    AppTextField {
                        variant: "search"
                        placeholderText: "Search families, members..."
                        width: 280
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Notification bell
                    Rectangle {
                        width: 38; height: 38; radius: Theme.radiusMd
                        color: bellMA.containsMouse ? Theme.surfaceHover : "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        // Notification dot
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

                    // User avatar
                    Rectangle {
                        width: 38; height: 38; radius: 19
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "A"
                            font.family: Theme.fontFamilyDisplay
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: Theme.textOnPrimary
                        }
                    }
                }
            }

            // ===== Scrollable content =====
            ScrollView {
                width: parent.width
                height: parent.height - 64
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: window.width - sidebar.width
                    spacing: 24
                    topPadding: 24
                    bottomPadding: 32

                    // ═══════════════════════════════════════
                    // KPI CARDS ROW
                    // ═══════════════════════════════════════
                    RowLayout {
                        spacing: 16
                        width: parent.width - 48

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
                    RowLayout {
                        spacing: 16
                        width: parent.width - 48

                        // Recent Activities
                        Rectangle {
                            width: (parent.width - 16) * 0.6
                            height: 320
                            radius: Theme.radiusLg
                            color: Theme.surface
                            border.width: 1
                            border.color: Theme.border

                            Column {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 0

                                // Header
                                Text {
                                    text: "Recent Activities"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeLg
                                    font.weight: Font.SemiBold
                                    color: Theme.textPrimary
                                }
                                Text {
                                    text: "Latest updates across the mahallu"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSm
                                    color: Theme.textSecondary
                                    topPadding: 2
                                    bottomPadding: 16
                                }

                                // Activity items
                                ListView {
                                    width: parent.width
                                    height: parent.height - 60
                                    clip: true
                                    spacing: 12
                                    model: ListModel {
                                        ListElement { title: "New Nikah Registered"; subtitle: "Faisal P. & Amina K."; time: "2 hours ago"; icon: "marriage"; accent: "orange" }
                                        ListElement { title: "New Member Added"; subtitle: "Rashid K."; time: "5 hours ago"; icon: "members"; accent: "blue" }
                                        ListElement { title: "Collection Received"; subtitle: "₹2,500 from Ibrahim K."; time: "1 day ago"; icon: "donations"; accent: "violet" }
                                        ListElement { title: "Certificate Generated"; subtitle: "Nikah Certificate #NK/2025/043"; time: "2 days ago"; icon: "certificates"; accent: "cyan" }
                                    }

                                    delegate: RowLayout {
                                        width: ListView.view.width
                                        spacing: 12

                                        // Colorful icon container
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
                                            spacing: 1
                                            width: parent.width - 36 - 12

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
                            height: 320
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
                                    font.weight: Font.SemiBold
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
                                    height: parent.height - 60
                                    clip: true
                                    spacing: 12
                                    model: ListModel {
                                        ListElement { day: "24"; month: "MAY"; title: "Jumma Khutbah"; time: "12:30 PM"; accent: "emerald" }
                                        ListElement { day: "30"; month: "MAY"; title: "Mahallu Meeting"; time: "7:00 PM"; accent: "blue" }
                                        ListElement { day: "07"; month: "JUN"; title: "Quran Study Circle"; time: "6:30 PM"; accent: "violet" }
                                    }

                                    delegate: RowLayout {
                                        width: ListView.view.width
                                        spacing: 12

                                        // Date block
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
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }
                                                Text {
                                                    text: model.month
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: 9
                                                    font.weight: Font.Bold
                                                    color: Theme.accent(model.accent).main
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }
                                            }
                                        }

                                        Column {
                                            spacing: 1
                                            anchors.verticalCenter: parent.verticalCenter

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
                            anchors.margins: 0
                            spacing: 0

                            // Table header
                            Rectangle {
                                width: parent.width
                                height: 64
                                color: "transparent"

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 1
                                    color: Theme.borderSubtle
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 12

                                    Column {
                                        spacing: 0
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: "Families"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeLg
                                            font.weight: Font.SemiBold
                                            color: Theme.textPrimary
                                        }
                                        Text {
                                            text: "Manage all registered families"
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeSm
                                            color: Theme.textSecondary
                                        }
                                    }

                                    Item { Layout.fillWidth: true; height: 1 }

                                    AppTextField {
                                        variant: "search"
                                        placeholderText: "Search..."
                                        width: 220
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    AppComboBox {
                                        model: ["All Wards", "Ward 1", "Ward 2", "Ward 3"]
                                        width: 140
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    AppButton {
                                        text: "Add Family"
                                        variant: "primary"
                                        iconSource: "qrc:/icons/svg/plus.svg"
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: showFamilyDialog = true
                                    }
                                }
                            }

                            // Column headers
                            Rectangle {
                                width: parent.width
                                height: 40
                                color: Theme.surfaceSubtle

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text { text: "FAMILY ID"; width: 90; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "HOUSE NAME"; width: 160; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "HEAD OF FAMILY"; width: 150; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "WARD"; width: 80; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "MEMBERS"; width: 70; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter; horizontalAlignment: Text.AlignHCenter }
                                    Text { text: "PHONE"; width: 120; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: "STATUS"; width: 100; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter }
                                    Item { Layout.fillWidth: true; height: 1 }
                                    Text { text: "ACTIONS"; width: 80; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter; horizontalAlignment: Text.AlignHCenter }
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
                                        width: parent.width
                                        height: 1
                                        color: Theme.borderSubtle
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        Text { text: model.famId; width: 90; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.Medium; color: Theme.textPrimary; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: model.house; width: 160; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textPrimary; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight }
                                        Text { text: model.head; width: 150; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight }
                                        Text { text: model.ward; width: 80; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: model.members; width: 70; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textPrimary; anchors.verticalCenter: parent.verticalCenter; horizontalAlignment: Text.AlignHCenter }
                                        Text { text: model.phone; width: 120; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter }
                                        StatusBadge { text: model.status.charAt(0).toUpperCase() + model.status.slice(1); variant: model.status; anchors.verticalCenter: parent.verticalCenter; width: 100 }
                                        Item { Layout.fillWidth: true; height: 1 }
                                        RowLayout {
                                            width: 80
                                            spacing: 4
                                            anchors.verticalCenter: parent.verticalCenter

                                            IconButton { iconName: "edit"; compact: true; iconSize: 15; tooltipText: "Edit" }
                                            IconButton { iconName: "trash"; compact: true; iconSize: 15; variant: "danger"; tooltipText: "Delete" }
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
                                    width: parent.width
                                    height: 1
                                    color: Theme.borderSubtle
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 8

                                    Text {
                                        text: "Showing 1-7 of 512 families"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        color: Theme.textSecondary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Item { Layout.fillWidth: true; height: 1 }

                                    IconButton { iconName: "chevron-left"; compact: true; tooltipText: "Previous" }
                                    Text { text: "1"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.Bold; color: Theme.primary; anchors.verticalCenter: parent.verticalCenter; width: 24; horizontalAlignment: Text.AlignHCenter }
                                    Text { text: "2"; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter; width: 24; horizontalAlignment: Text.AlignHCenter }
                                    Text { text: "3"; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter; width: 24; horizontalAlignment: Text.AlignHCenter }
                                    Text { text: "…"; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter; width: 24; horizontalAlignment: Text.AlignHCenter }
                                    Text { text: "73"; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textSecondary; anchors.verticalCenter: parent.verticalCenter; width: 24; horizontalAlignment: Text.AlignHCenter }
                                    IconButton { iconName: "chevron-right"; compact: true; tooltipText: "Next" }
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
                                font.weight: Font.SemiBold
                                color: Theme.textPrimary
                            }

                            // Buttons
                            RowLayout {
                                spacing: 16
                                width: parent.width

                                Text { text: "Buttons"; width: 100; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter }
                                AppButton { text: "Primary"; variant: "primary" }
                                AppButton { text: "Secondary"; variant: "secondary" }
                                AppButton { text: "Ghost"; variant: "ghost" }
                                AppButton { text: "Danger"; variant: "danger" }
                                AppButton { text: "Disabled"; variant: "primary"; enabled: false }
                            }

                            // Text fields
                            RowLayout {
                                spacing: 16
                                width: parent.width

                                Text { text: "Fields"; width: 100; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter }
                                AppTextField { label: "Normal"; placeholderText: "Type..."; width: 180 }
                                AppTextField { label: "With Icon"; placeholderText: "Phone"; leadingIcon: "user"; width: 180 }
                                AppTextField { label: "Error"; placeholderText: "123"; text: "123"; error: true; errorText: "Invalid"; width: 180 }
                            }

                            // Status badges
                            RowLayout {
                                spacing: 16
                                width: parent.width

                                Text { text: "Badges"; width: 100; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter }
                                StatusBadge { text: "Active"; variant: "active" }
                                StatusBadge { text: "Pending"; variant: "pending" }
                                StatusBadge { text: "Overdue"; variant: "overdue" }
                                StatusBadge { text: "Archived"; variant: "archived" }
                                StatusBadge { text: "Paid"; variant: "paid" }
                                StatusBadge { text: "Approved"; variant: "approved" }
                            }

                            // Icon buttons
                            RowLayout {
                                spacing: 16
                                width: parent.width

                                Text { text: "Icons"; width: 100; font.family: Theme.fontFamily; font.pixelSize: 12; color: Theme.textTertiary; anchors.verticalCenter: parent.verticalCenter }
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
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 64
        anchors.rightMargin: 20
        width: 360
        height: 400
        radius: Theme.radiusLg
        color: Theme.surface
        border.width: 1
        border.color: Theme.border
        z: 100

        // Subtle shadow
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0.02, 0.05, 0.15, Theme.shadowOpacityLarge)
            shadowBlur: 0.6
            shadowVerticalOffset: 6
        }

        Column {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            // Header
            Rectangle {
                width: parent.width
                height: 52
                color: "transparent"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Theme.borderSubtle
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 8

                    Text {
                        text: "Notifications"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMd
                        font.weight: Font.SemiBold
                        color: Theme.textPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item { Layout.fillWidth: true; height: 1 }
                    Text {
                        text: "Mark all read"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {}
                        }
                    }
                }
            }

            // Notification items
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

                    contentItem: RowLayout {
                        spacing: 12

                        Rectangle {
                            width: 32; height: 32; radius: Theme.radiusSm
                            color: Theme.accent(model.accent).subtle
                            border.width: 1
                            border.color: Theme.accent(model.accent).subtleAlt
                            anchors.verticalCenter: parent.verticalCenter

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
                            spacing: 1
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 32 - 12 - 32

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
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // Footer
            Rectangle {
                width: parent.width
                height: 48
                color: Theme.surfaceSubtle

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
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

        // Close on outside click
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true
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
        onVisibleChanged: {
            if (visible) {
                familyDlg.x = (window.width - familyDlg.width) / 2
                familyDlg.y = (window.height - familyDlg.height) / 2
            }
        }
        onAccepted: showFamilyDialog = false
        onRejected: showFamilyDialog = false
    }
}
