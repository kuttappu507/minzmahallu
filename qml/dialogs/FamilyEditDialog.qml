import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

// ============================================================================
// FamilyEditDialog - Add/Edit a family
// ============================================================================
Dialog {
    id: root
    title: familyId > 0 ? "Edit Family" : "Add Family"
    width: 640
    height: 620
    acceptLabel: "Save Family"

    property qint64 familyId: 0
    property var services: null
    property var onSaved: null
    property string familyNumberField: ""

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 20
        Layout.rightMargin: 20
        Layout.topMargin: 18
        Layout.bottomMargin: 18
        spacing: 12

        FormField {
            label: "FAMILY NUMBER"
            textField.readOnly: true
            text: root.familyNumberField
            helperText: "Auto-generated"
        }

        FormField { id: houseNameField; label: "HOUSE NAME"; required: true; placeholderText: "e.g. Manzil Manzoor" }

        RowLayout {
            Layout.fillWidth: true; spacing: 12
            FormField { id: houseNumberField; label: "HOUSE NUMBER"; placeholderText: "e.g. 14A" }
            FormField { id: wardField; label: "WARD"; placeholderText: "e.g. Ward 1" }
        }

        FormField { id: areaField; label: "AREA"; placeholderText: "e.g. Kondotty" }

        ColumnLayout {
            Layout.fillWidth: true; spacing: 4
            Text { text: "ADDRESS"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
            TextArea {
                id: addressField
                Layout.fillWidth: true; Layout.preferredHeight: 60
                font.family: Theme.fontPrimary; font.pixelSize: 12; color: Theme.text
                background: Rectangle { color: Theme.panel; border.width: 1; border.color: addressField.activeFocus ? Theme.sidebar : Theme.border; radius: 6 }
                padding: 10; wrapMode: TextArea.Wrap
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 12
            FormField { id: pincodeField; label: "PINCODE"; placeholderText: "6-digit code" }
            FormField { id: phoneField; label: "PHONE"; placeholderText: "10-digit mobile" }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 12
            FormField { id: altPhoneField; label: "ALT PHONE"; placeholderText: "Optional" }
            ColumnLayout {
                Layout.fillWidth: true; spacing: 4
                Text { text: "STATUS"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
                ComboBox {
                    id: statusField
                    Layout.fillWidth: true; Layout.preferredHeight: 36
                    model: ["Active", "Inactive", "Archived"]
                    font.family: Theme.fontPrimary; font.pixelSize: 12
                }
            }
        }

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

        var data = {
            familyNumber: root.familyNumberField,
            houseName: houseNameField.text,
            houseNumber: houseNumberField.text,
            ward: wardField.text,
            area: areaField.text,
            address: addressField.text,
            pincode: pincodeField.text,
            phone: phoneField.text,
            alternativePhone: altPhoneField.text,
            status: statusField.currentText,
            notes: notesField.text
        }

        var newId = 0
        if (familyId > 0) {
            services.updateFamily(familyId, data)
            newId = familyId
        } else {
            newId = services.createFamily(data)
        }

        if (newId > 0 && onSaved) onSaved(newId)
    }

    Component.onCompleted: {
        if (familyId > 0 && services) {
            var f = services.getFamily(familyId)
            root.familyNumberField = f.familyNumber || ""
            houseNameField.text = f.houseName || ""
            houseNumberField.text = f.houseNumber || ""
            wardField.text = f.ward || ""
            areaField.text = f.area || ""
            addressField.text = f.address || ""
            pincodeField.text = f.pincode || ""
            phoneField.text = f.phone || ""
            altPhoneField.text = f.alternativePhone || ""
            statusField.currentIndex = ["Active", "Inactive", "Archived"].indexOf(f.status || "Active")
            notesField.text = f.notes || ""
        }
    }
}
