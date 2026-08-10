# Minz Mahallu Management System (MMS)

<div align="center">

**A modern, production-grade mosque community administration system built with Qt 6 + QML**

![Qt 6.8](https://img.shields.io/badge/Qt-6.8+-green.svg)
![C++20](https://img.shields.io/badge/C%2B%2B-20-blue.svg)
![QML](https://img.shields.io/badge/QML-Quick-purple.svg)
![SQLite](https://img.shields.io/badge/SQLite-3-lightgrey.svg)
![Platform](https://img.shields.io/badge/Platform-Windows%20x64-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

</div>

---

## Overview

MMS is a comprehensive management system designed for Indian Muslim mahallu (parish) communities. It handles family registration, member management, financial collections, donations, accounting, marriage/death registers, welfare assistance, certificate generation, token distribution, and more — all in a beautiful, responsive desktop application.

Built with **Qt 6 Quick/QML** for the frontend and **C++20 + SQLite** for the backend, with zero compromise on either visual polish or data integrity.

---

## Features

### Core Modules (16 screens)
- **Dashboard** — Real-time KPI cards (families, members, collections, dues, donations, welfare, marriages, deaths, balance) wired to live database queries
- **Families** — Full CRUD with search, ward/status filters, pagination, auto-generated family numbers
- **Members** — Full CRUD with family linking, gender/status filters, family head management
- **Subscriptions** — Full CRUD + "Mark Overdue" batch action, plan selector, payment tracking
- **Donations** — Full CRUD with category filter, donor tracking, summary cards
- **Accounting** — Full CRUD with Income/Expense/Balance summary cards, ledger account selection
- **Marriage Register** — Full CRUD with 16-field form (bride, groom, 4 witnesses, mahar, imam)
- **Death Register** — Full CRUD with family linking, burial details
- **Welfare** — Full CRUD with Approve/Reject/Disburse workflow
- **Certificates** — Issue Membership/Residence/Marriage/Death certificates with PDF generation
- **Reports** — 14 report types with CSV/PDF/Excel export
- **Settings** — Organization info, theme toggle, language toggle, auto-backup config
- **Users** — User management with roles (Admin/President/Secretary/Treasurer/Imam/Staff/Auditor)
- **Audit Log** — Complete activity trail with action/module filters
- **Backup** — Create/Restore/Verify/Delete ZIP backups

### Design System
- **Emerald theme** — Green gradient sidebar, gold accents, tinted KPI cards
- **Light/Dark mode** — Instant switching via single `Theme.qml` singleton (zero inline colors)
- **Bilingual** — English + Malayalam (മലയാളം) with live language switching
- **Islamic geometric pattern** — Subtle 8-pointed star overlay on sidebar
- **Collapsible sidebar** — Flap button for expand/collapse with smooth animation
- **PerMonitorV2 DPI** — Crisp rendering at 100%, 125%, 150%, 175% Windows scaling
- **Responsive layout** — Grid columns adapt to window width (5→4→3→2→1)

### Architecture
```
QML (Presentation) → Controllers (Q_INVOKABLE) → Services (Business Logic) → Repositories (SQL) → SQLite
```
- **16 Controllers** — AuthController, FamilyController, MemberController, DashboardController, etc.
- **7 QAbstractListModel** subclasses for real-time table updates
- **Signal-based auto-refresh** — CRUD operations auto-refresh the table (no manual reload)
- **250+ I18N translation keys** — English + Malayalam
- **Audit logging** — Every ADD/EDIT/DELETE/LOGIN/LOGOUT recorded with actor
- **PBKDF2-HMAC-SHA256** password hashing (200k iterations)
- **WAL mode SQLite** with foreign keys, triggers, and views

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Qt 6.8 Quick, QML, QtQuick.Controls, QtQuick.Effects |
| Backend | C++20, Qt 6 Core/Sql/PrintSupport/Svg/Network |
| Database | SQLite 3 (WAL mode, foreign keys, triggers) |
| Security | OpenSSL 3 (PBKDF2-HMAC-SHA256) |
| Compression | zlib (ZIP backup/restore) |
| PDF | QPdfWriter + QPainter (certificates, reports) |
| Build | CMake 3.21+, MSVC 2022 / Ninja |
| CI/CD | GitHub Actions (Windows, auto-build on push) |

---

## Screenshots

> The approved design system features:
> - Green gradient sidebar (`#0a7f5d → #065f46 → #044633`)
> - Gold accent indicators (`#f2c14e`)
> - Tinted KPI cards (10 stat cards in 5-column grid)
> - White surface cards with `#d2e5d8` borders
> - Poppins typography (Anek Malayalam for Malayalam)
> - Islamic geometric star pattern on sidebar

---

## Getting Started

### Prerequisites
- Windows 10/11 x64
- No installation required — portable executable

### Download
1. Go to [Actions → Build Windows](https://github.com/kuttappu507/minzmahallu/actions)
2. Download the latest `MMS-portable` artifact
3. Extract the ZIP
4. Run `run_mms.bat`

### Default Login
```
Username: admin
Password: admin123
```

---

## Project Structure

```
minzmahallu/
├── qml/
│   ├── theme/
│   │   └── Theme.qml              # Single source of visual tokens
│   ├── components/
│   │   ├── AppButton.qml           # Primary/secondary/danger/ghost variants
│   │   ├── AppTextField.qml       # Label + input + error state
│   │   ├── AppComboBox.qml         # Styled dropdown with popup
│   │   ├── TableActionButton.qml  # Momentary action (view/edit/delete)
│   │   ├── StatusBadge.qml         # Active/Inactive/Overdue/Pending badges
│   │   ├── ModalDialog.qml         # Shared modal shell (backdrop + card)
│   │   └── ConfirmDialog.qml       # Delete confirmation
│   ├── pages/
│   │   ├── LoginPage.qml          # Auth gate
│   │   ├── SplashScreen.qml       # 2-second branded splash
│   │   ├── FamiliesPage.qml       # Family list + CRUD
│   │   ├── MembersPage.qml        # Member list + CRUD
│   │   └── ... (16 pages total)
│   └── design/
│       ├── AppShell.qml            # Main window (sidebar + topbar + stack)
│       └── DashboardPage.qml      # Dashboard with KPI cards
├── src/
│   ├── core/                       # Config, Database, I18N, Security, Logger
│   ├── models/                     # Family, Member, Subscription, etc.
│   ├── repositories/               # SQL queries (FamilyRepository, etc.)
│   ├── services/                   # Business logic + QML controllers
│   └── app_main.cpp               # Entry point
├── sql/
│   ├── schema.sql                  # 20 tables, 3 views, 5 triggers
│   ├── seed.sql                    # Demo data (15 families, 30 members)
│   └── migrations/                 # Schema migrations
├── resources/
│   ├── fonts/                      # Poppins + NotoSans + AnekMalayalam
│   ├── icons/svg/                  # 40+ Lucide SVG icons
│   ├── templates/                  # HTML certificate templates
│   └── app.manifest                # PerMonitorV2 DPI manifest
└── .github/workflows/             # CI/CD pipeline
```

---

## Build from Source

```bash
# Prerequisites: Qt 6.8+, MSVC 2022, CMake 3.21+
git clone https://github.com/kuttappu507/minzmahallu.git
cd minzmahallu
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel 4
```

---

## License

MIT License — see [LICENSE](LICENSE)

---

<div align="center">

**Built with care for the Muslim community** 🕌

</div>
