import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// DeathView — death records
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Death"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Death records and certificates"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search by death #, name..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text } } }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 130; model: ["This Year", "Last 6 Months", "All"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 130
                Text { anchors.centerIn: parent; text: "+ Record"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
        }
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "TOTAL"; value: "9"; sub: "1 this month"; tint: "sl" }
                    ListElement { label: "THIS MONTH"; value: "1"; sub: "August 2026"; tint: "sl" }
                    ListElement { label: "CERTIFICATES"; value: "9"; sub: "100% issued"; tint: "bl" }
                    ListElement { label: "AVG AGE"; value: "72"; sub: "Years"; tint: "vi" }
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
                        Text { text: "DEATH #"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "NAME"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "DATE OF DEATH"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "AGE"; Layout.preferredWidth: 70; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "GENDER"; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "PLACE"; Layout.preferredWidth: 140; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "CERT"; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: dModel
                    delegate: Rectangle { width: table.width; height: 44
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.regNo; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            Text { text: model.name; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; elide: Text.ElideRight }
                            Text { text: model.date; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.age; Layout.preferredWidth: 70; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; horizontalAlignment: Text.AlignHCenter }
                            Text { text: model.gender; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            Text { text: model.place; Layout.preferredWidth: 140; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Item { Layout.preferredWidth: 90; Layout.preferredHeight: 22
                                property var p: Theme.pillFor(model.cert)
                                Rectangle { anchors.centerIn: parent; width: 70; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–9 of 9 records"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
        }
    }
    ListModel { id: dModel
        ListElement { regNo: "D-2026-009"; name: "Kunjammu M"; date: "25 Jul 2026"; age: 78; gender: "Female"; place: "Manzil Manzoor"; cert: "Issued" }
        ListElement { regNo: "D-2026-008"; name: "Abdulla K"; date: "18 Jul 2026"; age: 82; gender: "Male"; place: "Kizhakkepuram"; cert: "Issued" }
        ListElement { regNo: "D-2026-007"; name: "Zainaba P"; date: "10 Jul 2026"; age: 75; gender: "Female"; place: "Puthanpurayil"; cert: "Issued" }
        ListElement { regNo: "D-2026-006"; name: "Moosa V"; date: "05 Jul 2026"; age: 68; gender: "Male"; place: "Vadakke Veettil"; cert: "Issued" }
        ListElement { regNo: "D-2026-005"; name: "Sainaba T"; date: "28 Jun 2026"; age: 80; gender: "Female"; place: "Thekkepuram"; cert: "Issued" }
        ListElement { regNo: "D-2026-004"; name: "Ibrahim P"; date: "20 Jun 2026"; age: 70; gender: "Male"; place: "Purayil House"; cert: "Issued" }
    }
}
