import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MMS.Theme 1.0
import QtQuick.Effects
import "../components"

// ============================================================================
// DesignPreview — Visual evaluation of the MMS design system
//
// Shows every component in every state so you can evaluate the visual
// quality before we use these components in the real application.
//
// This is NOT a production screen. It's a design review tool.
// ============================================================================

ApplicationWindow {
    id: window
    visible: true
    width: 960
    height: 720
    minimumWidth: 800
    minimumHeight: 600
    title: "MMS Design System — Phase 3 Preview"
    color: Theme.background

    // ===== Scrollable content =====
    ScrollView {
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            width: window.width
            spacing: 0

            // ===== Header =====
            Rectangle {
                width: parent.width
                height: 80
                color: Theme.surface

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Theme.borderSubtle
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spaceXl
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: "MMS Design System"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeXl
                        font.weight: Theme.fontWeightSemiBold
                        color: Theme.textPrimary
                    }
                    Text {
                        text: "Phase 3 — Visual preview for evaluation"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.textSecondary
                    }
                }
            }

            // ===== Body =====
            Column {
                width: window.width - 2 * Theme.spaceXl
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                leftPadding: Theme.spaceXl
                rightPadding: Theme.spaceXl
                topPadding: Theme.spaceXl
                bottomPadding: Theme.space2xl
                spacing: Theme.space2xl

                // ═══════════════════════════════════════════
                // SECTION: COLOR PALETTE
                // ═══════════════════════════════════════════
                SectionHeader { title: "Color Palette"; subtitle: "Brand, semantic, and surface colors" }

                GridLayout {
                    columns: 6
                    columnSpacing: Theme.spaceMd
                    rowSpacing: Theme.spaceMd

                    ColorSwatch { name: "Background";     color: Theme.background }
                    ColorSwatch { name: "Surface";        color: Theme.surface }
                    ColorSwatch { name: "Surface Hover";  color: Theme.surfaceHover }
                    ColorSwatch { name: "Surface Pressed"; color: Theme.surfacePressed }
                    ColorSwatch { name: "Border";         color: Theme.border }
                    ColorSwatch { name: "Border Subtle";  color: Theme.borderSubtle }

                    ColorSwatch { name: "Primary";        color: Theme.primary }
                    ColorSwatch { name: "Primary Hover";  color: Theme.primaryHover }
                    ColorSwatch { name: "Primary Pressed"; color: Theme.primaryPressed }
                    ColorSwatch { name: "Primary Subtle"; color: Theme.primarySubtle }
                    ColorSwatch { name: "Accent";         color: Theme.accent }
                    ColorSwatch { name: "Accent Hover";   color: Theme.accentHover }

                    ColorSwatch { name: "Danger";         color: Theme.danger }
                    ColorSwatch { name: "Danger Hover";   color: Theme.dangerHover }
                    ColorSwatch { name: "Success";        color: Theme.success }
                    ColorSwatch { name: "Warning";        color: Theme.warning }
                    ColorSwatch { name: "Info";           color: Theme.info }
                    ColorSwatch { name: "Text Primary";   color: Theme.textPrimary }
                }

                // ═══════════════════════════════════════════
                // SECTION: TYPOGRAPHY
                // ═══════════════════════════════════════════
                SectionHeader { title: "Typography"; subtitle: "Poppins family — size and weight hierarchy" }

                Column {
                    spacing: Theme.spaceSm
                    width: parent.width

                    TypographyRow { label: "Display 32px Bold";     size: Theme.fontSize3xl; weight: Theme.fontWeightBold }
                    TypographyRow { label: "Heading 24px SemiBold";  size: Theme.fontSize2xl; weight: Theme.fontWeightSemiBold }
                    TypographyRow { label: "Title 18px SemiBold";    size: Theme.fontSizeXl;  weight: Theme.fontWeightSemiBold }
                    TypographyRow { label: "Section 15px SemiBold";  size: Theme.fontSizeLg;  weight: Theme.fontWeightSemiBold }
                    TypographyRow { label: "Body 13px Regular";      size: Theme.fontSizeMd;  weight: Theme.fontWeightRegular }
                    TypographyRow { label: "Label 12px Medium";      size: Theme.fontSizeSm;  weight: Theme.fontWeightMedium }
                    TypographyRow { label: "Caption 11px Regular";   size: Theme.fontSizeXs;  weight: Theme.fontWeightRegular }
                }

                // ═══════════════════════════════════════════
                // SECTION: BUTTONS
                // ═══════════════════════════════════════════
                SectionHeader { title: "Buttons"; subtitle: "Hover, press, and focus each variant to see states" }

                Column {
                    spacing: Theme.spaceMd
                    width: parent.width

                    // Row 1: Normal (interactive)
                    LabeledRow {
                        label: "Normal"
                        Row {
                            spacing: Theme.spaceMd
                            AppButton { text: "Primary"; variant: "primary" }
                            AppButton { text: "Secondary"; variant: "secondary" }
                            AppButton { text: "Ghost"; variant: "ghost" }
                            AppButton { text: "Danger"; variant: "danger" }
                        }
                    }

                    // Row 2: With icons
                    LabeledRow {
                        label: "With icons"
                        Row {
                            spacing: Theme.spaceMd
                            AppButton { text: "Add Family"; variant: "primary"; iconSource: "qrc:/icons/svg/plus.svg" }
                            AppButton { text: "Edit"; variant: "secondary"; iconSource: "qrc:/icons/svg/edit.svg" }
                            AppButton { text: "Delete"; variant: "danger"; iconSource: "qrc:/icons/svg/trash.svg" }
                        }
                    }

                    // Row 3: Disabled
                    LabeledRow {
                        label: "Disabled"
                        Row {
                            spacing: Theme.spaceMd
                            AppButton { text: "Primary"; variant: "primary"; enabled: false }
                            AppButton { text: "Secondary"; variant: "secondary"; enabled: false }
                            AppButton { text: "Ghost"; variant: "ghost"; enabled: false }
                            AppButton { text: "Danger"; variant: "danger"; enabled: false }
                        }
                    }

                    // Row 4: Error state
                    LabeledRow {
                        label: "Error state"
                        Row {
                            spacing: Theme.spaceMd
                            AppButton { text: "Primary"; variant: "primary"; showError: true }
                            AppButton { text: "Secondary"; variant: "secondary"; showError: true }
                        }
                    }
                }

                // ═══════════════════════════════════════════
                // SECTION: TEXT FIELDS
                // ═══════════════════════════════════════════
                SectionHeader { title: "Text Fields"; subtitle: "Click to focus, hover to see border change" }

                Column {
                    spacing: Theme.spaceMd
                    width: parent.width

                    LabeledRow {
                        label: "Normal"
                        Row {
                            spacing: Theme.spaceLg
                            AppTextField { label: "House Name"; placeholderText: "e.g. Manzil Manzoor"; required: true }
                            AppTextField { label: "Phone"; placeholderText: "10-digit mobile" }
                        }
                    }

                    LabeledRow {
                        label: "With helper text"
                        AppTextField {
                            label: "Email"
                            placeholderText: "name@example.com"
                            helperText: "We'll never share your email"
                            width: 280
                        }
                    }

                    LabeledRow {
                        label: "Error state"
                        AppTextField {
                            label: "Phone"
                            placeholderText: "9847123456"
                            text: "123"
                            error: true
                            errorText: "Enter a valid 10-digit number"
                            width: 280
                        }
                    }

                    LabeledRow {
                        label: "Disabled"
                        AppTextField {
                            label: "Family Number"
                            text: "KH-F-0001"
                            enabled: false
                            width: 280
                        }
                    }
                }

                // ═══════════════════════════════════════════
                // SECTION: COMBO BOXES
                // ═══════════════════════════════════════════
                SectionHeader { title: "Combo Boxes"; subtitle: "Click to open dropdown" }

                Column {
                    spacing: Theme.spaceMd
                    width: parent.width

                    LabeledRow {
                        label: "Normal"
                        Row {
                            spacing: Theme.spaceLg
                            AppComboBox {
                                label: "Status"
                                model: ["Active", "Inactive", "Archived"]
                                width: 200
                            }
                            AppComboBox {
                                label: "Ward"
                                model: ["Ward 1", "Ward 2", "Ward 3", "Ward 4"]
                                width: 200
                            }
                        }
                    }

                    LabeledRow {
                        label: "With helper"
                        AppComboBox {
                            label: "Payment Method"
                            model: ["Cash", "UPI", "Cheque", "Bank Transfer"]
                            helperText: "Select how the payment was received"
                            width: 240
                        }
                    }

                    LabeledRow {
                        label: "Error state"
                        AppComboBox {
                            label: "Category"
                            model: ["General", "Sponsorship", "Zakat"]
                            error: true
                            helperText: "Please select a category"
                            width: 240
                        }
                    }
                }

                // ═══════════════════════════════════════════
                // SECTION: ICON BUTTONS
                // ═══════════════════════════════════════════
                SectionHeader { title: "Icon Buttons"; subtitle: "SVG icons tinted via MultiEffect" }

                Column {
                    spacing: Theme.spaceMd
                    width: parent.width

                    LabeledRow {
                        label: "Compact (icon only)"
                        Row {
                            spacing: Theme.spaceSm
                            IconButton { iconName: "plus"; compact: true }
                            IconButton { iconName: "edit"; compact: true }
                            IconButton { iconName: "trash"; compact: true }
                            IconButton { iconName: "search"; compact: true }
                            IconButton { iconName: "check"; compact: true }
                            IconButton { iconName: "settings"; compact: true }
                            IconButton { iconName: "download"; compact: true }
                            IconButton { iconName: "refresh"; compact: true }
                        }
                    }

                    LabeledRow {
                        label: "With label"
                        Row {
                            spacing: Theme.spaceMd
                            IconButton { iconName: "plus"; text: "Add" }
                            IconButton { iconName: "edit"; text: "Edit" }
                            IconButton { iconName: "trash"; text: "Delete" }
                            IconButton { iconName: "download"; text: "Export" }
                            IconButton { iconName: "print"; text: "Print" }
                        }
                    }

                    LabeledRow {
                        label: "Disabled"
                        Row {
                            spacing: Theme.spaceSm
                            IconButton { iconName: "plus"; compact: true; enabled: false }
                            IconButton { iconName: "edit"; compact: true; enabled: false }
                            IconButton { iconName: "trash"; compact: true; enabled: false }
                        }
                    }
                }

                // ═══════════════════════════════════════════
                // SECTION: STATUS PILLS
                // ═══════════════════════════════════════════
                SectionHeader { title: "Status Pills"; subtitle: "Semantic status indicators" }

                Row {
                    spacing: Theme.spaceMd

                    StatusPill { text: "Active";   pillColor: Theme.success; subtleColor: Theme.successSubtle }
                    StatusPill { text: "Overdue";  pillColor: Theme.danger;  subtleColor: Theme.dangerSubtle }
                    StatusPill { text: "Pending";  pillColor: Theme.warning; subtleColor: Theme.warningSubtle }
                    StatusPill { text: "Paid";     pillColor: Theme.success; subtleColor: Theme.successSubtle }
                    StatusPill { text: "Archived"; pillColor: Theme.textSecondary; subtleColor: Theme.surfacePressed }
                }

                // ═══════════════════════════════════════════
                // SECTION: CARD SAMPLE
                // ═══════════════════════════════════════════
                SectionHeader { title: "Card Sample"; subtitle: "Typical content card with border and padding" }

                Rectangle {
                    width: parent.width
                    implicitHeight: cardContent.implicitHeight + 2 * Theme.spaceLg
                    radius: Theme.radiusLg
                    color: Theme.surface
                    border.width: 1
                    border.color: Theme.border

                    Column {
                        id: cardContent
                        anchors.fill: parent
                        anchors.margins: Theme.spaceLg
                        spacing: Theme.spaceMd

                        Row {
                            spacing: Theme.spaceMd

                            Rectangle {
                                width: 40; height: 40; radius: Theme.radiusMd
                                color: Theme.primarySubtle
                                border.width: 1; border.color: Theme.primary

                                Item {
                                    anchors.centerIn: parent
                                    width: 20; height: 20

                                    Image {
                                        id: cardIcon
                                        source: "qrc:/icons/svg/families.svg"
                                        sourceSize: Qt.size(20, 20)
                                        anchors.fill: parent
                                        visible: false
                                    }
                                    MultiEffect {
                                        anchors.fill: parent
                                        source: cardIcon
                                        colorizationColor: Theme.primary
                                        colorization: 1.0
                                    }
                                }
                            }

                            Column {
                                spacing: 2
                                Text {
                                    text: "Manzil Manzoor"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeLg
                                    font.weight: Theme.fontWeightSemiBold
                                    color: Theme.textPrimary
                                }
                                Text {
                                    text: "KH-F-0001 · Ward 1 · 5 members"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSm
                                    color: Theme.textSecondary
                                }
                            }
                            Item { width: 1; Layout.fillWidth: true; height: 1 }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.borderSubtle
                        }

                        Row {
                            spacing: Theme.spaceLg
                            Text {
                                text: "House: Manzil Manzoor"
                                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSm
                                color: Theme.textSecondary
                            }
                            Text {
                                text: "Phone: 9847123456"
                                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSm
                                color: Theme.textSecondary
                            }
                        }

                        Row {
                            spacing: Theme.spaceMd
                            AppButton { text: "Edit"; variant: "secondary"; iconSource: "qrc:/icons/svg/edit.svg" }
                            IconButton { iconName: "trash"; text: "Delete" }
                        }
                    }
                }
            }
        }
    }

    // ===== Reusable components (local to this preview) =====

    component SectionHeader: Column {
        property string title: ""
        property string subtitle: ""
        spacing: 2

        Text {
            text: parent.title
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLg
            font.weight: Theme.fontWeightSemiBold
            color: Theme.textPrimary
        }
        Text {
            text: parent.subtitle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSm
            color: Theme.textSecondary
        }
    }

    component ColorSwatch: Rectangle {
        property string name: ""
        property color swatchColor: "white"
        width: 120
        height: 70
        radius: Theme.radiusMd
        color: pillColor
        border.width: 1
        border.color: Theme.border

        Column {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 6
            spacing: 1

            Text {
                text: parent.parent.name
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeXs
                font.weight: Theme.fontWeightMedium
                color: Theme.textPrimary
            }
            Text {
                text: parent.parent.swatchColor.toString().toUpperCase()
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.textSecondary
            }
        }
    }

    component TypographyRow: Row {
        property string label: ""
        property int size: 13
        property int weight: Font.Normal
        spacing: Theme.spaceXl

        Text {
            text: parent.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            color: Theme.textTertiary
            width: 180
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: "The quick brown fox jumps over the lazy dog"
            font.family: Theme.fontFamily
            font.pixelSize: parent.size
            font.weight: parent.weight
            color: Theme.textPrimary
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    component LabeledRow: Row {
        property string label: ""
        spacing: Theme.spaceXl

        Text {
            text: parent.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            color: Theme.textTertiary
            width: 120
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    component StatusPill: Rectangle {
        property string text: ""
        property color pillColor: Theme.success
        property color subtleColor: Theme.successSubtle
        implicitHeight: 24
        implicitWidth: pillText.implicitWidth + 24
        radius: 12
        color: subtleColor
        border.width: 1
        border.color: pillColor

        Text {
            id: pillText
            anchors.centerIn: parent
            text: parent.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeXs
            font.weight: Theme.fontWeightSemiBold
            color: pillColor
        }
    }
}
