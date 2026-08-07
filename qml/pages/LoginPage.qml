import QtQuick
import QtQuick.Controls
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
            GradientStop { position: 0.42; color: "#065f46" }
            GradientStop { position: 1.0;  color: "#044633" }
        }
    }

    // Login card
    Rectangle {
        id: loginCard
        anchors.centerIn: parent
        width: 420; height: 460
        radius: 16; color: "#ffffff"

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
                    color: "#059669"
                    Text { anchors.centerIn: parent; text: "M"; font.family: "Poppins"; font.pixelSize: 28; font.weight: Font.Bold; color: "#ffffff" }
                }
            }

            // Title
            Text {
                text: "Minz Mahallu"
                font.family: "Anek Malayalam"; font.pixelSize: 20; font.weight: Font.Bold; color: "#12241b"
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: "Management System"
                font.family: "Poppins"; font.pixelSize: 12; color: "#7e968a"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -12
            }

            // Error banner
            Rectangle {
                Layout.fillWidth: true; visible: errorText.text !== ""
                height: 36; radius: 8; color: "#fddfe5"; border.width: 1; border.color: "#e11d48"
                Text { id: errorText; anchors.fill: parent; anchors.margins: 8; verticalAlignment: Text.AlignVCenter; font.family: "Poppins"; font.pixelSize: 12; color: "#95102e"; elide: Text.ElideRight }
            }

            // Username field
            AppTextField {
                id: usernameField
                Layout.fillWidth: true
                label: "Username"
                placeholderText: "Enter username"
                onTextChanged: errorText.text = ""
            }

            // Password field
            ColumnLayout {
                Layout.fillWidth: true; spacing: 4
                Text { text: "Password"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Medium; color: "#7e968a" }
                Rectangle {
                    Layout.fillWidth: true; height: 38; radius: 9; color: "#f2faf4"; border.width: 1
                    border.color: passwordField.activeFocus ? "#059669" : (pwdHover.containsMouse ? "#b2cfbd" : "#d2e5d8")
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    HoverHandler { id: pwdHover; cursorShape: Qt.IBeamCursor }
                    TextField {
                        id: passwordField
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 38
                        verticalAlignment: Text.AlignVCenter
                        placeholderText: "Enter password"; placeholderTextColor: "#7e968a"
                        font.family: "Poppins"; font.pixelSize: 13; color: "#12241b"
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
                            Text { anchors.centerIn: parent; text: showPassword.checked ? "\u{1F441}" : "\u25CF"; font.pixelSize: 10; color: "#ffffff"; visible: showPassword.checked }
                        }
                    }
                }
            }

            // Login button
            AppButton {
                id: loginButton
                Layout.fillWidth: true
                text: "Login"; variant: "primary"; iconName: "key"
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
                text: "Default: admin / admin123"
                font.family: "Poppins"; font.pixelSize: 10; color: "#b2cfbd"
                Layout.alignment: Qt.AlignHCenter
            }

            Item { Layout.fillHeight: true }
        }
    }
}
