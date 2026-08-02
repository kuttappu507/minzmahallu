import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// DonationsView — donation receipts by category
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Donations"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Track all donations by category"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search by receipt, donor..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text } } }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 160; model: ["All Categories", "Sponsorship", "Zakat", "General", "Construction", "Ramadan"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 130; model: ["This Year", "Last 6 Months", "All"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 130
                Text { anchors.centerIn: parent; text: "+ Add Donation"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
        }
        // Summary
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "TOTAL DONATIONS"; value: "Rs.92,750"; sub: "84 receipts"; tint: "pk" }
                    ListElement { label: "SPONSORSHIP"; value: "Rs.45,000"; sub: "12 sponsors"; tint: "em" }
                    ListElement { label: "ZAKAT"; value: "Rs.28,500"; sub: "8 donors"; tint: "am" }
                    ListElement { label: "GENERAL FUND"; value: "Rs.19,250"; sub: "64 donors"; tint: "bl" }
                }
                delegate: Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 90; radius: 10
                    property var t: Theme.tint(model.tint)
                    color: t.sb; border.width: 1.5; border.color: t.sc
                    ColumnLayout { anchors.fill: parent; anchors.margins: 14; spacing: 4
                        Text { text: model.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: t.st }
                        Text { text: model.value; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: t.st }
                        Text { text: model.sub; font.family: Theme.fontPrimary; font.pixelSize: 9; color: t.st; opacity: 0.7 }
                    }
                }
            }
        }
        // Table
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 38; color: Theme.panelMuted
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                        Text { text: "RECEIPT #"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "DONOR"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "CATEGORY"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "AMOUNT"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignRight }
                        Text { text: "DATE"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "METHOD"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: donModel
                    delegate: Rectangle { width: table.width; height: 42
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.receiptNo; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            Text { text: model.donor; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; elide: Text.ElideRight }
                            Item { Layout.preferredWidth: 130; Layout.preferredHeight: 22
                                property var p: Theme.pillFor(model.category)
                                Rectangle { anchors.centerIn: parent; width: 95; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                            Text { text: model.amount; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text; horizontalAlignment: Text.AlignRight }
                            Text { text: model.date; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.method; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–84 of 84 donations"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
            Item { Layout.fillWidth: true }
            Text { text: "Total: Rs.92,750"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
        }
    }
    ListModel { id: donModel
        ListElement { receiptNo: "D-2026-078"; donor: "Rahim PT (Puthanpurayil)"; category: "Sponsorship"; amount: "Rs.5,000"; date: "28 Jul 2026"; method: "Cash" }
        ListElement { receiptNo: "D-2026-077"; donor: "Sulaiman K (Kizhakkepuram)"; category: "Zakat"; amount: "Rs.3,500"; date: "26 Jul 2026"; method: "UPI" }
        ListElement { receiptNo: "D-2026-076"; donor: "Yusuf T (Thekkepuram)"; category: "General"; amount: "Rs.1,000"; date: "25 Jul 2026"; method: "Cash" }
        ListElement { receiptNo: "D-2026-075"; donor: "Anonymous"; category: "Ramadan"; amount: "Rs.2,500"; date: "22 Jul 2026"; method: "Cash" }
        ListElement { receiptNo: "D-2026-074"; donor: "Hameed V (Vadakke Veettil)"; category: "Construction"; amount: "Rs.10,000"; date: "20 Jul 2026"; method: "Cheque" }
        ListElement { receiptNo: "D-2026-073"; donor: "Jameel P (Purayil House)"; category: "Sponsorship"; amount: "Rs.5,000"; date: "18 Jul 2026"; method: "UPI" }
        ListElement { receiptNo: "D-2026-072"; donor: "Ansar M (Madappattu)"; category: "General"; amount: "Rs.500"; date: "15 Jul 2026"; method: "Cash" }
    }
}
