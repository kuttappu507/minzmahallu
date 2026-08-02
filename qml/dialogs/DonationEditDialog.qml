import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

// ============================================================================
// DonationEditDialog - Add/Edit a donation
// ============================================================================
Dialog {
    id: root
    title: donationId > 0 ? "Edit Donation" : "Add Donation"
    width: 540
    height: 560
    acceptLabel: "Save Donation"

    property qint64 donationId: 0
    property var services: null
    property var onSaved: null

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 20
        Layout.rightMargin: 20
        Layout.topMargin: 18
        Layout.bottomMargin: 18
        spacing: 12

        FormField {
            id: receiptField
            label: "RECEIPT NUMBER"
            textField.readOnly: true
            helperText: "Auto-generated"
        }

        FormField {
            id: donorNameField
            label: "DONOR NAME"
            required: true
            placeholderText: "e.g. Rahim PT"
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 12
            FormField { id: donorPhoneField; label: "DONOR PHONE"; placeholderText: "10-digit mobile" }
            FormField { id: amountField; label: "AMOUNT (Rs)"; required: true; placeholderText: "e.g. 5000" }
        }

        ColumnLayout {
            Layout.fillWidth: true; spacing: 4
            Text { text: "CATEGORY"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
            ComboBox {
                id: categoryField
                Layout.fillWidth: true; Layout.preferredHeight: 36
                model: services ? services.donationCategories.map(function(c) { return c.name }) : ["General", "Sponsorship", "Zakat", "Construction", "Ramadan", "Education"]
                font.family: Theme.fontPrimary; font.pixelSize: 12
            }
        }

        FormField {
            id: dateField
            label: "DONATION DATE"
            placeholderText: "YYYY-MM-DD"
            text: Qt.formatDate(new Date(), "yyyy-MM-dd")
        }

        ColumnLayout {
            Layout.fillWidth: true; spacing: 4
            Text { text: "PAYMENT METHOD"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
            ComboBox {
                id: paymentMethodField
                Layout.fillWidth: true; Layout.preferredHeight: 36
                model: ["Cash", "UPI", "Cheque", "Bank Transfer"]
                font.family: Theme.fontPrimary; font.pixelSize: 12
            }
        }

        FormField { id: purposeField; label: "PURPOSE"; placeholderText: "e.g. Ramadan sponsorship" }

        ColumnLayout {
            Layout.fillWidth: true; spacing: 4
            Text { text: "NOTES"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
            TextArea {
                id: notesField
                Layout.fillWidth: true; Layout.preferredHeight: 50
                font.family: Theme.fontPrimary; font.pixelSize: 12; color: Theme.text
                background: Rectangle { color: Theme.panel; border.width: 1; border.color: notesField.activeFocus ? Theme.sidebar : Theme.border; radius: 6 }
                padding: 10; wrapMode: TextArea.Wrap
            }
        }
    }

    onAccepted: {
        if (!services) return

        var cats = services.donationCategories
        var selCat = cats.find(function(c) { return c.name === categoryField.currentText }) || { id: 1 }

        var data = {
            donorName: donorNameField.text,
            donorPhone: donorPhoneField.text,
            amount: parseFloat(amountField.text) || 0,
            categoryId: selCat.id,
            donationDate: dateField.text,
            paymentMethod: paymentMethodField.currentText,
            purpose: purposeField.text,
            notes: notesField.text
        }

        var newId = 0
        if (donationId > 0) {
            services.updateDonation(donationId, data)
            newId = donationId
        } else {
            newId = services.createDonation(data)
        }

        if (newId > 0 && onSaved) onSaved(newId)
    }

    Component.onCompleted: {
        if (services) {
            receiptField.text = services.nextDonationReceiptNumber()
        }
    }
}
