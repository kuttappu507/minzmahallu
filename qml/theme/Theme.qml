pragma Singleton
import QtQuick

// ============================================================================
// Theme.qml — Minz Mahallu Design System
// Centralized light/dark palette. Components should consume these tokens
// instead of embedding page-specific surface/text colors.
// ============================================================================

QtObject {
    readonly property bool dark: typeof SettingsController !== "undefined" && SettingsController.theme === "dark"

    // Compatibility shim for older AppShell code. The theme is now derived
    // directly from SettingsController.theme, so no mutable theme state is needed.
    function setDark(_enabled) { }

    // Canvas / surfaces
    readonly property color canvas:        dark ? "#111827" : "#e7f4ea"
    readonly property color canvasAlt:     dark ? "#0f172a" : "#eef8f1"
    readonly property color surface:       dark ? "#1f2937" : "#ffffff"
    readonly property color surfaceHover:  dark ? "#273449" : "#f2faf4"
    readonly property color surfacePressed:dark ? "#334155" : "#eef8f1"
    readonly property color surfaceSubtle: dark ? "#182231" : "#f2faf4"
    readonly property color surfaceRaised: dark ? "#243044" : "#ffffff"

    // Sidebar
    readonly property color sidebarTop:    dark ? "#064e3b" : "#0a7f5d"
    readonly property color sidebarMid:    dark ? "#053d2e" : "#065f46"
    readonly property color sidebarBot:    dark ? "#03291f" : "#044633"
    readonly property color sidebarHover:  "#ffffff14"
    readonly property color sidebarActive: "#ffffff24"
    readonly property color sidebarBorder: "#ffffff24"
    readonly property color sidebarText:   dark ? "#b9d8cb" : "#c4e7d7"
    readonly property color sidebarTextActive: "#ffffff"
    readonly property color sidebarTextMuted: dark ? "#b9d8cb66" : "#d6f0e46c"
    readonly property color sidebarLogo:   "#ffffff"
    readonly property color sidebarSubTitle: dark ? "#91cbb7" : "#a5dcc6"
    readonly property color sidebarBg:     dark ? "#053d2e" : "#065f46"

    // Brand / accents
    readonly property color primary:       "#059669"
    readonly property color primaryHover:  "#047857"
    readonly property color primaryPressed:"#036049"
    readonly property color primarySubtle: dark ? "#063b2d" : "#ecfdf5"
    readonly property color primarySubtleAlt: dark ? "#07543e" : "#d1fae5"
    readonly property color primaryOn:     "#ffffff"
    readonly property color blue:          "#3b82f6"
    readonly property color blueHover:     "#2563eb"
    readonly property color blueSubtle:    dark ? "#172554" : "#eff6ff"
    readonly property color blueSubtleAlt: dark ? "#1e3a8a" : "#dbeafe"
    readonly property color orange:        "#f97316"
    readonly property color orangeHover:   "#ea580c"
    readonly property color orangeSubtle:  dark ? "#431407" : "#fff7ed"
    readonly property color orangeSubtleAlt: dark ? "#7c2d12" : "#fed7aa"
    readonly property color violet:        "#8b5cf6"
    readonly property color violetHover:   "#7c3aed"
    readonly property color violetSubtle:  dark ? "#2e1065" : "#f5f3ff"
    readonly property color violetSubtleAlt: dark ? "#4c1d95" : "#ddd6fe"
    readonly property color cyan:          "#06b6d4"
    readonly property color cyanHover:     "#0891b2"
    readonly property color cyanSubtle:    dark ? "#083344" : "#ecfeff"
    readonly property color cyanSubtleAlt: dark ? "#155e75" : "#a5f3fc"
    readonly property color coral:         "#f43f5e"
    readonly property color coralHover:    "#e11d48"
    readonly property color coralSubtle:   dark ? "#4c0519" : "#fff1f2"
    readonly property color coralSubtleAlt:dark ? "#881337" : "#fecdd3"

    // Semantic
    readonly property color success:       "#10b981"
    readonly property color successSubtle: dark ? "#063b2d" : "#ecfdf5"
    readonly property color warning:       "#f59e0b"
    readonly property color warningSubtle: dark ? "#451a03" : "#fffbeb"
    readonly property color danger:        "#ef4444"
    readonly property color dangerHover:   "#dc2626"
    readonly property color dangerSubtle:  dark ? "#450a0a" : "#fef2f2"
    readonly property color info:          "#0ea5e9"
    readonly property color infoSubtle:    dark ? "#082f49" : "#f0f9ff"

    // Text
    readonly property color textPrimary:   dark ? "#e5e7eb" : "#12241b"
    readonly property color textSecondary: dark ? "#a7b4c2" : "#4f6b5c"
    readonly property color textTertiary:  dark ? "#7f8ea3" : "#7e968a"
    readonly property color textDisabled:  dark ? "#526174" : "#b2cfbd"
    readonly property color textOnPrimary: "#ffffff"
    readonly property color textOnDark:    "#ffffff"
    readonly property color textInverse:   dark ? "#111827" : "#ffffff"

    // Borders
    readonly property color border:        dark ? "#334155" : "#d2e5d8"
    readonly property color borderHover:   dark ? "#475569" : "#b2cfbd"
    readonly property color borderFocused: "#059669"
    readonly property color borderSubtle:  dark ? "#263548" : "#d2e5d8"

    // Typography
    readonly property string fontFamily: "Poppins"
    readonly property string fontFamilyDisplay: "Poppins"
    readonly property string fontFamilyMono: "Cascadia Code"
    readonly property int fontSizeXs: 11
    readonly property int fontSizeSm: 12
    readonly property int fontSizeMd: 13
    readonly property int fontSizeLg: 15
    readonly property int fontSizeXl: 18
    readonly property int fontSize2xl: 24
    readonly property int fontSize3xl: 30
    readonly property int fontSize4xl: 36
    readonly property int fontWeightRegular: Font.Normal
    readonly property int fontWeightMedium: Font.Medium
    readonly property int fontWeightSemiBold: Font.DemiBold
    readonly property int fontWeightBold: Font.Bold

    // Layout tokens
    readonly property int spaceXs: 4
    readonly property int spaceSm: 8
    readonly property int spaceMd: 12
    readonly property int spaceLg: 16
    readonly property int spaceXl: 24
    readonly property int space2xl: 32
    readonly property int space3xl: 48
    readonly property int radiusXs: 3
    readonly property int radiusSm: 4
    readonly property int radiusMd: 6
    readonly property int radiusLg: 8
    readonly property int radiusXl: 12
    readonly property int radius2xl: 16
    readonly property int controlHeightSm: 28
    readonly property int controlHeightMd: 32
    readonly property int controlHeightLg: 36
    readonly property int sidebarWidth: 260
    readonly property int iconSizeXs: 12
    readonly property int iconSizeSm: 14
    readonly property int iconSizeMd: 16
    readonly property int iconSizeLg: 20
    readonly property int iconSizeXl: 24
    readonly property int iconSize2xl: 32
    readonly property int animFast: 100
    readonly property int animNormal: 150
    readonly property int animSlow: 250
    readonly property int easingStandard: Easing.OutCubic
    readonly property int easingEntrance: Easing.OutQuint
    readonly property color shadowColor: dark ? "#000000" : "#94a3b8"
    readonly property real shadowOpacitySmall: dark ? 0.20 : 0.08
    readonly property real shadowOpacityMedium: dark ? 0.28 : 0.12
    readonly property real shadowOpacityLarge: dark ? 0.35 : 0.16

    function accent(name) {
        var accents = {
            "emerald": { main: primary, hover: primaryHover, subtle: primarySubtle, subtleAlt: primarySubtleAlt, deep: "#04543c" },
            "blue":    { main: blue, hover: blueHover, subtle: blueSubtle, subtleAlt: blueSubtleAlt, deep: "#1e3fae" },
            "orange":  { main: orange, hover: orangeHover, subtle: orangeSubtle, subtleAlt: orangeSubtleAlt, deep: "#8f3708" },
            "violet":  { main: violet, hover: violetHover, subtle: violetSubtle, subtleAlt: violetSubtleAlt, deep: "#5423b7" },
            "cyan":    { main: cyan, hover: cyanHover, subtle: cyanSubtle, subtleAlt: cyanSubtleAlt, deep: "#0f5e54" },
            "coral":   { main: coral, hover: coralHover, subtle: coralSubtle, subtleAlt: coralSubtleAlt, deep: "#95102e" },
            "gold":    { main: "#d97706", hover: "#b45309", subtle: dark ? "#451a03" : "#fcebc8", subtleAlt: dark ? "#78350f" : "#fde68a", deep: "#7c4403" }
        }
        return accents[name] || accents.emerald
    }
}