# MMS Architecture Document

## 1. Overview

The Mahallu Management System (MMS) is a desktop application built on a layered MVVM + Repository + Service architecture. The design prioritizes:

- **Separation of concerns** — UI, business logic, and data access are isolated.
- **Testability** — Services depend on repository interfaces, enabling unit testing.
- **Maintainability** — Each module is self-contained; new modules can be added without affecting existing ones.
- **Performance** — SQLite with WAL mode, indexed queries, and prepared statements deliver sub-500ms search performance.
- **Security** — Authentication, authorization, audit logging, and password hashing are built into the core.

## 2. Layered Architecture

```
┌─────────────────────────────────────────────┐
│ View Layer (Qt Widgets)                     │
│  - MainWindow, LoginView, DashboardView     │
│  - FamilyView, MemberView, SubscriptionView │
│  - DonationView, AccountingView, ...        │
├─────────────────────────────────────────────┤
│ ViewModel Layer (Qt Models / Dialogs)       │
│  - Table models, form dialogs, validators   │
├─────────────────────────────────────────────┤
│ Service Layer (Business Logic)              │
│  - AuthService, FamilyService, ...          │
│  - Validates inputs, enforces business rules│
│  - Logs to audit_log                        │
├─────────────────────────────────────────────┤
│ Repository Layer (Data Access)              │
│  - FamilyRepository, MemberRepository, ...  │
│  - CRUD operations on SQLite                │
│  - Joins, filters, pagination               │
├─────────────────────────────────────────────┤
│ Core Infrastructure                         │
│  - Database (SQLite wrapper, transactions)  │
│  - Logger (rotating file logger)            │
│  - Config (paths, user prefs)               │
│  - Security (PBKDF2/Argon2 hashing)         │
├─────────────────────────────────────────────┤
│ SQLite Database                             │
└─────────────────────────────────────────────┘
```

## 3. SOLID Principles Applied

### Single Responsibility
Each class has one clear purpose:
- `FamilyService` validates and orchestrates family operations.
- `FamilyRepository` only handles SQL CRUD.
- `Logger` only logs.
- `Security` only handles crypto.

### Open/Closed
New modules can be added without modifying existing ones:
1. Add a new `XxxRepository`.
2. Add a new `XxxService` using the repository.
3. Add a new `XxxView` UI screen.
4. Register the view in `MainWindow::showApp()`.

### Liskov Substitution
All repositories follow the same pattern (CRUD + list). They can be swapped with mock implementations for testing.

### Interface Segregation
Each repository exposes only the methods needed by its service. `FamilyRepository` doesn't have welfare methods.

### Dependency Inversion
Services depend on repository classes (concrete in C++, but conceptually as interfaces). High-level modules (views) depend on services, not repositories directly.

## 4. Database Design

The schema uses:

- **Foreign keys** with appropriate `ON DELETE` actions (`RESTRICT` for critical links, `SET NULL` for optional ones, `CASCADE` for child tables).
- **Indexes** on all foreign keys and frequently-searched columns.
- **Constraints** (CHECK, UNIQUE, NOT NULL) to enforce data integrity at the DB level.
- **Triggers** to maintain `updated_at` timestamps.
- **Views** for complex aggregations (dashboard summary, defaulters, member directory).

## 5. Authentication & Authorization

### Authentication Flow
1. User enters username + password.
2. `AuthService::login` queries the user by username.
3. Checks `is_active` and `is_locked` flags.
4. Verifies password via `Security::verifyPassword` (PBKDF2-SHA256 or Argon2id).
5. On failure, increments `failed_attempts`; locks at 5.
6. On success, resets failed attempts, updates `last_login_at`, creates session.
7. Audit log records the login.

### Authorization Model
- Each (role, module, action) tuple has an `allowed` flag in `permissions`.
- `AuthSession::hasPermission(module, action)` checks the current user's role.
- The sidebar in `MainWindow::showApp()` filters visible modules by permission.
- Individual view actions (Add/Edit/Delete) should also check permission — current implementation defers to UI visibility.

## 6. Audit Logging

Every state-changing operation logs an entry to `audit_log`:

| Field | Description |
|-------|-------------|
| user_id | Acting user's ID |
| username | Acting user's username (denormalized for history) |
| action | LOGIN, LOGOUT, ADD, EDIT, DELETE, PRINT, EXPORT, BACKUP, RESTORE, PASSWORD_CHANGE, etc. |
| module | family, member, subscription, donation, ... |
| entity_id | ID of affected record |
| description | Human-readable summary |
| ip_address | (currently empty - desktop app) |
| created_at | Timestamp |

## 7. Theme System

Themes are applied via Qt Style Sheets (QSS):

- `SettingsService::applyTheme(themeName)` sets `qApp->setStyleSheet(...)`.
- Two built-in themes: `light` and `dark`.
- Theme is persisted in the `settings` table.
- Toggle button in the top bar switches between themes instantly.

## 8. Backup Strategy

- Backups are ZIP files containing the SQLite database.
- Backup format uses zlib's `compress2` for deflate compression.
- CRC32 verification on restore.
- Auto-backup runs on a configurable interval (default: 24 hours).
- Auto-backup also runs on application exit if enabled.
- Old backups can be pruned (keeps last 10).

## 9. Certificate Generation

PDF certificates are generated using `QPdfWriter` + `QPainter`:

- Layout: A4 portrait, decorative border, header, body, QR code, signature/seal.
- QR payload format: `MMS|<type>|<id>|<number>|<timestamp>` for verification.
- Types: Membership, Residence, Marriage, Death, Character, Income.
- Each certificate issuance is recorded in the `certificates` table.

## 10. Report Generation

`ReportService` produces 14 report types:

- Family Register, Member Register, Active Members, Family Directory
- Subscription Report, Defaulters Report
- Donation Report
- Income Report, Expense Report, Cash Book Report, Financial Summary
- Marriage Register Report, Death Register Report, Welfare Report

Each report can be exported to:
- **CSV** (UTF-8)
- **PDF** (with pagination, zebra striping, header on each page)
- **Excel-compatible CSV** (with BOM for proper Excel UTF-8 handling)

## 11. Performance Considerations

- SQLite WAL mode for concurrent read access.
- 64 MB page cache (`PRAGMA cache_size = -64000`).
- Indexed foreign keys for fast joins.
- Paginated queries (25 rows/page by default).
- `LIKE` queries with leading wildcard on small tables only.
- For full-text search on large datasets, consider adding FTS5 virtual tables in a future release.

## 12. Future Enhancements

- Multi-language support (Arabic, Malayalam, Urdu, Hindi) via Qt translation files.
- Email/SMS notification integration.
- Cloud sync option for multi-office deployments.
- Mobile companion app for member self-service.
- Online payment gateway integration for subscriptions.
- FTS5 full-text search for very large datasets (>25,000 members).
