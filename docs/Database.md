# MMS Database Documentation

## Overview

The MMS database uses SQLite 3.35+ with the following configuration:

```sql
PRAGMA journal_mode = WAL;        -- Write-Ahead Logging for concurrent reads
PRAGMA synchronous = NORMAL;      -- Balance between safety and speed
PRAGMA foreign_keys = ON;         -- Enforce referential integrity
PRAGMA encoding = 'UTF-8';        -- Unicode support
PRAGMA cache_size = -64000;       -- 64 MB cache
```

## Schema Diagram

```
┌─────────────┐     ┌──────────────┐
│   users     │     │ permissions  │
└─────────────┘     └──────────────┘
       │
       │
┌─────────────┐
│  sessions   │
└─────────────┘

┌─────────────┐     ┌──────────────┐     ┌────────────────────┐
│  families   │────▶│   members    │────▶│   subscriptions    │
└─────────────┘     └──────────────┘     └────────────────────┘
       │                    │                       │
       │                    │                       ▼
       │                    │              ┌─────────────────┐
       │                    │              │ subscription_   │
       │                    │              │ plans           │
       │                    │              └─────────────────┘
       │                    │
       │                    ▼
       │              ┌──────────────┐
       │              │  documents   │
       │              └──────────────┘
       │
       ├────▶ ┌──────────────┐ ────▶ ┌──────────────┐
       │      │  donations   │      │ donation_    │
       │      └──────────────┘      │ categories   │
       │                             └──────────────┘
       │
       ├────▶ ┌──────────────┐
       │      │  marriages   │
       │      └──────────────┘
       │
       ├────▶ ┌──────────────┐
       │      │   deaths     │
       │      └──────────────┘
       │
       └────▶ ┌────────────────────┐
              │  welfare_requests  │
              └────────────────────┘

┌──────────────────┐     ┌──────────────────┐
│ ledger_accounts  │────▶│  transactions    │
└──────────────────┘     └──────────────────┘
                                │ (polymorphic linked_module + linked_id)
                                ▼
                  subscriptions / donations / welfare_requests

┌──────────────────┐     ┌──────────────┐     ┌──────────────┐
│  certificates    │     │  audit_log   │     │  settings    │
└──────────────────┘     └──────────────┘     └──────────────┘

┌──────────────┐
│ notifications│
└──────────────┘
```

## Tables

### users
Holds application users and their authentication data.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PK AUTOINCREMENT | |
| username | TEXT | NOT NULL UNIQUE NOCASE | |
| full_name | TEXT | NOT NULL | |
| password_hash | TEXT | NOT NULL | Encoded: `algo$iter$salt_b64$hash_b64` |
| password_salt | TEXT | NOT NULL | Base64-encoded salt |
| role | TEXT | CHECK in role list | One of 7 predefined roles |
| email | TEXT | | |
| phone | TEXT | | |
| is_active | INTEGER | DEFAULT 1 | 0/1 |
| is_locked | INTEGER | DEFAULT 0 | 0/1 |
| failed_attempts | INTEGER | DEFAULT 0 | Counter for lockout |
| locked_until | TEXT | | ISO datetime |
| last_login_at | TEXT | | ISO datetime |
| must_change_pwd | INTEGER | DEFAULT 0 | Force password change on next login |
| created_at, updated_at | TEXT | DEFAULT now | Triggers update `updated_at` |

### permissions
Fine-grained role-based access control matrix.

| Column | Type | Constraints |
|--------|------|-------------|
| id | INTEGER | PK |
| role | TEXT | NOT NULL |
| module | TEXT | NOT NULL |
| action | TEXT | NOT NULL |
| allowed | INTEGER | DEFAULT 0 |
| | | UNIQUE(role, module, action) |

### settings
Single-row table (PK constrained to `1`) holding organization settings.

