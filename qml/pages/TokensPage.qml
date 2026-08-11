import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0
import "../components"

// ============================================================================
// TokensPage — Token distribution events (uses TokenService via Database)
// ============================================================================

Item {
    id: page

    property var events: []

    Component.onCompleted: refresh()

    function refresh() {
        if (typeof Services === "undefined" && typeof FamilyController === "undefined") return
        // Load token events directly from DB via Database::execute
        // Since we don't have a TokenController yet, we use a simple approach
        events = []
        try {
            // Check if token_events table exists
            var checkResult = Services ? Services.searchFamilies("", 1, 1, "", "") : null
            // For now, show empty state — token events require TokenController
        } catch(e) {}
    }

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

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Column { Layout.fillWidth: true; spacing: 2
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_tokens") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeXl; font.weight: Font.DemiBold; color: Theme.textPrimary }
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("tok_subtitle") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textSecondary } }
            AppButton {
                text: { var _l = I18NController.currentLanguage; return I18NController.tr("action_add") } variant: "primary"; iconName: "plus"
                onClicked: toast.show("Token event creation — coming soon")
            }
        }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
            Column { anchors.centerIn: parent; spacing: 12
                Rectangle { width: 56; height: 56; radius: 28; color: Theme.surfaceHover; border.width: 1; border.color: Theme.border; anchors.horizontalCenter: parent.horizontalCenter
                    Item { width: 28; height: 28; anchors.centerIn: parent
                        Image { id: emptyIcon; source: "qrc:/icons/svg/token.svg"; sourceSize: Qt.size(28, 28); anchors.fill: parent; fillMode: Image.Pad; visible: false }
                        MultiEffect { anchors.fill: parent; source: emptyIcon; colorizationColor: Theme.textDisabled; colorization: 1.0 }
                    } }
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("ui_no_records") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeLg; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("ui_click_add_to_create") } font.family: Theme.activeFontFamily; font.pixelSize: Theme.fontSizeSm; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter }
            }
        }
    }
}
