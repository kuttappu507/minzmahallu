import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// Reports page — list of available reports (read-only)
Item {
    id: page

    property var reports: [
        { name: "Family Register", desc: "Complete list of all families", icon: "families" },
        { name: "Member Directory", desc: "All members with contact info", icon: "members" },
        { name: "Subscription Report", desc: "Collections and defaulters", icon: "subscriptions" },
        { name: "Donation Report", desc: "Donations by category and date", icon: "donations" },
        { name: "Cash Book", desc: "Income and expense transactions", icon: "accounting" },
        { name: "Marriage Register", desc: "All marriage records", icon: "marriage" },
        { name: "Death Register", desc: "All death records", icon: "death" },
        { name: "Welfare Report", desc: "Welfare requests and disbursements", icon: "welfare" },
        { name: "Financial Summary", desc: "Monthly income vs expense", icon: "reports" },
        { name: "Audit Log Report", desc: "System activity history", icon: "audit" }
    ]

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
            Text { text: "Reports"; font.family: "Poppins"; font.pixelSize: 21; font.weight: Font.DemiBold; color: "#12241b" }
            Text { text: "Generate and export reports"; font.family: "Poppins"; font.pixelSize: 12; color: "#4f6b5c" } }

        // Reports grid
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            GridLayout {
                width: parent.width; columns: page.width > 800 ? 3 : (page.width > 500 ? 2 : 1)
                columnSpacing: 12; rowSpacing: 12

                Repeater {
                    model: page.reports
                    delegate: Rectangle {
                        Layout.fillWidth: true; Layout.minimumWidth: 200; height: 100; radius: 9
                        color: "#ffffff"; border.width: 1; border.color: repMA.containsMouse ? "#059669" : "#d2e5d8"
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                        MouseArea { id: repMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: toast.show("Report generation: " + modelData.name + " — use the legacy app for now") }

                        Row {
                            anchors.fill: parent; anchors.margins: 16; spacing: 12
                            Item { width: 32; height: 32; anchors.verticalCenter: parent.verticalCenter
                                Image { id: repIcon; source: "qrc:/icons/svg/" + modelData.icon + ".svg"; sourceSize: Qt.size(32, 32); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                                MultiEffect { anchors.fill: parent; source: repIcon; colorizationColor: repMA.containsMouse ? "#059669" : "#7e968a"; colorization: 1.0; Behavior on colorizationColor { ColorAnimation { duration: 120 } } } }
                            Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                Text { text: modelData.name; font.family: "Poppins"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#12241b" }
                                Text { text: modelData.desc; font.family: "Poppins"; font.pixelSize: 11; color: "#7e968a"; width: 200; elide: Text.ElideRight } }
                        }
                    }
                }
            }
        }
    }
}
