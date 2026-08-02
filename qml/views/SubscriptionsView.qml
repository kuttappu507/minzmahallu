import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

// SubscriptionsView — receipt list, mark paid/overdue
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Subscriptions"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Monthly subscription receipts"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search by receipt #, family..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text } } }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 130; model: ["All Status", "Paid", "Overdue", "Pending"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 130; model: ["This Year", "Last 6 Months", "All"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 130
                Text { anchors.centerIn: parent; text: "+ New Receipt"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
        }
        // Summary cards
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "COLLECTED"; value: "Rs.48,200"; sub: "247 receipts"; tint: "em" }
                    ListElement { label: "OVERDUE"; value: "Rs.36,400"; sub: "7 families"; tint: "rd" }
                    ListElement { label: "PENDING"; value: "Rs.12,000"; sub: "12 receipts"; tint: "am" }
                    ListElement { label: "TOTAL DUE"; value: "Rs.96,600"; sub: "All months"; tint: "bl" }
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
                        Text { text: "FAMILY"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "MONTH"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "AMOUNT"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignRight }
                        Text { text: "PAID DATE"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "STATUS"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: subModel
                    delegate: Rectangle { width: table.width; height: 42
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.receiptNo; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            Text { text: model.family; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; elide: Text.ElideRight }
                            Text { text: model.month; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            Text { text: model.amount; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text; horizontalAlignment: Text.AlignRight }
                            Text { text: model.paidDate; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Item { Layout.preferredWidth: 110; Layout.preferredHeight: 26
                                property var p: Theme.pillFor(model.status)
                                Rectangle { anchors.centerIn: parent; width: 78; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–259 of 259 receipts"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
            Item { Layout.fillWidth: true }
            Rectangle { width: 26; height: 26; radius: 6; color: Theme.panel; border.width: 1; border.color: Theme.border; Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 14; color: Theme.muted } }
            Text { text: "1 of 6"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
            Rectangle { width: 26; height: 26; radius: 6; color: Theme.panel; border.width: 1; border.color: Theme.border; Text { anchors.centerIn: parent; text: "›"; font.pixelSize: 14; color: Theme.muted } }
        }
    }
    ListModel { id: subModel
        ListElement { receiptNo: "R-2026-07-001"; family: "Manzil Manzoor (KH-F-0001)"; month: "Jul 2026"; amount: "Rs.200"; paidDate: "02 Jul 2026"; status: "Paid" }
        ListElement { receiptNo: "R-2026-07-002"; family: "Puthanpurayil (KH-F-0002)"; month: "Jul 2026"; amount: "Rs.200"; paidDate: "05 Jul 2026"; status: "Paid" }
        ListElement { receiptNo: "R-2026-07-003"; family: "Kizhakkepuram (KH-F-0003)"; month: "Jul 2026"; amount: "Rs.200"; paidDate: ""; status: "Overdue" }
        ListElement { receiptNo: "R-2026-07-004"; family: "Vadakke Veettil (KH-F-0004)"; month: "Jul 2026"; amount: "Rs.200"; paidDate: "10 Jul 2026"; status: "Paid" }
        ListElement { receiptNo: "R-2026-07-005"; family: "Thekkepuram (KH-F-0005)"; month: "Jul 2026"; amount: "Rs.200"; paidDate: "12 Jul 2026"; status: "Paid" }
        ListElement { receiptNo: "R-2026-07-006"; family: "Purayil House (KH-F-0006)"; month: "Jul 2026"; amount: "Rs.200"; paidDate: ""; status: "Pending" }
        ListElement { receiptNo: "R-2026-07-007"; family: "Madappattu (KH-F-0007)"; month: "Jul 2026"; amount: "Rs.200"; paidDate: "18 Jul 2026"; status: "Paid" }
        ListElement { receiptNo: "R-2026-07-008"; family: "Kunnumpuram (KH-F-0008)"; month: "Jul 2026"; amount: "Rs.200"; paidDate: ""; status: "Overdue" }
    }
}
