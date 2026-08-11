import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// SettingsPage — Organization info, appearance, backup config
// Properly sectioned layout with labeled fields. All strings i18n'd.
// ============================================================================

Item {
    id: page

    // ===== Toast notification =====
    Rectangle {
        id: toast
        property bool visible_: false
        visible: visible_
        property string message: ""
        property color bgColor: Theme.primary
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: visible_ ? 18 : -60
        width: toastText.implicitWidth + 40; height: 40; radius: 9
        color: bgColor; z: 1000
        Behavior on anchors.topMargin { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; font.weight: Font.DemiBold; color: Theme.surface }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg, color) { message = msg; bgColor = color || Theme.primary; visible_ = true; toastTimer.restart() }
    }

    // ===== Main scrollable content =====
    ScrollView {
        anchors.fill: parent; clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: Math.min(parent.width, 820); anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            // ===== Page header =====
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 28
                spacing: 4
                Text {
                    text: { var _l = I18NController.currentLanguage; return I18NController.tr("set_title") }
                    font.family: Theme.activeFontFamily
                    font.pixelSize: Theme.fontSize2xl
                    font.weight: Font.DemiBold
                    color: Theme.textPrimary
                }
                Text {
                    text: { var _l = I18NController.currentLanguage; return I18NController.tr("set_subtitle") }
                    font.family: Theme.activeFontFamily
                    font.pixelSize: Theme.fontSizeSm
                    color: Theme.textSecondary
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }

            // ===== SECTION 1: Organization =====
            SectionCard {
                Layout.fillWidth: true
                title: I18NController.tr("set_org_section")
                icon: "families"

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    AppTextField {
                        id: mahalluNameField
                        Layout.fillWidth: true
                        label: I18NController.tr("set_mahallu_name")
                        placeholderText: I18NController.tr("set_mahallu_name")
                        onTextChanged: SettingsController.mahalluName = text
                    }

                    RowLayout {
                        Layout.fillWidth: true; spacing: 12
                        AppTextField {
                            id: phoneField
                            Layout.fillWidth: true
                            label: I18NController.tr("set_phone")
                            placeholderText: "+91 9847123456"
                            onTextChanged: SettingsController.phone = text
                        }
                        AppTextField {
                            id: emailField
                            Layout.fillWidth: true
                            label: I18NController.tr("set_email")
                            placeholderText: "info@mahallu.org"
                            onTextChanged: SettingsController.email = text
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 4
                        Text {
                            text: I18NController.tr("family_address")
                            font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXs; font.weight: Font.Medium; color: Theme.textTertiary
                        }
                        TextArea {
                            id: addressField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary
                            selectByMouse: true; wrapMode: TextArea.Wrap
                            placeholderText: I18NController.tr("set_address_placeholder")
                            placeholderTextColor: Theme.textTertiary
                            background: Rectangle {
                                radius: 9; color: Theme.surfaceHover; border.width: 1
                                border.color: addressField.activeFocus ? Theme.primary : (addressField.hovered ? Theme.borderHover : Theme.border)
                                Behavior on border.color { ColorAnimation { duration: 120 } }
                            }
                            padding: 10
                            onTextChanged: SettingsController.address = text
                        }
                    }
                }
            }

            // ===== SECTION 2: Financial =====
            SectionCard {
                Layout.fillWidth: true
                title: I18NController.tr("set_financial_section")
                icon: "accounting"

                RowLayout {
                    Layout.fillWidth: true; spacing: 12
                    AppTextField {
                        id: fysField
                        Layout.fillWidth: true
                        label: I18NController.tr("set_financial_year_start")
                        placeholderText: "04-01"
                        onTextChanged: SettingsController.financialYearStart = text
                    }
                    AppTextField {
                        id: currencyField
                        Layout.fillWidth: true
                        label: I18NController.tr("set_currency_symbol")
                        placeholderText: "\u20B9"
                        onTextChanged: SettingsController.currencySymbol = text
                    }
                    AppTextField {
                        id: receiptPrefixField
                        Layout.fillWidth: true
                        label: I18NController.tr("set_receipt_prefix")
                        placeholderText: "RCP"
                        onTextChanged: SettingsController.receiptPrefix = text
                    }
                }
            }

            // ===== SECTION 3: Appearance =====
            SectionCard {
                Layout.fillWidth: true
                title: I18NController.tr("set_appearance_section")
                icon: "settings"

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 16

                    // Theme selector
                    RowLayout {
                        Layout.fillWidth: true; spacing: 12
                        Text {
                            text: I18NController.tr("set_theme")
                            font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Medium
                            color: Theme.textPrimary
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 100
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 38; radius: 9
                            color: Theme.surfaceHover; border.width: 1
                            border.color: themeMA.containsMouse ? Theme.borderHover : Theme.border
                            Behavior on border.color { ColorAnimation { duration: 120 } }
                            MouseArea {
                                id: themeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: themePopup.visible = !themePopup.visible
                            }
                            Text {
                                anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
                                text: SettingsController.theme === "dark" ? I18NController.tr("set_theme_dark") : I18NController.tr("set_theme_light")
                                font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary
                            }
                            Item {
                                width: 16; height: 16; anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                                Image { id: themeChevron; source: "qrc:/icons/svg/chevron-down.svg"; sourceSize: Qt.size(16, 16); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                                MultiEffect { anchors.fill: parent; source: themeChevron; colorizationColor: Theme.textTertiary; colorization: 1.0 }
                            }
                            Popup {
                                id: themePopup; y: parent.height + 4; width: parent.width; padding: 4
                                background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                ColumnLayout {
                                    anchors.fill: parent; spacing: 2
                                    Repeater {
                                        model: [{ v: "light", l: I18NController.tr("set_theme_light") }, { v: "dark", l: I18NController.tr("set_theme_dark") }]
                                        delegate: ItemDelegate {
                                            width: parent.width; height: 34; padding: 0
                                            contentItem: Text {
                                                text: modelData.l
                                                font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd
                                                color: SettingsController.theme === modelData.v ? Theme.primary : Theme.textPrimary
                                                anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
                                            }
                                            background: Rectangle { color: SettingsController.theme === modelData.v ? Theme.primarySubtle : "transparent"; radius: 4 }
                                            onClicked: { SettingsController.theme = modelData.v; SettingsController.save(); themePopup.visible = false }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Language selector
                    RowLayout {
                        Layout.fillWidth: true; spacing: 12
                        Text {
                            text: I18NController.tr("set_language")
                            font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; font.weight: Font.Medium
                            color: Theme.textPrimary
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 100
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: 38; radius: 9
                            color: Theme.surfaceHover; border.width: 1
                            border.color: langMA.containsMouse ? Theme.borderHover : Theme.border
                            Behavior on border.color { ColorAnimation { duration: 120 } }
                            MouseArea {
                                id: langMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: langPopup.visible = !langPopup.visible
                            }
                            Text {
                                anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
                                text: SettingsController.language === "ml" ? I18NController.tr("set_lang_malayalam") : I18NController.tr("set_lang_english")
                                font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd; color: Theme.textPrimary
                            }
                            Item {
                                width: 16; height: 16; anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                                Image { id: langChevron; source: "qrc:/icons/svg/chevron-down.svg"; sourceSize: Qt.size(16, 16); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                                MultiEffect { anchors.fill: parent; source: langChevron; colorizationColor: Theme.textTertiary; colorization: 1.0 }
                            }
                            Popup {
                                id: langPopup; y: parent.height + 4; width: parent.width; padding: 4
                                background: Rectangle { color: Theme.surface; border.width: 1; border.color: Theme.border; radius: 9 }
                                ColumnLayout {
                                    anchors.fill: parent; spacing: 2
                                    Repeater {
                                        model: [{ v: "en", l: I18NController.tr("set_lang_english") }, { v: "ml", l: I18NController.tr("set_lang_malayalam") }]
                                        delegate: ItemDelegate {
                                            width: parent.width; height: 34; padding: 0
                                            contentItem: Text {
                                                text: modelData.l
                                                font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeMd
                                                color: SettingsController.language === modelData.v ? Theme.primary : Theme.textPrimary
                                                anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
                                            }
                                            background: Rectangle { color: SettingsController.language === modelData.v ? Theme.primarySubtle : "transparent"; radius: 4 }
                                            onClicked: {
                                                SettingsController.language = modelData.v
                                                SettingsController.save()
                                                I18NController.setLanguage(modelData.v)
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

            // ===== SECTION 4: Backup =====
            SectionCard {
                Layout.fillWidth: true
                title: I18NController.tr("set_backup_section")
                icon: "backup"

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 16

                    RowLayout {
                        Layout.fillWidth: true; spacing: 12
                        Text {
                            text: I18NController.tr("set_auto_backup")
                            font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textPrimary
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                        }
                        Switch {
                            id: autoBackupSwitch
                            onCheckedChanged: SettingsController.autoBackup = checked
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 12
                        AppTextField {
                            id: intervalField
                            Layout.fillWidth: true
                            label: I18NController.tr("set_backup_interval")
                            placeholderText: "24"
                            onTextChanged: {
                                var v = parseInt(text)
                                if (!isNaN(v) && v > 0) SettingsController.backupIntervalHours = v
                            }
                        }
                        Text {
                            text: I18NController.tr("set_hours")
                            font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textTertiary
                            Layout.alignment: Qt.AlignBottom
                            Layout.bottomMargin: 10
                        }
                    }
                }
            }

            // ===== Save button row =====
            Row {
                Layout.fillWidth: true
                Layout.bottomMargin: 28
                layoutDirection: Qt.RightToLeft
                spacing: 10

                AppButton {
                    text: I18NController.tr("action_save")
                    variant: "primary"
                    iconName: "check"
                    onClicked: {
                        var ok = SettingsController.save()
                        toast.show(ok ? I18NController.tr("ui_success") : I18NController.tr("val_save_failed"),
                                   ok ? Theme.primary : Theme.danger)
                    }
                }
                AppButton {
                    text: I18NController.tr("action_cancel")
                    variant: "secondary"
                    onClicked: page.loadValues()
                }
            }
        }
    }

    // ===== Helper to load values from SettingsController =====
    function loadValues() {
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

    Component.onCompleted: page.loadValues()
}
