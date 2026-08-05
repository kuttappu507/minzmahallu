import QtQuick
import QtQuick.Controls

// ============================================================================
// AppTextField — Reusable input matching DashboardV3 design
// CSS: .qwrap { background:#f2faf4; border:1px solid #d2e5d8; border-radius:9px; height:38px; }
// Focus: border #059669 + subtle green glow
// ============================================================================

FocusScope {
    id: root

    property string label: ""
    property string placeholderText: ""
    property string iconName: ""
    property bool showError: false
    property string errorText: ""

    property alias text: input.text
    property alias echoMode: input.echoMode
    property alias readOnly: input.readOnly
    property alias validator: input.validator

    signal editingFinished()

    implicitHeight: label !== "" ? labelItem.implicitHeight + 4 + 38 : 38
    implicitWidth: 240

    Column {
        anchors.fill: parent
        spacing: 4

        Text {
            id: labelItem
            text: root.label
            font.family: "Poppins"
            font.pixelSize: 11
            font.weight: Font.Medium
            color: root.showError ? "#e11d48" : "#7e968a"
            visible: root.label !== ""
            height: root.label !== "" ? implicitHeight : 0
        }

        Rectangle {
            width: parent.width
            height: 38
            radius: 9
            color: "#f2faf4"
            border.width: 1
            border.color: root.showError ? "#e11d48" :
                          input.activeFocus ? "#059669" :
                          (hoverMA.containsMouse ? "#b2cfbd" : "#d2e5d8")
            Behavior on border.color { ColorAnimation { duration: 120 } }

            // Focus glow
            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                radius: parent.radius + 2
                color: "transparent"
                border.width: 2
                border.color: Qt.rgba(5/255, 150/255, 105/255, 0.12)
                visible: input.activeFocus && !root.showError
            }

            // Optional leading icon
            Item {
                width: 16; height: 16
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                visible: root.iconName !== ""
                Image {
                    source: root.iconName !== "" ? "qrc:/icons/svg/" + root.iconName + ".svg" : ""
                    sourceSize: Qt.size(16, 16)
                    anchors.fill: parent
                    fillMode: Image.Pad
                    visible: false
                }
                MultiEffect {
                    anchors.fill: parent
                    source: parent.children[0]
                    colorizationColor: input.activeFocus ? "#059669" : "#7e968a"
                    colorization: 1.0
                    Behavior on colorizationColor { ColorAnimation { duration: 120 } }
                }
            }

            TextField {
                id: input
                anchors.left: parent.left
                anchors.leftMargin: root.iconName !== "" ? 32 : 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: root.placeholderText
                placeholderTextColor: "#7e968a"
                font.family: "Poppins"
                font.pixelSize: 13
                color: "#12241b"
                background: Item {}
                verticalAlignment: Text.AlignVCenter
                cursorDelegate: Rectangle {
                    visible: input.activeFocus
                    color: "#059669"
                    width: 1
                }
                onEditingFinished: root.editingFinished()
            }

            MouseArea {
                id: hoverMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.NoButton
            }
        }

        Text {
            text: root.errorText
            font.family: "Poppins"
            font.pixelSize: 10
            color: "#e11d48"
            visible: root.showError && root.errorText !== ""
            height: (root.showError && root.errorText !== "") ? implicitHeight : 0
        }
    }
}
