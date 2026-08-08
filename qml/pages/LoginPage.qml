import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// LoginPage — Login screen with username/password
// Calls AuthController.login. Shows error on failure.
// ============================================================================

Item {
    id: page

    // Green gradient background matching sidebar
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0;  color: "#0a7f5d" }
            GradientStop { position: 0.42; color: Theme.primaryPressed }
            GradientStop { position: 1.0;  color: "#044633" }
        }
    }

    // Login card
    Rectangle {
        id: loginCard
        anchors.centerIn: parent
        width: 420; height: 460
        radius: 16; color: Theme.surface

        // Subtle shadow
        Rectangle {
            anchors.fill: parent; anchors.margins: -2
            radius: parent.radius + 2; color: "#000000"; opacity: 0.15
            z: -1
        }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 36; spacing: 20

            // Logo
            Item {
                Layout.fillWidth: true; Layout.preferredHeight: 60
                Rectangle {
                    anchors.centerIn: parent; width: 56; height: 56; radius: 20
                    color: Theme.primary
                    Text { anchors.centerIn: parent; text: "M"; font.family: Theme.activeFontFamily; font.pixelSize: 28; font.weight: Font.Bold; color: Theme.surface }
                }
            }

            // Title
            Text {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("app_name") }
                font.family: "Anek Malayalam"; font.pixelSize: 20; font.weight: Font.Bold; color: Theme.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("app_subtitle") }
                font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textTertiary
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -12
            }

            // Error banner
            Rectangle {
                Layout.fillWidth: true; visible: errorText.text !== ""
                height: 36; radius: 8; color: Theme.coralSubtle; border.width: 1; border.color: Theme.danger
                Text { id: errorText; anchors.fill: parent; anchors.margins: 8; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: "#95102e"; elide: Text.ElideRight }
            }

            // Username field
            AppTextField {
                id: usernameField
                Layout.fillWidth: true
                label: "Username"
                placeholderText: { var _l = I18NController.currentLanguage; return I18NController.tr("login_username") }
                onTextChanged: errorText.text = ""
            }

            // Password field
            ColumnLayout {
                Layout.fillWidth: true; spacing: 4
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("login_password") }; font.family: Theme.activeFontFamily; font.pixelSize: 11; font.weight: Font.Medium; color: Theme.textTertiary }
                Rectangle {
                    Layout.fillWidth: true; height: 38; radius: 9; color: Theme.surfaceHover; border.width: 1
                    border.color: passwordField.activeFocus ? "#059669" : (pwdHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    HoverHandler { id: pwdHover; cursorShape: Qt.IBeamCursor }
                    TextField {
                        id: passwordField
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 38
                        verticalAlignment: Text.AlignVCenter
                        placeholderText: { var _l = I18NController.currentLanguage; return I18NController.tr("login_password") }; placeholderTextColor: "#7e968a"
                        font.family: Theme.activeFontFamily; font.pixelSize: 13; color: Theme.textPrimary
                        echoMode: showPassword.checked ? TextInput.Normal : TextInput.Password
                        background: Item {}
                        onTextChanged: errorText.text = ""
                        onAccepted: loginButton.clicked()
                        Keys.onReturnPressed: loginButton.clicked()
                    }
                    // Show/hide password toggle
                    CheckBox {
                        id: showPassword
                        anchors.right: parent.right; anchors.rightMargin: 6; anchors.verticalCenter: parent.verticalCenter
                        width: 26; height: 26
                        text: ""; checked: false
                        indicator: Rectangle {
                            width: 18; height: 18; radius: 4; anchors.centerIn: parent
                            color: showPassword.checked ? "#059669" : "transparent"
                            border.width: 1; border.color: showPassword.checked ? "#059669" : "#d2e5d8"
                            Text { anchors.centerIn: parent; text: showPassword.checked ? "\u{1F441}" : "\u25CF"; font.pixelSize: 10; color: Theme.surface; visible: showPassword.checked }
                        }
                    }
                }
            }

            // Login button
            AppButton {
                id: loginButton
                Layout.fillWidth: true
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("login_button") }; variant: "primary"; iconName: "key"
                onClicked: {
                    if (usernameField.text.trim() === "" || passwordField.text === "") {
                        errorText.text = "Please enter username and password."
                        return
                    }
                    var result = AuthController.login(usernameField.text.trim(), passwordField.text)
                    if (!result.success) {
                        errorText.text = result.error || "Login failed."
                    }
                    // On success, sessionChanged signal will hide this page
                }
            }

            // Hint text
            Text {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("login_default_hint") }
                font.family: Theme.activeFontFamily; font.pixelSize: 10; color: Theme.textDisabled
                Layout.alignment: Qt.AlignHCenter
            }

            Item { Layout.fillHeight: true }
        }
    }
}
