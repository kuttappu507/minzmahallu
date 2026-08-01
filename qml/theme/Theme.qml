// =============================================================================
// Theme.qml — Singleton with all colors, fonts, spacing from HTML :root vars
// Accessible from anywhere as: Theme.bg, Theme.em, Theme.tint.em.sc, etc.
// =============================================================================
pragma Singleton
import QtQuick

QtObject {
    // Mode
    readonly property bool dark: false

    // Base colors (from HTML :root)
    readonly property color bg:      dark ? "#0a1a12" : "#e7f4ea"
    readonly property color panel:   dark ? "#13221a" : "#ffffff"
    readonly property color panel2:  dark ? "#0f1c15" : "#f2faf4"
    readonly property color header:  dark ? "#1b2f23" : "#eef8f1"
    readonly property color border:  dark ? "#23402f" : "#d2e5d8"
    readonly property color border2: dark ? "#335944" : "#b2cfbd"
    readonly property color text:    dark ? "#e6f2ea" : "#12241b"
    readonly property color muted:   dark ? "#9fb8aa" : "#4f6b5c"
    readonly property color faint:   dark ? "#6d8878" : "#7e968a"

    // Brand colors
    readonly property color em:      "#059669"
    readonly property color emD:     "#047857"
    readonly property color emDD:    "#065f46"
    readonly property color emBg:    dark ? "#0a2f22" : "#ecfdf5"
    readonly property color emLine:  dark ? "#14532d" : "#a7f3d0"
    readonly property color gold:    "#d97706"
    readonly property color rose:    "#e11d48"
    readonly property color slate:   "#64748b"

    // Selection
    readonly property color sel:     dark ? "#0c3527" : "#dff5e7"
    readonly property color selText: dark ? "#6ee7b7" : "#065f46"

    // Sidebar gradient
    readonly property var sidebarGradient: [
        { stop: 0.0, color: "#0a7f5d" },
        { stop: 0.42, color: "#065f46" },
        { stop: 1.0, color: "#044633" }
    ]

    // Fonts
    readonly property string fontPrimary: "Poppins"
    readonly property string fontDisplay: "Space Grotesk"
    readonly property string fontMalayalam: "Gayathri"

    // Tint system — each tint has solid color (sc), background (sb), text (st)
    readonly property var tints: ({
        em:     { sc: dark ? "#0aa06f" : "#059669", sb: dark ? "#0a2f23" : "#d3f5e6", st: dark ? "#77ecbb" : "#04543c" },
        teal:   { sc: dark ? "#12a594" : "#0d9488", sb: dark ? "#07302c" : "#c8f6f1", st: dark ? "#6fe3d4" : "#0f5e54" },
        sky:    { sc: dark ? "#2f9bdd" : "#0284c7", sb: dark ? "#0a2c42" : "#d7edfb", st: dark ? "#85cdf6" : "#0a5480" },
        cyan:   { sc: dark ? "#1ba3c6" : "#0891b2", sb: dark ? "#08313c" : "#c9f2fa", st: dark ? "#7fdcf0" : "#115e72" },
        blue:   { sc: dark ? "#4f83f0" : "#2563eb", sb: dark ? "#13234d" : "#dbe7fd", st: dark ? "#9dbcfa" : "#1e3fae" },
        violet: { sc: dark ? "#9161ee" : "#7c3aed", sb: dark ? "#241343" : "#e7defc", st: dark ? "#c3a9f8" : "#5423b7" },
        pink:   { sc: dark ? "#e44a90" : "#db2777", sb: dark ? "#3d1027" : "#fadfeb", st: dark ? "#f5a3c8" : "#93184f" },
        rose:   { sc: dark ? "#ef4d70" : "#e11d48", sb: dark ? "#3c0d18" : "#fddfe5", st: dark ? "#fba8ba" : "#95102e" },
        orange: { sc: dark ? "#f0762f" : "#ea580c", sb: dark ? "#3a1808" : "#ffe4cf", st: dark ? "#f8b58b" : "#8f3708" },
        gold:   { sc: dark ? "#e59b25" : "#d97706", sb: dark ? "#39230a" : "#fcebc8", st: dark ? "#f7cf8e" : "#7c4403" },
        slate:  { sc: dark ? "#7d8ea8" : "#64748b", sb: dark ? "#1c2739" : "#e6ebf2", st: dark ? "#c0cde0" : "#33415c" }
    })

    // Helper to get tint by name
    function tint(name) {
        return tints[name] || tints.slate
    }

    // Status pill colors
    readonly property var pillColors: ({
        "Paid":      { bg: tints.em.sb,     fg: tints.em.st,     border: tints.em.sc },
        "Active":    { bg: tints.em.sb,     fg: tints.em.st,     border: tints.em.sc },
        "Collected": { bg: tints.em.sb,     fg: tints.em.st,     border: tints.em.sc },
        "Disbursed": { bg: tints.em.sb,     fg: tints.em.st,     border: tints.em.sc },
        "Income":    { bg: tints.em.sb,     fg: tints.em.st,     border: tints.em.sc },
        "Pending":   { bg: tints.gold.sb,   fg: tints.gold.st,   border: tints.gold.sc },
        "Requested": { bg: tints.gold.sb,   fg: tints.gold.st,   border: tints.gold.sc },
        "Assigned":  { bg: tints.gold.sb,   fg: tints.gold.st,   border: tints.gold.sc },
        "Overdue":   { bg: tints.rose.sb,   fg: tints.rose.st,   border: tints.rose.sc },
        "Revoked":   { bg: tints.rose.sb,   fg: tints.rose.st,   border: tints.rose.sc },
        "Expense":   { bg: tints.rose.sb,   fg: tints.rose.st,   border: tints.rose.sc },
        "Approved":  { bg: tints.cyan.sb,   fg: tints.cyan.st,   border: tints.cyan.sc },
        "Manager":   { bg: tints.cyan.sb,   fg: tints.cyan.st,   border: tints.cyan.sc },
        "Manual":    { bg: tints.cyan.sb,   fg: tints.cyan.st,   border: tints.cyan.sc },
        "Available": { bg: tints.slate.sb,  fg: tints.slate.st,  border: tints.slate.sc },
        "Archived":  { bg: tints.slate.sb,  fg: tints.slate.st,  border: tints.slate.sc },
        "Disabled":  { bg: tints.slate.sb,  fg: tints.slate.st,  border: tints.slate.sc },
        "User":      { bg: tints.slate.sb,  fg: tints.slate.st,  border: tints.slate.sc },
        "Auto":      { bg: tints.slate.sb,  fg: tints.slate.st,  border: tints.slate.sc },
        "Administrator": { bg: tints.em.sb, fg: tints.em.st,     border: tints.em.sc }
    })

    function pillFor(status) {
        return pillColors[status] || pillColors["Available"]
    }

    // Spacing
    readonly property int spacingXS: 4
    readonly property int spacingSM: 8
    readonly property int spacingMD: 12
    readonly property int spacingLG: 16
    readonly property int spacingXL: 22
    readonly property int spacingXXL: 26

    // Radii
    readonly property int radiusBtn: 8
    readonly property int radiusCard: 10
    readonly property int radiusPill: 99
    readonly property int radiusSquircle: 12

    // Sidebar
    readonly property int sidebarWidth: 260
    readonly property int sidebarCollapsedWidth: 80
    readonly property int topbarHeight: 58
    readonly property int statusbarHeight: 28

    // Avatar colors (for user initials)
    readonly property var avatarColors: ["#059669","#0d9488","#7c3aed","#d97706","#0284c7","#e11d48","#db2777","#ea580c"]
    function avatarColor(name) {
        var sum = 0
        for (var i = 0; i < name.length; i++) sum += name.charCodeAt(i)
        return avatarColors[sum % avatarColors.length]
    }
    function initials(name) {
        var parts = name.split(" ")
        return (parts[0] ? parts[0][0] : "") + (parts[1] ? parts[1][0] : "")
    }
}
