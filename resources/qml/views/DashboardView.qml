import QtQuick
import QtQuick.Layouts
import "../components"

ScrollView {
    id: dashboard
    clip: true

    ColumnLayout {
        width: dashboard.width
        spacing: 16

        // ---- View header ----
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            Layout.topMargin: 20
            spacing: 14

            ColumnLayout {
                spacing: 3
                Text {
                    text: "Assalamu Alaikum, " + "Administrator"
                    font.family: Theme.fontDisplay
                    font.pixelSize: 21
                    font.weight: Font.Bold
                    color: Theme.text
                }
                Text {
                    text: "Here's what's happening in your mahallu today."
                    font.family: Theme.fontPrimary
                    font.pixelSize: 12
                    color: Theme.muted
                }
            }
            Item { Layout.fillWidth: true }

            // Date chip
            Rectangle {
                radius: 7; color: Theme.tints.slate.sb
                border.width: 1.5; border.color: Theme.tints.slate.sc
                implicitHeight: 32
                Text {
                    anchors.centerIn: parent; anchors.margins: 12
                    text: "Tuesday, 28 July 2026"
                    font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold
                    color: Theme.tints.slate.st
                }
            }

            // Refresh button
            SquircleButton {
                text: "Refresh"
                palette.button: Theme.tints.slate.sb
                palette.buttonText: Theme.tints.slate.st
            }
        }

        // ---- Quick action row ----
        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            columns: 5
            columnSpacing: 12

            Repeater {
                model: ListModel {
                    ListElement { title: "Add Family"; sub: "F-0013 next"; tint: "em"; icon: "⌂" }
                    ListElement { title: "Add Member"; sub: "1,142 on record"; tint: "teal"; icon: "☺" }
                    ListElement { title: "Record Payment"; sub: "RCP-2026-048"; tint: "gold"; icon: "☰" }
                    ListElement { title: "Add Donation"; sub: "5 categories"; tint: "pink"; icon: "🎁" }
                    ListElement { title: "Generate Report"; sub: "15 report types"; tint: "violet"; icon: "📊" }
                }
                delegate: Rectangle {
                    Layout.fillWidth: true
                    radius: 10; color: Theme.panel
                    border.width: 1.5; border.color: Theme.border
                    implicitHeight: 68
                    readonly property var t: Theme.tint(model.tint)

                    Rectangle {
                        anchors.fill: parent; radius: 10
                        color: "transparent"
                        border.width: 1.5
                        border.color: qaMouse.containsMouse ? t.sc : Theme.border
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 12; spacing: 10
                        Rectangle {
                            width: 42; height: 42; radius: 9
                            color: t.sc
                            Text { anchors.centerIn: parent; text: model.icon; font.pixelSize: 20; color: "#ffffff" }
                        }
                        ColumnLayout {
                            spacing: 1
                            Text { text: model.title; font.family: Theme.fontPrimary; font.pixelSize: 12; font.weight: Font.Bold; color: Theme.text }
                            Text { text: model.sub; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.faint }
                        }
                        Item { Layout.fillWidth: true }
                    }
                    MouseArea { id: qaMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }
            }
        }

        // ---- Stat grid 5×2 ----
        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            columns: 5; columnSpacing: 12; rowSpacing: 12

            Repeater {
                model: ListModel {
                    ListElement { label: "FAMILIES"; value: "248"; delta: "+6 this month"; up: 1; tint: "em"; icon: "⌂" }
                    ListElement { label: "MEMBERS"; value: "1,142"; delta: "+18 this month"; up: 1; tint: "teal"; icon: "☺" }
                    ListElement { label: "ACTIVE"; value: "986"; delta: "86.3% active"; up: 1; tint: "sky"; icon: "✓" }
                    ListElement { label: "COLLECTION"; value: "₹48,200"; delta: "+9.1% vs June"; up: 1; tint: "gold"; icon: "₹" }
                    ListElement { label: "PENDING DUES"; value: "₹36,400"; delta: "7 families overdue"; up: 0; tint: "rose"; icon: "!" }
                    ListElement { label: "DONATIONS"; value: "₹92,750"; delta: "+12.4% vs June"; up: 1; tint: "pink"; icon: "🎁" }
                    ListElement { label: "WELFARE"; value: "₹1,45,000"; delta: "14 beneficiaries"; up: 1; tint: "violet"; icon: "♥" }
                    ListElement { label: "MARRIAGES"; value: "17"; delta: "2 this quarter"; up: 1; tint: "orange"; icon: "◆" }
                    ListElement { label: "DEATHS"; value: "9"; delta: "1 this month"; up: 0; tint: "slate"; icon: "✿" }
                    ListElement { label: "BALANCE"; value: "₹4,56,320"; delta: "across all funds"; up: 1; tint: "blue"; icon: "↑" }
                }
                delegate: StatCard {
                    Layout.fillWidth: true
                    tintName: model.tint
                    iconText: model.icon
                    valueText: model.value
                    labelText: model.label
                    deltaText: model.delta
                    deltaUp: model.up === 1
                }
            }
        }

        // ---- Chart grid 2×2 ----
        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            columns: 2; columnSpacing: 12; rowSpacing: 12

            // Chart 1: Collections
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                Layout.minimumHeight: 220
                radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 6
                    RowLayout {
                        spacing: 6
                        Rectangle { width: 5; Layout.fillHeight: true; color: Theme.tints.em.sc; radius: 2 }
                        Text { text: "Collections"; font.family: Theme.fontPrimary; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text }
                    }
                    Text { text: "Subscription receipts · last 12 months"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.faint; Layout.leftMargin: 11 }
                    Item { Layout.fillWidth: true; Layout.fillHeight: true }
                }
            }

            // Chart 2: Donations
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                Layout.minimumHeight: 220
                radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 6
                    RowLayout {
                        spacing: 6
                        Rectangle { width: 5; Layout.fillHeight: true; color: Theme.tints.gold.sc; radius: 2 }
                        Text { text: "Donations"; font.family: Theme.fontPrimary; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text }
                    }
                    Text { text: "All categories · last 12 months"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.faint; Layout.leftMargin: 11 }
                    Item { Layout.fillWidth: true; Layout.fillHeight: true }
                }
            }

            // Chart 3: Income vs Expense
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                Layout.minimumHeight: 220
                radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 6
                    RowLayout {
                        spacing: 6
                        Rectangle { width: 5; Layout.fillHeight: true; color: Theme.tints.violet.sc; radius: 2 }
                        Text { text: "Income vs Expense"; font.family: Theme.fontPrimary; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text }
                    }
                    Text { text: "Financial year 2026-27 · to date"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.faint; Layout.leftMargin: 11 }
                    Item { Layout.fillWidth: true; Layout.fillHeight: true }
                }
            }

            // Chart 4: Membership Growth
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                Layout.minimumHeight: 220
                radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 6
                    RowLayout {
                        spacing: 6
                        Rectangle { width: 5; Layout.fillHeight: true; color: Theme.tints.sky.sc; radius: 2 }
                        Text { text: "Membership Growth"; font.family: Theme.fontPrimary; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text }
                    }
                    Text { text: "Total registered members"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.faint; Layout.leftMargin: 11 }
                    Item { Layout.fillWidth: true; Layout.fillHeight: true }
                }
            }
        }

        // ---- Recent activity ----
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            Layout.bottomMargin: 26
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
            implicitHeight: 280

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 6

                RowLayout {
                    spacing: 6
                    Rectangle { width: 5; Layout.fillHeight: true; color: Theme.tints.em.sc; radius: 2 }
                    Text { text: "Recent Activity"; font.family: Theme.fontPrimary; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text }
                }
                Text { text: "Latest user actions across all modules"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.faint; Layout.leftMargin: 11 }

                // Table header
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 36
                    color: Theme.header; radius: 8
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 2; color: Theme.border }
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16
                        spacing: 0
                        Text { text: "TIME"; Layout.preferredWidth: 80; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted; letterSpacing: 1 }
                        Text { text: "USER"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted; letterSpacing: 1 }
                        Text { text: "ACTION"; Layout.preferredWidth: 100; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted; letterSpacing: 1 }
                        Text { text: "DESCRIPTION"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted; letterSpacing: 1 }
                    }
                }

                // Table rows (placeholder)
                Repeater {
                    model: 6
                    delegate: Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 36
                        color: ma.containsMouse ? Theme.sel : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16
                            spacing: 0
                            Text { text: "14:31"; Layout.preferredWidth: 80; font.family: Theme.fontDisplay; font.pixelSize: 12; color: Theme.faint }
                            Text { text: "admin"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 13; font.weight: Font.Bold; color: Theme.text }
                            Pill { status: "Paid"; Layout.preferredWidth: 100 }
                            Text { text: "RCP-2026-046 payment recorded"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 13; color: Theme.text }
                        }
                        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true }
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }
}
