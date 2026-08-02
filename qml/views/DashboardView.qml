import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

// ============================================================================
// DashboardView - live data from Services + functional quick actions
// ============================================================================
ScrollView {
    id: dashboard
    clip: true

    property var services: typeof Services !== "undefined" ? Services : null
    property var stats: services ? services.dashboardStats : ({})

    ColumnLayout {
        width: dashboard.width
        spacing: 16

        // View header
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            Layout.topMargin: 20
            spacing: 14

            ColumnLayout {
                spacing: 3
                Text {
                    text: "Assalamu Alaikum, " + (services ? services.currentUserName : "Administrator")
                    font.family: Theme.fontDisplay; font.pixelSize: 21; font.weight: Font.Bold
                    color: Theme.text
                }
                Text {
                    text: "Here's what's happening in your mahallu today."
                    font.family: Theme.fontPrimary; font.pixelSize: 12
                    color: Theme.muted
                }
            }
            Item { Layout.fillWidth: true }

            Rectangle {
                radius: 7; color: Theme.tints.sl.sb
                border.width: 1.5; border.color: Theme.tints.sl.sc
                implicitHeight: 32
                Text {
                    anchors.centerIn: parent; anchors.margins: 12
                    text: Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
                    font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold
                    color: Theme.tints.sl.st
                }
            }
        }

        // Stat cards (live data)
        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            columns: 5
            rowSpacing: 12; columnSpacing: 12

            Repeater {
                model: ListModel {
                    ListElement { label: "FAMILIES";    valueExpr: "stats.totalFamilies || 0";     delta: "Total registered";   up: 1; tint: "em"; icon: "F" }
                    ListElement { label: "MEMBERS";     valueExpr: "stats.totalMembers || 0";      delta: "Active community";   up: 1; tint: "cy"; icon: "M" }
                    ListElement { label: "ACTIVE";      valueExpr: "stats.activeMembers || 0";     delta: "Active members";     up: 1; tint: "bl"; icon: "A" }
                    ListElement { label: "COLLECTION";  valueExpr: "'Rs.' + (stats.monthlyCollection || 0).toLocaleString()"; delta: "This month"; up: 1; tint: "am"; icon: "₹" }
                    ListElement { label: "DUES";        valueExpr: "'Rs.' + (stats.pendingDues || 0).toLocaleString()";       delta: "Pending dues"; up: 0; tint: "rd"; icon: "!" }
                    ListElement { label: "DONATIONS";   valueExpr: "'Rs.' + (stats.monthlyDonations || 0).toLocaleString()";  delta: "This month"; up: 1; tint: "pk"; icon: "D" }
                    ListElement { label: "WELFARE";     valueExpr: "stats.welfareBeneficiaries || 0"; delta: "Beneficiaries"; up: 1; tint: "vi"; icon: "W" }
                    ListElement { label: "MARRIAGES";   valueExpr: "stats.marriagesThisYear || 0";  delta: "This year";          up: 1; tint: "or"; icon: "♥" }
                    ListElement { label: "DEATHS";      valueExpr: "stats.deathsThisYear || 0";     delta: "This year";          up: 0; tint: "sl"; icon: "✿" }
                    ListElement { label: "BALANCE";     valueExpr: "'Rs.' + (stats.balanceThisMonth || 0).toLocaleString()";  delta: "This month"; up: 1; tint: "ib"; icon: "₹" }
                }
                delegate: statCard
            }
        }

        // Quick actions row (functional — switch to the relevant view)
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            spacing: 10

            Repeater {
                model: ListModel {
                    ListElement { label: "+ Add Family";      navIndex: 1 }
                    ListElement { label: "+ Add Member";      navIndex: 2 }
                    ListElement { label: "+ Receive Donation"; navIndex: 4 }
                    ListElement { label: "+ New Token";       navIndex: 10 }
                    ListElement { label: "+ Issue Certificate"; navIndex: 9 }
                }
                delegate: Rectangle {
                    property bool isHover: qaMA.containsMouse
                    radius: 8; color: isHover ? Theme.panelMuted : Theme.panel
                    border.width: 1.5; border.color: isHover ? Theme.sidebar : Theme.border
                    implicitHeight: 36
                    Layout.preferredWidth: 160
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    scale: isHover ? 1.04 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Text {
                        anchors.centerIn: parent; anchors.margins: 12
                        text: model.label
                        font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold
                        color: isHover ? Theme.sidebar : Theme.text
                    }
                    MouseArea { id: qaMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { navList.currentIndex = model.navIndex; win.currentNavIndex = model.navIndex } }
                }
            }
            Item { Layout.fillWidth: true }
        }

        // Chart cards row
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            spacing: 12

            Repeater {
                model: ListModel {
                    ListElement { title: "Collections"; sub: "Subscription receipts - last 12 months" }
                    ListElement { title: "Donations"; sub: "All categories - last 12 months" }
                    ListElement { title: "Income vs Expense"; sub: "Financial year 2026-27 - to date" }
                }
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 14; spacing: 4
                        Text {
                            text: model.title
                            font.family: Theme.fontDisplay; font.pixelSize: 13; font.weight: Font.Bold
                            color: Theme.text
                        }
                        Text {
                            text: model.sub
                            font.family: Theme.fontPrimary; font.pixelSize: 10
                            color: Theme.muted
                        }
                        Item { Layout.fillWidth: true; Layout.fillHeight: true }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 6
                            Repeater {
                                model: 12
                                delegate: Rectangle {
                                    property var heights: [40, 55, 65, 50, 72, 88, 95, 80, 70, 90, 100, 85]
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: heights[index]
                                    radius: 3
                                    color: Theme.tints.em.sc
                                    opacity: 0.35 + (heights[index] / 200)
                                }
                            }
                        }
                        Text {
                            text: "Jul 2025 → Jun 2026"
                            font.family: Theme.fontPrimary; font.pixelSize: 9
                            color: Theme.muted
                        }
                    }
                }
            }
        }

        // Recent activity
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            Layout.bottomMargin: 20
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
            implicitHeight: 280
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 6
                Text {
                    text: "Recent Activity"
                    font.family: Theme.fontDisplay; font.pixelSize: 14; font.weight: Font.Bold
                    color: Theme.text
                }
                Text {
                    text: "Latest user actions across all modules"
                    font.family: Theme.fontPrimary; font.pixelSize: 11
                    color: Theme.muted
                }
                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 4
                    model: ListModel {
                        ListElement { who: "Administrator"; what: "Welcome to Minz Mahallu Management System"; when: "Just now"; tint: "em" }
                    }
                    delegate: RowLayout {
                        width: ListView.view.width; height: 38; spacing: 10
                        Rectangle {
                            width: 28; height: 28; radius: 7
                            color: Theme.tint(model.tint).sb; border.width: 1; border.color: Theme.tint(model.tint).sc
                            Text {
                                anchors.centerIn: parent
                                text: model.who.charAt(0).toUpperCase()
                                font.family: Theme.fontDisplay; font.pixelSize: 11; font.weight: Font.Bold
                                color: Theme.tint(model.tint).st
                            }
                        }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: model.what
                                font.family: Theme.fontPrimary; font.pixelSize: 11
                                color: Theme.text
                                Layout.fillWidth: true; elide: Text.ElideRight
                            }
                            Text {
                                text: model.who + " · " + model.when
                                font.family: Theme.fontPrimary; font.pixelSize: 9
                                color: Theme.muted
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }
    }

    // Stat card component with hover effect
    Component {
        id: statCard
        Rectangle {
            property var t: Theme.tint(model.tint)
            property bool isHover: scMA.containsMouse
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            radius: 10
            color: t.sb
            border.width: 1.5; border.color: t.sc
            scale: isHover ? 1.03 : 1.0
            Behavior on scale { NumberAnimation { duration: 150 } }

            Rectangle {
                width: 56; height: 56; radius: 28
                anchors.right: parent.right; anchors.bottom: parent.bottom
                anchors.rightMargin: -14; anchors.bottomMargin: -14
                color: t.sc; opacity: 0.14
            }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 14; spacing: 6
                RowLayout {
                    Layout.fillWidth: true; spacing: 8
                    Rectangle {
                        width: 37; height: 37; radius: 9; color: t.sc
                        Text {
                            anchors.centerIn: parent
                            text: model.icon
                            font.family: Theme.fontDisplay; font.pixelSize: 18; font.weight: Font.Bold
                            color: "#ffffff"
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        visible: model.delta !== ""
                        radius: 99; color: Theme.panel; border.width: 1.5; border.color: t.sc
                        implicitHeight: 22
                        Text {
                            anchors.centerIn: parent; anchors.margins: 8
                            text: (model.up ? "▲ " : "■ ") + model.delta
                            font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black
                            color: t.st
                        }
                    }
                }
                Text {
                    text: evalExpr(model.valueExpr)
                    font.family: Theme.fontDisplay; font.pixelSize: 24; font.weight: Font.Bold
                    color: t.st
                    Layout.fillWidth: true; elide: Text.ElideRight
                }
                Text {
                    text: model.label
                    font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black
                    color: t.st; opacity: 0.75
                    Layout.fillWidth: true; elide: Text.ElideRight
                }
            }

            MouseArea { id: scMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
        }
    }

    // Helper to evaluate a stat value expression against the current stats
    function evalExpr(expr) {
        try { return Function("stats", "return " + expr)(stats); }
        catch (e) { return "—"; }
    }
}
