pragma Singleton
import QtQuick

// ============================================================================
// Theme.qml — The ONE source of application visual tokens
//
// All colors, typography, spacing, radii, control heights, shadows, and
// animation durations live here. Pages and components reference Theme.*
// — they do NOT inline hex colors.
//
// Dark mode is driven by SettingsController.theme:
//   "light" → light palette
//   "dark"  → dark palette
//
// Changing SettingsController.theme immediately re-evaluates all Theme
// bindings — no restart required.
// ============================================================================

QtObject {
    // ===== THEME STATE =====
    // Driven by SettingsController.theme — ONE source of truth.
    readonly property bool dark: typeof SettingsController !== "undefined" && SettingsController.theme === "dark"

    // ===== CANVAS =====
    readonly property color canvas:          dark ? "#0a1a12" : "#e7f4ea"

    // ===== SURFACES =====
    readonly property color surface:         dark ? "#13221a" : Theme.surface
    readonly property color surfaceHover:     dark ? "#1a2e22" : Theme.surfaceHover
    readonly property color surfacePressed:  dark ? "#1e3327" : Theme.surfacePressed
    readonly property color surfaceSubtle:   dark ? "#0f1e16" : Theme.surfaceHover

    // ===== GREEN SIDEBAR (same in both themes — sidebar is always dark green) =====
    readonly property color sidebarTop:      "#0a7f5d"
    readonly property color sidebarMid:      "#065f46"
    readonly property color sidebarBot:      "#044633"
    readonly property color sidebarHover:    Qt.rgba(255/255, 255/255, 255/255, 0.06)
    readonly property color sidebarActive:   Qt.rgba(255/255, 255/255, 255/255, 0.14)
    readonly property color sidebarText:     dark ? "#a5dcc6" : "#a5dcc6"
    readonly property color sidebarTextActive: Theme.surface
    readonly property color sidebarTextMuted: Qt.rgba(214/255, 240/255, 228/255, 0.42)
    readonly property color sidebarSubTitle: "#a5dcc6"
    readonly property color sidebarTextHover: dark ? "#d6f5e7" : "#d6f5e7"

    // ===== GOLD ACCENT (sidebar indicator, avatar) =====
    readonly property color gold:               "#f2c14e"
    readonly property color goldBorder:        "#b98317"
    readonly property color goldText:          "#4a3606"

    // ===== SHADOW =====
    readonly property color shadow:            "#000000"

    // ===== PINK ACCENT (donation summary card) =====
    readonly property color pink:              "#db2777"
    readonly property color pinkSubtle:        "#fadfeb"

    // ===== BRAND — Emerald =====
    readonly property color primary:         Theme.primary
    readonly property color primaryHover:    "#047857"
    readonly property color primaryPressed:  "#036049"
    readonly property color primarySubtle:   dark ? "#0a2e22" : "#ecfdf5"
    readonly property color primarySubtleAlt: dark ? "#0d3b2c" : "#d1fae5"
    readonly property color primaryOn:       Theme.surface

    // ===== ACCENT — Blue =====
    readonly property color blue:            "#3b82f6"
    readonly property color blueHover:       "#2563eb"
    readonly property color blueSubtle:     dark ? "#0d1830" : "#eff6ff"

    // ===== ACCENT — Orange =====
    readonly property color orange:          "#f97316"
    readonly property color orangeHover:     "#ea580c"
    readonly property color orangeSubtle:    dark ? "#2a1a0a" : "#fff7ed"

    // ===== ACCENT — Violet =====
    readonly property color violet:          "#8b5cf6"
    readonly property color violetHover:     "#7c3aed"
    readonly property color violetSubtle:    dark ? "#1a1530" : "#f5f3ff"
    readonly property color violetSubtleAlt: dark ? "#241d3d" : "#ddd6fe"

    // ===== ACCENT — Cyan =====
    readonly property color cyan:            "#06b6d4"
    readonly property color cyanHover:       "#0891b2"
    readonly property color cyanSubtle:     dark ? "#0a2a30" : "#ecfeff"

    // ===== ACCENT — Coral/Red =====
    readonly property color coral:           "#f43f5e"
    readonly property color coralHover:     Theme.danger
    readonly property color coralSubtle:    dark ? "#2a0f15" : "#fff1f2"

    // ===== SEMANTIC =====
    readonly property color success:         "#10b981"
    readonly property color successSubtle:   dark ? "#0a2e22" : "#ecfdf5"
    readonly property color warning:         "#f59e0b"
    readonly property color warningSubtle:   dark ? "#2a1f0a" : "#fffbeb"
    readonly property color danger:          "#ef4444"
    readonly property color dangerHover:     "#dc2626"
    readonly property color dangerSubtle:    dark ? "#2a0f0f" : "#fef2f2"
    readonly property color info:            "#0ea5e9"
    readonly property color infoSubtle:      dark ? "#0a1f2a" : "#f0f9ff"

    // ===== TEXT =====
    readonly property color textPrimary:     dark ? "#e6f2ea" : Theme.textPrimary
    readonly property color textSecondary:   dark ? "#9fb8aa" : Theme.textSecondary
    readonly property color textTertiary:    dark ? "#6d8878" : Theme.textTertiary
    readonly property color textDisabled:    dark ? "#3a5048" : Theme.borderHover

    // ===== BORDERS =====
    readonly property color border:          dark ? "#23402f" : Theme.border
    readonly property color borderHover:     dark ? "#335944" : Theme.borderHover
    readonly property color borderFocused:   Theme.primary
    readonly property color borderSubtle:    dark ? "#1a3020" : Theme.border

    // ===== TYPOGRAPHY =====
    readonly property string fontFamily:     "Poppins"
    readonly property string fontFamilyDisplay: "Poppins"
    readonly property string fontFamilyMalayalam: "Anek Malayalam"
    readonly property string fontFamilyMono:  "Cascadia Code"

    // Active font family — switches based on language
    readonly property string activeFontFamily: typeof I18NController !== "undefined" && I18NController.isMalayalam ? fontFamilyMalayalam : fontFamily

    // Font sizes (logical pixels — do NOT scale by DPI)
    // Font sizes — larger for better readability on high-DPI screens
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
    readonly property color shadowColor:       dark ? "#000000" : "#94a3b8"
    readonly property real shadowOpacitySmall: dark ? 0.15 : 0.08
    readonly property real shadowOpacityMedium: dark ? 0.20 : 0.12
    readonly property real shadowOpacityLarge:  dark ? 0.25 : 0.16

    // ===== ACCENT HELPER =====
    function accent(name) {
        var accents = {
            "emerald": { main: primary, hover: primaryHover, subtle: primarySubtle, subtleAlt: primarySubtleAlt, deep: "#04543c" },
            "blue":    { main: blue,    hover: blueHover,    subtle: blueSubtle,    subtleAlt: blueSubtleAlt, deep: "#1e3fae" },
            "orange":  { main: orange,  hover: orangeHover,  subtle: orangeSubtle,  subtleAlt: orangeSubtleAlt, deep: "#8f3708" },
            "violet":  { main: violet,  hover: violetHover,  subtle: violetSubtle,  subtleAlt: violetSubtleAlt, deep: "#5423b7" },
            "cyan":    { main: cyan,    hover: cyanHover,    subtle: cyanSubtle,    subtleAlt: cyanSubtleAlt, deep: "#0f5e54" },
            "coral":   { main: coral,   hover: coralHover,   subtle: coralSubtle,   subtleAlt: coralSubtleAlt, deep: "#95102e" },
            "gold":    { main: "#d97706", hover: "#b45309", subtle: warningSubtle, subtleAlt: "#fde68a", deep: "#7c4403" }
        }
        return accents[name] || accents.emerald
    }
}
