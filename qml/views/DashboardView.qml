import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

ScrollView {
    id: dashboard
    clip: true

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
                    text: "Assalamu Alaikum, " + "Administrator"
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

            // Date chip
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

        // 10 stat cards in 2 rows x 5 cols
        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            columns: 5
            rowSpacing: 12; columnSpacing: 12

            Repeater {
                model: ListModel {
                    ListElement { label: "FAMILIES"; value: "248"; delta: "+6 this month"; up: 1; tint: "em"; icon: "F" }
                    ListElement { label: "MEMBERS"; value: "1,142"; delta: "+18 this month"; up: 1; tint: "cy"; icon: "M" }
                    ListElement { label: "ACTIVE"; value: "986"; delta: "86.3% active"; up: 1; tint: "bl"; icon: "A" }
                    ListElement { label: "COLLECTION"; value: "Rs.48,200"; delta: "+9.1% vs June"; up: 1; tint: "am"; icon: "₹" }
                    ListElement { label: "DUES"; value: "Rs.36,400"; delta: "7 families overdue"; up: 0; tint: "rd"; icon: "!" }
                    ListElement { label: "DONATIONS"; value: "Rs.92,750"; delta: "+12.4% vs June"; up: 1; tint: "pk"; icon: "D" }
                    ListElement { label: "WELFARE"; value: "Rs.1,45,000"; delta: "14 beneficiaries"; up: 1; tint: "vi"; icon: "W" }
                    ListElement { label: "MARRIAGES"; value: "17"; delta: "2 this quarter"; up: 1; tint: "or"; icon: "♥" }
                    ListElement { label: "DEATHS"; value: "9"; delta: "1 this month"; up: 0; tint: "sl"; icon: "✿" }
                    ListElement { label: "BALANCE"; value: "Rs.4,56,320"; delta: "across all funds"; up: 1; tint: "ib"; icon: "₹" }
                }
                delegate: statCard
            }
        }

        // Quick actions row
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 22; Layout.rightMargin: 22
            spacing: 10

            Repeater {
                model: ["+ Add Family", "+ Add Member", "+ Receive Donation", "+ New Token", "+ Issue Certificate"]
                delegate: Rectangle {
                    radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border
                    implicitHeight: 36
                    Layout.preferredWidth: 160
                    Text {
                        anchors.centerIn: parent; anchors.margins: 12
                        text: modelData
                        font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold
                        color: Theme.text
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
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
                        // Placeholder bar chart
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
                        ListElement { who: "Administrator"; what: "Added new family: KH-F-0249 (Manzil Manzoor)"; when: "2 min ago"; tint: "em" }
                        ListElement { who: "Treasurer"; what: "Recorded donation: Rs.5,000 (Sponsorship) from Rahim PT"; when: "17 min ago"; tint: "pk" }
                        ListElement { who: "Administrator"; what: "Issued marriage certificate: M-2026-017"; when: "1 hour ago"; tint: "or" }
                        ListElement { who: "Secretary"; what: "Marked subscription overdue: 7 families"; when: "2 hours ago"; tint: "rd" }
                        ListElement { who: "Administrator"; what: "Created token event: Eid Milad 2026"; when: "Yesterday"; tint: "vi" }
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

    // Stat card component
    Component {
        id: statCard
        Rectangle {
            property var t: Theme.tint(model.tint)
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            radius: 10
            color: t.sb
            border.width: 1.5; border.color: t.sc

            // Decorative circle (bottom-right, semi-transparent)
            Rectangle {
                width: 56; height: 56; radius: 28
                anchors.right: parent.right; anchors.bottom: parent.bottom
                anchors.rightMargin: -14; anchors.bottomMargin: -14
                color: t.sc; opacity: 0.14
            }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 14; spacing: 6
                // Top row: icon + delta
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
                            text: (model.up ? "▲ " : "▼ ") + model.delta
                            font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black
                            color: t.st
                        }
                    }
                }
                Text {
                    text: model.value
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
        }
    }
}
