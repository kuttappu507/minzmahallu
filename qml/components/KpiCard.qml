import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// KpiCard — Attractive KPI card (Phase 3.2 fixed clipping)
//
// Increased height to 148px so all content fits at Windows scaling.
// Layout: Rectangle → Column (anchors.fill, margins: 16)
//   ├─ Row (icon + spacer + trend badge) — height: 40
//   ├─ Text (value) — fontSize3xl
//   ├─ Text (label) — fontSizeSm
//   └─ Text (subtitle) — fontSizeXs
// ============================================================================

Rectangle {
    id: root

    property string label: ""
    property string value: ""
    property string trend: ""
    property bool trendUp: true
    property string accentName: "emerald"
    property string iconName: ""
    property string subtitle: ""

    implicitHeight: 148
    implicitWidth: 240
    radius: Theme.radiusLg
    color: Theme.surface
    border.width: 1
    border.color: Theme.border

    readonly property var accent: Theme.accent(accentName)

    // Accent tint in top-right corner
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        width: 120
        height: 120
        radius: parent.radius
        color: root.accent.main
        opacity: 0.06
    }

    // Hover shadow
    layer.enabled: hoverMA.containsMouse
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0.15, 0.23, 0.42, Theme.shadowOpacitySmall)
        shadowBlur: 0.4
        shadowVerticalOffset: 3
    }

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    MouseArea {
        id: hoverMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Column {
        id: cardContent
        anchors.fill: parent
        anchors.margins: 16
        spacing: 6

        // Top row: icon + trend badge
        Item {
            width: parent.width
            height: 40

            // Tinted icon container (left)
            Rectangle {
                id: iconContainer
                x: 0
                y: 0
                width: 40; height: 40; radius: Theme.radiusMd
                color: root.accent.subtle
                border.width: 1
                border.color: root.accent.subtleAlt

                Item {
                    width: Theme.iconSizeLg; height: Theme.iconSizeLg
                    anchors.centerIn: parent

                    Image {
                        id: kpiIcon
                        source: root.iconName !== "" ? "qrc:/icons/svg/" + root.iconName + ".svg" : ""
                        sourceSize: Qt.size(Theme.iconSizeLg, Theme.iconSizeLg)
                        anchors.fill: parent
                        fillMode: Image.Pad
                        visible: false
                    }
                    MultiEffect {
                        anchors.fill: parent
                        source: kpiIcon
                        colorizationColor: root.accent.main
                        colorization: 1.0
                    }
                }
            }

            // Trend badge (right)
            Rectangle {
                id: trendBadge
                visible: root.trend !== ""
                x: parent.width - width
                y: (40 - height) / 2
                height: 22
                width: trendRow.implicitWidth + 12
                radius: 11
                color: root.trendUp ? Theme.successSubtle : Theme.coralSubtle
                border.width: 0

                Row {
                    id: trendRow
                    anchors.centerIn: parent
                    spacing: 2

                    Item {
                        width: 12; height: 12
                        y: (parent.height - height) / 2

                        Image {
                            id: trendIcon
                            source: root.trendUp ? "qrc:/icons/svg/trending-up.svg" : "qrc:/icons/svg/trending-down.svg"
                            sourceSize: Qt.size(12, 12)
                            anchors.fill: parent
                            fillMode: Image.Pad
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: parent
                            source: trendIcon
                            colorizationColor: root.trendUp ? Theme.success : Theme.coral
                            colorization: 1.0
                        }
                    }

                    Text {
                        text: root.trend
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeXs
                        font.weight: Font.DemiBold
                        color: root.trendUp ? Theme.success : Theme.coral
                        y: (parent.height - height) / 2
                    }
                }
            }
        }

        // Value (large number)
        Text {
            text: root.value
            font.family: Theme.fontFamilyDisplay
            font.pixelSize: Theme.fontSize3xl
            font.weight: Font.Bold
            color: Theme.textPrimary
            width: parent.width
            elide: Text.ElideRight
        }

        // Label
        Text {
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            font.weight: Font.Medium
            color: Theme.textSecondary
            width: parent.width
            elide: Text.ElideRight
        }

        // Subtitle
        Text {
            text: root.subtitle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            color: Theme.textTertiary
            visible: root.subtitle !== ""
            width: parent.width
            elide: Text.ElideRight
        }
    }
}
