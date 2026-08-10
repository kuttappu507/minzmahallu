import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects

// ============================================================================
// DashboardPage — Dashboard content only (no sidebar/topbar)
// Loaded by AppShell which provides the sidebar and topbar
// ============================================================================

Item {
    id: page

ScrollView {
                id: scrollView
                anchors.fill: parent
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    id: contentCol
                    // CRITICAL: bind to scrollView.width, NOT parent.width
                    // parent is the ScrollView's internal Flickable (contentItem)
                    // whose width creates a circular dependency with contentWidth.
                    // scrollView.width is the actual viewport width.
                    width: scrollView.width
                    spacing: 16  // CSS: margin-bottom:16px on each section
                    x: 0

                    // Top padding (CSS: .view has padding:18px)
                    Item { Layout.fillWidth: true; Layout.preferredHeight: 18 }

                    // ===== VIEW HEADER =====
                    // CSS: .vhead h1 { font:700 21px "Space Grotesk"; }
                    // CSS: .vhead .vs { font:600 12px Manrope; color:var(--muted)=#4f6b5c; margin-top:2px; }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 18
                        Layout.rightMargin: 18
                        spacing: 2

                        Text {
                            text: { var _l = I18NController.currentLanguage; return I18NController.tr("dash_greeting") + ", " + AuthController.fullName }
                            font.family: Theme.activeFontFamily
                            font.pixelSize: Theme.fontSizeXl
                            font.weight: Font.DemiBold
                            color: Theme.textPrimary
                        }
                        Text {
                            text: { var _l = I18NController.currentLanguage; return I18NController.tr("dash_subtitle") }
                            font.family: Theme.activeFontFamily
                            font.pixelSize: Theme.fontSizeSm
                            font.weight: Font.DemiBold
                            color: Theme.textSecondary
                        }
                    }

                    // ===== QUICK ACTIONS ROW =====
                    // CSS: .qa-row { grid-template-columns:repeat(5,1fr); gap:12px; margin-bottom:16px; }
                    // CSS: .qa { padding:12px 14px; background:var(--panel)=#ffffff; border:1.5px solid var(--border)=#d2e5d8; border-radius:10px; box-shadow:var(--sh); }
                    // CSS: .qa .qic { width:42px; height:42px; border-radius:9px; background:var(--sc); color:#fff; box-shadow:0 3px 0 rgba(0,0,0,.18); }
                    // CSS: .qa b { font:700 12.5px Manrope; color:var(--text)=#12241b; }
                    // CSS: .qa small { font:600 10.5px Manrope; color:var(--faint)=#7e968a; }
                    GridLayout {
                        id: qaGrid
                        Layout.fillWidth: true
                        Layout.leftMargin: 18
                        Layout.rightMargin: 18
                        columns: mainApp.responsiveColumns
                        columnSpacing: 12
                        rowSpacing: 12

                        Repeater {
                            model: 5
                            delegate: Rectangle {
                                id: qaCard
                                Layout.fillWidth: true
                                Layout.minimumWidth: 180
                                implicitHeight: qaContent.implicitHeight + 24
                                radius: 10
                                color: Theme.surface
                                property string qaLabel: { var _l = I18NController.currentLanguage; return [I18NController.tr("dash_quick_add_family"), I18NController.tr("dash_quick_add_member"), I18NController.tr("dash_quick_record_payment"), I18NController.tr("dash_quick_add_donation"), I18NController.tr("dash_quick_generate_report")][index] }
                                property string qaSub: [DashboardController.totalFamilies + " families", DashboardController.totalMembers + " members", "RCP-" + (DashboardController.totalFamilies + 1), "5 categories", "15 report types"][index]
                                property string qaSc: [Theme.primary,"#0d9488","#d97706","#db2777","#7c3aed"][index]
                                property string qaIcon: ["plus","user","dollar","donations","reports"][index]
                                border.width: 1
                                border.color: qaMA.containsMouse ? qaSc : Theme.border
                                z: qaMA.containsMouse ? 10 : 0
                                transform: Translate { y: qaMA.containsMouse ? -2 : 0; Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } } }
                                Behavior on border.color { ColorAnimation { duration: 160 } }

                                Row {
                                    id: qaContent
                                    x: 14; y: 12
                                    spacing: 12

                                    Rectangle {
                                        width: 42; height: 42; radius: 9
                                        color: qaCard.qaSc

                                        Item {
                                            width: 20; height: 20
                                            anchors.centerIn: parent

                                            Image {
                                                id: qaIcon
                                                source: "qrc:/icons/svg/" + qaCard.qaIcon + ".svg"
                                                sourceSize: Qt.size(20, 20)
                                                anchors.fill: parent
                                                fillMode: Image.Pad
                                                visible: false
                                            }
                                            MultiEffect {
                                                anchors.fill: parent
                                                source: qaIcon
                                                colorizationColor: Theme.surface
                                                colorization: 1.0
                                            }
                                        }
                                    }

                                    Column {
                                        spacing: 1
                                        y: (42 - height) / 2

                                        Text {
                                            text: qaCard.qaLabel
                                            font.family: Theme.activeFontFamily
                                            font.pixelSize: Theme.fontSizeMd
                                            font.weight: Font.DemiBold
                                            color: Theme.textPrimary
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                            width: qaCard.width - 42 - 12 - 28
                                        }
                                        Text {
                                            text: qaCard.qaSub
                                            font.family: Theme.activeFontFamily
                                            font.pixelSize: Theme.fontSizeXs
                                            font.weight: Font.Normal
                                            color: Theme.textTertiary
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                            width: qaCard.width - 42 - 12 - 28
                                        }
                                    }
                                }

                                MouseArea {
                                    id: qaMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }

                    // ===== STAT GRID (10 cards, 5 columns) =====
                    // CSS: .stat-grid { grid-template-columns:repeat(5,1fr); gap:12px; }
                    // CSS: .stat { padding:13px 14px 12px; background:var(--sb); border:1.5px solid var(--sc); border-radius:10px; overflow:hidden; }
                    // CSS: .stat::after { right:-14px; bottom:-14px; width:56px; height:56px; border-radius:50%; background:var(--sc); opacity:.14; }
                    // CSS: .stat .sic { width:37px; height:37px; border-radius:9px; background:var(--sc); color:#fff; box-shadow:0 3px 0 rgba(0,0,0,.18); }
                    // CSS: .stat .delta { font:800 9.5px Manrope; padding:3.5px 8px; border-radius:99px; background:var(--panel)=#fff; color:var(--st); border:1.5px solid var(--sc); }
                    // CSS: .stat .val { font:700 24px/1 "Space Grotesk"; color:var(--st); }
                    // CSS: .stat .slab { font:800 10px Manrope; letter-spacing:.09em; text-transform:uppercase; color:var(--st); opacity:.75; margin-top:6px; }
                    GridLayout {
                        id: statGrid
                        Layout.fillWidth: true
                        Layout.leftMargin: 18
                        Layout.rightMargin: 18
                        columns: mainApp.responsiveColumns
                        columnSpacing: 12
                        rowSpacing: 12

                        // Stat card component — accepts dynamic values via properties
                        Repeater {
                            model: 10
                            delegate: Rectangle {
                                id: statCard
                                Layout.fillWidth: true
                                Layout.minimumWidth: 180
                                implicitHeight: statContent.implicitHeight + 25
                                radius: 10
                                property string cardLabel: ["FAMILIES","MEMBERS","ACTIVE","COLLECTION","DUES","DONATIONS","WELFARE","MARRIAGES","DEATHS","BALANCE"][index]
                                property string cardValue: [
                                    DashboardController.totalFamilies,
                                    DashboardController.totalMembers,
                                    DashboardController.activeMembers,
                                    "₹" + DashboardController.monthlyCollection.toFixed(0),
                                    "₹" + DashboardController.pendingDues.toFixed(0),
                                    "₹" + DashboardController.monthlyDonations.toFixed(0),
                                    "—",
                                    DashboardController.marriagesThisYear,
                                    DashboardController.deathsThisYear,
                                    "₹" + DashboardController.balance.toFixed(0)
                                ][index]
                                property string cardSc: [Theme.primary,"#0d9488","#0284c7","#d97706",Theme.danger,"#db2777","#7c3aed","#ea580c","#64748b","#2563eb"][index]
                                property string cardSb: ["#d3f5e6","#c8f6f1","#d7edfb","#fcebc8","#fddfe5","#fadfeb","#e7defc","#ffe4cf","#e6ebf2","#dbe7fd"][index]
                                property string cardSt: ["#04543c","#0f5e54","#0a5480","#7c4403","#95102e","#93184f","#5423b7","#8f3708","#33415c","#1e3fae"][index]
                                property string cardIcon: ["families","members","user","dollar","alert","donations","welfare","marriage","death","accounting"][index]
                                color: Theme.dark ? Qt.darker(cardSb, 3) : cardSb
                                border.width: 1
                                border.color: statHover.containsMouse ? cardSc : Qt.lighter(cardSc, 1.15)
                                z: statHover.hovered ? 10 : 0
                                transform: Translate { id: statLift; y: statHover.hovered ? -2 : 0; Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } } }
                                Behavior on border.color { ColorAnimation { duration: 160 } }

                                HoverHandler { id: statHover; cursorShape: Qt.PointingHandCursor }

                                Rectangle {
                                    anchors.right: parent.right; anchors.bottom: parent.bottom
                                    anchors.rightMargin: 4; anchors.bottomMargin: 4
                                    width: statHover.hovered ? 52 : 46; height: width; radius: width / 2
                                    color: cardSc; opacity: 0.12
                                    Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                                    Behavior on opacity { NumberAnimation { duration: 160 } }
                                }

                                Column {
                                    id: statContent
                                    x: 14; y: 13; width: parent.width - 28; spacing: 0

                                    Item {
                                        width: parent.width; height: 37
                                        Rectangle {
                                            width: 37; height: 37; radius: 9; color: cardSc
                                            Item {
                                                width: 18; height: 18; anchors.centerIn: parent
                                                Image { id: statIcon; source: "qrc:/icons/svg/" + statCard.cardIcon + ".svg"; sourceSize: Qt.size(18, 18); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                                                MultiEffect { anchors.fill: parent; source: statIcon; colorizationColor: Theme.surface; colorization: 1.0 }
                                            }
                                        }
                                    }

                                    Text {
                                        text: statCard.cardValue
                                        font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSize2xl; font.weight: Font.Bold
                                        color: Theme.dark ? Qt.lighter(cardSt, 1.5) : cardSt
                                        topPadding: 9; elide: Text.ElideRight; maximumLineCount: 1; width: parent.width
                                    }

                                    Text {
                                        text: statCard.cardLabel
                                        font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium
                                        color: Theme.dark ? Qt.lighter(cardSt, 1.5) : cardSt
                                        opacity: 0.75; topPadding: 6; elide: Text.ElideRight; maximumLineCount: 1; width: parent.width
                                    }
                                }
                            }
                        }
                    }

                    // ===== EVENT ROW =====
                    // CSS: .ev-row { grid-template-columns:1fr 1fr; gap:12px; }
                    // CSS: .ev-card { padding:14px 16px; display:flex; gap:13px; }
                    // CSS: .ev-card .eic { width:42px; height:42px; border-radius:10px; background:#db2777; color:#fff; box-shadow:0 3px 0 rgba(0,0,0,.18); }
                    // CSS: .ev-card b { font:700 13.5px Manrope; }
                    // CSS: .ev-card small { font:600 11.5px Manrope; color:var(--muted)=#4f6b5c; }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 18
                        Layout.rightMargin: 18
                        spacing: 12

                        Repeater {
                            model: ListModel {
                                ListElement { title: "Eid Milad 2026";   sub: "05 Sep 2026 · 1,142 tokens · 0 collected"; icon: "token" }
                                ListElement { title: "Ramadan Kit 2026"; sub: "01 Mar 2026 · 1,142 tokens · 1,142 collected"; icon: "token" }
                            }

                            delegate: Rectangle {
                                id: evCard
                                Layout.fillWidth: true
                                implicitHeight: evContent.implicitHeight + 28
                                radius: 10
                                color: Theme.surface
                                border.width: 1
                                border.color: evHover.containsMouse ? Theme.primary : Theme.border
                                z: evHover.containsMouse ? 10 : 0
                                transform: Translate { y: evHover.containsMouse ? -2 : 0; Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                HoverHandler {
                                    id: evHover
                                    cursorShape: Qt.PointingHandCursor
                                }

                                Row {
                                    id: evContent
                                    x: 16; y: 14
                                    spacing: 13

                                    // CSS: .ev-card .eic
                                    Rectangle {
                                        width: 42; height: 42; radius: 10
                                        color: Theme.pink

                                        Item {
                                            width: 20; height: 20
                                            anchors.centerIn: parent

                                            Image {
                                                id: evIcon
                                                source: "qrc:/icons/svg/" + model.icon + ".svg"
                                                sourceSize: Qt.size(20, 20)
                                                anchors.fill: parent
                                                fillMode: Image.Pad
                                                visible: false
                                            }
                                            MultiEffect {
                                                anchors.fill: parent
                                                source: evIcon
                                                colorizationColor: Theme.surface
                                                colorization: 1.0
                                            }
                                        }
                                    }

                                    Column {
                                        spacing: 1
                                        y: (42 - height) / 2

                                        Text {
                                            text: model.title
                                            font.family: Theme.activeFontFamily
                                            font.pixelSize: Theme.fontSizeMd
                                            font.weight: Font.DemiBold
                                            color: Theme.textPrimary
                                            elide: Text.ElideRight
                                            width: evCard.width - 42 - 13 - 32
                                        }
                                        Text {
                                            text: model.sub
                                            font.family: Theme.activeFontFamily
                                            font.pixelSize: Theme.fontSizeSm
                                            font.weight: Font.Normal
                                            color: Theme.textSecondary
                                            elide: Text.ElideRight
                                            width: evCard.width - 42 - 13 - 32
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bottom padding
                    Item { Layout.fillWidth: true; Layout.preferredHeight: 18 }
                }
            }
}
