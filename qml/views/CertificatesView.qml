import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

// CertificatesView — issued certificates (membership/residence/marriage/death)
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Certificates"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Issued certificates and PDF generation"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search by cert #, name..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text } } }
            ComboBox { implicitHeight: 34; Layout.preferredWidth: 180; model: ["All Types", "Membership", "Residence", "Marriage", "Death"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
            Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 130
                Text { anchors.centerIn: parent; text: "+ Issue"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
        }
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "TOTAL ISSUED"; value: "186"; sub: "All types"; tint: "bl" }
                    ListElement { label: "MEMBERSHIP"; value: "98"; sub: "53% of total"; tint: "em" }
                    ListElement { label: "RESIDENCE"; value: "62"; sub: "33% of total"; tint: "am" }
                    ListElement { label: "THIS MONTH"; value: "14"; sub: "August 2026"; tint: "vi" }
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
                        Text { text: "CERT #"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "NAME"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "TYPE"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "ISSUE DATE"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "ISSUED BY"; Layout.preferredWidth: 140; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "ACTIONS"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: cModel
                    delegate: Rectangle { width: table.width; height: 44
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.certNo; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text }
                            Text { text: model.name; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; elide: Text.ElideRight }
                            Item { Layout.preferredWidth: 130; Layout.preferredHeight: 22
                                property var p: Theme.pillFor(model.type)
                                Rectangle { anchors.centerIn: parent; width: 90; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                            Text { text: model.date; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.issuedBy; Layout.preferredWidth: 140; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                            RowLayout { Layout.preferredWidth: 110; spacing: 4
                                Rectangle { width: 28; height: 26; radius: 6; color: Theme.tints.bl.sb; border.width: 1; border.color: Theme.tints.bl.sc; Text { anchors.centerIn: parent; text: "🖨"; font.pixelSize: 11; color: Theme.tints.bl.st } }
                                Rectangle { width: 28; height: 26; radius: 6; color: Theme.tints.em.sb; border.width: 1; border.color: Theme.tints.em.sc; Text { anchors.centerIn: parent; text: "↓"; font.pixelSize: 11; color: Theme.tints.em.st } }
                                Rectangle { width: 28; height: 26; radius: 6; color: Theme.tints.sl.sb; border.width: 1; border.color: Theme.tints.sl.sc; Text { anchors.centerIn: parent; text: "✎"; font.pixelSize: 11; color: Theme.tints.sl.st } }
                            }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–186 of 186 certificates"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
        }
    }
    ListModel { id: cModel
        ListElement { certNo: "C-2026-186"; name: "Manzoor PP"; type: "Membership"; date: "28 Jul 2026"; issuedBy: "Administrator" }
        ListElement { certNo: "C-2026-185"; name: "Rahim PT"; type: "Residence"; date: "26 Jul 2026"; issuedBy: "Administrator" }
        ListElement { certNo: "C-2026-184"; name: "Rashid PP & Sajna K"; type: "Marriage"; date: "28 Jul 2026"; issuedBy: "Secretary" }
        ListElement { certNo: "C-2026-183"; name: "Kunjammu M"; type: "Death"; date: "25 Jul 2026"; issuedBy: "Administrator" }
        ListElement { certNo: "C-2026-182"; name: "Sulaiman K"; type: "Membership"; date: "22 Jul 2026"; issuedBy: "Administrator" }
        ListElement { certNo: "C-2026-181"; name: "Hameed V"; type: "Residence"; date: "20 Jul 2026"; issuedBy: "Administrator" }
    }
}
