# UI Architecture Audit

## DPI STATUS

**FIXED**: All redundant DPI mechanisms have been removed from `app_main.cpp`:
- Removed `SetProcessDpiAwarenessContext` / `SetProcessDPIAware` Win32 calls
- Removed `QT_ENABLE_HIGHDPI_SCALING` env var
- Removed `QT_AUTO_SCREEN_SCALE_FACTOR` env var
- Removed `QT_SCALE_FACTOR_ROUNDING_POLICY` env var

Qt 6 is natively Per-Monitor-V2 DPI aware on Windows. QML dimensions remain logical pixels — Qt scales to physical pixels automatically.

**DPI diagnostics logging** added — logs screen name, logical DPI, physical DPI, devicePixelRatio, and geometry on startup.

**NOT VERIFIED**: Visual testing at 100%, 125%, 150%, 175% scaling requires running the application on a Windows machine. The build succeeds and the DPI handling is architecturally correct (Qt 6 native).

---

## THEME STATUS

**IMPLEMENTED**: Single `Theme.qml` singleton with light/dark palette.

- `Theme.dark` property is driven by `SettingsController.theme` (ONE source of truth)
- All color tokens have light/dark variants: `canvas`, `surface`, `surfaceHover`, `textPrimary`, `textSecondary`, `textTertiary`, `textDisabled`, `border`, `borderHover`, etc.
- Dark mode changes immediately — `SettingsController.theme` change triggers `settingsChanged` signal → Theme bindings re-evaluate → all UI updates instantly
- No restart required
- 600+ inline hex colors replaced with `Theme.*` tokens across ALL QML files
- 12 remaining inline colors are intentional accent colors (gold `#f2c14e`, sidebar gradient — same in both themes)

**Sidebar** stays dark green in both themes (by design — the approved visual language has a green gradient sidebar).

**NOT VERIFIED**: Visual verification of dark mode appearance requires running the application. The architecture is correct — `Theme.dark` toggles all surface/text/border colors.

---

## LANGUAGE STATUS

**IMPLEMENTED**: `I18NController` with:
- `Q_PROPERTY(QString currentLanguage)` — emits `languageChanged` signal
- `Q_PROPERTY(int revision)` — counter that increments on language change, ensures QML bindings re-evaluate
- `Q_INVOKABLE tr(key)` — returns translated string
- `Q_INVOKABLE setLanguage(code)` — switches language + applies font + emits signal
- `Q_INVOKABLE toggleLanguage()` — switches between EN and ML

**Font switching**: `setLanguage()` calls `FontManager::applyFont()` which sets:
- English → "Noto Sans" + fallbacks
- Malayalam → "Anek Malayalam" + fallbacks

`Theme.activeFontFamily` returns the correct font family based on `I18NController.isMalayalam`. All QML `font.family` references now use `Theme.activeFontFamily`.

**Malayalam font loading**: 4 AnekMalayalam TTFs loaded in `app_main.cpp`.

**NOT VERIFIED**: Visual verification of Malayalam text rendering requires running the application with Malayalam language selected. The I18N dictionary has 250+ translation keys.

**KNOWN LIMITATION**: Most QML pages still use hardcoded English strings (e.g., `text: "Families"`). To fully translate, each `text:` binding needs to change to `{ var _r = I18NController.currentLanguage; return I18NController.tr("nav_families") }`. The architecture is in place — the translation bindings just need to be applied to each page.

---

## ROUTE STATUS

All 16 routes are implemented and load without QML errors:

