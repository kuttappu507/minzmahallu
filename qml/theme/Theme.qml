pragma Singleton
import QtQuick

// ============================================================================
// Theme.qml — All visual tokens. Properties set from C++ (app_main.cpp).
// NO readonly bindings that reference 'dark' — this eliminates binding loops.
// C++ sets dark + all color properties imperatively.
// ============================================================================

QtObject {
    // ===== THEME STATE =====
    property bool dark: false

    // ===== CANVAS =====
    property color canvas:          "#e7f4ea"
    property color canvasAlt:       "#eef8f1"

    // ===== SURFACES =====
    property color surface:         "#ffffff"
    property color surfaceHover:     "#f2faf4"
    property color surfacePressed:  "#eef8f1"
    property color surfaceSubtle:   "#f2faf4"

    // ===== GREEN SIDEBAR (same in both themes) =====
    readonly property color sidebarTop:      "#0a7f5d"
    readonly property color sidebarMid:      "#065f46"
    readonly property color sidebarBot:      "#044633"
    readonly property color sidebarHover:    Qt.rgba(255/255, 255/255, 255/255, 0.06)
    readonly property color sidebarActive:   Qt.rgba(255/255, 255/255, 255/255, 0.14)
    readonly property color sidebarText:     "#a5dcc6"
    readonly property color sidebarTextActive: "#ffffff"
    readonly property color sidebarTextMuted: Qt.rgba(214/255, 240/255, 228/255, 0.42)
    readonly property color sidebarSubTitle: "#a5dcc6"
    readonly property color sidebarTextHover: "#d6f5e7"

    // ===== GOLD ACCENT =====
    readonly property color gold:               "#f2c14e"
    readonly property color goldBorder:        "#b98317"
    readonly property color goldText:          "#4a3606"

    // ===== SHADOW =====
    readonly property color shadow:            "#000000"

    // ===== PINK ACCENT =====
    readonly property color pink:              "#db2777"
    readonly property color pinkSubtle:        "#fadfeb"

    // ===== BRAND — Emerald =====
    property color primary:         "#059669"
    property color primaryHover:    "#047857"
    property color primaryPressed:  "#036049"
    property color primarySubtle:   "#ecfdf5"
    property color primaryOn:       "#ffffff"

    // ===== ACCENTS =====
    readonly property color blue:            "#3b82f6"
    readonly property color blueHover:       "#2563eb"
    readonly property color blueSubtle:     "#eff6ff"

    readonly property color orange:          "#f97316"
    readonly property color orangeHover:     "#ea580c"
    readonly property color orangeSubtle:    "#fff7ed"

    readonly property color violet:          "#8b5cf6"
    readonly property color violetHover:     "#7c3aed"
    readonly property color violetSubtle:    "#f5f3ff"

    readonly property color cyan:            "#06b6d4"
    readonly property color cyanHover:       "#0891b2"
    readonly property color cyanSubtle:     "#ecfeff"

    readonly property color coral:           "#f43f5e"
    readonly property color coralHover:     "#e11d48"
    readonly property color coralSubtle:    "#fff1f2"

    // ===== SEMANTIC =====
    readonly property color success:         "#10b981"
    property color successSubtle:   "#ecfdf5"
    readonly property color warning:         "#f59e0b"
    property color warningSubtle:   "#fffbeb"
    readonly property color danger:          "#ef4444"
    readonly property color dangerHover:     "#dc2626"
    property color dangerSubtle:    "#fef2f2"
    readonly property color info:            "#0ea5e9"
    readonly property color infoSubtle:      "#f0f9ff"

    // ===== TEXT =====
    property color textPrimary:     "#12241b"
    property color textSecondary:   "#4f6b5c"
    property color textTertiary:    "#7e968a"
    property color textDisabled:    "#b2cfbd"

    // ===== BORDERS =====
    property color border:          "#d2e5d8"
    property color borderHover:     "#b2cfbd"
    readonly property color borderFocused:   "#059669"

    // ===== TYPOGRAPHY =====
    readonly property string fontFamily:     "Poppins"
    readonly property string fontFamilyDisplay: "Poppins"
    readonly property string fontFamilyMalayalam: "Anek Malayalam"
    readonly property string fontFamilyMono:  "Cascadia Code"
    property string activeFontFamily: "Poppins"

    // Font sizes
    readonly property int fontSizeXs:   13
    readonly property int fontSizeSm:   14
    readonly property int fontSizeMd:   15
    readonly property int fontSizeLg:   17
    readonly property int fontSizeXl:   20
    readonly property int fontSize2xl:  26
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
    readonly property int sidebarWidth:     260
    readonly property int sidebarCollapsedWidth: 64

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

    // ===== SHADOWS =====
    readonly property color shadowColor:       "#94a3b8"
    readonly property real shadowOpacitySmall: 0.08
    readonly property real shadowOpacityMedium: 0.12
    readonly property real shadowOpacityLarge:  0.16

    // ===== APPLY THEME FROM C++ =====
    // Called from app_main.cpp to set all colors based on dark mode.
    // This completely avoids QML binding loops.
    function applyTheme(isDark) {
        dark = isDark
        if (isDark) {
            canvas = "#0a1a12"; canvasAlt = "#0f1e16"
            surface = "#13221a"; surfaceHover = "#1a2e22"; surfacePressed = "#1e3327"; surfaceSubtle = "#0f1e16"
            primary = "#059669"; primaryHover = "#047857"; primaryPressed = "#036049"
            primarySubtle = "#0a2e22"; primaryOn = "#ffffff"
            successSubtle = "#0a2e22"; warningSubtle = "#2a1f0a"; dangerSubtle = "#2a0f0f"
            textPrimary = "#e6f2ea"; textSecondary = "#9fb8aa"; textTertiary = "#6d8878"; textDisabled = "#3a5048"
            border = "#23402f"; borderHover = "#335944"
            blueSubtle = "#0d1830"; orangeSubtle = "#2a1a0a"
            violetSubtle = "#1a1530"; cyanSubtle = "#0a2a30"
            coralSubtle = "#2a0f15"; infoSubtle = "#0a1f2a"
            shadowColor = "#000000"
            shadowOpacitySmall = 0.15; shadowOpacityMedium = 0.20; shadowOpacityLarge = 0.25
        } else {
            canvas = "#e7f4ea"; canvasAlt = "#eef8f1"
            surface = "#ffffff"; surfaceHover = "#f2faf4"; surfacePressed = "#eef8f1"; surfaceSubtle = "#f2faf4"
            primary = "#059669"; primaryHover = "#047857"; primaryPressed = "#036049"
            primarySubtle = "#ecfdf5"; primaryOn = "#ffffff"
            successSubtle = "#ecfdf5"; warningSubtle = "#fffbeb"; dangerSubtle = "#fef2f2"
            textPrimary = "#12241b"; textSecondary = "#4f6b5c"; textTertiary = "#7e968a"; textDisabled = "#b2cfbd"
            border = "#d2e5d8"; borderHover = "#b2cfbd"
            blueSubtle = "#eff6ff"; orangeSubtle = "#fff7ed"
            violetSubtle = "#f5f3ff"; cyanSubtle = "#ecfeff"
            coralSubtle = "#fff1f2"; infoSubtle = "#f0f9ff"
            shadowColor = "#94a3b8"
            shadowOpacitySmall = 0.08; shadowOpacityMedium = 0.12; shadowOpacityLarge = 0.16
        }
    }

    function applyFont(isMalayalam) {
        activeFontFamily = isMalayalam ? fontFamilyMalayalam : fontFamily
    }

    // ===== ACCENT HELPER =====
    function accent(name) {
        var accents = {
            "emerald": { main: primary, hover: primaryHover, subtle: primarySubtle, deep: "#04543c" },
            "blue":    { main: blue,    hover: blueHover,    subtle: blueSubtle,    deep: "#1e3fae" },
            "orange":  { main: orange,  hover: orangeHover,  subtle: orangeSubtle,  deep: "#8f3708" },
            "violet":  { main: violet,  hover: violetHover,  subtle: violetSubtle,  deep: "#5423b7" },
            "cyan":    { main: cyan,    hover: cyanHover,    subtle: cyanSubtle,    deep: "#0f5e54" },
            "coral":   { main: coral,   hover: coralHover,   subtle: coralSubtle,   deep: "#95102e" },
            "gold":    { main: gold, hover: "#b45309", subtle: warningSubtle, subtleAlt: "#fde68a", deep: "#7c4403" }
        }
        return accents[name] || accents.emerald
    }
}
