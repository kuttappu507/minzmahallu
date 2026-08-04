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
    // ===== CANVAS (matches HTML --bg) =====
    readonly property color canvas:          "#e7f4ea"   // light green-tinted background
    readonly property color canvasAlt:       "#eef8f1"   // slightly lighter

    // ===== SURFACES (matches HTML --panel, --panel2) =====
    readonly property color surface:         "#ffffff"   // cards, panels (--panel)
    readonly property color surfaceHover:    "#f2faf4"   // hover background (--panel2)
    readonly property color surfacePressed:  "#eef8f1"   // pressed background (--header)
    readonly property color surfaceSubtle:   "#f2faf4"   // table alt rows (--panel2)
    readonly property color surfaceRaised:   "#ffffff"   // elevated cards

    // ===== GREEN SIDEBAR (matches HTML gradient) =====
    readonly property color sidebarTop:      "#0a7f5d"   // gradient stop 0%
    readonly property color sidebarMid:      "#065f46"   // gradient stop 42%
    readonly property color sidebarBot:      "#044633"   // gradient stop 100%
    readonly property color sidebarHover:    "#ffffff14" // rgba(255,255,255,0.09)
    readonly property color sidebarActive:   "#ffffff24" // rgba(255,255,255,0.14)
    readonly property color sidebarBorder:   "#ffffff24" // rgba(255,255,255,0.14)
    readonly property color sidebarText:     "#c4e7d7"   // nav text color
    readonly property color sidebarTextActive: "#ffffff" // active nav text
    readonly property color sidebarTextMuted: "#d6f0e46c" // section labels rgba(214,240,228,0.42)
    readonly property color sidebarLogo:     "#ffffff"   // logo text
    readonly property color sidebarSubTitle: "#a5dcc6"   // logo subtitle
    // Keep sidebarBg as a fallback (gradient applied in QML)
    readonly property color sidebarBg:       "#065f46"   // fallback solid color

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
    readonly property color textPrimary:     "#12241b"   // HTML --text
    readonly property color textSecondary:   "#4f6b5c"   // HTML --muted
    readonly property color textTertiary:    "#7e968a"   // HTML --faint
    readonly property color textDisabled:    "#b2cfbd"   // HTML --border2
    readonly property color textOnPrimary:   "#ffffff"
    readonly property color textOnDark:      "#ffffff"
    readonly property color textInverse:     "#ffffff"

    // ===== BORDERS =====
    readonly property color border:          "#d2e5d8"   // HTML --border
    readonly property color borderHover:     "#b2cfbd"   // HTML --border2
    readonly property color borderFocused:   "#059669"   // focused input
    readonly property color borderSubtle:    "#d2e5d8"   // HTML --border (same as border)

    // ===== TYPOGRAPHY =====
    // Use "Segoe UI" on Windows (falls back to system sans on Linux)
    // Poppins kept for branding/display only
    readonly property string fontFamily:     "Poppins"   // HTML uses Manrope (closest available)
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
    readonly property int sidebarWidth:     260   // HTML sidebar width

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
            "emerald": { main: primary, hover: primaryHover, subtle: primarySubtle, subtleAlt: primarySubtleAlt, deep: "#04543c" },
            "blue":    { main: blue,    hover: blueHover,    subtle: blueSubtle,    subtleAlt: blueSubtleAlt, deep: "#1e3fae" },
            "orange":  { main: orange,  hover: orangeHover,  subtle: orangeSubtle,  subtleAlt: orangeSubtleAlt, deep: "#8f3708" },
            "violet":  { main: violet,  hover: violetHover,  subtle: violetSubtle,  subtleAlt: violetSubtleAlt, deep: "#5423b7" },
            "cyan":    { main: cyan,    hover: cyanHover,    subtle: cyanSubtle,    subtleAlt: cyanSubtleAlt, deep: "#0f5e54" },
            "coral":   { main: coral,   hover: coralHover,   subtle: coralSubtle,   subtleAlt: coralSubtleAlt, deep: "#95102e" },
        "gold":    { main: "#d97706", hover: "#b45309", subtle: "#fcebc8", subtleAlt: "#fde68a", deep: "#7c4403" }
        }
        return accents[name] || accents.emerald
    }
}
