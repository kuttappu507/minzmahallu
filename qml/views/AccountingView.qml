import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

// AccountingView — transactions, fund balances, ledger
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Accounting"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Ledger and fund balances"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 150; model: ["General Fund", "Welfare Fund", "Construction Fund", "Zakat Fund"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 130; model: ["This Month", "This Quarter", "This Year"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search transactions..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text } } }
            Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 130
                Text { anchors.centerIn: parent; text: "+ Transaction"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
        }
        // Fund balance cards
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "GENERAL FUND"; value: "Rs.4,56,320"; sub: "+Rs.48,200 this month"; tint: "em" }
                    ListElement { label: "WELFARE FUND"; value: "Rs.1,45,000"; sub: "+Rs.12,500 this month"; tint: "vi" }
                    ListElement { label: "CONSTRUCTION"; value: "Rs.2,80,500"; sub: "+Rs.10,000 this month"; tint: "am" }
                    ListElement { label: "ZAKAT FUND"; value: "Rs.78,500"; sub: "+Rs.3,500 this month"; tint: "bl" }
                }
                delegate: Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 100; radius: 10
                    property var t: Theme.tint(model.tint)
                    color: t.sb; border.width: 1.5; border.color: t.sc
                    ColumnLayout { anchors.fill: parent; anchors.margins: 14; spacing: 4
                        Text { text: model.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: t.st }
                        Text { text: model.value; font.family: Theme.fontDisplay; font.pixelSize: 24; font.weight: Font.Bold; color: t.st }
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
                        Text { text: "DATE"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "DESCRIPTION"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "FUND"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "TYPE"; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "DEBIT"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignRight }
                        Text { text: "CREDIT"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignRight }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: txModel
                    delegate: Rectangle { width: table.width; height: 40
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.date; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.desc; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; elide: Text.ElideRight }
                            Text { text: model.fund; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            Item { Layout.preferredWidth: 90; Layout.preferredHeight: 22
                                property var p: Theme.pillFor(model.type)
                                Rectangle { anchors.centerIn: parent; width: 70; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                            Text { text: model.debit; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.tints.rd.st; horizontalAlignment: Text.AlignRight }
                            Text { text: model.credit; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.tints.em.st; font.weight: Font.Bold; horizontalAlignment: Text.AlignRight }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Net balance: Rs.9,60,320"; font.family: Theme.fontPrimary; font.pixelSize: 12; font.weight: Font.Bold; color: Theme.text }
            Item { Layout.fillWidth: true }
            Text { text: "Showing 1–8 of 8 transactions"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
        }
    }
    ListModel { id: txModel
        ListElement { date: "28 Jul 2026"; desc: "Donation from Rahim PT - Sponsorship"; fund: "General"; type: "Approved"; debit: ""; credit: "Rs.5,000" }
        ListElement { date: "27 Jul 2026"; desc: "Monthly cleaning expense"; fund: "General"; type: "Paid"; debit: "Rs.1,200"; credit: "" }
        ListElement { date: "26 Jul 2026"; desc: "Zakat collection - Sulaiman K"; fund: "Zakat"; type: "Approved"; debit: ""; credit: "Rs.3,500" }
        ListElement { date: "25 Jul 2026"; desc: "Mosque electricity bill - July"; fund: "General"; type: "Paid"; debit: "Rs.3,800"; credit: "" }
        ListElement { date: "22 Jul 2026"; desc: "Ramadan donation - Anonymous"; fund: "General"; type: "Approved"; debit: ""; credit: "Rs.2,500" }
        ListElement { date: "20 Jul 2026"; desc: "Construction donation - Hameed V"; fund: "Construction"; type: "Approved"; debit: ""; credit: "Rs.10,000" }
        ListElement { date: "18 Jul 2026"; desc: "Welfare aid - Fathima S (medical)"; fund: "Welfare"; type: "Paid"; debit: "Rs.8,000"; credit: "" }
        ListElement { date: "15 Jul 2026"; desc: "Imam salary - July 2026"; fund: "General"; type: "Paid"; debit: "Rs.12,000"; credit: "" }
    }
}
