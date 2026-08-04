import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MMS.Theme 1.0

// ============================================================================
// KpiCardV2 — Compact sophisticated KPI card
//
// Design:
//   - White surface with thin neutral border
//   - Subtle accent left bar (3px) as the ONLY color decoration
//   - Small tinted icon container (top-left)
//   - Trend badge (top-right)
//   - Large number (strongest element)
//   - Label + subtitle
//
// NO large colored rectangles. Color is an ACCENT, not decoration.
//
// Layout: content-driven via Column → no fixed height.
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

    implicitWidth: 220
    implicitHeight: content.implicitHeight + 32   // 16px top + 16px bottom padding
    radius: 10
    color: root.accent.subtle
    border.width: 1
    border.color: root.accent.main

    readonly property var accent: Theme.accent(accentName)

    // Subtle accent left bar (3px) — the ONLY color decoration
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 3
        color: root.accent.main
        radius: 0

        // Round only the left corners to match parent radius
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            height: root.radius
            color: root.accent.main
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width
            height: root.radius
            color: root.accent.main
        }
    }

    // Hover shadow (very subtle)
    layer.enabled: hoverMA.containsMouse
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0.15, 0.23, 0.42, 0.06)
        shadowBlur: 0.3
        shadowVerticalOffset: 2
    }

    MouseArea {
        id: hoverMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: 16
        anchors.leftMargin: 20   // extra to clear the 3px accent bar
        spacing: 8

        // Top row: icon + trend badge
        Item {
            width: parent.width
            height: 32
            implicitHeight: 32

            // Small tinted icon container
            Rectangle {
                id: iconContainer
                x: 0
                y: 0
                width: 37; height: 37; radius: 9
                color: root.accent.main

                Item {
                    width: 18; height: 18
                    anchors.centerIn: parent

                    Image {
                        id: kpiIcon
                        source: root.iconName !== "" ? "qrc:/icons/svg/" + root.iconName + ".svg" : ""
                        sourceSize: Qt.size(Theme.iconSizeSm, Theme.iconSizeSm)
                        anchors.fill: parent
                        fillMode: Image.Pad
                        visible: false
                    }
                    MultiEffect {
                        anchors.fill: parent
                        source: kpiIcon
                        colorizationColor: "#ffffff"
                        colorization: 1.0
                    }
                }
            }

            // Trend badge (right)
            Rectangle {
                visible: root.trend !== ""
                x: parent.width - width
                y: (32 - height) / 2
                height: 22
                width: trendRow.implicitWidth + 14
                radius: 11
                color: Theme.surface

                Row {
                    id: trendRow
                    anchors.centerIn: parent
                    spacing: 3

                    Item {
                        width: 11; height: 11
                        y: (parent.height - height) / 2

                        Image {
                            id: trendIcon
                            source: root.trendUp ? "qrc:/icons/svg/trending-up.svg" : "qrc:/icons/svg/trending-down.svg"
                            sourceSize: Qt.size(11, 11)
                            anchors.fill: parent
                            fillMode: Image.Pad
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: parent
                            source: trendIcon
                            colorizationColor: root.accent.main
                            colorization: 1.0
                        }
                    }

                    Text {
                        text: root.trend
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeXs
                        font.weight: Font.DemiBold
                        color: root.accent.deep
                        y: (parent.height - height) / 2
                    }
                }
            }
        }

        // Value (large number — strongest element)
        Text {
            text: root.value
            font.family: Theme.fontFamilyDisplay
            font.pixelSize: 24
            font.weight: Font.Bold
            color: root.accent.deep
            width: parent.width
            elide: Text.ElideRight
        }

        // Label
        Text {
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.weight: Font.Black
            color: root.accent.deep
            opacity: 0.75
            width: parent.width
            elide: Text.ElideRight
        }

        // Subtitle (trend context)
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
