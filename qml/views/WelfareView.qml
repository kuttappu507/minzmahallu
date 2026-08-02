import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

// WelfareView — welfare aid requests
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Welfare"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Welfare aid requests and disbursements"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search by request #, beneficiary..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text } } }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 130; model: ["All Status", "Pending", "Approved", "Rejected"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 130
                Text { anchors.centerIn: parent; text: "+ New Request"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
        }
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "DISBURSED"; value: "Rs.1,45,000"; sub: "14 beneficiaries"; tint: "vi" }
                    ListElement { label: "PENDING"; value: "Rs.32,000"; sub: "3 requests"; tint: "am" }
                    ListElement { label: "APPROVED"; value: "Rs.45,000"; sub: "2 awaiting payment"; tint: "bl" }
                    ListElement { label: "BUDGET"; value: "Rs.2,50,000"; sub: "FY 2026-27"; tint: "em" }
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
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            radius: 10; color: Theme.panel; border.width: 1.5; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 38; color: Theme.panelMuted
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                        Text { text: "REQUEST #"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "BENEFICIARY"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "REASON"; Layout.preferredWidth: 200; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "AMOUNT"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignRight }
                        Text { text: "DATE"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "STATUS"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: wModel
                    delegate: Rectangle { width: table.width; height: 44
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.reqNo; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            Text { text: model.beneficiary; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; elide: Text.ElideRight }
                            Text { text: model.reason; Layout.preferredWidth: 200; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted; elide: Text.ElideRight }
                            Text { text: model.amount; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text; horizontalAlignment: Text.AlignRight }
                            Text { text: model.date; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Item { Layout.preferredWidth: 110; Layout.preferredHeight: 22
                                property var p: Theme.pillFor(model.status)
                                Rectangle { anchors.centerIn: parent; width: 80; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–19 of 19 requests"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
        }
    }
    ListModel { id: wModel
        ListElement { reqNo: "W-2026-018"; beneficiary: "Fathima S (Kizhakkepuram)"; reason: "Medical - Surgery"; amount: "Rs.8,000"; date: "18 Jul 2026"; status: "Approved" }
        ListElement { reqNo: "W-2026-017"; beneficiary: "Rasheed P (Puzhaypuram)"; reason: "Education - Books"; amount: "Rs.5,000"; date: "15 Jul 2026"; status: "Approved" }
        ListElement { reqNo: "W-2026-016"; beneficiary: "Suhara V (Velichappuram)"; reason: "Housing repair"; amount: "Rs.15,000"; date: "12 Jul 2026"; status: "Pending" }
        ListElement { reqNo: "W-2026-015"; beneficiary: "Hamsa C (Chalil House)"; reason: "Daughter marriage"; amount: "Rs.10,000"; date: "10 Jul 2026"; status: "Approved" }
        ListElement { reqNo: "W-2026-014"; beneficiary: "Anonymous"; reason: "Food assistance"; amount: "Rs.2,500"; date: "05 Jul 2026"; status: "Rejected" }
        ListElement { reqNo: "W-2026-013"; beneficiary: "Ansar M (Madappattu)"; reason: "Job loss - emergency"; amount: "Rs.6,000"; date: "28 Jun 2026"; status: "Approved" }
    }
}
