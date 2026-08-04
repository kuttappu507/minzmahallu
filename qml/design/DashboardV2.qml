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
        objectName: "rootRowLayout"
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
            objectName: "mainColumnLayout"
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ===== TopBar =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 58
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
                            text: "MINZ MAHALLU /"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.textTertiary
                        }
                        Text {
                            text: "Dashboard"
                            font.family: Theme.fontFamilyDisplay
                            font.pixelSize: 15
                            font.weight: Font.Bold
                            color: Theme.textPrimary
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
                objectName: "scrollView"
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    objectName: "contentColumnLayout"
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
                            text: "Good evening, Abdul Kareem"
                            font.family: Theme.fontFamilyDisplay
                            font.pixelSize: 22
                            font.weight: Font.Bold
                            color: Theme.textPrimary
                        }
                        Text {
                            text: "Here is what is happening in your mahallu today."
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            color: Theme.textSecondary
                        }
                    }

                    // ═══════════════════════════════════════
                    // KPI GRID (responsive)
                    // ═══════════════════════════════════════
                    GridLayout {
                        objectName: "kpiGridLayout"
                        Layout.fillWidth: true
                        columns: window.width > 1360 ? 5 : (window.width > 900 ? 3 : (window.width > 600 ? 2 : 1))
                        columnSpacing: 16
                        rowSpacing: 16

                        KpiCardV2 {
                            objectName: "kpiCard"
                            Layout.fillWidth: true
                            label: "FAMILIES"
                            value: "248"
                            trend: "+6 this month"
                            trendUp: true
                            subtitle: "registered"
                            accentName: "emerald"
                            iconName: "families"
                        }
                        KpiCardV2 {
                            objectName: "kpiCard"
                            Layout.fillWidth: true
                            label: "MEMBERS"
                            value: "1,142"
                            trend: "+18 this month"
                            trendUp: true
                            subtitle: "registered"
                            accentName: "cyan"
                            iconName: "members"
                        }
                        KpiCardV2 {
                            objectName: "kpiCard"
                            Layout.fillWidth: true
                            label: "ACTIVE"
                            value: "986"
                            trend: "86.3% active"
                            trendUp: true
                            subtitle: "members"
                            accentName: "blue"
                            iconName: "user"
                        }
                        KpiCardV2 {
                            objectName: "kpiCard"
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
                    // NO Layout.fillHeight on this RowLayout.
                    // Its height = max(activitiesPanel.implicitHeight, eventsPanel.implicitHeight)
                    // which is driven by content.
                    RowLayout {
        objectName: "rootRowLayout"
                        Layout.fillWidth: true
                        spacing: 16

                        // Recent Activities — natural content height via DashboardPanel
                        DashboardPanel {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            panelName: "activitiesPanel"
                            title: "Recent Activities"
                            subtitle: "Latest updates across the mahallu"

                            // Activity rows via Column + Repeater (NOT ListView)
                            // Column correctly calculates implicitHeight from children
                            Repeater {
                                model: ListModel {
                                    ListElement { title: "New Nikah Registered"; subtitle: "Faisal P. & Amina K."; time: "2h ago"; icon: "marriage"; accent: "orange" }
                                    ListElement { title: "New Member Added"; subtitle: "Rashid K."; time: "5h ago"; icon: "members"; accent: "blue" }
                                    ListElement { title: "Collection Received"; subtitle: "₹2,500 from Ibrahim K."; time: "1d ago"; icon: "donations"; accent: "violet" }
                                    ListElement { title: "Certificate Generated"; subtitle: "Nikah Cert #NK/2025/043"; time: "2d ago"; icon: "certificates"; accent: "cyan" }
                                }

                                delegate: Row {
                                    Layout.fillWidth: true
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

                        // Upcoming Events — natural content height via DashboardPanel
                        DashboardPanel {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            panelName: "eventsPanel"
                            title: "Upcoming Events"
                            subtitle: "Next 2 weeks"

                            // Event rows via Column + Repeater (NOT ListView)
                            Repeater {
                                model: ListModel {
                                    ListElement { day: "24"; month: "MAY"; title: "Jumma Khutbah"; time: "12:30 PM"; accent: "emerald" }
                                    ListElement { day: "30"; month: "MAY"; title: "Mahallu Meeting"; time: "7:00 PM"; accent: "blue" }
                                    ListElement { day: "07"; month: "JUN"; title: "Quran Study Circle"; time: "6:30 PM"; accent: "violet" }
                                }

                                delegate: Row {
                                    Layout.fillWidth: true
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

                    // Bottom spacer
                    Item { Layout.fillWidth: true; Layout.preferredHeight: 24 }
                }
            }
        }
    }

}
