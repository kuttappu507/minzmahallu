import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

// TokensView — token events and assignments (Eid, Ramadan, etc.)
Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout { spacing: 2
                Text { text: "Tokens"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                Text { text: "Token events and family assignments"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
            }
            Item { Layout.fillWidth: true }
            Rectangle { radius: 8; color: Theme.panel; border.width: 1.5; border.color: Theme.border; implicitHeight: 34; Layout.preferredWidth: 240
                RowLayout { anchors.fill: parent; anchors.margins: 8; spacing: 6
                    Text { text: "🔍"; font.pixelSize: 12; color: Theme.muted }
                    TextField { Layout.fillWidth: true; placeholderText: "Search events..."; font.family: Theme.fontPrimary; font.pixelSize: 11; background: Item {} color: Theme.text } } }
            Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 130
                Text { anchors.centerIn: parent; text: "+ New Event"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
        }
        RowLayout { Layout.fillWidth: true; spacing: 12
            Repeater {
                model: ListModel {
                    ListElement { label: "EVENTS"; value: "12"; sub: "3 upcoming"; tint: "vi" }
                    ListElement { label: "ASSIGNED"; value: "1,142"; sub: "Tokens distributed"; tint: "em" }
                    ListElement { label: "COLLECTED"; value: "986"; sub: "86% collection rate"; tint: "bl" }
                    ListElement { label: "PENDING"; value: "156"; sub: "Awaiting collection"; tint: "am" }
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
                        Text { text: "EVENT NAME"; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "DATE"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        Text { text: "TOKENS"; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "COLLECTED"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "STATUS"; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "ACTIONS"; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
                    } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: tModel
                    delegate: Rectangle { width: table.width; height: 44
                        color: index % 2 === 0 ? Theme.panel : Theme.panelMuted
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border; opacity: 0.4 }
                        RowLayout { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Text { text: model.name; Layout.fillWidth: true; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.text; elide: Text.ElideRight }
                            Text { text: model.date; Layout.preferredWidth: 130; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                            Text { text: model.tokens; Layout.preferredWidth: 90; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text; horizontalAlignment: Text.AlignHCenter }
                            Text { text: model.collected; Layout.preferredWidth: 110; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.tints.em.st; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter }
                            Item { Layout.preferredWidth: 110; Layout.preferredHeight: 22
                                property var p: Theme.pillFor(model.status)
                                Rectangle { anchors.centerIn: parent; width: 80; height: 22; radius: 11; color: parent.p.sb; border.width: 1.2; border.color: parent.p.sc
                                    Text { anchors.centerIn: parent; text: parent.parent.p.label; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Bold; color: parent.parent.p.st } } }
                            RowLayout { Layout.preferredWidth: 130; spacing: 4
                                Rectangle { width: 28; height: 26; radius: 6; color: Theme.tints.bl.sb; border.width: 1; border.color: Theme.tints.bl.sc; Text { anchors.centerIn: parent; text: "🖨"; font.pixelSize: 11; color: Theme.tints.bl.st } }
                                Rectangle { width: 28; height: 26; radius: 6; color: Theme.tints.em.sb; border.width: 1; border.color: Theme.tints.em.sc; Text { anchors.centerIn: parent; text: "↓"; font.pixelSize: 11; color: Theme.tints.em.st } }
                                Rectangle { width: 28; height: 26; radius: 6; color: Theme.tints.sl.sb; border.width: 1; border.color: Theme.tints.sl.sc; Text { anchors.centerIn: parent; text: "✎"; font.pixelSize: 11; color: Theme.tints.sl.st } }
                                Rectangle { width: 28; height: 26; radius: 6; color: Theme.tints.vi.sb; border.width: 1; border.color: Theme.tints.vi.sc; Text { anchors.centerIn: parent; text: "✓"; font.pixelSize: 11; color: Theme.tints.vi.st } }
                            }
                        } } } } }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Text { text: "Showing 1–12 of 12 events"; font.family: Theme.fontPrimary; font.pixelSize: 10; color: Theme.muted }
        }
    }
    ListModel { id: tModel
        ListElement { name: "Eid Milad 2026"; date: "05 Sep 2026"; tokens: "1,142"; collected: "0"; status: "Pending" }
        ListElement { name: "Ramadan Kit 2026"; date: "01 Mar 2026"; tokens: "1,142"; collected: "1,142"; status: "Approved" }
        ListElement { name: "Bakrid 2025"; date: "07 Jun 2025"; tokens: "1,142"; collected: "986"; status: "Approved" }
        ListElement { name: "Ramadan Iftar Kit 2025"; date: "02 Mar 2025"; tokens: "1,142"; collected: "1,138"; status: "Approved" }
        ListElement { name: "Eid Special 2024"; date: "10 Apr 2024"; tokens: "1,089"; collected: "1,089"; status: "Approved" }
        ListElement { name: "Annual Day 2024"; date: "26 Jan 2024"; tokens: "1,089"; collected: "954"; status: "Approved" }
    }
}
