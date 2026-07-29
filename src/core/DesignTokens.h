#pragma once
#include <QString>

namespace DS {
    // Spacing (4px grid)
    constexpr int XS  = 4;
    constexpr int SM  = 8;
    constexpr int MD  = 16;
    constexpr int LG  = 24;
    constexpr int XL  = 32;
    constexpr int XXL = 48;

    // Border radius
    constexpr int RadiusSM  = 6;
    constexpr int RadiusMD  = 10;
    constexpr int RadiusLG  = 14;
    constexpr int RadiusXL  = 20;

    // Typography (in points)
    constexpr int FontXS  = 9;
    constexpr int FontSM  = 10;
    constexpr int FontMD  = 11;
    constexpr int FontLG  = 13;
    constexpr int FontXL  = 16;
    constexpr int FontXXL = 20;
    constexpr int Font3XL = 28;

    // Animation (ms)
    constexpr int AnimFast   = 120;
    constexpr int AnimNormal = 200;
    constexpr int AnimSlow   = 350;

    // Component sizes
    constexpr int ButtonHeightSM  = 32;
    constexpr int ButtonHeightMD  = 40;
    constexpr int ButtonHeightLG  = 48;
    constexpr int InputHeightMD   = 38;
    constexpr int NavItemHeight   = 44;
    constexpr int TopBarHeight    = 56;
    constexpr int SidebarExpanded = 260;
    constexpr int SidebarCollapsed= 72;
    constexpr int CardRadius      = 12;

    // Colors — semantic
    namespace Color {
        constexpr auto Primary        = "#059669";
        constexpr auto PrimaryHover   = "#047857";
        constexpr auto PrimaryActive  = "#065f46";
        constexpr auto PrimaryLight   = "#ecfdf5";
        constexpr auto PrimaryBorder  = "#a7f3d0";

        constexpr auto Success        = "#059669";
        constexpr auto SuccessLight   = "#ecfdf5";
        constexpr auto Warning        = "#d97706";
        constexpr auto WarningLight   = "#fffbeb";
        constexpr auto Error          = "#dc2626";
        constexpr auto ErrorLight     = "#fef2f2";
        constexpr auto Info           = "#0891b2";
        constexpr auto InfoLight      = "#ecfeff";

        constexpr auto Text           = "#0f172a";
        constexpr auto TextMuted      = "#475569";
        constexpr auto TextDisabled   = "#94a3b8";
        constexpr auto Border         = "#cbd5e1";
        constexpr auto BorderStrong   = "#94a3b8";
        constexpr auto Surface        = "#ffffff";
        constexpr auto SurfaceRaised  = "#f8fafc";
        constexpr auto SurfaceSunken  = "#f1f5f9";

        // Dark mode equivalents
        constexpr auto DarkText       = "#f1f5f9";
        constexpr auto DarkTextMuted  = "#94a3b8";
        constexpr auto DarkBorder     = "#334155";
        constexpr auto DarkSurface    = "#1e293b";
        constexpr auto DarkRaised     = "#243044";
    }
}
