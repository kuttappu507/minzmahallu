// =============================================================================
// main.qml — Root application window with sidebar + topbar + content stack
// =============================================================================
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Theme

ApplicationWindow {
    id: win
    visible: true
    width: 1366
    height: 768
    minimumWidth: 1200
    minimumHeight: 700
    color: Theme.bg
    title: "Minz Mahallu Management"

    // ---- State ----
    property bool sidebarCollapsed: false
    property string currentView: "dash"
    property string currentUser: "Administrator"
    property string currentRole: "Administrator"

    // ---- Behavior: animated sidebar width ----
    Behavior on sidebarCollapsed { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

    // ---- Splash overlay ----
    Rectangle {
        id: splash
        anchors.fill: parent
        z: 100
        color: "#065f46"
        visible: true
        opacity: 1

        // Islamic star pattern
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = "rgba(255,255,255,0.05)"
                ctx.lineWidth = 1.5
                var s = 64
                for (var y = 0; y < height; y += s) {
                    for (var x = 0; x < width; x += s) {
                        drawStar(ctx, x, y, s)
                    }
                }
            }
            function drawStar(ctx, ox, oy, sz) {
                var cx = ox + sz/2, cy = oy + sz/2
                ctx.beginPath()
                var pts = [
                    [cx, cy-sz*0.375], [cx+sz*0.078, cy-sz*0.11], [cx+sz*0.344, cy-sz*0.11],
                    [cx+sz*0.125, cy+sz*0.047], [cx+sz*0.203, cy+sz*0.328],
                    [cx, cy+sz*0.156], [cx-sz*0.203, cy+sz*0.328],
                    [cx-sz*0.125, cy+sz*0.047], [cx-sz*0.344, cy-sz*0.11], [cx-sz*0.078, cy-sz*0.11]
                ]
                pts.forEach(function(p, i) {
                    if (i === 0) ctx.moveTo(p[0], p[1])
                    else ctx.lineTo(p[0], p[1])
                })
                ctx.closePath()
                ctx.stroke()
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 26
            Image {
                source: "qrc:/icons/mms_white.png"
                width: 92; height: 92
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
            }
            Text {
                text: "Minz Mahallu Management"
                font.family: Theme.fontDisplay
                font.pixelSize: 26
                font.weight: Font.Bold
                color: "#ffffff"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Mosque Community Administration"
                font.family: Theme.fontPrimary
                font.pixelSize: 14
                color: "#c9ecd9"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            // Progress bar
            Rectangle {
                width: 280; height: 10
                radius: 5
                color: "#04463a"
                border.width: 2; border.color: "#0a7f5d"
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    width: parent.width * 0.65; height: parent.height
                    radius: 5
                    color: "#f2c14e"
                    Behavior on width { NumberAnimation { duration: 1200; easing.type: Easing.OutCubic } }
                }
            }
            Text {
                text: "Loading…"
                font.family: Theme.fontPrimary
                font.pixelSize: 12
                color: "#d7f2e4"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // Gold bottom stripe
        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right
            anchors.bottom: parent.bottom; height: 10
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#f2c14e" }
                GradientStop { position: 0.3; color: "#065f46" }
                GradientStop { position: 0.6; color: "#ffffff" }
                GradientStop { position: 0.65; color: "#065f46" }
                GradientStop { position: 1.0; color: "#f2c14e" }
            }
        }

        // Fade out after 2.5s
        Timer {
            interval: 2500; running: true; repeat: false
            onTriggered: {
                splash.opacity = 0
                fadeOut.target = splash
                fadeOut.running = true
            }
        }
        NumberAnimation { id: fadeOut; property: "opacity"; to: 0; duration: 500; onStopped: splash.visible = false }
    }

    // ---- Main app layout ----
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ===== SIDEBAR =====
        Rectangle {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: sidebarCollapsed ? 80 : 260
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
            clip: true

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#0a7f5d" }
                GradientStop { position: 0.42; color: "#065f46" }
                GradientStop { position: 1.0; color: "#044633" }
            }

            // Islamic star pattern overlay
            Canvas {
                anchors.fill: parent
                opacity: 0.9
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = "rgba(255,255,255,0.05)"
                    ctx.lineWidth = 1.5
                    var s = 64
                    for (var y = 0; y < height; y += s) {
                        for (var x = 0; x < width; x += s) {
                            var cx = x + s/2, cy = y + s/2
                            ctx.beginPath()
                            var pts = [
                                [cx, cy-s*0.375], [cx+s*0.078, cy-s*0.11], [cx+s*0.344, cy-s*0.11],
                                [cx+s*0.125, cy+s*0.047], [cx+s*0.203, cy+s*0.328],
                                [cx, cy+s*0.156], [cx-s*0.203, cy+s*0.328],
                                [cx-s*0.125, cy+s*0.047], [cx-s*0.344, cy-s*0.11], [cx-s*0.078, cy-s*0.11]
                            ]
                            pts.forEach(function(p, i) {
                                if (i === 0) ctx.moveTo(p[0], p[1])
                                else ctx.lineTo(p[0], p[1])
                            })
                            ctx.closePath()
                            ctx.stroke()
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Logo (centered, no text)
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    Image {
                        source: "qrc:/icons/mms_white.png"
                        width: 48; height: 48
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                    }
                }

                // Nav list
                ListView {
                    id: navList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: navModel
                    delegate: navDelegate
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                }

                // User card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: "transparent"
                    border.color: "rgba(255,255,255,0.14)"
                    border.width: 1
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "rgba(255,255,255,0.14)" }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        // Avatar (gold gradient)
                        Rectangle {
                            width: 36; height: 36
                            radius: 9
                            color: "#f2c14e"
                            border.width: 2; border.color: "#b98317"
                            Text {
                                anchors.centerIn: parent
                                text: Theme.initials(currentUser)
                                font.family: Theme.fontDisplay
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: "#4a3606"
                            }
                        }

                        ColumnLayout {
                            spacing: 1
                            visible: !sidebarCollapsed
                            Text {
                                text: currentUser
                                font.family: Theme.fontPrimary
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                            Text {
                                text: currentRole
                                font.family: Theme.fontPrimary
                                font.pixelSize: 10
                                color: "#9fd8c3"
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // Flap button (collapse/expand)
            Rectangle {
                id: flap
                width: 26; height: 62
                radius: 9
                anchors.right: parent.right
                anchors.rightMargin: -13
                anchors.verticalCenter: parent.verticalCenter
                color: flapMouseArea.containsMouse ? "#0aa06f" : "#047857"
                border.width: 1; border.color: "#0a7f5d"
                z: 50

                Text {
                    anchors.centerIn: parent
                    text: sidebarCollapsed ? "▶" : "◀"
                    color: "#ffffff"
                    font.pixelSize: 14
                    rotation: sidebarCollapsed ? 180 : 0
                    Behavior on rotation { NumberAnimation { duration: 280 } }
                }

                MouseArea {
                    id: flapMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sidebarCollapsed = !sidebarCollapsed
                }
            }
        }

        // ===== MAIN COLUMN =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ---- Top bar ----
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 58
                color: Theme.panel
                border.color: Theme.border
                border.width: 0
                Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1.5; color: Theme.border }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18; anchors.rightMargin: 18
                    spacing: 13

                    // Breadcrumb
                    Text {
                        text: "Minz Mahallu /"
                        font.family: Theme.fontPrimary
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Theme.faint
                    }
                    Text {
                        text: navModel.get(navList.currentIndex).title
                        font.family: Theme.fontDisplay
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: Theme.text
                    }

                    // Search
                    Rectangle {
                        Layout.preferredWidth: 250
                        Layout.preferredHeight: 38
                        radius: 9
                        color: Theme.panel2
                        border.width: 1.5; border.color: searchInput.activeFocus ? Theme.em : Theme.border
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text { text: "🔍"; color: Theme.faint }
                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: "Search records…"
                                color: Theme.text
                                font.family: Theme.fontPrimary
                                font.pixelSize: 13
                                background: Item {}
                                selectByMouse: true
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Session chip
                    Rectangle {
                        width: 80; height: 32
                        radius: 99
                        color: Theme.panel2
                        border.width: 1.5; border.color: Theme.border
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 7
                            Rectangle { width: 7; height: 7; radius: 4; color: Theme.em }
                            Text {
                                text: "30:00"
                                font.family: Theme.fontDisplay
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: Theme.muted
                            }
                        }
                    }

                    // Language toggle
                    Rectangle {
                        width: 70; height: 32
                        radius: 8
                        color: Theme.panel2
                        border.width: 1.5; border.color: Theme.border
                        RowLayout {
                            anchors.centerIn: parent
                            Text { text: "EN"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.muted }
                            Text { text: "│"; color: Theme.border2 }
                            Text { text: "മല"; font.family: Theme.fontMalayalam; font.pixelSize: 11; color: Theme.faint }
                        }
                    }

                    // Backup button
                    Rectangle {
                        width: 38; height: 32
                        radius: 8
                        color: backupMouse.containsMouse ? Theme.emBg : "transparent"
                        border.width: 0
                        Text { anchors.centerIn: parent; text: "💾"; font.pixelSize: 16; opacity: 0.7 }
                        MouseArea { id: backupMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                    }

                    // Avatar button
                    Rectangle {
                        width: 80; height: 36
                        radius: 9
                        color: Theme.panel2
                        border.width: 1.5; border.color: Theme.border
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 8
                            Rectangle {
                                width: 28; height: 28; radius: 7
                                color: "#f2c14e"
                                Text {
                                    anchors.centerIn: parent
                                    text: Theme.initials(currentUser)
                                    font.family: Theme.fontDisplay
                                    font.pixelSize: 11; font.weight: Font.Bold
                                    color: "#4a3606"
                                }
                            }
                            Text {
                                text: currentUser
                                font.family: Theme.fontPrimary
                                font.pixelSize: 12; font.weight: Font.Bold
                                color: Theme.text
                            }
                        }
                    }
                }
            }

            // ---- Content area ----
            StackLayout {
                id: contentStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: navList.currentIndex

                // Load views — for now, placeholder rectangles
                // These will be replaced with actual QML view files
                Repeater {
                    model: navModel
                    delegate: Rectangle {
                        color: Theme.bg
                        Text {
                            anchors.centerIn: parent
                            text: model.title + " view"
                            font.pixelSize: 24
                            color: Theme.faint
                        }
                    }
                }
            }

            // ---- Status bar ----
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                color: Theme.panel2
                Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1.5; color: Theme.border }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14; anchors.rightMargin: 14
                    RowLayout {
                        spacing: 7
                        Rectangle { width: 7; height: 7; radius: 4; color: Theme.em }
                        Text { text: "Ready"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.muted }
                    }
                    Item { Layout.fillWidth: true }
                    Text { text: "v1.0.0"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.faint }
                }
            }
        }
    }

    // ---- Navigation model ----
    ListModel {
        id: navModel
        ListElement { title: "Dashboard"; icon: "dash"; navId: "dash"; section: "Overview" }
        ListElement { title: "Families"; icon: "home"; navId: "families"; section: "Management" }
        ListElement { title: "Members"; icon: "user"; navId: "members"; section: "" }
        ListElement { title: "Subscriptions"; icon: "receipt"; navId: "subs"; section: "" }
        ListElement { title: "Donations"; icon: "gift"; navId: "dons"; section: "" }
        ListElement { title: "Accounting"; icon: "calc"; navId: "acct"; section: "Finance" }
        ListElement { title: "Marriage"; icon: "gem"; navId: "marriage"; section: "Registers" }
        ListElement { title: "Death"; icon: "flower"; navId: "death"; section: "" }
        ListElement { title: "Welfare"; icon: "pulse"; navId: "welfare"; section: "" }
        ListElement { title: "Certificates"; icon: "award"; navId: "certs"; section: "" }
        ListElement { title: "Tokens"; icon: "ticket"; navId: "tokens"; section: "" }
        ListElement { title: "Reports"; icon: "chart"; navId: "reports"; section: "System" }
        ListElement { title: "Settings"; icon: "sliders"; navId: "settings"; section: "" }
        ListElement { title: "Users"; icon: "users"; navId: "users"; section: "" }
        ListElement { title: "Audit Log"; icon: "file"; navId: "audit"; section: "" }
        ListElement { title: "Backup"; icon: "db"; navId: "backup"; section: "" }
    }

    // ---- Nav delegate ----
    Component {
        id: navDelegate
        Item {
            width: navList.width
            height: model.section ? 60 : 44

            // Section header
            Text {
                visible: model.section !== ""
                text: model.section
                font.family: Theme.fontPrimary
                font.pixelSize: 9
                font.weight: Font.Black
                color: "rgba(214,240,228,0.42)"
                letterSpacing: 2
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.topMargin: 15
            }

            // Nav item
            Rectangle {
                visible: model.section === ""
                anchors.fill: parent
                anchors.margins: 2
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                radius: 9
                color: navItemMouse.containsMouse ? "rgba(255,255,255,0.09)" :
                       (navList.currentIndex === index ? "rgba(255,255,255,0.14)" : "transparent")
                Behavior on color { ColorAnimation { duration: 140 } }

                // Gold indicator bar for active item
                Rectangle {
                    visible: navList.currentIndex === index
                    width: 4; height: 22
                    radius: 2
                    color: "#f2c14e"
                    anchors.left: parent.left
                    anchors.leftMargin: -10
                    anchors.verticalCenter: parent.verticalCenter
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 13
                    anchors.rightMargin: 13
                    spacing: 12

                    Text {
                        text: {
                            var icons = {"dash":"▦","home":"⌂","user":"☺","receipt":"☰","gift":"🎁",
                                         "calc":"≡","gem":"◆","flower":"✿","pulse":"♥","award":"★",
                                         "ticket":"🎫","chart":"📊","sliders":"⚙","users":"👥",
                                         "file":"📄","db":"💾"}
                            return icons[model.icon] || "●"
                        }
                        font.pixelSize: 18
                        color: navList.currentIndex === index ? "#ffd76a" : "#c4e7d7"
                    }

                    Text {
                        text: model.title
                        font.family: Theme.fontPrimary
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: navList.currentIndex === index ? "#ffffff" : "#c4e7d7"
                        visible: !sidebarCollapsed
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: navItemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: navList.currentIndex = index
                }
            }
        }
    }
}
