import QtQuick
import QtQuick.Controls
import MMS.Theme 1.0
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

// ============================================================================
// CertificatesPage — Issue certificates (Membership/Residence/Marriage/Death)
// + list + delete + generate PDF + export CSV
// ============================================================================

Item {
    id: page

    property var certificates: []
    property int currentPage: 1
    property int pageSize: 25
    property string typeFilter: ""
    property string dateFrom: ""
    property string dateTo: ""

    Component.onCompleted: refresh()

    function refresh() {
        certificates = CertificateController.list(currentPage, pageSize, typeFilter, dateFrom, dateTo)
    }

    // Issue dialog
    ModalDialog {
        id: issueDialog
        modalWidth: 480; modalHeight: 280
        closeOnBackdrop: true; closeOnEscape: true
        property string certType: "Membership"
        property string labelText: "Member Code"
        property string placeholderText: "MBR-0001"

        content: Component {
            Rectangle {
                anchors.fill: parent; color: Theme.surface; radius: 12; clip: true
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 24; spacing: 16

                    Text { text: "Issue " + issueDialog.certType + " Certificate"; font.family: Theme.activeFontFamily; font.pixelSize: 16; font.weight: Font.DemiBold; color: Theme.textPrimary }
                    Text { text: "Enter the " + issueDialog.labelText.toLowerCase() + " to issue a " + issueDialog.certType.toLowerCase() + " certificate:"; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textTertiary; Layout.fillWidth: true; wrapMode: Text.Wrap }

                    AppTextField { id: codeInput; Layout.fillWidth: true; label: issueDialog.labelText; placeholderText: issueDialog.placeholderText }

                    // Extra field for Residence (issued to name)
                    AppTextField { id: issuedToInput; Layout.fillWidth: true; visible: issueDialog.certType === "Residence"; label: "Issued To (name)"; placeholderText: "Person's name (optional)" }

                    Item { Layout.fillHeight: true; Layout.fillWidth: true }

                    Row { spacing: 10; layoutDirection: Qt.RightToLeft
                        AppButton { text: "Cancel"; variant: "secondary"; onClicked: issueDialog.visible = false }
                        AppButton { text: "Issue Certificate"; variant: "primary"; iconName: "check"; onClicked: {
                            var result
                            if (issueDialog.certType === "Membership") result = CertificateController.issueMembership(codeInput.text)
                            else if (issueDialog.certType === "Residence") result = CertificateController.issueResidence(codeInput.text, issuedToInput.text)
                            else if (issueDialog.certType === "Marriage") result = CertificateController.issueMarriage(codeInput.text)
                            else if (issueDialog.certType === "Death") result = CertificateController.issueDeath(codeInput.text)

                            if (result.success) {
                                toast.show(issueDialog.certType + " certificate issued: " + result.certificateNumber, "#059669")
                                // Generate PDF
                                var pdfPath = CertificateController.generatePdf(result.id)
                                if (pdfPath && pdfPath.length > 0) toast.show("PDF generated: " + pdfPath, "#059669")
                                issueDialog.visible = false
                                page.refresh()
                            } else {
                                toast.show(result.error || "Issue failed", "#e11d48")
                            }
                        } }
                    }
                }
            }
        }
    }

    ConfirmDialog {
        id: deleteDialog
        message: "Delete Certificate?"
        warningText: "This certificate record will be permanently deleted."
        property int _id: 0
        onAccepted: {
            if (_id > 0) {
                var ok = CertificateController.remove(_id)
                toast.show(ok ? "Certificate deleted" : "Delete failed", ok ? "#059669" : "#e11d48")
                if (ok) page.refresh()
            }
        }
    }

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
        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Column { Layout.fillWidth: true; spacing: 2
                Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("cert_title") }; font.family: Theme.activeFontFamily; font.pixelSize: 21; font.weight: Font.DemiBold; color: Theme.textPrimary }
                Text { text: "Issue and manage certificates with PDF generation"; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary } }
        }

        // Issue buttons row
        RowLayout {
            Layout.fillWidth: true; spacing: 10
            AppButton { text: "Membership"; variant: "primary"; iconName: "certificates"; onClicked: { issueDialog.certType = "Membership"; issueDialog.labelText = "Member Code"; issueDialog.placeholderText = "MBR-0001"; issueDialog.visible = true } }
            AppButton { text: "Residence"; variant: "secondary"; iconName: "families"; onClicked: { issueDialog.certType = "Residence"; issueDialog.labelText = "Family Number"; issueDialog.placeholderText = "FAM-0001"; issueDialog.visible = true } }
            AppButton { text: "Marriage"; variant: "secondary"; iconName: "marriage"; onClicked: { issueDialog.certType = "Marriage"; issueDialog.labelText = "Marriage Number"; issueDialog.placeholderText = "MRG-2026-001"; issueDialog.visible = true } }
            AppButton { text: "Death"; variant: "secondary"; iconName: "death"; onClicked: { issueDialog.certType = "Death"; issueDialog.labelText = "Death Number"; issueDialog.placeholderText = "DTH-2026-001"; issueDialog.visible = true } }
            Item { Layout.fillWidth: true }
            AppButton { text: "Export CSV"; variant: "secondary"; iconName: "download"; onClicked: {
                var dir = CertificateController.exportDir()
                var path = CertificateController.exportToCsv(dir + "/certificates.csv")
                toast.show(path && path.length > 0 ? "Exported: " + path : "Export failed", path && path.length > 0 ? "#059669" : "#e11d48")
            } }
        }

        // Filter row
        RowLayout {
            Layout.fillWidth: true; spacing: 10
            AppComboBox { model: ["All Types", "Membership", "Residence", "Marriage", "Death", "Character", "Income"]; implicitHeight: 38; onActivated: function(index) { typeFilter = index === 0 ? "" : model[index]; currentPage = 1; refresh() } }
            Item { Layout.fillWidth: true }
            Text { text: "Showing " + certificates.length + " certificates"; font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary; Layout.alignment: Qt.AlignVCenter }
        }

        // Table
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 10; color: Theme.surface; border.width: 1; border.color: Theme.border
            ColumnLayout { anchors.fill: parent; spacing: 0
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 40; color: Theme.surfaceHover
                    Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.border }
                    Row { x: 16; width: parent.width - 32; spacing: 0
                        Text { text: "CERT NO"; width: 150; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "TYPE"; width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "ISSUED TO"; width: 250; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "DATE"; width: 120; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Text { text: "ISSUED BY"; width: 150; height: 40; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary }
                        Item { width: parent.width - 150 - 120 - 250 - 120 - 150 - 80; height: 40 }
                        Text { text: "ACTIONS"; width: 80; height: 40; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; font.family: Theme.activeFontFamily; font.pixelSize: 10; font.weight: Font.Medium; color: Theme.textTertiary } } }
                ListView { id: table; Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 0; model: page.certificates
                    delegate: Rectangle { width: table.width; height: 44; color: rowMA.containsMouse ? "#f2faf4" : (index % 2 === 0 ? "#ffffff" : "#fafdfa")
                        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: Theme.surfacePressed }
                        Row { x: 16; width: parent.width - 32; spacing: 0
                            Text { text: modelData.certificateNumber; width: 150; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; font.weight: Font.DemiBold; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: modelData.type; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary }
                            Text { text: modelData.issuedTo; width: 250; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textPrimary; elide: Text.ElideRight }
                            Text { text: modelData.issuedDate; width: 120; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary }
                            Text { text: modelData.issuedByName || "—"; width: 150; height: 44; verticalAlignment: Text.AlignVCenter; font.family: Theme.activeFontFamily; font.pixelSize: 12; color: Theme.textSecondary; elide: Text.ElideRight }
                            Item { width: parent.width - 150 - 120 - 250 - 120 - 150 - 80; height: 44 }
                            Row { width: 80; height: 44; spacing: 4; layoutDirection: Qt.RightToLeft
                                TableActionButton { iconSource: "qrc:/icons/svg/trash.svg"; variantColor: "#e11d48"; anchors.verticalCenter: parent.verticalCenter; onClicked: { deleteDialog._id = modelData.id; deleteDialog.warningText = "Certificate " + modelData.certificateNumber + " will be permanently deleted."; deleteDialog.visible = true } }
                                TableActionButton { iconSource: "qrc:/icons/svg/print.svg"; variantColor: "#7c3aed"; anchors.verticalCenter: parent.verticalCenter; onClicked: { var p = CertificateController.generatePdf(modelData.id); toast.show(p && p.length > 0 ? "PDF: " + p : "PDF failed", p && p.length > 0 ? "#059669" : "#e11d48") } }
                            } }
                        MouseArea { id: rowMA; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton } } }
                Item { Layout.fillWidth: true; Layout.fillHeight: true; visible: page.certificates.length === 0
                    Column { anchors.centerIn: parent; spacing: 8
                        Text { text: "No certificates found"; font.family: Theme.activeFontFamily; font.pixelSize: 14; font.weight: Font.DemiBold; color: Theme.textPrimary; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Click an issue button above to create a certificate"; font.family: Theme.activeFontFamily; font.pixelSize: 11; color: Theme.textTertiary; anchors.horizontalCenter: parent.horizontalCenter } } }
            }
        }
    }

}
