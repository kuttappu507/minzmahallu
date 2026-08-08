import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// ReportsPage — Generate reports + CSV/PDF/Excel export
// ============================================================================

Item {
    id: page

    property var reportTypes: ReportController.reportTypes()
    property int selectedReport: 0
    property string dateFrom: ""
    property string dateTo: ""
    property var reportData: null

    function generate() {
        reportData = ReportController.generate(selectedReport, dateFrom, dateTo)
    }

    Component.onCompleted: generate()

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
        Text { id: toastText; anchors.centerIn: parent; text: toast.message; font.family: Theme.activeFontFamily; font.pixelSize: 13; font.weight: Font.DemiBold; color: Theme.surface }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.visible_ = false }
        function show(msg, color) { message = msg; bgColor = color || "#059669"; visible_ = true; toastTimer.restart() }
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 16

        // Header
        Column { Layout.fillWidth: true; spacing: 2
            Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("rpt_title") } font.family: Theme.activeFontFamily; font.pixelSize: 21; font.weight: Font.DemiBold; color: Theme.textPrimary }
            Text { text: "Generate and export reports"; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary } }

        // Toolbar
        RowLayout {
            Layout.fillWidth: true; spacing: 10

            AppComboBox {
                implicitHeight: 38; Layout.fillWidth: true; Layout.minimumWidth: 200
                model: page.reportTypes
                currentIndex: 0
                onActivated: function(index) { selectedReport = index; generate() }
            }

            AppTextField { Layout.preferredWidth: 140; implicitHeight: 38; label: ""; placeholderText: "From (YYYY-MM-DD)"; text: dateFrom; onTextChanged: dateFrom = text }
            AppTextField { Layout.preferredWidth: 140; implicitHeight: 38; label: ""; placeholderText: "To (YYYY-MM-DD)"; text: dateTo; onTextChanged: dateTo = text }

            AppButton { text: { var _l = I18NController.currentLanguage; return I18NController.tr("rpt_generate") }; variant: "primary"; iconName: "reports"; onClicked: generate() }

            AppButton { text: "CSV"; variant: "secondary"; iconName: "download"; onClicked: {
                var path = ReportController.ensureExportPath("report.csv")
                var result = ReportController.exportToCsv(selectedReport, dateFrom, dateTo, path)
                toast.show(result && result.length > 0 ? "Exported: " + result : "Export failed", result && result.length > 0 ? "#059669" : "#e11d48")
            } }
            AppButton { text: "PDF"; variant: "secondary"; iconName: "print"; onClicked: {
                var path = ReportController.ensureExportPath("report.pdf")
                var result = ReportController.exportToPdf(selectedReport, dateFrom, dateTo, path)
                toast.show(result && result.length > 0 ? "Exported: " + result : "Export failed", result && result.length > 0 ? "#059669" : "#e11d48")
            } }
            AppButton { text: "Excel"; variant: "secondary"; iconName: "download"; onClicked: {
                var path = ReportController.ensureExportPath("report.xlsx")
                var result = ReportController.exportToExcel(selectedReport, dateFrom, dateTo, path)
                toast.show(result && result.length > 0 ? "Exported: " + result : "Export failed", result && result.length > 0 ? "#059669" : "#e11d48")
            } }
        }

        // Results table
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0

                // Header row (dynamic based on report headers)
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 40; color: Theme.surfaceHover
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    Row {
                        x: 16; width: parent.width - 32; spacing: 0
                        Repeater {
                            model: page.reportData ? page.reportData.headers : []
                            delegate: Text {
                                text: modelData; width: Math.max(100, (parent.width - 32) / (page.reportData ? page.reportData.columnCount : 1))
                                height: 40; verticalAlignment: Text.AlignVCenter
                                font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // Data rows
                ListView {
                    id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0
                    model: page.reportData ? page.reportData.rows : []
                    delegate: Rectangle {
                        width: table.width; height: 36; color: index % 2 === 0 ? "#ffffff" : "#fafdfa"
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                        Row {
                            x: 16; width: parent.width - 32; spacing: 0
                            Repeater {
                                model: modelData
                                delegate: Text {
                                    text: (modelData === null || modelData === undefined) ? "—" : modelData.toString()
                                    width: Math.max(100, (parent.width - 32) / (page.reportData ? page.reportData.columnCount : 1))
                                    height: 36; verticalAlignment: Text.AlignVCenter
                                    font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textPrimary
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                // Empty state
                Item { Layout.fillWidth: true; Layout.fillHeight: true; visible: !page.reportData || page.reportData.rowCount === 0
                    Column { anchors.centerIn: parent; spacing: 8
                        Text { text: "No data"; font.family: Theme.activeFontFamily; font.pixelSize: 14; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Select a report and click Generate"; font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter } } }

                // Footer with count
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 36; color: Theme.surfaceHover
                    Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    Text { anchors.centerIn: parent; text: page.reportData ? (page.reportData.rowCount + " rows") : ""; font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary } }
            }
        }
    }
}