### families
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER | PK |
| family_number | TEXT | UNIQUE (e.g. FAM-0001) |
| house_name, house_number, ward, area, address, pincode | TEXT | Address fields |
| phone, alternative_phone | TEXT | Contact |
| status | TEXT | CHECK in (Active, Inactive, Archived) |
| notes | TEXT | Free text |

### members
| Column | Type | Notes |
|--------|------|-------|
| id | INTEGER | PK |
| family_id | INTEGER | FK → families(id) ON DELETE RESTRICT |
| member_code | TEXT | UNIQUE (e.g. MEM-0001) |
| photo_path | TEXT | Relative file path |
| name, arabic_name | TEXT | Bilingual name |
| gender | TEXT | CHECK (Male, Female, Other) |
| date_of_birth | TEXT | ISO date |
| age | INTEGER | Auto-computed in service |
| blood_group | TEXT | ABO+Rh |
| occupation, education, marital_status | TEXT | |
| mobile, email, emergency_contact | TEXT | |
| nationality | TEXT | Default 'Indian' |
| relationship | TEXT | Head/Spouse/Son/Daughter/Parent/Other |
| is_head | INTEGER | Boolean |
| status | TEXT | Active/Inactive/Deceased |

### subscription_plans
Master list of subscription types (Monthly, Yearly, Special) with default amounts.

### subscriptions
Records each subscription billing & payment.

| Column | Type | Notes |
|--------|------|-------|
| family_id | INTEGER | FK families |
| member_id | INTEGER | FK members (nullable) |
| plan_id | INTEGER | FK subscription_plans |
| period_start, period_end | TEXT | Billing period |
| amount, amount_paid | REAL | Total and paid amount |
| payment_date | TEXT | When paid |
| receipt_number | TEXT | UNIQUE |
| payment_method | TEXT | CHECK Cash/Cheque/UPI/Bank Transfer/Card/Other |
| status | TEXT | CHECK Paid/Pending/Overdue/Partial |

### donation_categories
Master list of donation categories (General, Masjid, Building, Education, Medical).

### donations
Records each donation with donor info, category, amount, receipt.

### ledger_accounts
Chart of accounts: Income/Expense/Asset/Liability with category codes.

### transactions
Polymorphic accounting transactions linked to subscriptions/donations/welfare via `linked_module` + `linked_id`.

### marriages
Marriage register with bride, groom, witnesses, mahar, nikah date.

### deaths
Death register with deceased, father, dates, cause, burial.

### welfare_requests
Welfare aid requests with approval workflow (Pending → Approved → Disbursed).

### certificates
Issued certificate log with QR payload for verification.

### documents
Polymorphic attachment storage linked to any entity via `linked_module` + `linked_id`.

### audit_log
Immutable log of all user actions.

### sessions
Active login session tracking.

### notifications
In-app notification messages for users.

## Views

### v_defaulters
Lists families with pending or overdue subscriptions and their total due amount.

### v_member_directory
Joined view of members with their family details for easy lookup.

### v_dashboard_summary
Aggregated dashboard metrics (total families, members, monthly collection, etc.).

## Triggers

Five triggers automatically update `updated_at` on the main entities (users, families, members, subscriptions, welfare_requests).

## Indexes

Indexes are created on:
- All foreign key columns
- Frequently-searched text columns (name, phone, mobile, receipt_number)
- Status columns for filtered queries
- Date columns for range queries

## Migration System

Migrations are stored as `sql/migrations/V<NNN>_<description>.sql` files. The Database class:

1. Reads current `schema_version` from the `schema_version` table.
2. Lists all `V*.sql` files in `migrations/`.
3. Applies each file with version > current in order.
4. Records each applied migration.

## Performance Notes

- All search queries use indexed columns.
- Pagination uses `LIMIT ? OFFSET ?`.
- Dashboard stats use the `v_dashboard_summary` view (single query).
- WAL mode allows concurrent readers during writes.
- The 64 MB cache (`PRAGMA cache_size = -64000`) fits the working set for up to 25,000 members.
