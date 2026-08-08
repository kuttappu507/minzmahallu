import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// SettingsPage — Organization info, logo/seal, theme, backup config
// Uses Component.onCompleted to avoid binding loops (text:onTextChanged creates
// a loop — load once, then only write back on user edit).
// ============================================================================

Item {
    id: page

    Rectangle {
        id: toast
        property bool visible_: false
        property string message: ""
        property color bgColor: "#059669"
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: visible_ ? 18 : -60
        width: toastText.implicitWidth + 40; height: 40; radius: 9
        color: bgColor; z: 1000
        Behavior on anchors.topMargin { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: Theme.activeFontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: Theme.surface }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg, color) { message = msg; bgColor = color || "#059669"; visible_ = true; toastTimer.restart() }
    }

    ScrollView {
        anchors.fill: parent; clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: parent.width; spacing: 16

            // Header
            Column { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.topMargin: 24; spacing: 2
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("set_title") } font.family: Theme.activeFontFamily; font.pixelSize: 21; font.weight: Font.DemiBold; color: Theme.textPrimary }
                Text { text: "Application configuration"; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary } }

            // Organization info
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
                ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 14

                    Text { text: "Organization"; font.family: Theme.activeFontFamily; font.pixelSize: 14; font.weight: Font.DemiBold; color: Theme.textPrimary }

                    AppTextField { id: mahalluNameField; Layout.fillWidth: true; label: "Mahallu Name"; onTextChanged: SettingsController.mahalluName = text }
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        AppTextField { id: phoneField; Layout.fillWidth: true; label: "Phone"; onTextChanged: SettingsController.phone = text }
                        AppTextField { id: emailField; Layout.fillWidth: true; label: "Email"; onTextChanged: SettingsController.email = text } }
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        AppTextField { id: fysField; Layout.fillWidth: true; label: "Financial Year Start (MM-DD)"; placeholderText: "04-01"; onTextChanged: SettingsController.financialYearStart = text }
                        AppTextField { id: currencyField; Layout.fillWidth: true; label: "Currency Symbol"; onTextChanged: SettingsController.currencySymbol = text }
                        AppTextField { id: receiptPrefixField; Layout.fillWidth: true; label: "Receipt Prefix"; onTextChanged: SettingsController.receiptPrefix = text } }

                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: "ADDRESS"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                        TextArea { id: addressField; Layout.fillWidth: true; Layout.preferredHeight: 56; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary; placeholderText: "Mahallu address..."; placeholderTextColor: "#7e968a"; selectByMouse: true; wrapMode: TextArea.Wrap
                            background: Rectangle { radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                            padding: 10; onTextChanged: SettingsController.address = text } }
                }
            }

            // User Interface
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
                ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 14
                    Text { text: "User Interface"; font.family: Theme.activeFontFamily; font.pixelSize: 14; font.weight: Font.DemiBold; color: Theme.textPrimary }
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "Theme"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: themeMA.containsMouse ? "#b2cfbd" : "#d2e5d8"
                                Behavior on border.color { ColorAnimation { duration: 120 } }
                                MouseArea { id: themeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: themePopup.visible = !themePopup.visible }
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: SettingsController.theme; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary }
                                Popup { id: themePopup; y: parent.height + 4; width: parent.width; padding: 4; background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                    ColumnLayout { anchors.fill: parent; spacing: 2
                                        Repeater { model: ["light", "dark"]
                                            delegate: ItemDelegate { width: parent.width; height: 34; padding: 0
                                                contentItem: Text { text: modelData; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                                background: Rectangle { color: highlighted ? "#ecfdf5" : "transparent"; radius: 4 }
                                                onClicked: { SettingsController.theme = modelData; themePopup.visible = false } } } } } } }
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "Language"; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                            Rectangle { Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1; border.color: langMA.containsMouse ? "#b2cfbd" : "#d2e5d8"
                                Behavior on border.color { ColorAnimation { duration: 120 } }
                                MouseArea { id: langMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: langPopup.visible = !langPopup.visible }
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: SettingsController.language === "ml" ? "Malayalam" : "English"; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary }
                                Popup { id: langPopup; y: parent.height + 4; width: parent.width; padding: 4; background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                    ColumnLayout { anchors.fill: parent; spacing: 2
                                        Repeater { model: [{v: "en", l: "English"}, {v: "ml", l: "Malayalam"}]
                                            delegate: ItemDelegate { width: parent.width; height: 34; padding: 0
                                                contentItem: Text { text: modelData.l; font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                                background: Rectangle { color: highlighted ? "#ecfdf5" : "transparent"; radius: 4 }
                                                onClicked: { SettingsController.language = modelData.v; langPopup.visible = false } } } } } } }
                    }
                }
            }

            // Backup config
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
                ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 14
                    Text { text: "Backup"; font.family: Theme.activeFontFamily; font.pixelSize: 14; font.weight: Font.DemiBold; color: Theme.textPrimary }
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        Text { text: "Auto Backup"; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary; Layout.alignment: Qt.AlignVCenter }
                        Switch { id: autoBackupSwitch; onCheckedChanged: SettingsController.autoBackup = checked }
                        AppTextField { id: intervalField; Layout.fillWidth: true; label: "Interval (hours)"; onTextChanged: { var v = parseInt(text); if (!isNaN(v) && v > 0) SettingsController.backupIntervalHours = v } } }
                }
            }

            // Save button
            Row { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.bottomMargin: 24; layoutDirection: Qt.RightToLeft
                AppButton { text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_save") } variant: "primary"; iconName: "check"; onClicked: {
                    var ok = SettingsController.save()
                    toast.show(ok ? "Settings saved successfully" : "Save failed", ok ? "#059669" : "#e11d48")
                } }
            }
        }
    }

    // Load settings ONCE on completed — avoids binding loops
    Component.onCompleted: {
        mahalluNameField.text = SettingsController.mahalluName
        phoneField.text = SettingsController.phone
        emailField.text = SettingsController.email
        fysField.text = SettingsController.financialYearStart
        currencyField.text = SettingsController.currencySymbol
        receiptPrefixField.text = SettingsController.receiptPrefix
        addressField.text = SettingsController.address
        intervalField.text = SettingsController.backupIntervalHours.toString()
        autoBackupSwitch.checked = SettingsController.autoBackup
    }
}
