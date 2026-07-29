# UI_RULES.md — Minz Mahallu Management System (MMS)

> **Contract document for all UI changes.**
> Read this file BEFORE any UI edit. If a proposed change conflicts with a rule below, STOP and tell the user. If a new rule is needed, PROPOSE it and wait for approval before adding it.
> Last updated: 2026-07-23

---

## 0. Workflow Rules (process — not style)

### 0.1 Scope Lock Rule
Before writing any code, define the Scope in the response:
- Which file(s) will change
- Which lines/sections of those files
- Which other files might be affected (Risk Areas)
- Whether changing `.cpp`, `.qss`, `.qrc`, or other

Do NOT touch anything outside the declared Scope without asking first.

### 0.2 Diff First Policy
First response to any UI change request must be a unified diff (or clearly formatted before/after for short changes), NOT a compiled binary. Wait for explicit user approval before compiling. The user will NOT download a 21MB binary just to see a broken button.

### 0.3 One Feature Per Build
Never bundle multiple UI changes into one build. Each build = exactly one logical UI change. If the user asks for two things, propose a sequence of two separate builds.

### 0.4 Regression Check
Every time a global QSS selector is touched (`QPushButton`, `QLabel`, `QWidget`, `QListWidget`, `QTableWidget`, `QComboBox`, `QFrame`, etc.):
- List the specific selectors being changed
- List the views/widgets most likely to be affected (Risk Areas)
- Tell the user what to look for when testing
- Acknowledge if a particular view has NOT been verified

### 0.5 Honesty Rule
If something is unknown, say "I do not know" or "I am guessing, please verify." Do not invent Qt APIs that do not exist. Do not claim a selector affects only one widget when that has not been verified. If a request is ambiguous, ask for clarification before coding. If a change requires touching more than 3 files, stop and explain why before proceeding.

---

## 1. Color Palette (2026 modern, emerald-based)

| Role              | Hex       | Usage                                            |
|-------------------|-----------|--------------------------------------------------|
| Primary           | `#059669` | Buttons, accents, selected states                |
| Primary dark      | `#065f46` | Sidebar background, hover-darken                 |
| Primary light     | `#d1fae5` | Soft backgrounds, success tints                  |
| Surface           | `#ffffff` | Card backgrounds, page background                |
| Surface muted     | `#f9fafb` | Table headers, subtle panels                     |
| Border            | `#e5e7eb` | Card borders, dividers                           |
| Border subtle     | `#f3f4f6` | Inner separators                                 |
| Text primary      | `#111827` | Body text, headings                              |
| Text secondary    | `#6b7280` | Captions, secondary labels                       |
| Text tertiary     | `#9ca3af` | Hints, placeholders                              |
| Success           | `#16a34a` | Paid status, success badges                      |
| Warning           | `#f59e0b` | Pending status, warning banners                  |
| Danger            | `#dc2626` | Overdue status, destructive actions              |
| Info              | `#0891b2` | Info badges, informational banners               |

**Forbidden:** Any blue color (no `#3b82f6`, `#2563eb`, `#1e3a8a`, `#1e1b4b`, `#60a5fa`, `#93c5fd`, `#c7d2fe`, etc.). The previous blue→emerald migration is final. Do not reintroduce blue tones.

---

## 2. Spacing Scale

Use only these values. If a different value is needed, propose it as a new rule first.

| Token | Value | Usage                                  |
|-------|-------|----------------------------------------|
| `xs`  | 4px   | Tight gaps inside components           |
| `sm`  | 8px   | Small gaps, button internal padding    |
| `md`  | 12px  | Table cell horizontal padding          |
| `lg`  | 16px  | Section gap, button vertical padding   |
| `xl`  | 24px  | Window content padding from edge       |
| `2xl` | 32px  | Major section separation               |
| `3xl` | 48px  | Hero spacing, splash padding           |

### Hard-coded component sizes
- Window content padding: **24px** from edge
- Card padding: **20px** internal
- Section gap: **16px**
- Button padding: **8px 16px**
- Button min height: **32px**
- Input height: **36px**
- Table cell padding: **12px 16px**
- Sidebar nav item height: **44px**
- Sidebar expanded width: **240px**
- Sidebar collapsed width: **64px**
- Stat card min width: **180px**
- Chart min height: **280px**

---

## 3. Typography Scale

Use exactly 5 text styles, applied via `setProperty("role", "...")` in code and matched by `[role="..."]` selector in QSS.

| Role      | Size  | Weight | Color      | Usage                                          |
|-----------|-------|--------|------------|------------------------------------------------|
| `display` | 28px  | 700    | `#111827`  | Login screen title, splash title               |
| `title`   | 20px  | 700    | `#059669`  | View titles, dialog titles                     |
| `heading` | 16px  | 600    | `#111827`  | Section headers, card titles                   |
| `body`    | 14px  | 400    | `#111827`  | All body text, table cells                     |
| `caption` | 12px  | 400    | `#6b7280`  | Subtitles, hints, timestamps                   |

**Forbidden:** Any other font sizes. Do NOT use `setStyleSheet` on `QLabel` for font properties — use the `setProperty("role", ...)` approach.

**Qt 6.8 note:** Use `QFont::Weight` enum (e.g., `QFont::Bold`) instead of integer weights.

---

## 4. Component Rules

### 4.1 Cards
- `QFrame` with `objectName="card"`
- `border-radius: 8px`
- `border: 1px solid #e5e7eb`
- `background: #ffffff`
- Optional elevation: `QGraphicsDropShadowEffect` (blur 16, color `rgba(0,0,0,20)`, offset 0,2)
- Padding: 20px internal

### 4.2 Buttons
- Radius: 6px
- Padding: 8px 16px
- Min height: 32px
- Hover: slight background darken (e.g., primary `#059669` → `#047857`)
- Focus: 2px outline `#059669`
- **Do not change `QPushButton` globally without explicit approval.**

