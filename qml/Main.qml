// =============================================================================
// Main.qml — Phase 2 QML SMOKE TEST
//
// This is NOT the real application UI.
// It only verifies that Qt Quick / QML loads and renders.
//
// Success criteria:
//   - ApplicationWindow creates without error
//   - Text "QML OK" renders
//   - Component.onCompleted fires
//   - Zero QML warnings
// =============================================================================
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: window
    visible: true
    width: 400
    height: 200
    title: "MMS QML Smoke Test"
    color: "#ffffff"

    Column {
        anchors.centerIn: parent
        spacing: 12

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "QML OK"
            font.pixelSize: 32
            font.weight: Font.Bold
            color: "#059669"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Phase 2 smoke test — Qt Quick is operational"
            font.pixelSize: 12
            color: "#6b7280"
        }
    }

    Component.onCompleted: {
        console.log("[smoke] ApplicationWindow created successfully")
        console.log("[smoke] Screen devicePixelRatio:", Screen.devicePixelRatio)
        console.log("[smoke] Window size:", width, "x", height)
    }
}
