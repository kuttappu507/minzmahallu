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

    // Public window-level metrics used by route components.
    readonly property int sidebarWidth: mainApp.sidebarWidth
    readonly property int contentWidth: width - sidebarWidth
    readonly property int responsiveColumns: {
        var cw = contentWidth
        if (cw >= 1200) return 5
        if (cw >= 950) return 4
        if (cw >= 700) return 3
        if (cw >= 500) return 2
        return 1
    }

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

        Behavior on sidebarWidth {
            NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                id: sidebar
                Layout.fillHeight: true
                Layout.preferredWidth: mainApp.sidebarWidth
                Layout.minimumWidth: mainApp.sidebarWidth
                color: Theme.sidebarMid
                clip: true

                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Theme.sidebarTop }
                    GradientStop { position: 0.45; color: Theme.sidebarMid }
                    GradientStop { position: 1.0; color: Theme.sidebarBot }
                }

                Column {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        width: parent.width
                        height: 72
                        Row {
                            x: 18; y: 17; spacing: 11
                            visible: !mainApp.sidebarCollapsed
                            Rectangle {
                                width: 38; height: 38; radius: 14
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
                                Text { text: "MMS"; font.family: Theme.fontFamily; font.pixelSize: 17; font.weight: Font.Bold; color: Theme.sidebarLogo }
                                Text { text: "Minz Mahallu"; font.family: Theme.fontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.sidebarSubTitle }
                            }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            visible: mainApp.sidebarCollapsed
                            width: 38; height: 38; radius: 14
                            color: Qt.rgba(255,255,255,0.14)
                            Text { anchors.centerIn: parent; text: "M"; font.family: Theme.fontFamily; font.pixelSize: 16; font.weight: Font.Bold; color: Theme.sidebarLogo }
                        }
                    }

                    Text {
                        width: parent.width
                        height: 28
                        text: "OVERVIEW"
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: Theme.sidebarTextMuted
                        leftPadding: 24
                        topPadding: 7
                        visible: !mainApp.sidebarCollapsed
                    }

                    ListView {
                        id: navList
                        width: parent.width
                        height: Math.max(80, parent.height - 72 - 28 - 68)
                        clip: true
                        spacing: 1
                        interactive: true
                        boundsBehavior: Flickable.StopAtBounds
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
                                anchors.fill: parent
                                radius: 7
                                color: ListView.isCurrentItem ? Qt.rgba(255,255,255,0.14) : (navMA.containsMouse ? Qt.rgba(255,255,255,0.06) : "transparent")
                                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                                Rectangle {
                                    x: -10
                                    y: 7
                                    width: 4; height: 20; radius: 4
                                    color: "#f2c14e"
                                    visible: ListView.isCurrentItem
                                }
                            }

                            Row {
                                x: 13; width: parent.width - 13; height: 34; spacing: 12
                                Item {
                                    width: 17; height: 17
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image { id: navIcon; source: "qrc:/icons/svg/" + model.icon + ".svg"; sourceSize: Qt.size(17,17); anchors.fill: parent; visible: false }
                                    MultiEffect {
                                        anchors.fill: parent
                                        source: navIcon
                                        colorizationColor: ListView.isCurrentItem ? "#ffffff" : (navMA.containsMouse ? "#e7fff5" : Theme.sidebarSubTitle)
                                        colorization: 1.0
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    width: parent.width - 29
                                    text: I18NController.tr(model.key)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    font.weight: ListView.isCurrentItem ? Font.DemiBold : Font.Medium
                                    color: ListView.isCurrentItem ? Theme.sidebarTextActive : (navMA.containsMouse ? "#e7fff5" : Theme.sidebarText)
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: navMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    mainApp.currentNavIndex = index
                                    navList.positionViewAtIndex(index, ListView.Contain)
                                }
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: 68
                        Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: Theme.sidebarBorder }
                        MouseArea { anchors.fill: parent; onClicked: AuthController.logout() }
                        Row {
                            x: 14; y: 13; spacing: 10
                            visible: !mainApp.sidebarCollapsed
                            Rectangle {
                                width: 36; height: 36; radius: 9
                                color: "#f2c14e"; border.width: 2; border.color: "#b98317"
                                Text { anchors.centerIn: parent; text: AuthController.initials; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#4a3606" }
                            }
                            Column {
                                spacing: 0
                                Text { text: AuthController.fullName; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#ffffff"; elide: Text.ElideRight; width: sidebar.width - 76 }
                                Text { text: AuthController.role; font.family: Theme.fontFamily; font.pixelSize: 11; color: Theme.sidebarSubTitle; elide: Text.ElideRight; width: sidebar.width - 76 }
                            }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            visible: mainApp.sidebarCollapsed
                            width: 36; height: 36; radius: 9
                            color: "#f2c14e"; border.width: 2; border.color: "#b98317"
                            Text { anchors.centerIn: parent; text: AuthController.initials; font.family: Theme.fontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#4a3606" }
                        }
                    }
                }

                // Fully inside the sidebar and vertically centered. The previous
                // version deliberately crossed the clipped edge and was cut off.
                Rectangle {
                    id: collapseButton
                    x: sidebar.width - width - 6
                    y: Math.round((sidebar.height - height) / 2)
                    width: 24; height: 48; radius: 8
                    z: 100
                    color: collapseMA.containsMouse ? "#f2c14e" : Theme.surfaceRaised
                    border.width: 1; border.color: Theme.border
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    Text {
                        anchors.centerIn: parent
                        text: mainApp.sidebarCollapsed ? "\u203A" : "\u2039"
                        font.family: Theme.fontFamily
                        font.pixelSize: 20
                        font.weight: Font.Medium
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
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    color: Theme.surface
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        Text { text: "MINZ MAHALLU /"; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text {
                            text: navList.model.get(navList.currentIndex) ? I18NController.tr(navList.model.get(navList.currentIndex).key) : I18NController.tr("nav_dashboard")
                            font.family: Theme.fontFamily; font.pixelSize: 16; font.weight: Font.DemiBold; color: Theme.textPrimary
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Rectangle {
                            width: 44; height: 38; radius: 9
                            color: langMA.containsMouse ? Theme.surfaceHover : Theme.surface
                            border.width: 1; border.color: langMA.containsMouse ? Theme.borderHover : Theme.border
                            Text { anchors.centerIn: parent; text: I18NController.isMalayalam ? "ML" : "EN"; font.family: Theme.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.primary }
                            MouseArea {
                                id: langMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    I18NController.toggleLanguage()
                                    SettingsController.language = I18NController.currentLanguage
                                    SettingsController.save()
                                }
                            }
                        }

                        Rectangle {
                            width: 38; height: 38; radius: 9
                            color: themeMA.containsMouse ? Theme.surfaceHover : Theme.surface
                            border.width: 1; border.color: themeMA.containsMouse ? Theme.borderHover : Theme.border
                            Text { anchors.centerIn: parent; text: SettingsController.theme === "dark" ? "☀" : "☾"; font.family: Theme.fontFamily; font.pixelSize: 17; color: Theme.textTertiary }
                            MouseArea {
                                id: themeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SettingsController.theme = SettingsController.theme === "light" ? "dark" : "light"
                                    SettingsController.save()
                                }
                            }
                        }

                        Rectangle {
                            width: 250; height: 38; radius: 9
                            color: Theme.surfaceSubtle
                            border.width: 1
                            border.color: searchInput.activeFocus ? Theme.borderFocused : (searchMA.containsMouse ? Theme.borderHover : Theme.border)
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 8
                                spacing: 7
                                Item {
                                    width: 16; height: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image { id: shellSearchIcon; source: "qrc:/icons/svg/search.svg"; sourceSize: Qt.size(16,16); anchors.fill: parent; visible: false }
                                    MultiEffect { anchors.fill: parent; source: shellSearchIcon; colorizationColor: searchInput.activeFocus ? Theme.primary : Theme.textTertiary; colorization: 1.0 }
                                }
                                TextField {
                                    id: searchInput
                                    Layout.fillWidth: true
                                    width: parent.width - 23
                                    anchors.verticalCenter: parent.verticalCenter
                                    placeholderText: I18NController.isMalayalam ? "തിരയുക..." : "Search records..."
                                    placeholderTextColor: Theme.textTertiary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    color: Theme.textPrimary
                                    leftPadding: 0
                                    rightPadding: 0
                                    background: Item {}
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            MouseArea { id: searchMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }
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

    Component.onCompleted: {
        // Theme.dark is derived directly from SettingsController.theme.
        // Do not call a mutable Theme setter here.
        I18NController.setLanguage(SettingsController.language)
    }
}
