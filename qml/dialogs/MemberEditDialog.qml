import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

// ============================================================================
// MemberEditDialog - Add/Edit a member
// ============================================================================
Dialog {
    id: root
    title: memberId > 0 ? "Edit Member" : "Add Member"
    width: 680
    height: 700
    acceptLabel: "Save Member"

    property qint64 memberId: 0
    property qint64 presetFamilyId: 0
    property var services: null
    property var onSaved: null

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 20
        Layout.rightMargin: 20
        Layout.topMargin: 18
        Layout.bottomMargin: 18
        spacing: 12

        // Family ID + Member code
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            FormField { id: familyIdField; label: "FAMILY ID"; placeholderText: "1"; text: root.presetFamilyId > 0 ? String(root.presetFamilyId) : "" }
            FormField { id: memberCodeField; label: "MEMBER CODE"; placeholderText: "Auto" }
        }

        // Name (required)
        FormField { id: nameField; label: "FULL NAME"; required: true; placeholderText: "e.g. Manzoor PP" }

        // Arabic name + Gender
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            FormField { id: arabicNameField; label: "ARABIC NAME"; placeholderText: "Optional" }
            ColumnLayout {
                Layout.fillWidth: true; spacing: 4
                Text { text: "GENDER"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
                ComboBox { id: genderField; Layout.fillWidth: true; Layout.preferredHeight: 36; model: ["Male", "Female"]; font.family: Theme.fontPrimary; font.pixelSize: 12 }
            }
        }

        // DOB + Age
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            FormField { id: dobField; label: "DATE OF BIRTH"; placeholderText: "YYYY-MM-DD" }
            FormField { id: ageField; label: "AGE"; placeholderText: "45" }
        }

        // Blood group + Marital status
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout {
                Layout.fillWidth: true; spacing: 4
                Text { text: "BLOOD GROUP"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
                ComboBox { id: bloodGroupField; Layout.fillWidth: true; Layout.preferredHeight: 36; model: ["", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]; font.family: Theme.fontPrimary; font.pixelSize: 12 }
            }
            ColumnLayout {
                Layout.fillWidth: true; spacing: 4
                Text { text: "MARITAL STATUS"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
                ComboBox { id: maritalStatusField; Layout.fillWidth: true; Layout.preferredHeight: 36; model: ["Single", "Married", "Divorced", "Widowed"]; font.family: Theme.fontPrimary; font.pixelSize: 12 }
            }
        }

        // Occupation + Education
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            FormField { id: occupationField; label: "OCCUPATION"; placeholderText: "e.g. Business" }
            FormField { id: educationField; label: "EDUCATION"; placeholderText: "e.g. B.Com" }
        }

        // Mobile + Email
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            FormField { id: mobileField; label: "MOBILE"; placeholderText: "10-digit" }
            FormField { id: emailField; label: "EMAIL"; placeholderText: "name@example.com" }
        }

        // Relationship + Status
        RowLayout {
            Layout.fillWidth: true; spacing: 12
            ColumnLayout {
                Layout.fillWidth: true; spacing: 4
                Text { text: "RELATIONSHIP"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
                ComboBox { id: relationshipField; Layout.fillWidth: true; Layout.preferredHeight: 36; model: ["Head", "Spouse", "Son", "Daughter", "Parent", "Other"]; font.family: Theme.fontPrimary; font.pixelSize: 12 }
            }
            ColumnLayout {
                Layout.fillWidth: true; spacing: 4
                Text { text: "STATUS"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
                ComboBox { id: statusField; Layout.fillWidth: true; Layout.preferredHeight: 36; model: ["Active", "Inactive"]; font.family: Theme.fontPrimary; font.pixelSize: 12 }
            }
        }

        // Address
        ColumnLayout {
            Layout.fillWidth: true; spacing: 4
            Text { text: "ADDRESS"; font.family: Theme.fontPrimary; font.pixelSize: 10; font.weight: Font.Black; color: Theme.muted }
            TextArea {
                id: addressField
                Layout.fillWidth: true; Layout.preferredHeight: 50
                font.family: Theme.fontPrimary; font.pixelSize: 12; color: Theme.text
                background: Rectangle { color: Theme.panel; border.width: 1; border.color: addressField.activeFocus ? Theme.sidebar : Theme.border; radius: 6 }
                padding: 10; wrapMode: TextArea.Wrap
            }
        }
    }

    onAccepted: {
        if (!services) return

        var data = {
            familyId: parseInt(familyIdField.text) || 0,
            memberCode: memberCodeField.text,
            name: nameField.text,
            arabicName: arabicNameField.text,
            gender: genderField.currentText,
            dateOfBirth: dobField.text,
            age: parseInt(ageField.text) || 0,
            bloodGroup: bloodGroupField.currentText,
            occupation: occupationField.text,
            education: educationField.text,
            maritalStatus: maritalStatusField.currentText,
            mobile: mobileField.text,
            email: emailField.text,
            relationship: relationshipField.currentText,
            status: statusField.currentText,
            address: addressField.text
        }

        var newId = 0
        if (memberId > 0) {
            services.updateMember(memberId, data)
            newId = memberId
        } else {
            newId = services.createMember(data)
        }

        if (newId > 0 && onSaved) onSaved(newId)
    }

    Component.onCompleted: {
        if (memberId > 0 && services) {
            var m = services.getMember(memberId)
            familyIdField.text = m.familyId || ""
            memberCodeField.text = m.memberCode || ""
            nameField.text = m.name || ""
            arabicNameField.text = m.arabicName || ""
            genderField.currentIndex = ["Male", "Female"].indexOf(m.gender || "Male")
            dobField.text = m.dateOfBirth || ""
            ageField.text = m.age || ""
            bloodGroupField.currentIndex = ["", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"].indexOf(m.bloodGroup || "")
            maritalStatusField.currentIndex = ["Single", "Married", "Divorced", "Widowed"].indexOf(m.maritalStatus || "Single")
            occupationField.text = m.occupation || ""
            educationField.text = m.education || ""
            mobileField.text = m.mobile || ""
            emailField.text = m.email || ""
            relationshipField.currentIndex = ["Head", "Spouse", "Son", "Daughter", "Parent", "Other"].indexOf(m.relationship || "Head")
            statusField.currentIndex = ["Active", "Inactive"].indexOf(m.status || "Active")
            addressField.text = m.address || ""
        }
    }
}
