import QtQuick

QtObject {
    // ===== Fonts =====
    readonly property string fontDisplay: "Space Grotesk"
    readonly property string fontPrimary: "Poppins"

    // ===== Base palette =====
    readonly property color bg:           "#e7f4ea"
    readonly property color panel:        "#ffffff"
    readonly property color panelMuted:   "#f2faf4"
    readonly property color border:       "#d2e5d8"
    readonly property color text:         "#12241b"
    readonly property color muted:        "#7e968a"
    readonly property color sidebar:      "#065f46"
    readonly property color accent:       "#f2c14e"
    readonly property color accentDeep:   "#b98317"
    readonly property color danger:       "#e11d48"
    readonly property color success:      "#059669"

    // ===== Sidebar gradient stops =====
    readonly property color sidebarTop:    "#0a7f5d"
    readonly property color sidebarMid:    "#065f46"
    readonly property color sidebarBot:    "#044633"

    // ===== Tints (used by stat cards / pills) =====
    readonly property var tints: ({
        "em":   { sb: "#d3f5e6", sc: "#059669", st: "#04543c" },
        "cy":   { sb: "#c8f6f1", sc: "#0d9488", st: "#0f5e54" },
        "bl":   { sb: "#d7edfb", sc: "#0284c7", st: "#0a5480" },
        "am":   { sb: "#fcebc8", sc: "#d97706", st: "#7c4403" },
        "rd":   { sb: "#fddfe5", sc: "#e11d48", st: "#95102e" },
        "pk":   { sb: "#fadfeb", sc: "#db2777", st: "#93184f" },
        "vi":   { sb: "#e7defc", sc: "#7c3aed", st: "#5423b7" },
        "or":   { sb: "#ffe4cf", sc: "#ea580c", st: "#8f3708" },
        "sl":   { sb: "#e6ebf2", sc: "#64748b", st: "#33415c" },
        "ib":   { sb: "#dbe7fd", sc: "#2563eb", st: "#1e3fae" }
    })

    function tint(name) {
        var t = tints[name];
        return t || tints["em"];
    }

    // ===== Status pills =====
    readonly property var pills: ({
        "Active":      { sb: "#d3f5e6", sc: "#059669", st: "#04543c", label: "Active" },
        "Inactive":    { sb: "#e6ebf2", sc: "#64748b", st: "#33415c", label: "Inactive" },
        "Archived":    { sb: "#fddfe5", sc: "#e11d48", st: "#95102e", label: "Archived" },
        "Overdue":     { sb: "#fddfe5", sc: "#e11d48", st: "#95102e", label: "Overdue" },
        "Paid":        { sb: "#d3f5e6", sc: "#059669", st: "#04543c", label: "Paid" },
        "Pending":     { sb: "#fcebc8", sc: "#d97706", st: "#7c4403", label: "Pending" },
        "Approved":    { sb: "#d3f5e6", sc: "#059669", st: "#04543c", label: "Approved" },
        "Rejected":    { sb: "#fddfe5", sc: "#e11d48", st: "#95102e", label: "Rejected" },
        "Issued":      { sb: "#d7edfb", sc: "#0284c7", st: "#0a5480", label: "Issued" }
    })

    function pillFor(status) {
        var p = pills[status];
        return p || { sb: "#e6ebf2", sc: "#64748b", st: "#33415c", label: status || "—" };
    }
}
