pragma Singleton
import QtQuick

// ============================================================================
// Theme.qml — Centralized design system for MMS
//
// All colors, typography, spacing, radii, and animation tokens live here.
// Components reference these values — never hardcode colors elsewhere.
//
// Design language: polished modern Windows desktop (Windows 11 inspired)
//   - Emerald brand palette (#059669)
//   - Compact desktop spacing (not mobile)
//   - Subtle borders, restrained radii
//   - Smooth micro-animations (100-150ms)
// ============================================================================

QtObject {
    // ===== COLORS — Backgrounds =====
    readonly property color background:       "#f5f7fa"   // app background (mica-like light gray)
    readonly property color surface:          "#ffffff"   // cards, inputs, panels
    readonly property color surfaceHover:     "#f0f2f5"   // hover background for items
    readonly property color surfacePressed:   "#e8eaed"   // pressed background
    readonly property color surfaceSubtle:    "#f8f9fb"   // alternating rows, subtle panels

    // ===== COLORS — Brand (Emerald) =====
    readonly property color primary:          "#059669"   // buttons, active states
    readonly property color primaryHover:     "#047857"
    readonly property color primaryPressed:   "#036049"
    readonly property color primarySubtle:    "#ecfdf5"   // light emerald tint for backgrounds
    readonly property color primaryOn:        "#ffffff"   // text/icon on primary color

    // ===== COLORS — Accent (Gold) =====
    readonly property color accent:           "#f2c14e"
    readonly property color accentHover:      "#e0ad3a"

    // ===== COLORS — Text =====
    readonly property color textPrimary:      "#1a1d23"   // body text, headings
    readonly property color textSecondary:    "#5f6368"   // labels, secondary info
    readonly property color textTertiary:     "#9aa0a6"   // hints, placeholders
    readonly property color textDisabled:     "#bbbfc4"   // disabled controls
    readonly property color textOnPrimary:    "#ffffff"
    readonly property color textOnDark:       "#ffffff"

    // ===== COLORS — Borders =====
    readonly property color border:           "#dadce0"   // default border
    readonly property color borderHover:      "#bdc1c6"   // hover border
    readonly property color borderFocused:    "#059669"   // focused input border
    readonly property color borderSubtle:     "#eef0f3"   // very subtle dividers

    // ===== COLORS — Semantic =====
    readonly property color danger:           "#dc2626"
    readonly property color dangerHover:      "#b91c1c"
    readonly property color dangerPressed:    "#991b1b"
    readonly property color dangerSubtle:     "#fef2f2"
    readonly property color success:          "#16a34a"
    readonly property color successSubtle:    "#f0fdf4"
    readonly property color warning:          "#d97706"
    readonly property color warningSubtle:    "#fffbeb"
    readonly property color info:             "#0284c7"
    readonly property color infoSubtle:       "#f0f9ff"

    // ===== TYPOGRAPHY — Font families =====
    readonly property string fontFamily:      "Poppins"
    readonly property string fontFamilyMono:  "Cascadia Code"  // fallback to system mono

    // ===== TYPOGRAPHY — Font sizes =====
    readonly property int fontSizeXs:   11    // captions, helper text
    readonly property int fontSizeSm:   12    // labels, secondary text
    readonly property int fontSizeMd:   13    // body text, button labels (desktop default)
    readonly property int fontSizeLg:   15    // section headers
    readonly property int fontSizeXl:   18    // page titles
    readonly property int fontSize2xl:  24    // hero text
    readonly property int fontSize3xl:  32    // large display

    // ===== TYPOGRAPHY — Font weights =====
    readonly property int fontWeightRegular:   Font.Normal
    readonly property int fontWeightMedium:    Font.Medium
    readonly property int fontWeightSemiBold:  Font.DemiBold
    readonly property int fontWeightBold:      Font.Bold

    // ===== SPACING =====
    readonly property int spaceXs:   4
    readonly property int spaceSm:   8
    readonly property int spaceMd:   12
    readonly property int spaceLg:   16
    readonly property int spaceXl:   24
    readonly property int space2xl:  32
    readonly property int space3xl:  48

    // ===== RADII =====
    readonly property int radiusXs:  3
    readonly property int radiusSm:  4
    readonly property int radiusMd:  6    // buttons, inputs (desktop standard)
    readonly property int radiusLg:  8    // cards, panels
    readonly property int radiusXl:  12   // large containers

    // ===== SIZES — Controls =====
    readonly property int controlHeightSm:  28
    readonly property int controlHeightMd:  32    // standard desktop control height
    readonly property int controlHeightLg:  38
    readonly property int iconSizeSm:       14
    readonly property int iconSizeMd:       16
    readonly property int iconSizeLg:       20
    readonly property int iconSizeXl:       24

    // ===== ANIMATION =====
    readonly property int animFast:    100   // hover color transitions
    readonly property int animNormal:  150   // standard transitions
    readonly property int animSlow:    250   // layout changes

    // ===== EASING =====
    readonly property int easingStandard: Easing.OutCubic
    readonly property int easingEntrance: Easing.OutQuint
}
