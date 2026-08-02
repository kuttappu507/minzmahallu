#pragma once

// =============================================================================
// ThemeColors.h — Color constants for QPainter-based rendering.
//
// QSS does not apply to:
//   - SplashScreen::drawContents (paints on a pixmap before QSS exists)
//   - DashboardView chart series (QtCharts API takes QColors directly)
//   - CertificateService / ReportService / TokenPdfEngine (PDF output)
//
// For these cases, use the constants below so colors live in ONE place
// (this header) instead of being hardcoded throughout the codebase.
//
// Color values mirror the Emerald theme in resources/styles/light.qss.
// =============================================================================

#include <QColor>

namespace mms {

namespace colors {

// Brand identity (same in light & dark)
inline const QColor emerald      { "#059669" };
inline const QColor emeraldHover { "#047857" };
inline const QColor emeraldDeep  { "#065f46" };
inline const QColor emeraldTint  { "#ecfdf5" };
inline const QColor gold         { "#c8941a" };
inline const QColor goldLight    { "#f2c14e" };
inline const QColor goldCream    { "#ffe9a8" };

// Sidebar gradient stops
inline const QColor sidebarTop    { "#0a4a38" };
inline const QColor sidebarBottom { "#053527" };

// Splash gradient stops
inline const QColor splashStart   { "#065f46" };
inline const QColor splashMid     { "#059669" };
inline const QColor splashEnd     { "#065f46" };

// Status palette (mirrors StatusColors.h)
inline const QColor paid      { "#059669" };
inline const QColor overdue   { "#e11d48" };
inline const QColor pending   { "#d97706" };
inline const QColor revoked   { "#6b7280" };

// Chart series — matches DashboardView
inline const QColor chartBlue   { "#3b82f6" };
inline const QColor chartGreen  { "#22c55e" };
inline const QColor chartPurple { "#a855f7" };
inline const QColor chartOrange { "#f59e0b" };
inline const QColor chartTeal   { "#14b8a6" };
inline const QColor chartRed    { "#ef4444" };
inline const QColor chartIndigo { "#6366f1" };
inline const QColor chartCyan   { "#06b6d4" };
inline const QColor chartSlate  { "#6b7280" };

// Text colors used by charts (depend on theme)
inline const QColor lightText      { "#1e293b" };
inline const QColor lightTextMuted { "#64748b" };
inline const QColor lightGrid      { "#f1f5f9" };
inline const QColor darkText       { "#e2e8f0" };
inline const QColor darkTextMuted  { "#94a3b8" };
inline const QColor darkGrid       { "#334155" };

// Icon tint for sidebar / flap buttons (always white because sidebar is dark emerald).
inline const QColor sidebarIconTint { "#ffffff" };

// Icon tint for topbar / login buttons (matches QLabel text color in light theme).
// In dark theme the QSS handles button color, but icons rendered via
// icons::renderSvgIcon need an explicit tint color.
inline const QColor topbarIconTint { "#0f172a" };

// Table cell foreground colors (semantic, same in light & dark).
// Used by setForeground on QTableWidgetItem to indicate status.
inline const QColor cellPositive   { "#047857" };  // paid / approved / active
inline const QColor cellNegative   { "#be123c" };  // overdue / rejected / deleted
inline const QColor cellWarning    { "#b45309" };  // pending / pending-action
inline const QColor cellInfo       { "#1d4ed8" };  // disbursed / income / info
inline const QColor cellMuted      { "#6b7280" };  // archived / inactive
inline const QColor cellAccent     { "#6d28d9" };  // custom accent (rare)

} // namespace colors

} // namespace mms
