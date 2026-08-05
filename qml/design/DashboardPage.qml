import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// DashboardPage — Dashboard content as embeddable Item
// Extracted from DashboardV3 for use inside AppShell
// ============================================================================

Item {
    id: page

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ===== SIDEBAR (260px, green gradient) =====
        // CSS: #sidebar { width:260px; background:linear-gradient(180deg,#0a7f5d 0%,#065f46 42%,#044633 100%); color:#e8f6ef; }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: false
            implicitWidth: 260
            // CSS gradient
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0;  color: "#0a7f5d" }
                GradientStop { position: 0.42; color: "#065f46" }
                GradientStop { position: 1.0;  color: "#044633" }
            }

            Column {
                anchors.fill: parent
                spacing: 0

                // CSS: .sb-logo { padding:18px 18px 16px; gap:11px; }
                // Logo area
                Item {
                    width: parent.width
                    height: 72  // 18+38+16 padding

                    Row {
                        x: 18; y: 18
                        spacing: 11

                        // CSS: .sb-logo svg { width:38px;height:38px; }
                        Rectangle {
                            width: 38; height: 38; radius: 14
                            color: Qt.rgba(255,255,255,0.14)

                            // Logo SVG (simplified — gold crescent + white dome)
                            Rectangle {
                                anchors.centerIn: parent
                                width: 24; height: 24; radius: 12
                                color: "#f2c14e"
                                visible: false
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "M"
                                font.family: "Poppins"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                        }

                        Column {
                            spacing: 0
                            // CSS: .sb-logo b { font:800 17px "Space Grotesk"; color:#fff; }
                            Text {
                                text: "MMS"
                                font.family: "Poppins"
                                font.pixelSize: 17
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                            // CSS: .sb-logo small { font:600 10.5px Manrope; color:#a5dcc6; letter-spacing:.05em; }
                            Text {
                                text: "Minz Mahallu"
                                font.family: "Poppins"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: "#a5dcc6"
                            }
                        }
                    }
                }

                // Nav section label
                // CSS: .nav-sec { font:800 9px Manrope; letter-spacing:.22em; text-transform:uppercase; color:rgba(214,240,228,.42); padding:15px 24px 5px; }
                Text {
                    text: "OVERVIEW"
                    font.family: "Poppins"
                    font.pixelSize: 9
                    font.weight: Font.Black
                    color: Qt.rgba(214/255, 240/255, 228/255, 0.42)
                    leftPadding: 24
                    topPadding: 15
                    bottomPadding: 5
                }

                // Nav items — CSS: .nav-it { height:44px; margin:2px 10px; padding:0 13px; border-radius:9px; color:#c4e7d7; gap:12px; }
                // .nav-it.on { background:rgba(255,255,255,.14); color:#fff; }
                // .nav-it.on::before { left:-10px; width:4px; height:22px; border-radius:4px; background:#f2c14e; }
                // .nav-it:hover { background:rgba(255,255,255,.09); color:#fff; }
                ListView {
                    id: navList
                    width: parent.width
                    height: parent.height - 72 - 36 - 80  // logo + label + user
                    clip: true
                    spacing: 2  // compact: was 4px
                    interactive: false
                    model: ListModel {
                        ListElement { label: "Dashboard";     icon: "dashboard";     active: true }
                        ListElement { label: "Families";      icon: "families";      active: false }
                        ListElement { label: "Members";       icon: "members";       active: false }
                        ListElement { label: "Subscriptions"; icon: "subscriptions"; active: false }
                        ListElement { label: "Donations";     icon: "donations";     active: false }
                        ListElement { label: "Accounting";    icon: "accounting";    active: false }
                        ListElement { label: "Marriage";      icon: "marriage";      active: false }
                        ListElement { label: "Death";         icon: "death";         active: false }
                        ListElement { label: "Welfare";       icon: "welfare";       active: false }
                        ListElement { label: "Certificates";  icon: "certificates";  active: false }
                        ListElement { label: "Tokens";        icon: "token";         active: false }
                        ListElement { label: "Reports";       icon: "reports";       active: false }
                        ListElement { label: "Settings";      icon: "settings";      active: false }
                        ListElement { label: "Users";         icon: "users";         active: false }
                        ListElement { label: "Audit Log";     icon: "audit";         active: false }
                        ListElement { label: "Backup";        icon: "backup";        active: false }
                    }

                    delegate: Item {
                        width: navList.width - 20  // CSS: margin:2px 10px
                        height: 40  // compact: was 44px
                        x: 10

                        Rectangle {
                            id: navRect
                            anchors.fill: parent
                            radius: 9
                            color: model.active ? Qt.rgba(255/255,255/255,255/255,0.14) :
                                   (navMA.containsMouse ? Qt.rgba(255/255,255/255,255/255,0.09) : "transparent")
                            Behavior on color { ColorAnimation { duration: 140 } }

                            // CSS: .nav-it.on::before { left:-10px; width:4px; height:22px; border-radius:4px; background:#f2c14e; }
                            Rectangle {
                                x: -10
                                y: (40 - 22) / 2
                                width: 4; height: 22; radius: 4
                                color: "#f2c14e"
                                visible: model.active
                            }
                        }

                        Row {
                            x: 13  // CSS: padding:0 13px
                            y: 0
                            height: 44
                            spacing: 12  // CSS: gap:12px

                            // Icon
                            Item {
                                width: 18; height: 18
                                y: (44 - 18) / 2

                                Image {
                                    id: navIcon
                                    source: "qrc:/icons/svg/" + model.icon + ".svg"
                                    sourceSize: Qt.size(18, 18)
                                    anchors.fill: parent
                                    fillMode: Image.Pad
                                    visible: false
                                }
                                MultiEffect {
                                    anchors.fill: parent
                                    source: navIcon
                                    // CSS: .nav-it .ic { color:#c4e7d7; } .nav-it.on .ic { color:#ffd76a; }
                                    colorizationColor: model.active ? "#ffffff" :
                                                       (navMA.containsMouse ? "#ffffff" : "#ffffff")
                                    colorization: 1.0
                                }
                            }

                            // CSS: .nav-it b { font:700 12.8px Manrope; color:#c4e7d7; } .nav-it.on { color:#fff; }
                            Text {
                                text: model.label
                                font.family: "Poppins"
                                font.pixelSize: 13
                                font.weight: model.active ? Font.DemiBold : Font.Medium
                                color: model.active ? "#ffffff" :
                                       (navMA.containsMouse ? "#ffffff" : "#c4e7d7")
                                y: (44 - height) / 2
                            }
                        }

                        MouseArea {
                            id: navMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPressed: navRect.color = model.active ? Qt.rgba(255/255,255/255,255/255,0.22) : Qt.rgba(255/255,255/255,255/255,0.14)
                            onReleased: navRect.color = model.active ? Qt.rgba(255/255,255/255,255/255,0.14) : (containsMouse ? Qt.rgba(255/255,255/255,255/255,0.09) : "transparent")
                        }
                    }
                }

                // CSS: .sb-user { border-top:1px solid rgba(255,255,255,.14); padding:13px 14px; gap:10px; }
                // .sb-user .av { width:36px; height:36px; border-radius:9px; font:800 13px "Space Grotesk"; color:#4a3606; background:#f2c14e; border:2px solid #b98317; }
                // .sb-user b { font:700 12.5px Manrope; color:#fff; }
                // .sb-user small { font:600 10.5px Manrope; color:#9fd8c3; }
                Item {
                    width: parent.width
                    height: 80

                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: Qt.rgba(255/255,255/255,255/255,0.14)
                    }

                    // Profile hover background (outside Row to avoid anchor conflict)
                    Rectangle {
                        x: 10; y: 9
                        width: profileRow.width + 8
                        height: profileRow.height + 8
                        radius: 9
                        color: Qt.rgba(255/255,255/255,255/255, profileHover.containsMouse ? 0.06 : 0)
                        Behavior on color { ColorAnimation { duration: 120 } }
                        z: -1
                    }

                    HoverHandler {
                        id: profileHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    Row {
                        id: profileRow
                        x: 14; y: 13
                        spacing: 10

                        // Avatar — gold
                        Rectangle {
                            width: 36; height: 36; radius: 9
                            color: "#f2c14e"
                            border.width: 2
                            border.color: "#b98317"

                            Text {
                                anchors.centerIn: parent
                                text: "AK"
                                font.family: "Poppins"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: "#4a3606"
                            }
                        }

                        Column {
                            spacing: 0

                            Text {
                                text: "Abdul Kareem"
                                font.family: "Poppins"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: "#ffffff"
                            }
                            Text {
                                text: "Administrator"
                                font.family: "Poppins"
                                font.pixelSize: 11
                                font.weight: Font.Normal
                                color: "#9fd8c3"
                            }
                        }
                    }
                }
            }
        }

        // ===== MAIN CONTENT AREA =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ===== TOPBAR =====
            // CSS: .topbar { height:58px; background:var(--panel)=#ffffff; border-bottom:1.5px solid var(--border)=#d2e5d8; padding:0 18px; gap:13px; }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 58
                color: "#ffffff"

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: "#d2e5d8"
                }

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    // CSS: .crumb small { font:700 11px Manrope; color:var(--faint)=#7e968a; letter-spacing:.06em; text-transform:uppercase; }
                    // CSS: .crumb b { font:700 15.5px "Space Grotesk"; color:var(--text)=#12241b; }
                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Text {
                            text: "MINZ MAHALLU /"
                            font.family: "Poppins"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#7e968a"
                            y: (parent.height - height) / 2
                        }
                        Text {
                            text: "Dashboard"
                            font.family: "Poppins"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: "#12241b"
                            y: (parent.height - height) / 2
                        }
                    }

                    // CSS: .qwrap { background:var(--panel2)=#f2faf4; border:1.5px solid var(--border)=#d2e5d8; border-radius:9px; height:38px; width:250px; padding:0 10px; }
                    Rectangle {
                        id: searchBox
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: window.contentWidth > 800 ? 250 : (window.contentWidth > 500 ? 180 : 120); height: 38; radius: 9
                        color: "#f2faf4"
                        border.width: 1
                        border.color: searchInput.activeFocus ? "#059669" : (searchHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        // Subtle focus glow
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -2
                            radius: parent.radius + 2
                            color: "transparent"
                            border.width: 2
                            border.color: Qt.rgba(5/255,150/255,105/255,0.12)
                            visible: searchInput.activeFocus
                        }

                        HoverHandler {
                            id: searchHover
                            cursorShape: Qt.IBeamCursor
                        }

                        // Search icon — vertically centered
                        Text {
                            text: "\u{1F50D}"
                            font.pixelSize: 14
                            color: searchInput.activeFocus ? "#059669" : "#7e968a"
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                        // Text input — vertically centered, fills remaining width
                        TextField {
                            id: searchInput
                            anchors.left: parent.left
                            anchors.leftMargin: 32
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            placeholderText: "Search records..."
                            placeholderTextColor: "#7e968a"
                            font.family: "Poppins"
                            font.pixelSize: 13
                            color: "#12241b"
                            background: Item {}
                            verticalAlignment: Text.AlignVCenter
                            cursorDelegate: Rectangle {
                                visible: searchInput.activeFocus
                                color: "#059669"
                                width: 1
                            }
                        }
                    }
                }
            }

            // ===== SCROLLABLE CONTENT =====
            // CSS: .view { padding:18px; }
            ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                            text: "Good evening, Abdul Kareem"
                            font.family: "Poppins"
                            font.pixelSize: 21
                            font.weight: Font.DemiBold
                            color: "#12241b"
                        }
                        Text {
                            text: "Here is what is happening in your mahallu today."
                            font.family: "Poppins"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: "#4f6b5c"
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
                        columns: window.responsiveColumns
                        columnSpacing: 12
                        rowSpacing: 12

                        Repeater {
                            model: ListModel {
                                ListElement { label: "Add Family";       sub: "F-0013 next";        sc: "#059669"; icon: "plus" }
                                ListElement { label: "Add Member";       sub: "1,142 on record";    sc: "#0d9488"; icon: "user" }
                                ListElement { label: "Receive Payment";  sub: "RCP-2026-048";       sc: "#d97706"; icon: "dollar" }
                                ListElement { label: "Add Donation";     sub: "5 categories";       sc: "#db2777"; icon: "donations" }
                                ListElement { label: "Generate Report";  sub: "15 report types";    sc: "#7c3aed"; icon: "reports" }
                            }

                            delegate: Rectangle {
                                id: qaCard
                                Layout.fillWidth: true
                                Layout.minimumWidth: 180
                                implicitHeight: qaContent.implicitHeight + 24
                                radius: 10
                                color: "#ffffff"
                                border.width: 1
                                border.color: qaMA.containsMouse ? model.sc : "#d2e5d8"
                                z: qaMA.containsMouse ? 10 : 0
                                transform: Translate { y: qaMA.containsMouse ? -2 : 0; Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } } }
                                Behavior on border.color { ColorAnimation { duration: 160 } }



                                Row {
                                    id: qaContent
                                    x: 14; y: 12  // CSS: padding:12px 14px
                                    spacing: 12   // CSS: gap:12px

                                    // Icon container
                                    Rectangle {
                                        width: 42; height: 42; radius: 9
                                        color: model.sc
                                        scale: qaMA.containsMouse ? 1.02 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                                        Item {
                                            width: 20; height: 20
                                            anchors.centerIn: parent

                                            Image {
                                                id: qaIcon
                                                source: "qrc:/icons/svg/" + model.icon + ".svg"
                                                sourceSize: Qt.size(20, 20)
                                                anchors.fill: parent
                                                fillMode: Image.Pad
                                                visible: false
                                            }
                                            MultiEffect {
                                                anchors.fill: parent
                                                source: qaIcon
                                                colorizationColor: "#ffffff"
                                                colorization: 1.0
                                            }
                                        }
                                    }

                                    Column {
                                        spacing: 1
                                        y: (42 - height) / 2

                                        Text {
                                            text: model.label
                                            font.family: "Poppins"
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                            color: "#12241b"
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                            width: qaCard.width - 42 - 12 - 28
                                        }
                                        Text {
                                            text: model.sub
                                            font.family: "Poppins"
                                            font.pixelSize: 11
                                            font.weight: Font.Normal
                                            color: "#7e968a"
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
                        columns: window.responsiveColumns
                        columnSpacing: 12
                        rowSpacing: 12

                        Repeater {
                            model: ListModel {
                                ListElement { label: "FAMILIES";    value: "248";      delta: "▲ +6 this month";    sc: "#059669"; sb: "#d3f5e6"; st: "#04543c"; icon: "families"; up: 1 }
                                ListElement { label: "MEMBERS";     value: "1,142";    delta: "▲ +18 this month";   sc: "#0d9488"; sb: "#c8f6f1"; st: "#0f5e54"; icon: "members"; up: 1 }
                                ListElement { label: "ACTIVE";      value: "986";      delta: "▲ 86.3% active";     sc: "#0284c7"; sb: "#d7edfb"; st: "#0a5480"; icon: "user"; up: 1 }
                                ListElement { label: "COLLECTION";  value: "₹48,200";  delta: "▲ +9.1% vs June";    sc: "#d97706"; sb: "#fcebc8"; st: "#7c4403"; icon: "dollar"; up: 1 }
                                ListElement { label: "DUES";        value: "₹36,400";  delta: "▼ 7 families overdue"; sc: "#e11d48"; sb: "#fddfe5"; st: "#95102e"; icon: "alert"; up: 0 }
                                ListElement { label: "DONATIONS";   value: "₹92,750";  delta: "▲ +12.4% vs June";   sc: "#db2777"; sb: "#fadfeb"; st: "#93184f"; icon: "donations"; up: 1 }
                                ListElement { label: "WELFARE";     value: "₹1,45,000"; delta: "▲ 14 beneficiaries";  sc: "#7c3aed"; sb: "#e7defc"; st: "#5423b7"; icon: "welfare"; up: 1 }
                                ListElement { label: "MARRIAGES";   value: "17";       delta: "▲ 2 this quarter";    sc: "#ea580c"; sb: "#ffe4cf"; st: "#8f3708"; icon: "marriage"; up: 1 }
                                ListElement { label: "DEATHS";      value: "9";        delta: "▼ 1 this month";      sc: "#64748b"; sb: "#e6ebf2"; st: "#33415c"; icon: "death"; up: 0 }
                                ListElement { label: "BALANCE";     value: "₹4,56,320"; delta: "▲ across all funds";  sc: "#2563eb"; sb: "#dbe7fd"; st: "#1e3fae"; icon: "accounting"; up: 1 }
                            }

                            delegate: Rectangle {
                                id: statCard
                                Layout.fillWidth: true
                                Layout.minimumWidth: 180
                                implicitHeight: statContent.implicitHeight + 25
                                radius: 10
                                color: model.sb
                                border.width: 1
                                border.color: statHover.containsMouse ? model.sc : Qt.lighter(model.sc, 1.15)
                                z: statHover.hovered ? 10 : 0
                                transform: Translate { id: statLift; y: statHover.hovered ? -2 : 0; Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } } }
                                Behavior on border.color { ColorAnimation { duration: 160 } }

                                HoverHandler {
                                    id: statHover
                                    cursorShape: Qt.PointingHandCursor
                                }



                                // Decorative circle — fully INSIDE card, bottom-right corner
                                // Positioned with small margins so nothing extends past the card
                                Rectangle {
                                    id: decorCircle
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.rightMargin: 4
                                    anchors.bottomMargin: 4
                                    width: statHover.hovered ? 52 : 46
                                    height: width
                                    radius: width / 2
                                    color: model.sc
                                    opacity: 0.12
                                    Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                                    Behavior on opacity { NumberAnimation { duration: 160 } }
                                }

                                Column {
                                    id: statContent
                                    x: 14; y: 13  // CSS: padding:13px 14px
                                    width: parent.width - 28
                                    spacing: 0

                                    // Top row: icon + delta
                                    Item {
                                        width: parent.width
                                        height: 37

                                        // CSS: .stat .sic
                                        Rectangle {
                                            width: 37; height: 37; radius: 9
                                            color: model.sc
                                            scale: statHover.hovered ? 1.02 : 1.0
                                            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                                            Item {
                                                width: 18; height: 18
                                                anchors.centerIn: parent

                                                Image {
                                                    id: statIcon
                                                    source: "qrc:/icons/svg/" + model.icon + ".svg"
                                                    sourceSize: Qt.size(18, 18)
                                                    anchors.fill: parent
                                                    fillMode: Image.Pad
                                                    visible: false
                                                }
                                                MultiEffect {
                                                    anchors.fill: parent
                                                    source: statIcon
                                                    colorizationColor: "#ffffff"
                                                    colorization: 1.0
                                                }
                                            }
                                        }

                                        // CSS: .stat .delta
                                        Rectangle {
                                            x: parent.width - width
                                            y: (37 - height) / 2
                                            height: 18
                                            width: deltaText.implicitWidth + 16  // 3.5*2 padding + border
                                            radius: 99
                                            color: "#ffffff"
                                            border.width: 1
                                            border.color: model.sc

                                            Text {
                                                id: deltaText
                                                anchors.centerIn: parent
                                                text: model.delta
                                                font.family: "Poppins"
                                                font.pixelSize: 10
                                                font.weight: Font.Medium
                                                color: model.st
                                            }
                                        }
                                    }

                                    // CSS: .stat .val { font:700 24px/1 "Space Grotesk"; color:var(--st); }
                                    Text {
                                        text: model.value
                                        font.family: "Poppins"
                                        font.pixelSize: 24
                                        font.weight: Font.Bold
                                        color: model.st
                                        topPadding: 9
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                        width: parent.width  // CSS: margin-bottom:9px on .srow
                                    }

                                    // CSS: .stat .slab { font:800 10px Manrope; letter-spacing:.09em; text-transform:uppercase; color:var(--st); opacity:.75; margin-top:6px; }
                                    Text {
                                        text: model.label
                                        font.family: "Poppins"
                                        font.pixelSize: 10
                                        font.weight: Font.Medium
                                        color: model.st
                                        opacity: 0.75
                                        topPadding: 6
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                        width: parent.width
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
                                color: "#ffffff"
                                border.width: 1
                                border.color: evHover.containsMouse ? "#059669" : "#d2e5d8"
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
                                        color: "#db2777"

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
                                                colorizationColor: "#ffffff"
                                                colorization: 1.0
                                            }
                                        }
                                    }

                                    Column {
                                        spacing: 1
                                        y: (42 - height) / 2

                                        Text {
                                            text: model.title
                                            font.family: "Poppins"
                                            font.pixelSize: 14
                                            font.weight: Font.DemiBold
                                            color: "#12241b"
                                            elide: Text.ElideRight
                                            width: evCard.width - 42 - 13 - 32
                                        }
                                        Text {
                                            text: model.sub
                                            font.family: "Poppins"
                                            font.pixelSize: 12
                                            font.weight: Font.Normal
                                            color: "#4f6b5c"
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
    }
}
