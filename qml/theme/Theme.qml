pragma Singleton
import QtQuick

// ============================================================================
// Theme.qml — Minz Mahallu Design System
//
// Colorful + Modern + Premium + Clean Desktop Management Application
//
// Color strategy:
//   - Navy sidebar (deep, authoritative)
//   - Cool light canvas (blue-gray neutral, not pure white)
//   - White cards with subtle borders + very subtle shadows
//   - 6 coordinated accent colors, each with a purpose:
//       Emerald  → Families / Brand
//       Blue     → Members
//       Orange   → Nikah / Marriage
//       Violet   → Collections / Finance
//       Cyan     → Events / Tokens
//       Coral    → Errors / Overdue
//   - 70-80% neutral surfaces, 20-30% accent color
// ============================================================================

QtObject {
    // ===== CANVAS =====
    readonly property color canvas:          "#eef1f6"   // app background (cool blue-gray)
    readonly property color canvasAlt:       "#e6eaf1"   // slightly darker for contrast

    // ===== SURFACES =====
    readonly property color surface:         "#ffffff"   // cards, panels
    readonly property color surfaceHover:    "#f5f7fa"   // hover background
    readonly property color surfacePressed:  "#eceff3"   // pressed background
    readonly property color surfaceSubtle:   "#f8fafc"   // table alt rows, subtle panels
    readonly property color surfaceRaised:   "#ffffff"   // elevated cards (with shadow)

    // ===== NAVY SIDEBAR =====
    readonly property color sidebarBg:       "#0f172a"   // deep navy
    readonly property color sidebarBgAlt:    "#1e293b"   // slightly lighter navy for sections
    readonly property color sidebarHover:    "#1e293b"   // nav item hover
    readonly property color sidebarActive:   "#1e293b"   // nav item active background
    readonly property color sidebarBorder:   "#1e293b"   // subtle border on navy
    readonly property color sidebarText:     "#cbd5e1"   // primary nav text
    readonly property color sidebarTextActive: "#ffffff" // active nav text
    readonly property color sidebarTextMuted: "#64748b"  // section labels, metadata
    readonly property color sidebarLogo:     "#ffffff"   // logo text

    // ===== BRAND — Emerald =====
    readonly property color primary:         "#059669"
    readonly property color primaryHover:    "#047857"
    readonly property color primaryPressed:  "#036049"
    readonly property color primarySubtle:   "#ecfdf5"   // very light emerald
    readonly property color primarySubtleAlt:"#d1fae5"   // light emerald for badges
    readonly property color primaryOn:       "#ffffff"

    // ===== ACCENT — Blue (Members) =====
    readonly property color blue:            "#3b82f6"
    readonly property color blueHover:       "#2563eb"
    readonly property color blueSubtle:      "#eff6ff"
    readonly property color blueSubtleAlt:   "#dbeafe"

    // ===== ACCENT — Orange (Nikah) =====
    readonly property color orange:          "#f97316"
    readonly property color orangeHover:     "#ea580c"
    readonly property color orangeSubtle:    "#fff7ed"
    readonly property color orangeSubtleAlt: "#fed7aa"

    // ===== ACCENT — Violet (Collections) =====
    readonly property color violet:          "#8b5cf6"
    readonly property color violetHover:     "#7c3aed"
    readonly property color violetSubtle:    "#f5f3ff"
    readonly property color violetSubtleAlt: "#ddd6fe"

    // ===== ACCENT — Cyan (Events/Tokens) =====
    readonly property color cyan:            "#06b6d4"
    readonly property color cyanHover:       "#0891b2"
    readonly property color cyanSubtle:      "#ecfeff"
    readonly property color cyanSubtleAlt:   "#a5f3fc"

    // ===== ACCENT — Coral/Red (Errors/Overdue) =====
    readonly property color coral:           "#f43f5e"
    readonly property color coralHover:      "#e11d48"
    readonly property color coralSubtle:     "#fff1f2"
    readonly property color coralSubtleAlt:  "#fecdd3"

    // ===== SEMANTIC =====
    readonly property color success:         "#10b981"
    readonly property color successSubtle:   "#ecfdf5"
    readonly property color warning:         "#f59e0b"
    readonly property color warningSubtle:   "#fffbeb"
    readonly property color danger:          "#ef4444"
    readonly property color dangerHover:     "#dc2626"
    readonly property color dangerSubtle:    "#fef2f2"
    readonly property color info:            "#0ea5e9"
    readonly property color infoSubtle:      "#f0f9ff"

    // ===== TEXT =====
    readonly property color textPrimary:     "#0f172a"   // headings, body
    readonly property color textSecondary:   "#475569"   // labels, secondary
    readonly property color textTertiary:    "#94a3b8"   // hints, placeholders
    readonly property color textDisabled:    "#cbd5e1"   // disabled controls
    readonly property color textOnPrimary:   "#ffffff"
    readonly property color textOnDark:      "#ffffff"
    readonly property color textInverse:     "#ffffff"

    // ===== BORDERS =====
    readonly property color border:          "#e2e8f0"   // default border
    readonly property color borderHover:     "#cbd5e1"   // hover border
    readonly property color borderFocused:   "#059669"   // focused input
    readonly property color borderSubtle:    "#f1f5f9"   // very subtle dividers

    // ===== TYPOGRAPHY =====
    // Use "Segoe UI" on Windows (falls back to system sans on Linux)
    // Poppins kept for branding/display only
    readonly property string fontFamily:     "Segoe UI"
    readonly property string fontFamilyDisplay: "Poppins"  // for logo, big numbers
    readonly property string fontFamilyMono:  "Cascadia Code"

    // Font sizes
    readonly property int fontSizeXs:   11
    readonly property int fontSizeSm:   12
    readonly property int fontSizeMd:   13
    readonly property int fontSizeLg:   15
    readonly property int fontSizeXl:   18
    readonly property int fontSize2xl:  24
    readonly property int fontSize3xl:  30
    readonly property int fontSize4xl:  36

    // Font weights
    readonly property int fontWeightRegular:  Font.Normal
    readonly property int fontWeightMedium:   Font.Medium
    readonly property int fontWeightSemiBold: Font.DemiBold
    readonly property int fontWeightBold:     Font.Bold

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
    readonly property int radiusMd:  6
    readonly property int radiusLg:  8
    readonly property int radiusXl:  12
    readonly property int radius2xl: 16

    // ===== CONTROL SIZES =====
    readonly property int controlHeightSm:  28
    readonly property int controlHeightMd:  32
    readonly property int controlHeightLg:  36
    readonly property int sidebarWidth:     248

    // ===== ICON SIZES =====
    readonly property int iconSizeXs:   12
    readonly property int iconSizeSm:   14
    readonly property int iconSizeMd:   16
    readonly property int iconSizeLg:   20
    readonly property int iconSizeXl:   24
    readonly property int iconSize2xl:  32

    // ===== ANIMATIONS =====
    readonly property int animFast:    100
    readonly property int animNormal:  150
    readonly property int animSlow:    250
    readonly property int easingStandard: Easing.OutCubic
    readonly property int easingEntrance: Easing.OutQuint

    // ===== SHADOWS (subtle) =====
    readonly property color shadowColor:       "#94a3b8"
    readonly property real shadowOpacitySmall: 0.08
    readonly property real shadowOpacityMedium: 0.12
    readonly property real shadowOpacityLarge:  0.16

    // ===== ACCENT HELPER =====
    // Returns an accent object {main, hover, subtle, subtleAlt} by name
    function accent(name) {
        var accents = {
            "emerald": { main: primary, hover: primaryHover, subtle: primarySubtle, subtleAlt: primarySubtleAlt },
            "blue":    { main: blue,    hover: blueHover,    subtle: blueSubtle,    subtleAlt: blueSubtleAlt },
            "orange":  { main: orange,  hover: orangeHover,  subtle: orangeSubtle,  subtleAlt: orangeSubtleAlt },
            "violet":  { main: violet,  hover: violetHover,  subtle: violetSubtle,  subtleAlt: violetSubtleAlt },
            "cyan":    { main: cyan,    hover: cyanHover,    subtle: cyanSubtle,    subtleAlt: cyanSubtleAlt },
            "coral":   { main: coral,   hover: coralHover,   subtle: coralSubtle,   subtleAlt: coralSubtleAlt }
        }
        return accents[name] || accents.emerald
    }
}
