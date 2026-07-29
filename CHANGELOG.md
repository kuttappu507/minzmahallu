# MMS Changelog

## [1.0.0] - 2024-12-15

### Added
- Initial production release of Mahallu Management System (MMS).
- Complete C++20 / Qt 6.8+ / SQLite desktop application.
- 14 modules:
  - Authentication with PBKDF2/Argon2 password hashing
  - Dashboard with stats and Qt Charts visualizations
  - Family Management with CRUD, archive/restore, search
  - Member Management with photo upload, family head designation
  - Subscription Collection with receipt generation, defaulters tracking
  - Donation Management with categories and donor history
  - Accounting with income/expense transactions, ledger accounts
  - Marriage Register with certificate generation
  - Death Register with auto member status update
  - Welfare Management with approval workflow (Pending → Approved → Disbursed)
  - Certificate Generation (Membership, Residence, Marriage, Death) with PDF + QR codes
  - Reports module with 14 report types exportable to PDF/CSV/Excel
  - Audit Log with searchable history
  - Backup & Restore with ZIP compression, verify, prune
  - Settings with theme toggle (light/dark), logo & seal upload
- 7 user roles with fine-grained per-module permissions.
- SQLite database with foreign keys, indexes, triggers, and views.
- Full audit trail of all user actions.
- Light and dark themes.
- Multi-resolution support (1366x768 to 4K).
- Inno Setup installer + portable ZIP distribution.
- Comprehensive documentation:
  - Architecture Document
  - Database Documentation
  - User Manual
  - Administrator Manual
  - Installation Guide
  - Developer Guide

### Security
- Account locking after 5 failed login attempts (15-min lockout).
- Strong password policy enforcement.
- SQL injection protection via prepared statements.
- All state changes logged to audit_log.

### Performance
- SQLite WAL mode for concurrent reads.
- 64 MB cache for fast queries.
- Paginated UI queries (25 rows/page default).
- Sub-3-second startup time.
- Sub-500ms search performance.
- Sub-5-second report generation.

### Tested
- Database initialization & migration.
- Authentication (login, logout, password change, failed attempts).
- Family CRUD (create, update, archive, restore, delete).
- Member CRUD with photo upload.
- Subscription collection & defaulters tracking.

## [Unreleased]

### Planned
- Multi-language support (Arabic, Malayalam, Urdu, Hindi).
- FTS5 full-text search for very large datasets (>25,000 members).
- Email/SMS notification integration.
- Online payment gateway integration.
- Cloud sync for multi-office deployments.
