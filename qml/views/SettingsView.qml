import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

// SettingsView — mahallu profile, theme, language, backup config
Item {
    ScrollView {
        anchors.fill: parent; clip: true
        ColumnLayout {
            width: parent.width; spacing: 16
            // Header
            RowLayout {
                Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22; Layout.topMargin: 20; spacing: 12
                ColumnLayout { spacing: 2
                    Text { text: "Settings"; font.family: Theme.fontDisplay; font.pixelSize: 22; font.weight: Font.Bold; color: Theme.text }
                    Text { text: "Configure mahallu profile and preferences"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                }
                Item { Layout.fillWidth: true }
                Rectangle { radius: 8; color: Theme.sidebar; implicitHeight: 34; Layout.preferredWidth: 100
                    Text { anchors.centerIn: parent; text: "Save"; font.family: Theme.fontPrimary; font.pixelSize: 11; font.weight: Font.Bold; color: "#ffffff" } }
            }
            // Mahallu Profile section
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22; Layout.preferredHeight: 320; radius: 10
                color: Theme.panel; border.width: 1.5; border.color: Theme.border
                ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                    Text { text: "Mahallu Profile"; font.family: Theme.fontDisplay; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text }
                    RowLayout { Layout.fillWidth: true; spacing: 12
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "MAHALLU NAME"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                            TextField { Layout.fillWidth: true; text: "Minz Mahallu"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text
                                background: Rectangle { color: Theme.panelMuted; border.width: 1; border.color: Theme.border; radius: 6 } implicitHeight: 32 }
                        }
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "PHONE"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                            TextField { Layout.fillWidth: true; text: "0495 123 4567"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text
                                background: Rectangle { color: Theme.panelMuted; border.width: 1; border.color: Theme.border; radius: 6 } implicitHeight: 32 }
                        }
                    }
                    RowLayout { Layout.fillWidth: true; spacing: 12
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "EMAIL"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                            TextField { Layout.fillWidth: true; text: "info@minzmahallu.org"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text
                                background: Rectangle { color: Theme.panelMuted; border.width: 1; border.color: Theme.border; radius: 6 } implicitHeight: 32 }
                        }
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "FINANCIAL YEAR START"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                            ComboBox { Layout.fillWidth: true; model: ["April", "January", "July"]; font.family: Theme.fontPrimary; font.pixelSize: 11; implicitHeight: 32 }
                        }
                    }
                    ColumnLayout { Layout.fillWidth: true; spacing: 4
                        Text { text: "ADDRESS"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                        TextField { Layout.fillWidth: true; text: "Minz Mahallu Office, Calicut Road, Malappuram, Kerala 676501"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text
                            background: Rectangle { color: Theme.panelMuted; border.width: 1; border.color: Theme.border; radius: 6 } implicitHeight: 60; wrapMode: TextArea.Wrap }
                    }
                    RowLayout { Layout.fillWidth: true; spacing: 12
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "CURRENCY SYMBOL"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                            TextField { Layout.fillWidth: true; text: "Rs."; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text
                                background: Rectangle { color: Theme.panelMuted; border.width: 1; border.color: Theme.border; radius: 6 } implicitHeight: 32 }
                        }
                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "RECEIPT PREFIX"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                            TextField { Layout.fillWidth: true; text: "R"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text
                                background: Rectangle { color: Theme.panelMuted; border.width: 1; border.color: Theme.border; radius: 6 } implicitHeight: 32 }
                        }
                    }
                }
            }
            // Appearance section
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22; Layout.preferredHeight: 200; radius: 10
                color: Theme.panel; border.width: 1.5; border.color: Theme.border
                ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                    Text { text: "Appearance"; font.family: Theme.fontDisplay; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text }
                    RowLayout { Layout.fillWidth: true; spacing: 12
                        Text { text: "Theme"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                        ComboBox { implicitHeight: 30; Layout.preferredWidth: 180; model: ["Emerald (Default)", "Light", "Dark"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                    }
                    RowLayout { Layout.fillWidth: true; spacing: 12
                        Text { text: "Language"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                        ComboBox { implicitHeight: 30; Layout.preferredWidth: 180; model: ["English", "മലയാളം (Malayalam)"]; font.family: Theme.fontPrimary; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                    }
                    RowLayout { Layout.fillWidth: true; spacing: 12
                        Text { text: "Auto Backup"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.text }
                        Switch { checked: true }
                        Text { text: "Every 6 hours"; font.family: Theme.fontPrimary; font.pixelSize: 11; color: Theme.muted }
                        Item { Layout.fillWidth: true }
                    }
                }
            }
            // Branding section
            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 22; Layout.rightMargin: 22; Layout.bottomMargin: 20; Layout.preferredHeight: 160; radius: 10
                color: Theme.panel; border.width: 1.5; border.color: Theme.border
                ColumnLayout { anchors.fill: parent; anchors.margins: 18; spacing: 12
                    Text { text: "Branding"; font.family: Theme.fontDisplay; font.pixelSize: 14; font.weight: Font.Bold; color: Theme.text }
                    RowLayout { Layout.fillWidth: true; spacing: 16
                        ColumnLayout { Layout.fillWidth: true; spacing: 6
                            Text { text: "MAHALLU LOGO"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                            Rectangle { width: 120; height: 80; radius: 8; color: Theme.panelMuted; border.width: 1.5; border.color: Theme.border
                                Text { anchors.centerIn: parent; text: "LOGO"; font.family: Theme.fontDisplay; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.muted } }
                            Text { text: "PNG · 240×80px"; font.family: Theme.fontPrimary; font.pixelSize: 9; color: Theme.muted }
                        }
                        ColumnLayout { Layout.fillWidth: true; spacing: 6
                            Text { text: "OFFICIAL SEAL"; font.family: Theme.fontPrimary; font.pixelSize: 9; font.weight: Font.Black; color: Theme.muted }
                            Rectangle { width: 80; height: 80; radius: 40; color: Theme.panelMuted; border.width: 1.5; border.color: Theme.border
                                Text { anchors.centerIn: parent; text: "SEAL"; font.family: Theme.fontDisplay; font.pixelSize: 11; font.weight: Font.Bold; color: Theme.muted } }
                            Text { text: "PNG · 200×200px"; font.family: Theme.fontPrimary; font.pixelSize: 9; color: Theme.muted }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }
    }
}
