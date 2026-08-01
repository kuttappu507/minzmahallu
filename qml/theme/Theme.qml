// Theme.qml — Color/font constants (included as a QtObject, not singleton)
import QtQuick

QtObject {
    readonly property color bg: "#e7f4ea"
    readonly property color panel: "#ffffff"
    readonly property color panel2: "#f2faf4"
    readonly property color header: "#eef8f1"
    readonly property color border: "#d2e5d8"
    readonly property color border2: "#b2cfbd"
    readonly property color text: "#12241b"
    readonly property color muted: "#4f6b5c"
    readonly property color faint: "#7e968a"
    readonly property color em: "#059669"
    readonly property color emD: "#047857"
    readonly property color emDD: "#065f46"
    readonly property color emBg: "#ecfdf5"
    readonly property color emLine: "#a7f3d0"
    readonly property color gold: "#d97706"
    readonly property color rose: "#e11d48"
    readonly property color slate: "#64748b"
    readonly property color sel: "#dff5e7"
    readonly property color selText: "#065f46"

    readonly property string fontPrimary: "Poppins"
    readonly property string fontDisplay: "Space Grotesk"
    readonly property string fontMalayalam: "Gayathri"

    // Tint system
    readonly property var tints: ({
        em:     { sc: "#059669", sb: "#d3f5e6", st: "#04543c" },
        teal:   { sc: "#0d9488", sb: "#c8f6f1", st: "#0f5e54" },
        sky:    { sc: "#0284c7", sb: "#d7edfb", st: "#0a5480" },
        cyan:   { sc: "#0891b2", sb: "#c9f2fa", st: "#115e72" },
        blue:   { sc: "#2563eb", sb: "#dbe7fd", st: "#1e3fae" },
        violet: { sc: "#7c3aed", sb: "#e7defc", st: "#5423b7" },
        pink:   { sc: "#db2777", sb: "#fadfeb", st: "#93184f" },
        rose:   { sc: "#e11d48", sb: "#fddfe5", st: "#95102e" },
        orange: { sc: "#ea580c", sb: "#ffe4cf", st: "#8f3708" },
        gold:   { sc: "#d97706", sb: "#fcebc8", st: "#7c4403" },
        slate:  { sc: "#64748b", sb: "#e6ebf2", st: "#33415c" }
    })
    function tint(name) { return tints[name] || tints.slate }

    readonly property var pillColors: ({
        "Paid":      { bg: "#d3f5e6", fg: "#04543c", border: "#059669" },
        "Active":    { bg: "#d3f5e6", fg: "#04543c", border: "#059669" },
        "Collected": { bg: "#d3f5e6", fg: "#04543c", border: "#059669" },
        "Pending":   { bg: "#fcebc8", fg: "#7c4403", border: "#d97706" },
        "Overdue":   { bg: "#fddfe5", fg: "#95102e", border: "#e11d48" },
        "Approved":  { bg: "#c9f2fa", fg: "#115e72", border: "#0891b2" },
        "Available": { bg: "#e6ebf2", fg: "#33415c", border: "#64748b" }
    })
    function pillFor(s) { return pillColors[s] || pillColors["Available"] }

    readonly property var avatarColors: ["#059669","#0d9488","#7c3aed","#d97706","#0284c7","#e11d48","#db2777","#ea580c"]
    function avatarColor(n) { var s=0; for(var i=0;i<n.length;i++) s+=n.charCodeAt(i); return avatarColors[s%avatarColors.length] }
    function initials(n) { var p=n.split(" "); return (p[0]?p[0][0]:"")+(p[1]?p[1][0]:"") }
}
