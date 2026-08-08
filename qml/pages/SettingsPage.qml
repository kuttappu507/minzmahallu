import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"
import "../theme"

// Settings page — organization, UI preferences and backup configuration.
Item {
    id: page

    Rectangle {
        id: toast
        property bool visible_: false
        property string message: ""
        property color bgColor: Theme.primary
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: visible_ ? 18 : -60
        width: toastText.implicitWidth + 40
        height: 40
        radius: Theme.radiusXl
        color: bgColor
        z: 1000
        Behavior on anchors.topMargin { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeMd; font.weight: Theme.fontWeightSemiBold; color: Theme.textOnPrimary }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg, color) { message = msg; bgColor = color || Theme.primary; visible_ = true; toastTimer.restart() }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            // Never bind to the Flickable contentItem's parent width. That
            // creates a circular contentWidth dependency and can collapse the
            // page at certain window sizes/DPI factors.
            width: scrollView.width
            spacing: Theme.spaceLg

            Column {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.spaceXl
                Layout.rightMargin: Theme.spaceXl
                Layout.topMargin: Theme.spaceXl
                spacing: 2
                Text { text: "Settings"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize2xl - 3; font.weight: Theme.fontWeightSemiBold; color: Theme.textPrimary }
                Text { text: "Application configuration"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: Theme.spaceXl; Layout.rightMargin: Theme.spaceXl
                radius: Theme.radiusXl; color: Theme.surface; border.width: 1; border.color: Theme.border
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 14
                    Text { text: "Organization"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLg - 1; font.weight: Theme.fontWeightSemiBold; color: Theme.textPrimary }
                    AppTextField { id: mahalluNameField; Layout.fillWidth: true; label: "Mahallu Name"; onTextChanged: SettingsController.mahalluName = text }
                    RowLayout { Layout.fillWidth: true; spacing: Theme.spaceLg
                        AppTextField { id: phoneField; Layout.fillWidth: true; label: "Phone"; onTextChanged: SettingsController.phone = text }
                        AppTextField { id: emailField; Layout.fillWidth: true; label: "Email"; onTextChanged: SettingsController.email = text }
                    }
                    RowLayout { Layout.fillWidth: true; spacing: Theme.spaceLg
                        AppTextField { id: fysField; Layout.fillWidth: true; label: "Financial Year Start (MM-DD)"; placeholderText: "04-01"; onTextChanged: SettingsController.financialYearStart = text }
                        AppTextField { id: currencyField; Layout.fillWidth: true; label: "Currency Symbol"; onTextChanged: SettingsController.currencySymbol = text }
                        AppTextField { id: receiptPrefixField; Layout.fillWidth: true; label: "Receipt Prefix"; onTextChanged: SettingsController.receiptPrefix = text }
                    }
                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: "ADDRESS"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Theme.fontWeightMedium; color: Theme.textTertiary }
                        TextArea {
                            id: addressField; Layout.fillWidth: true; Layout.preferredHeight: 56
                            font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary
                            placeholderText: "Mahallu address..."; placeholderTextColor: Theme.textTertiary
                            selectByMouse: true; wrapMode: TextArea.Wrap; padding: 10
                            background: Rectangle { radius: Theme.radiusXl; color: Theme.surfaceSubtle; border.width: 1; border.color: parent.activeFocus ? Theme.borderFocused : parent.hovered ? Theme.borderHover : Theme.border; Behavior on border.color { ColorAnimation { duration: Theme.animFast } } }
                            onTextChanged: SettingsController.address = text
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: Theme.spaceXl; Layout.rightMargin: Theme.spaceXl
                radius: Theme.radiusXl; color: Theme.surface; border.width: 1; border.color: Theme.border
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 14
                    Text { text: "User Interface"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLg - 1; font.weight: Theme.fontWeightSemiBold; color: Theme.textPrimary }
                    RowLayout { Layout.fillWidth: true; spacing: Theme.spaceLg
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "Theme"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Theme.fontWeightMedium; color: Theme.textTertiary }
                            Rectangle {
                                Layout.fillWidth: true; height: 38; radius: Theme.radiusXl; color: Theme.surfaceSubtle; border.width: 1; border.color: themeMA.containsMouse ? Theme.borderHover : Theme.border
                                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                                MouseArea { id: themeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: themePopup.visible = !themePopup.visible }
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: SettingsController.theme; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary }
                                Popup {
                                    id: themePopup; y: parent.height + 4; width: parent.width; padding: 4
                                    background: Rectangle { color: Theme.surfaceRaised; border.width: 1; border.color: Theme.border; radius: Theme.radiusXl }
                                    ColumnLayout { anchors.fill: parent; spacing: 2
                                        Repeater { model: ["light", "dark"]
                                            delegate: ItemDelegate {
                                                width: parent.width; height: 34; padding: 0
                                                contentItem: Text { text: modelData; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                                background: Rectangle { color: highlighted ? Theme.primarySubtle : "transparent"; radius: Theme.radiusSm }
                                                onClicked: {
                                                    SettingsController.theme = modelData
                                                    SettingsController.save()
                                                    themePopup.visible = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "Language"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Theme.fontWeightMedium; color: Theme.textTertiary }
                            Rectangle {
                                Layout.fillWidth: true; height: 38; radius: Theme.radiusXl; color: Theme.surfaceSubtle; border.width: 1; border.color: langMA.containsMouse ? Theme.borderHover : Theme.border
                                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                                MouseArea { id: langMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: langPopup.visible = !langPopup.visible }
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: I18NController.isMalayalam ? "Malayalam" : "English"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary }
                                Popup {
                                    id: langPopup; y: parent.height + 4; width: parent.width; padding: 4
                                    background: Rectangle { color: Theme.surfaceRaised; border.width: 1; border.color: Theme.border; radius: Theme.radiusXl }
                                    ColumnLayout { anchors.fill: parent; spacing: 2
                                        Repeater { model: [{v: "en", l: "English"}, {v: "ml", l: "Malayalam"}]
                                            delegate: ItemDelegate {
                                                width: parent.width; height: 34; padding: 0
                                                contentItem: Text { text: modelData.l; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary; anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter }
                                                background: Rectangle { color: highlighted ? Theme.primarySubtle : "transparent"; radius: Theme.radiusSm }
                                                onClicked: {
                                                    I18NController.setLanguage(modelData.v)
                                                    SettingsController.language = modelData.v
                                                    SettingsController.save()
                                                    langPopup.visible = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: Theme.spaceXl; Layout.rightMargin: Theme.spaceXl
                radius: Theme.radiusXl; color: Theme.surface; border.width: 1; border.color: Theme.border
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 14
                    Text { text: "Backup"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLg - 1; font.weight: Theme.fontWeightSemiBold; color: Theme.textPrimary }
                    RowLayout { Layout.fillWidth: true; spacing: Theme.spaceLg
                        Text { text: "Auto Backup"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeMd - 1; color: Theme.textSecondary; Layout.alignment: Qt.AlignVCenter }
                        Switch { id: autoBackupSwitch; onCheckedChanged: if (SettingsController.autoBackup !== checked) SettingsController.autoBackup = checked }
                        AppTextField { id: intervalField; Layout.fillWidth: true; label: "Interval (hours)"; onTextChanged: { var v = parseInt(text); if (!isNaN(v) && v > 0) SettingsController.backupIntervalHours = v } }
                    }
                }
            }

            Row {
                Layout.fillWidth: true; Layout.leftMargin: Theme.spaceXl; Layout.rightMargin: Theme.spaceXl; Layout.bottomMargin: Theme.spaceXl; layoutDirection: Qt.RightToLeft
                AppButton { text: "Save Settings"; variant: "primary"; iconName: "check"; onClicked: { var ok = SettingsController.save(); toast.show(ok ? "Settings saved successfully" : "Save failed", ok ? Theme.primary : Theme.coral) } }
            }
        }
    }

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