| # | Route | CRUD | Search | Filter | Pagination | Theme | I18N |
|---|-------|------|--------|--------|------------|-------|------|
| 0 | Dashboard | Read-only | — | — | — | Theme tokens | Hardcoded EN |
| 1 | Families | Full CRUD | ✅ | Status + Ward | ✅ | Theme tokens | Hardcoded EN |
| 2 | Members | Full CRUD | ✅ | Gender + Status | ✅ | Theme tokens | Hardcoded EN |
| 3 | Subscriptions | Full CRUD + Mark Overdue | ✅ | Status | ✅ | Theme tokens | Hardcoded EN |
| 4 | Donations | Full CRUD | ✅ | Category | ✅ | Theme tokens | Hardcoded EN |
| 5 | Accounting | Full CRUD + Summary | — | Type | ✅ | Theme tokens | Hardcoded EN |
| 6 | Marriage | Full CRUD | ✅ | — | ✅ | Theme tokens | Hardcoded EN |
| 7 | Death | Full CRUD | ✅ | — | ✅ | Theme tokens | Hardcoded EN |
| 8 | Welfare | Full CRUD + Approve/Reject/Disburse | ✅ | Status + Category | ✅ | Theme tokens | Hardcoded EN |
| 9 | Certificates | Issue + Delete + PDF | — | Type | ✅ | Theme tokens | Hardcoded EN |
| 10 | Tokens | Placeholder | — | — | — | Theme tokens | Hardcoded EN |
| 11 | Reports | Generate + Export CSV/PDF/Excel | — | Date range | — | Theme tokens | Hardcoded EN |
| 12 | Settings | Full form + Save | — | — | — | Theme tokens | Hardcoded EN |
| 13 | Users | List + Delete + Unlock | — | — | — | Theme tokens | Hardcoded EN |
| 14 | Audit Log | Read-only list | — | Action | ✅ | Theme tokens | Hardcoded EN |
| 15 | Backup | Create/Restore/Verify/Delete/Prune | — | — | — | Theme tokens | Hardcoded EN |

---

## INLINE STYLE AUDIT

| Category | Before | After | Action |
|----------|--------|-------|--------|
| `color: "#..."` | 601 | 12 | Replaced with Theme tokens |
| `border.color: "#..."` | 61 | 0 | Replaced with Theme tokens |
| `font.family: "Poppins"` | 423 | 0 | Replaced with Theme.activeFontFamily |
| `font.family: "Anek Malayalam"` | 2 | 0 | Replaced with Theme.activeFontFamily |

**Remaining 12 inline colors** (intentional):
- Gold `#f2c14e` — sidebar indicator + avatar accent (same in both themes)
- `#b98317` — gold border (avatar)
- `#4a3606` — gold text on avatar
- Sidebar gradient `#0a7f5d`/`#065f46`/`#044633` on splash/login pages
- `#000000` shadow on login card
- `#fadfeb`/`#db2777` — donation summary card accent

These are accent colors that don't change between light/dark themes.

---

## DUPLICATE CODE AUDIT

- No duplicate Theme implementations (ONE `Theme.qml`)
- No duplicate I18N systems (ONE `I18NController`)
- No duplicate SettingsController (ONE `SettingsController`)
- No duplicate AuthController (ONE `AuthController`)
- All shared components are single implementations in `qml/components/`
- No V2/V3/V4 variants exist
- Legacy Widgets code has been completely deleted

---

## RESPONSIVE TEST RESULTS

**NOT VERIFIED**: Responsive testing at 1280×720, 1366×768, 1600×900 requires running the application on a Windows machine.

Architecture:
- Dashboard grid uses `responsiveColumns` property (5/4/3/2/1 based on content width)
- Sidebar collapses from 260px to 64px with flap button
- Table columns use fixed widths + flexible spacer
- Pages use `RowLayout`/`ColumnLayout` with `Layout.fillWidth`
- ScrollView used where content may overflow

---

## REMAINING ISSUES

1. **I18N translation bindings**: Most QML pages use hardcoded English strings. The `I18NController.tr()` mechanism works and is ready, but each page's `text:` bindings need to be updated to use `I18NController.tr("key")` with the `currentLanguage` dependency pattern. This is a large but mechanical task — 250+ translation keys exist in `I18N.cpp`.

2. **Dark mode visual verification**: The dark palette is architecturally correct (Theme tokens with `dark ? darkColor : lightColor`), but has not been visually verified on a running application.

3. **DPI visual verification**: DPI handling is architecturally correct (Qt 6 native, no hacks), but has not been visually verified at 125%/150% scaling.

4. **Tokens module**: Token tables are missing from the database schema (need V003 migration). Token page is a placeholder.

5. **Dashboard real data**: Dashboard still uses hardcoded mock KPI values. Needs `DashboardController` to wire to `DashboardService`.
