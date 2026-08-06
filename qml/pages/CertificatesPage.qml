import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// Certificates page — placeholder (certificate generation is complex, uses legacy app for now)
Item {
    id: page

    Rectangle {
        id: toast
        property bool visible_: false
        property string message: ""
        property color bgColor: "#7e968a"
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: visible_ ? 18 : -60
        width: toastText.implicitWidth + 40; height: 40; radius: 9
        color: bgColor; z: 1000
        Behavior on anchors.topMargin { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: "Poppins"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#ffffff" }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg) { message = msg; visible_ = true; toastTimer.restart() }
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        Column { Layout.fillWidth: true; spacing: 2
            Text { text: "Certificates"; font.family: "Poppins"; font.pixelSize: 21; font.weight: Font.DemiBold; color: "#12241b" }
            Text { text: "Generate membership, residence, marriage, death certificates"; font.family: "Poppins"; font.pixelSize: 12; color: "#4f6b5c" } }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: "#ffffff"; border.width: 1; border.color: "#d2e5d8"
            Column { anchors.centerIn: parent; spacing: 16
                Rectangle { width: 64; height: 64; radius: 32; color: "#f2faf4"; border.width: 1; border.color: "#d2e5d8"; anchors.horizontalCenter: parent.horizontalCenter
                    Item { width: 32; height: 32; anchors.centerIn: parent
                        Image { id: certIcon; source: "qrc:/icons/svg/certificates.svg"; sourceSize: Qt.size(32, 32); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                        MultiEffect { anchors.fill: parent; source: certIcon; colorizationColor: "#b2cfbd"; colorization: 1.0 } } }
                Column { spacing: 4; anchors.horizontalCenter: parent.horizontalCenter
                    Text { text: "Certificate Generation"; font.family: "Poppins"; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#12241b"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "Certificate generation with QR codes and PDF export"; font.family: "Poppins"; font.pixelSize: 12; color: "#7e968a"; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: "Use the legacy MMS.exe for certificate generation during migration"; font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a"; anchors.horizontalCenter: parent.horizontalCenter } }
                AppButton { text: "Coming Soon"; variant: "secondary"; anchors.horizontalCenter: parent.horizontalCenter; onClicked: toast.show("Certificate generation will be available after full migration") }
            }
        }
    }
}