### 4.3 Inputs
- Radius: 8px
- Border: 1px `#d1d5db`
- Focus border: `#059669`
- Height: 36px
- **Do not change padding/margin on `QComboBox` without explicit approval** — popup positioning is fragile.

### 4.4 Tables
- Cell padding: 12px 16px
- No internal grid lines (only outer border + header bottom border)
- Header background: `#f9fafb`
- Header weight: 600
- Selection background: `#ecfdf5`
- Selection color: `#065f46`

### 4.5 Sidebar
- Background: `#065f46`
- Nav item text: `#d1fae5`
- Hover: `rgba(255,255,255,0.08)`
- Selected: background `#059669`, white text, 3px white left border
- Width: 240px expanded, 64px collapsed
- Nav item height: 44px

### 4.6 Empty State
- Use the existing `EmptyStateWidget` class — do not create ad-hoc empty-state labels.

---

## 5. Icon System

### 5.1 Single Icon Family: Lucide
- Source: https://lucide.dev
- License: ISC (open source)
- Grid: 24×24
- Stroke: 2px
- All SVG files MUST use `stroke="currentColor"` so they can be tinted via QSS `color` property
- Rendered via `QSvgRenderer` (Qt 6.8)

### 5.2 Required Lucide Icons
`home, users, user, credit-card, heart, book-open, file-text, settings, log-out, moon, sun, search, bell, database, shield, award, briefcase, activity, plus, edit, trash, download, upload, check, x, chevron-left, chevron-right, menu, more-vertical, printer, qr-code`

### 5.3 Forbidden Icon Sources
- No SVG icons from sources other than Lucide
- No mixed icon families
- No Unicode characters used as icons **except the flap button arrows** (◀ / ▶) — this is the ONLY allowed Unicode-as-icon usage

---

## 6. Forbidden Patterns

1. **No `setStyleSheet()` calls on individual widgets in `.cpp` files.** All styling must come from QSS files. Exception: `QGraphicsDropShadowEffect` is allowed for card elevation.
2. **No global `* {}` selectors in QSS** — catches everything, breaks everything.
3. **No changing `QPushButton`, `QLabel`, `QWidget` globally** without first listing every view that uses them and waiting for approval.
4. **No changing padding/margin on `QComboBox`** without explicit approval — popup positioning is fragile.
5. **No changing `QListWidget` item sizing** without checking both sidebar and dropdown popups.
6. **No inline `setForeground(QColor(...))` for theme colors.** Status colors (paid=green, overdue=red) are allowed because they are semantic data colors, not theme colors, but they must use the palette values (`#16a34a` for success, `#dc2626` for danger).
7. **No SVG icons from sources other than Lucide.**
8. **No Unicode characters used as icons** except the flap button arrows.
9. **No animation/transition properties in QSS** — Qt Widgets does not support them reliably.
10. **No blue colors anywhere.**

---

## 7. Qt 6.8 Specific Features

- **Dark mode detection:** `QStyleHints` + `Qt::ColorScheme` signal
- **Font weights:** `QFont::Weight` enum (e.g., `QFont::Bold`) — not integer weights
- **Icon rendering:** `QSvgRenderer` with `currentColor` support
- **Charts:** `QChart::setAnimationOptions(QChart::SeriesAnimations)` for dashboard
- **High DPI:** Default in Qt 6 — do NOT set `AA_EnableHighDpiScaling` manually
- **Card elevation:** `QGraphicsDropShadowEffect` (QSS `box-shadow` does not exist in Qt Widgets)

---

## 8. Responsive Layout Rule

For any view with stat cards or charts:

- Use `QGridLayout`, **not** `QHBoxLayout` chains
- Set column stretch factors so extra space distributes evenly
- Minimum widths: stat cards 180px, charts 280px tall
- Size policy: `Expanding` both directions on charts, `Expanding` horizontal + `Fixed` vertical on stat cards
- Wrap the whole view in `QScrollArea` if content might exceed window on small screens (under 1200px wide)
- **Never use `FlowLayout` for primary content** — it does not fill width reliably

---

## 9. Delivery Rule

When a build is approved and produced:

- Provide the exact path to the new `MMS.exe`
- List the single change that was made
- List the views the user should test (focus on the Risk Areas declared in Scope)
- State the build number (increment from previous)
- Do NOT claim the change is "fully tested" — the user tests visually because the developer cannot

---

## 10. Project Context (for reference)

- **Source layout:** `src/core/`, `src/models/`, `src/repositories/`, `src/services/`, `src/views/`
- **Source files:** 51 `.cpp` + headers
- **SQL:** `sql/schema.sql`, `sql/seed.sql`, `sql/migrations/`
- **Resources:** `resources/mms.qrc`, `resources/styles/light.qss`, `resources/styles/dark.qss`, `resources/icons/svg/`, `resources/fonts/`, `resources/templates/`
- **Build:** CMake with `toolchain-mingw.cmake` for cross-compile Linux→Windows
- **Existing classes to reuse:** `StyledComboBox`, `EmptyStateWidget`, `FlowLayout`, `FontManager`, `I18N`
- **Existing views:** `LoginView`, `MainWindow`, `DashboardView`, `FamilyView`, `MemberView`, `SubscriptionView`, `DonationView`, `AccountingView`, `RegisterViews`, `OtherViews` (Certificate, Reports, Settings, Audit, Backup, UserMgmt), `TokenView`, `SplashScreen`

---

## 11. Change Log

| Date       | Change                              | Approved By |
|------------|-------------------------------------|-------------|
| 2026-07-23 | Initial creation of UI_RULES.md     | (pending)   |

---

**End of UI_RULES.md**
