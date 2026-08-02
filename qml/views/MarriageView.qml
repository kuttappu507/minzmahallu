import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

// MarriageView — marriage registrations
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Marriage"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Marriage registrations and certificates"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search by marriage #, name..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text } } }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 130; model: ["This Year", "Last 6 Months", "All"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 130
                Text { anchors.centerIn: parent; text: "+ Register"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
        }
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "MARRIAGES"; value: "17"; sub: "2 this quarter"; tint: "or" }
                    ListElement { label: "THIS MONTH"; value: "1"; sub: "August 2026"; tint: "em" }
                    ListElement { label: "CERTIFICATES"; value: "17"; sub: "100% issued"; tint: "bl" }
                    ListElement { label: "AVG AGE"; value: "26"; sub: "Years"; tint: "vi" }
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
                        Text { text: "MARRIAGE #"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "GROOM"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "BRIDE"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "DATE"; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "MAHALLU"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "CERT"; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "ACTIONS"; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: mModel
                    delegate: Rectangle { width: table.width; height: 44
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.regNo; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            Text { text: model.groom; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; elide: Text.ElideRight }
                            Text { text: model.bride; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; elide: Text.ElideRight }
                            Text { text: model.date; Layout.preferredWidth: 120; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.mahallu; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            Item { Layout.preferredWidth: 90; Layout.preferredHeight: 22
                                property var p: Theme.pillFor(model.cert)
                                Rectangle { anchors.centerIn: parent; width: 70; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                            RowLayout { Layout.preferredWidth: 90; spacing: 4
                                Rectangle { width: 26; height: 26; radius: 6; color: Theme.tints.bl.sb; border.width: 1; border.color: Theme.tints.bl.sc; Text { anchors.centerIn: parent; text: "🖨"; font.pixelSize: 11; color: Theme.tints.bl.st } }
                                Rectangle { width: 26; height: 26; radius: 6; color: Theme.tints.sl.sb; border.width: 1; border.color: Theme.tints.sl.sc; Text { anchors.centerIn: parent; text: "✎"; font.pixelSize: 11; color: Theme.tints.sl.st } }
                            }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–17 of 17 marriages"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
        }
    }
    ListModel { id: mModel
        ListElement { regNo: "M-2026-017"; groom: "Rashid PP"; bride: "Sajna K"; date: "28 Jul 2026"; mahallu: "Kizhakkepuram"; cert: "Issued" }
        ListElement { regNo: "M-2026-016"; groom: "Faisal M"; bride: "Rashida V"; date: "20 Jul 2026"; mahallu: "Vadakke Veettil"; cert: "Issued" }
        ListElement { regNo: "M-2026-015"; groom: "Shameer T"; bride: "Haseena P"; date: "15 Jul 2026"; mahallu: "Thekkepuram"; cert: "Issued" }
        ListElement { regNo: "M-2026-014"; groom: "Mujeeb R"; bride: "Shafeeqa M"; date: "10 Jul 2026"; mahallu: "Purayil House"; cert: "Issued" }
        ListElement { regNo: "M-2026-013"; groom: "Anas K"; bride: "Zareena P"; date: "01 Jul 2026"; mahallu: "Manzil Manzoor"; cert: "Issued" }
        ListElement { regNo: "M-2026-012"; groom: "Jaseem P"; bride: "Nazeefa K"; date: "25 Jun 2026"; mahallu: "Puthanpurayil"; cert: "Issued" }
    }
}
