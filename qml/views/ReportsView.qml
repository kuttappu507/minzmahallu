import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ReportsView — analytics with chart placeholders + export buttons
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Reports"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Generate reports and export data"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 180; model: ["This Year", "Last 6 Months", "This Quarter", "Custom"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 100
                Text { anchors.centerIn: parent; text: "↓ CSV"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text } }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 100
                Text { anchors.centerIn: parent; text: "↓ PDF"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text } }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 100
                Text { anchors.centerIn: parent; text: "↓ Excel"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text } }
        }
        // Quick stats
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "FAMILIES"; value: "248"; delta: "+6"; tint: "em" }
                    ListElement { label: "MEMBERS"; value: "1,142"; delta: "+18"; tint: "cy" }
                    ListElement { label: "COLLECTIONS"; value: "Rs.5.84L"; delta: "+9.1%"; tint: "am" }
                    ListElement { label: "DONATIONS"; value: "Rs.92.7K"; delta: "+12.4%"; tint: "pk" }
                    ListElement { label: "BALANCE"; value: "Rs.9.6L"; delta: "+8.7%"; tint: "ib" }
                }
                delegate: Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 80; radius: 10
                    property var t: Theme.tint(model.tint)
                    color: t.sb; border.width: 1.5; border.color: t.sc
                    ColumnLayout { anchors.fill: parent; anchors.margins: 12; spacing: 2
                        Text { text: model.label; font.family: Theme.fontPrimary; font.pixelSize: 8; font.weight: Font.Black; color: t.st }
                        Text { text: model.value; font.family: Theme.fontDisplay; font.pixelSize: 18; font.weight: Font.Bold; color: t.st }
                        Text { text: "▲ " + model.delta; font.family: Theme.fontPrimary; font.pixelSize: 9; color: t.st; opacity: 0.7 }
                    }
                }
            }
        }
        // Charts grid (placeholder bars)
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { title: "Monthly Collections"; sub: "FY 2026-27" }
                    ListElement { title: "Donations by Category"; sub: "This year" }
                }
                delegate: Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 240; radius: 10
                    color: Theme.panel; border.width: 1.5; border.color: Theme.border
                    ColumnLayout { anchors.fill: parent; anchors.margins: 14; spacing: 4
                        Text { text: model.title; font.family: Theme.fontDisplay; font.pixelSize: 13; font.weight: Font.Bold; color: Theme.text }
                        Text { text: model.sub; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
                        Item { Layout.fillWidth: true; Layout.fillHeight: true }
                        RowLayout { Layout.fillWidth: true; spacing: 6
                            Repeater { model: 12; delegate: Rectangle {
                                    property var heights: [40, 55, 65, 50, 72, 88, 95, 80, 70, 90, 100, 85]
                                    Layout.fillWidth: true; Layout.preferredHeight: heights[index]
                                    radius: 3; color: Theme.tints.em.sc; opacity: 0.35 + (heights[index] / 200) } } }
                        Text { text: "Jul 2025 → Jun 2026"; font.family: Theme.fontPrimary; font.pixelSize: 9; color: Theme.muted }
                    }
                }
            }
        }
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { title: "Membership Growth"; sub: "Last 12 months" }
                    ListElement { title: "Members by Age Group"; sub: "Current snapshot" }
                }
                delegate: Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 240; radius: 10
                    color: Theme.panel; border.width: 1.5; border.color: Theme.border
                    ColumnLayout { anchors.fill: parent; anchors.margins: 14; spacing: 4
                        Text { text: model.title; font.family: Theme.fontDisplay; font.pixelSize: 13; font.weight: Font.Bold; color: Theme.text }
                        Text { text: model.sub; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
                        Item { Layout.fillWidth: true; Layout.fillHeight: true }
                        // Pie-ish placeholder
                        RowLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 8
                            Repeater { model: ListModel {
                                    ListElement { label: "0-18";    pct: 25; tint: "em" }
                                    ListElement { label: "19-35";   pct: 32; tint: "bl" }
                                    ListElement { label: "36-50";   pct: 22; tint: "am" }
                                    ListElement { label: "51-70";   pct: 16; tint: "vi" }
                                    ListElement { label: "70+";     pct: 5;  tint: "sl" }
                                }
                                delegate: Rectangle {
                                    Layout.fillWidth: true; Layout.preferredHeight: 24; radius: 4
                                    property var t: Theme.tint(model.tint)
                                    color: t.sc; opacity: 0.7
                                    Text { anchors.centerIn: parent; text: model.label + " · " + model.pct + "%"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: "#ffffff" }
                                }
                            }
                        }
                    }
                }
            }
        }
        // Report list
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 200; radius: 10
            color: Theme.panel; border.width: 1.5; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; anchors.margins: 14; spacing: 6
                Text { text: "Available Reports"; font.family: Theme.fontDisplay; font.pixelSize: 13; font.weight: Font.Bold; color: Theme.text }
                ListView { Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 4; model: ListModel {
                        ListElement { name: "Family Directory Report (PDF)"; desc: "All families with members, ward-wise" }
                        ListElement { name: "Subscription Collection Report (CSV)"; desc: "Monthly collection summary" }
                        ListElement { name: "Donation Statement (Excel)"; desc: "Category-wise donations with donor details" }
                        ListElement { name: "Welfare Disbursement Report (PDF)"; desc: "Approved welfare aids with beneficiary details" }
                        ListElement { name: "Audit Trail Export (CSV)"; desc: "Full audit log with user actions" }
                    }
                    delegate: Rectangle { width: ListView.view.width; height: 36; color: "transparent"
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.margins: 4; spacing: 8
                            Text { text: "📄"; font.pixelSize: 14 }
                            ColumnLayout { Layout.fillWidth: true; spacing: 0
                                Text { text: model.name; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                                Text { text: model.desc; font.family: Theme.fontPrimary; font.pixelSize: 9; color: Theme.muted }
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle { width: 70; height: 26; radius: 6; color: Theme.tints.em.sb; border.width: 1; border.color: Theme.tints.em.sc; Text { anchors.centerIn: parent; text: "Generate"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: Theme.tints.em.st } }
                        }
                    }
                }
            }
        }
    }
}
