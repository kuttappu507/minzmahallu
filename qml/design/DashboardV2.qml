import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0
import "../components"

// ============================================================================
// DashboardV2 — Production-quality dashboard screen
//
// Clean implementation of ONLY the application shell + Dashboard.
// No families table, no component showcase, no dialogs, no popups.
//
// LAYOUT (deterministic, content-driven):
//   ApplicationWindow
//   └─ RowLayout (anchors.fill)
//      ├─ DashboardSidebarV2 (fixed 230px width, fills height)
//      └─ ColumnLayout (fills remaining)
//         ├─ TopBar (fixed 56px height)
//         └─ ScrollView (fills remaining)
//            └─ ColumnLayout (content)
//               ├─ Page heading
//               ├─ KPI grid (responsive 4/2/1 columns)
//               └─ Activities + Events row (content-driven height)
// ============================================================================

ApplicationWindow {
    id: window
    visible: true
    width: 1366
    height: 768
    minimumWidth: 1024
    minimumHeight: 640
    title: "Minz Mahallu — Dashboard"
    color: Theme.canvas

    // ===== ROOT: RowLayout =====
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ===== Sidebar =====
        DashboardSidebarV2 {
            id: sidebar
            Layout.fillHeight: true
            Layout.fillWidth: false
            implicitWidth: 230
        }

        // ===== Main content area =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ===== TopBar =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                Layout.fillHeight: false
                color: Theme.surface

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.borderSubtle
                }

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 24
                    anchors.rightMargin: 16

                    // Title + subtitle (left)
                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        Text {
                            text: "Dashboard"
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Good evening, Admin"
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: Theme.textSecondary
                        }
                    }

                    // Avatar (right)
                    Rectangle {
                        id: avatar
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 34; height: 34; radius: 17
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

                    // Notification bell
                    Rectangle {
                        id: bellBtn
                        anchors.right: avatar.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 34; height: 34; radius: Theme.radiusSm
                        color: bellMA.containsMouse ? Theme.surfaceHover : "transparent"
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 7
                            anchors.rightMargin: 7
                            width: 7; height: 7; radius: 4
                            color: Theme.coral
                            border.width: 2
                            border.color: Theme.surface
                        }

                        Item {
                            width: 16; height: 16
                            anchors.centerIn: parent

                            Image {
                                id: bellIcon
                                source: "qrc:/icons/svg/bell.svg"
                                sourceSize: Qt.size(16, 16)
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
                        }
                    }

                    // Search field
                    AppTextField {
                        anchors.right: bellBtn.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        variant: "search"
                        placeholderText: "Search..."
                        width: 240
                    }
                }
            }

            // ===== Scrollable dashboard content =====
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: parent.width - 48
                    x: 24
                    spacing: 20

                    // Top spacer
                    Item { Layout.fillWidth: true; Layout.preferredHeight: 20 }

                    // ═══════════════════════════════════════
                    // PAGE HEADING
                    // ═══════════════════════════════════════
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Overview"
                            font.family: Theme.fontFamily
                            font.pixelSize: 22
                            font.weight: Font.Bold
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Mahallu statistics and recent activities"
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            color: Theme.textSecondary
                        }
                    }

                    // ═══════════════════════════════════════
                    // KPI GRID (responsive)
                    // ═══════════════════════════════════════
                    GridLayout {
                        Layout.fillWidth: true
                        columns: window.width > 1200 ? 4 : (window.width > 800 ? 2 : 1)
                        columnSpacing: 16
                        rowSpacing: 16

                        KpiCardV2 {
                            Layout.fillWidth: true
                            label: "Total Families"
                            value: "512"
                            trend: "+12"
                            trendUp: true
                            subtitle: "this month"
                            accentName: "emerald"
                            iconName: "families"
                        }
                        KpiCardV2 {
                            Layout.fillWidth: true
                            label: "Total Members"
                            value: "2,345"
                            trend: "+28"
                            trendUp: true
                            subtitle: "this month"
                            accentName: "blue"
                            iconName: "members"
                        }
                        KpiCardV2 {
                            Layout.fillWidth: true
                            label: "Nikahs This Year"
                            value: "48"
                            trend: "+8"
                            trendUp: true
                            subtitle: "this month"
                            accentName: "orange"
                            iconName: "marriage"
                        }
                        KpiCardV2 {
                            Layout.fillWidth: true
                            label: "Collections (Month)"
                            value: "₹48,750"
                            trend: "+15%"
                            trendUp: true
                            subtitle: "from last month"
                            accentName: "violet"
                            iconName: "donations"
                        }
                    }

                    // ═══════════════════════════════════════
                    // ACTIVITIES + EVENTS ROW
                    // ═══════════════════════════════════════
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        // Recent Activities (content-driven height)
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                            radius: Theme.radiusLg
                            color: Theme.surface
                            border.width: 1
                            border.color: Theme.border

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 0

                                // Section header
                                Text {
                                    text: "Recent Activities"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 15
                                    font.weight: Font.DemiBold
                                    color: Theme.textPrimary
                                }
                                Text {
                                    text: "Latest updates across the mahallu"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    color: Theme.textSecondary
                                    topPadding: 2
                                    bottomPadding: 12
                                }

                                // Activity list (content-driven)
                                ListView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    spacing: 10
                                    model: ListModel {
                                        ListElement { title: "New Nikah Registered"; subtitle: "Faisal P. & Amina K."; time: "2h ago"; icon: "marriage"; accent: "orange" }
                                        ListElement { title: "New Member Added"; subtitle: "Rashid K."; time: "5h ago"; icon: "members"; accent: "blue" }
                                        ListElement { title: "Collection Received"; subtitle: "₹2,500 from Ibrahim K."; time: "1d ago"; icon: "donations"; accent: "violet" }
                                        ListElement { title: "Certificate Generated"; subtitle: "Nikah Cert #NK/2025/043"; time: "2d ago"; icon: "certificates"; accent: "cyan" }
                                    }

                                    delegate: Row {
                                        width: ListView.view.width
                                        spacing: 10

                                        // Compact tinted icon
                                        Rectangle {
                                            width: 28; height: 28; radius: Theme.radiusSm
                                            color: Theme.accent(model.accent).subtle
                                            y: (parent.height - 28) / 2

                                            Item {
                                                width: 14; height: 14
                                                anchors.centerIn: parent

                                                Image {
                                                    id: actIcon
                                                    source: "qrc:/icons/svg/" + model.icon + ".svg"
                                                    sourceSize: Qt.size(14, 14)
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

                                        // Content
                                        Column {
                                            width: parent.width - 28 - 10
                                            y: (parent.height - height) / 2
                                            spacing: 1

                                            Text {
                                                text: model.title
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 13
                                                font.weight: Font.Medium
                                                color: Theme.textPrimary
                                            }
                                            Text {
                                                text: model.subtitle + " · " + model.time
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 11
                                                color: Theme.textTertiary
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Upcoming Events (content-driven height)
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                            radius: Theme.radiusLg
                            color: Theme.surface
                            border.width: 1
                            border.color: Theme.border

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 0

                                // Section header
                                Text {
                                    text: "Upcoming Events"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 15
                                    font.weight: Font.DemiBold
                                    color: Theme.textPrimary
                                }
                                Text {
                                    text: "Next 2 weeks"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    color: Theme.textSecondary
                                    topPadding: 2
                                    bottomPadding: 12
                                }

                                // Events list (content-driven)
                                ListView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    spacing: 10
                                    model: ListModel {
                                        ListElement { day: "24"; month: "MAY"; title: "Jumma Khutbah"; time: "12:30 PM"; accent: "emerald" }
                                        ListElement { day: "30"; month: "MAY"; title: "Mahallu Meeting"; time: "7:00 PM"; accent: "blue" }
                                        ListElement { day: "07"; month: "JUN"; title: "Quran Study Circle"; time: "6:30 PM"; accent: "violet" }
                                    }

                                    delegate: Row {
                                        width: ListView.view.width
                                        spacing: 10

                                        // Compact date block
                                        Rectangle {
                                            width: 40; height: 40; radius: Theme.radiusSm
                                            color: Theme.accent(model.accent).subtle
                                            y: (parent.height - 40) / 2

                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 0

                                                Text {
                                                    text: model.day
                                                    font.family: Theme.fontFamilyDisplay
                                                    font.pixelSize: 14
                                                    font.weight: Font.Bold
                                                    color: Theme.accent(model.accent).main
                                                    horizontalAlignment: Text.AlignHCenter
                                                }
                                                Text {
                                                    text: model.month
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: 8
                                                    font.weight: Font.Bold
                                                    color: Theme.accent(model.accent).main
                                                    horizontalAlignment: Text.AlignHCenter
                                                }
                                            }
                                        }

                                        // Content
                                        Column {
                                            width: parent.width - 40 - 10

                                            Text {
                                                text: model.title
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 13
                                                font.weight: Font.Medium
                                                color: Theme.textPrimary
                                            }
                                            Text {
                                                text: model.time
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 11
                                                color: Theme.textTertiary
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bottom spacer
                    Item { Layout.fillWidth: true; Layout.preferredHeight: 24 }
                }
            }
        }
    }
}
