import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// SettingsPage — Organization info, logo/seal, theme, backup config
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
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: "Poppins"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#ffffff" }
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
                Text { text: "Settings"; font.family: "Poppins"; font.pixelSize: 21; font.weight: Font.DemiBold; color: "#12241b" }
                Text { text: "Application configuration"; font.family: "Poppins"; font.pixelSize: 12; color: "#4f6b5c" } }

            // Organization info
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; radius: 10; color: "#ffffff"; border.width: 1; border.color: "#d2e5d8"
                ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 14

                    Text { text: "Organization"; font.family: "Poppins"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#12241b" }

                    AppTextField { Layout.fillWidth: true; label: "Mahallu Name"; text: SettingsController.mahalluName; onTextChanged: SettingsController.mahalluName = text }
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        AppTextField { Layout.fillWidth: true; label: "Phone"; text: SettingsController.phone; onTextChanged: SettingsController.phone = text }
                        AppTextField { Layout.fillWidth: true; label: "Email"; text: SettingsController.email; onTextChanged: SettingsController.email = text } }
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        AppTextField { Layout.fillWidth: true; label: "Financial Year Start (MM-DD)"; placeholderText: "04-01"; text: SettingsController.financialYearStart; onTextChanged: SettingsController.financialYearStart = text }
                        AppTextField { Layout.fillWidth: true; label: "Currency Symbol"; text: SettingsController.currencySymbol; onTextChanged: SettingsController.currencySymbol = text }
                        AppTextField { Layout.fillWidth: true; label: "Receipt Prefix"; text: SettingsController.receiptPrefix; onTextChanged: SettingsController.receiptPrefix = text } }

                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: "ADDRESS"; font.family: "Poppins"; font.pixelSize: 11; font.weight: Font.Medium; color: "#7e968a" }
                        TextArea { Layout.fillWidth: true; Layout.preferredHeight: 56; text: SettingsController.address; font.family: "Poppins"; font.pixelSize: 13; color: "#12241b"; placeholderText: "Mahallu address..."; placeholderTextColor: "#7e968a"; selectByMouse: true; wrapMode: TextArea.Wrap
                            background: Rectangle { radius: 9; color: "#f2faf4"; border.width: 1; border.color: parent.activeFocus ? "#059669" : parent.hovered ? "#b2cfbd" : "#d2e5d8"; Behavior on border.color { ColorAnimation { duration: 120 } } }
                            padding: 10; onTextChanged: SettingsController.address = text } }
                }
            }

            // User Interface
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; radius: 10; color: "#ffffff"; border.width: 1; border.color: "#d2e5d8"
                ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 14
                    Text { text: "User Interface"; font.family: "Poppins"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#12241b" }
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        AppComboBox { Layout.fillWidth: true; label: "Theme"; model: ["light", "dark"]; currentIndex: model.indexOf(SettingsController.theme); onActivated: function(index) { SettingsController.theme = model[index] } }
                        AppComboBox { Layout.fillWidth: true; label: "Language"; model: ["en", "ml"]; currentIndex: model.indexOf(SettingsController.language); onActivated: function(index) { SettingsController.language = model[index] } } }
                }
            }

            // Backup config
            Rectangle { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; radius: 10; color: "#ffffff"; border.width: 1; border.color: "#d2e5d8"
                ColumnLayout { anchors.fill: parent; anchors.margins: 20; spacing: 14
                    Text { text: "Backup"; font.family: "Poppins"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#12241b" }
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        Text { text: "Auto Backup"; font.family: "Poppins"; font.pixelSize: 12; color: "#4f6b5c"; Layout.alignment: Qt.AlignVCenter }
                        Switch { checked: SettingsController.autoBackup; onCheckedChanged: SettingsController.autoBackup = checked }
                        AppTextField { Layout.fillWidth: true; label: "Interval (hours)"; text: SettingsController.backupIntervalHours.toString(); onTextChanged: { var v = parseInt(text); if (!isNaN(v) && v > 0) SettingsController.backupIntervalHours = v } } }
                }
            }

            // Save button
            Row { Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.bottomMargin: 24; layoutDirection: Qt.RightToLeft
                AppButton { text: "Save Settings"; variant: "primary"; iconName: "check"; onClicked: {
                    var ok = SettingsController.save()
                    toast.show(ok ? "Settings saved successfully" : "Save failed", ok ? "#059669" : "#e11d48")
                } }
            }
        }
    }
}
