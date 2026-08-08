import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
import "../pages"
import "../theme"

ApplicationWindow {
    id: window
    visible: true
    width: 1600
    height: 900
    minimumWidth: 1024
    minimumHeight: 640
    title: "Minz Mahallu Management System"
    color: Theme.canvas

    SplashScreen {
        id: splashScreen
        anchors.fill: parent
        z: 9999
        visible: true
    }

    LoginPage {
        id: loginPage
        anchors.fill: parent
        z: 9998
        visible: !splashScreen.visible && !AuthController.isLoggedIn
    }

    Item {
        id: mainApp
        anchors.fill: parent
        visible: !splashScreen.visible && AuthController.isLoggedIn

        property int currentNavIndex: 0
        property bool sidebarCollapsed: false
        property int sidebarWidth: sidebarCollapsed ? 64 : 260
        readonly property int contentWidth: width - sidebarWidth

        readonly property int responsiveColumns: {
            var cw = contentWidth
            if (cw >= 1000) return 5
            if (cw >= 800) return 4
            if (cw >= 600) return 3
            if (cw >= 400) return 2
            return 1
        }

        Behavior on sidebarWidth {
            NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                id: sidebar
                Layout.fillHeight: true
                Layout.fillWidth: false
                implicitWidth: mainApp.sidebarWidth
                clip: true

                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Theme.sidebarTop }
                    GradientStop { position: 0.42; color: Theme.sidebarMid }
                    GradientStop { position: 1.0; color: Theme.sidebarBot }
                }

                Canvas {
                    anchors.fill: parent
                    opacity: 0.04
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = "#ffffff"
                        ctx.lineWidth = 1
                        var tileSize = 40
                        for (var y = 0; y < height; y += tileSize) {
                            for (var x = 0; x < width; x += tileSize) {
                                var cx = x + tileSize / 2
                                var cy = y + tileSize / 2
                                var r = tileSize / 2 - 2
                                ctx.beginPath()
                                for (var i = 0; i < 8; i++) {
                                    var angle = (i * Math.PI) / 4
                                    var px = cx + r * Math.cos(angle)
                                    var py = cy + r * Math.sin(angle)
                                    if (i === 0) ctx.moveTo(px, py)
                                    else ctx.lineTo(px, py)
                                }
                                ctx.closePath()
                                ctx.stroke()
                                ctx.beginPath()
                                for (var j = 0; j < 8; j++) {
                                    var angle2 = (j * Math.PI) / 4 + Math.PI / 8
                                    var px2 = cx + (r * 0.5) * Math.cos(angle2)
                                    var py2 = cy + (r * 0.5) * Math.sin(angle2)
                                    if (j === 0) ctx.moveTo(px2, py2)
                                    else ctx.lineTo(px2, py2)
                                }
                                ctx.closePath()
                                ctx.stroke()
                            }
                        }
                    }
                }

                Column {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        width: parent.width
                        height: 72
                        Row {
                            x: 18
                            y: 18
                            spacing: 11
                            visible: !mainApp.sidebarCollapsed
                            Rectangle {
                                width: 38
                                height: 38
                                radius: 14
                                color: Qt.rgba(255,255,255,0.14)
                                Text {
                                    anchors.centerIn: parent
                                    text: "M"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                    color: Theme.sidebarLogo
                                }
                            }
                            Column {
                                spacing: 0
                                Text {
                                    text: "MMS"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 17
                                    font.weight: Font.Bold
                                    color: Theme.sidebarLogo
                                }
                                Text {
                                    text: "Minz Mahallu"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                    color: Theme.sidebarSubTitle
                                }
                            }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            visible: mainApp.sidebarCollapsed
                            width: 38
                            height: 38
                            radius: 14
                            color: Qt.rgba(255,255,255,0.14)
                            Text {
                                anchors.centerIn: parent
                                text: "M"
                                font.family: Theme.fontFamily
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: Theme.sidebarLogo
                            }
                        }
                    }

                    Rectangle {
                        width: 24
                        height: 48
                        radius: 8
                        color: collapseMA.containsMouse ? "#f2c14e" : Theme.surface
                        border.width: 1
                        border.color: Theme.border
                        x: parent.width - 12
                        y: parent.height / 2 - 24
                        z: 100
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Text {
                            anchors.centerIn: parent
                            text: mainApp.sidebarCollapsed ? "\u203A" : "\u2039"
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            color: collapseMA.containsMouse ? "#4a3606" : Theme.sidebarMid
                        }
                        MouseArea {
                            id: collapseMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mainApp.sidebarCollapsed = !mainApp.sidebarCollapsed
                        }
                    }

                    Text {
                        text: "OVERVIEW"
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: Theme.sidebarTextMuted
                        leftPadding: 24
                        topPadding: 15
                        bottomPadding: 5
                        visible: !mainApp.sidebarCollapsed
                    }

                    ListView {
                        id: navList
                        width: parent.width
                        height: parent.height - 72 - 36 - 80
                        clip: true
                        spacing: 1
                        interactive: false
                        currentIndex: mainApp.currentNavIndex
                        model: ListModel {
                            ListElement { key: "nav_dashboard"; label: "Dashboard"; icon: "dashboard" }
                            ListElement { key: "nav_families"; label: "Families"; icon: "families" }
                            ListElement { key: "nav_members"; label: "Members"; icon: "members" }
                            ListElement { key: "nav_subscriptions"; label: "Subscriptions"; icon: "subscriptions" }
                            ListElement { key: "nav_donations"; label: "Donations"; icon: "donations" }
                            ListElement { key: "nav_accounting"; label: "Accounting"; icon: "accounting" }
                            ListElement { key: "nav_marriage"; label: "Marriage"; icon: "marriage" }
                            ListElement { key: "nav_death"; label: "Death"; icon: "death" }
                            ListElement { key: "nav_welfare"; label: "Welfare"; icon: "welfare" }
                            ListElement { key: "nav_certificates"; label: "Certificates"; icon: "certificates" }
                            ListElement { key: "nav_tokens"; label: "Tokens"; icon: "token" }
                            ListElement { key: "nav_reports"; label: "Reports"; icon: "reports" }
                            ListElement { key: "nav_settings"; label: "Settings"; icon: "settings" }
                            ListElement { key: "nav_users"; label: "Users"; icon: "users" }
                            ListElement { key: "nav_audit"; label: "Audit Log"; icon: "audit" }
                            ListElement { key: "nav_backup"; label: "Backup"; icon: "backup" }
                        }

                        delegate: Item {
                            width: navList.width - 20
                            height: 34
                            x: 10
                            Rectangle {
                                id: navRect
                                anchors.fill: parent
                                radius: 7
                                color: ListView.isCurrentItem ? Qt.rgba(255,255,255,0.14) : (navMA.containsMouse ? Qt.rgba(255,255,255,0.06) : "transparent")
                                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                                Rectangle {
                                    x: -10
                                    y: (34 - 20) / 2
                                    width: 4
                                    height: 20
                                    radius: 4
                                    color: "#f2c14e"
                                    visible: ListView.isCurrentItem
                                }
                            }
                            Row {
                                x: 13
                                y: 0
                                height: 34
                                spacing: 12
                                Item {
                                    width: 17
                                    height: 17
                                    y: (34 - 17) / 2
                                    Image {
                                        id: navIcon
                                        source: "qrc:/icons/svg/" + model.icon + ".svg"
                                        sourceSize: Qt.size(17, 17)
                                        anchors.fill: parent
                                        fillMode: Image.Pad
                                        visible: false
                                    }
                                    MultiEffect {
                                        anchors.fill: parent
                                        source: navIcon
                                        colorizationColor: ListView.isCurrentItem ? "#ffffff" : (navMA.containsMouse ? "#d6f5e7" : Theme.sidebarSubTitle)
                                        colorization: 1.0
                                        Behavior on colorizationColor { ColorAnimation { duration: Theme.animNormal } }
                                    }
                                }
                                Text {
                                    text: I18NController.tr(model.key)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    font.weight: ListView.isCurrentItem ? Font.DemiBold : Font.Medium
                                    color: ListView.isCurrentItem ? "#ffffff" : (navMA.containsMouse ? "#d6f5e7" : Theme.sidebarText)
                                    y: (34 - height) / 2
                                    visible: !mainApp.sidebarCollapsed
                                    Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                                }
                            }
                            MouseArea {
                                id: navMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    navList.currentIndex = index
                                    mainApp.currentNavIndex = index
                                }
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: 80
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: Qt.rgba(255,255,255,0.14)
                        }
                        Rectangle {
                            x: 10
                            y: 9
                            width: profileRow.width + 8
                            height: profileRow.height + 8
                            radius: 9
                            color: Qt.rgba(255,255,255, profileHover.containsMouse ? 0.06 : 0)
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            z: -1
                            visible: !mainApp.sidebarCollapsed
                        }
                        HoverHandler { id: profileHover; cursorShape: Qt.PointingHandCursor }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: AuthController.logout()
                        }
                        Row {
                            id: profileRow
                            x: 14
                            y: 13
                            spacing: 10
                            visible: !mainApp.sidebarCollapsed
                            Rectangle {
                                width: 36
                                height: 36
                                radius: 9
                                color: "#f2c14e"
                                border.width: 2
                                border.color: "#b98317"
                                Text {
                                    anchors.centerIn: parent
                                    text: AuthController.initials
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: "#4a3606"
                                }
                            }
                            Column {
                                spacing: 0
                                Text {
                                    text: AuthController.fullName
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: "#ffffff"
                                }
                                Text {
                                    text: AuthController.role
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: Theme.sidebarSubTitle
                                }
                            }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            visible: mainApp.sidebarCollapsed
                            width: 36
                            height: 36
                            radius: 9
                            color: "#f2c14e"
                            border.width: 2
                            border.color: "#b98317"
                            Text {
                                anchors.centerIn: parent
                                text: AuthController.initials
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: "#4a3606"
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    color: Theme.surface
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: Theme.border
                    }
                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        Text {
                            text: "MINZ MAHALLU /"
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Theme.textTertiary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: navList.model.get(navList.currentIndex) ? I18NController.tr(navList.model.get(navList.currentIndex).key) : I18NController.tr("nav_dashboard")
                            font.family: Theme.fontFamily
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: Theme.textPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        Rectangle {
                            width: 44
                            height: 38
                            radius: 9
                            color: langToggleMA.containsMouse ? Theme.surfaceHover : Theme.surface
                            border.width: 1
                            border.color: langToggleMA.containsMouse ? Theme.borderHover : Theme.border
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            HoverHandler { id: langToggleMA; cursorShape: Qt.PointingHandCursor }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    I18NController.toggleLanguage()
                                    SettingsController.language = I18NController.currentLanguage
                                    SettingsController.save()
                                }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: I18NController.isMalayalam ? "ML" : "EN"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: Theme.primary
                            }
                        }
                        Rectangle {
                            width: 38
                            height: 38
                            radius: 9
                            color: themeToggleMA.containsMouse ? Theme.surfaceHover : Theme.surface
                            border.width: 1
                            border.color: themeToggleMA.containsMouse ? Theme.borderHover : Theme.border
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            HoverHandler { id: themeToggleMA; cursorShape: Qt.PointingHandCursor }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SettingsController.theme = SettingsController.theme === "light" ? "dark" : "light"
                                    SettingsController.save()
                                }
                            }
                            Item {
                                width: 16
                                height: 16
                                anchors.centerIn: parent
                                Image {
                                    id: themeIcon
                                    source: "qrc:/icons/svg/" + (SettingsController.theme === "dark" ? "sun" : "moon") + ".svg"
                                    sourceSize: Qt.size(16, 16)
                                    anchors.fill: parent
                                    fillMode: Image.Pad
                                    visible: false
                                }
                                MultiEffect {
                                    anchors.fill: parent
                                    source: themeIcon
                                    colorizationColor: Theme.textTertiary
                                    colorization: 1.0
                                }
                            }
                        }
                        Rectangle {
                            width: 250
                            height: 38
                            radius: 9
                            color: Theme.surfaceSubtle
                            border.width: 1
                            border.color: searchInput.activeFocus ? Theme.borderFocused : (searchHover.containsMouse ? Theme.borderHover : Theme.border)
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                            HoverHandler { id: searchHover; cursorShape: Qt.IBeamCursor }
                            Item {
                                width: 16
                                height: 16
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                Image {
                                    id: shellSearchIcon
                                    source: "qrc:/icons/svg/search.svg"
                                    sourceSize: Qt.size(16,16)
                                    anchors.fill: parent
                                    visible: false
                                }
                                MultiEffect {
                                    anchors.fill: parent
                                    source: shellSearchIcon
                                    colorizationColor: searchInput.activeFocus ? Theme.primary : Theme.textTertiary
                                    colorization: 1.0
                                }
                            }
                            TextField {
                                id: searchInput
                                anchors.left: parent.left
                                anchors.leftMargin: 32
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                placeholderText: "Search records..."
                                placeholderTextColor: Theme.textTertiary
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                color: Theme.textPrimary
                                background: Item {}
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                StackLayout {
                    id: pageStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: mainApp.currentNavIndex
                    Loader { source: "qrc:/qml/design/DashboardPage.qml" }
                    FamiliesPage {}
                    MembersPage {}
                    SubscriptionsPage {}
                    DonationsPage {}
                    AccountingPage {}
                    MarriagePage {}
                    DeathPage {}
                    WelfarePage {}
                    CertificatesPage {}
                    TokensPage {}
                    ReportsPage {}
                    SettingsPage {}
                    UsersPage {}
                    AuditLogPage {}
                    BackupPage {}
                }
            }
        }
    }

    Connections {
        target: SettingsController
        function onThemeChanged() {
            Theme.setDark(SettingsController.theme === "dark")
        }
        function onLanguageChanged() {
            I18NController.setLanguage(SettingsController.language)
        }
    }

    Component.onCompleted: {
        Theme.setDark(SettingsController.theme === "dark")
        I18NController.setLanguage(SettingsController.language)
    }
}
