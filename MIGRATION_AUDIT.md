# MMS — Qt Widgets → Qt Quick/QML Migration Audit

**Task ID:** AUDIT-1
**Agent:** general-purpose (research sub-agent)
**Date:** generated during AUDIT-1
**Scope:** Full audit of the existing Qt Widgets MMS codebase at `/home/z/my-project/minzmahallu/` to prepare a migration to Qt Quick/QML.
**Constraint:** RESEARCH ONLY — no files were modified.

---

## Section 1 — Application Overview

### What the app does
**Minz Mahallu Management System (MMS)** is a mosque-community (mahallu) administration
package targeted at Indian Muslim congregations. It manages:

- **Families** — household registration, address, ward, status (Active/Inactive/Archived)
- **Members** — individuals inside a family, with head-of-family flag, photo, demographics
- **Subscriptions** — recurring monthly/annual/special contributions, with receipt numbers, partial/overdue state, defaulters view
- **Donations** — one-off donations categorized (General/Masjid/Building/Education/Medical)
- **Accounting** — ledger accounts (Income/Expense/Asset/Liability), transactions, monthly summaries
- **Marriage Register** — nikah records with bride/groom/witnesses/mahar/imam
- **Death Register** — death/burial records, auto-marks the linked member as Deceased
- **Welfare** — assistance requests with approve/reject/disburse workflow
- **Certificates** — Membership/Residence/Marriage/Death/Character/Income, with QR code + PDF generation
- **Tokens** — meat/food distribution token events, with per-family unique 4-digit codes and collection tracking (note: schema for this module is MISSING — see Section 3)
- **Reports** — 13 built-in reports exported as PDF/CSV/Excel (UTF-8 BOM CSV)
- **Users** — admin/President/Secretary/Treasurer/Imam/Staff/Auditor roles, with permission matrix and account lockout
- **Audit Log** — every ADD/EDIT/DELETE/PRINT/EXPORT/BACKUP/RESTORE/LOGIN/LOGOUT is recorded
- **Backup/Restore** — manual ZIP backups of the SQLite DB with deflate compression (custom minizip-style writer)

### Tech stack
- **Language:** C++20
- **Framework:** Qt 6.5+ (project tracks 6.8.0 in `toolchain-mingw.cmake`)
- **DB:** SQLite 3.35+ (via `QSqlDatabase` + `QSQLITE` driver), WAL journal mode, foreign keys ON
- **Hashing:** OpenSSL 3.x — PBKDF2-HMAC-SHA256 200k iters (Argon2id preferred if available)
- **Compression:** zlib (manual ZIP framing in `BackupService.cpp`)
- **PDF:** `QPdfWriter` + `QPainter` (no external PDF library)
- **Charts:** `QtCharts` (QChart/QChartView, only used by widgets `DashboardView`)
- **Build:** CMake 3.21+, MSVC 2022 (primary) or MinGW (cross-compile for Windows)
- **I18N:** Custom `I18N` singleton — hardcoded hash of EN + Malayalam strings (no .ts/.qm files)

### Build targets (from `CMakeLists.txt`)
| Target | Purpose | Built when |
|---|---|---|
| `MMS` (WIN32 exe) | **Original Qt Widgets application** — the production app shipped in the dist zip | `MMS_QML_ONLY=OFF` and all Qt6 widgets modules found |
| `mms_tests` | Unit tests (TestDatabase/TestAuth/TestFamily/TestMember/TestSubscription) | `BUILD_TESTS=ON` |
| `mms_qml_smoke` | Phase-2 minimal QML loader — no backend | `MMS_BUILD_QML_SMOKE=ON` (default) |
| `mms_design_preview` | Phase-3 design system showcase — no backend | `MMS_BUILD_DESIGN_PREVIEW=ON` (default) |
| `mms_dashboard_v2` | DashboardV2 preview — visual only, no backend | `MMS_BUILD_DASHBOARD_V2=ON` |
| `mms_dashboard_v3` | DashboardV3 preview — visual only, no backend | `MMS_BUILD_DASHBOARD_V3=ON` |
| `mms_app` | **The new full QML+backend application** — the migration target. Uses `src/app_main.cpp`, links all backend sources + QML modules | `MMS_BUILD_APP=ON` (default) |

Note: `MMS` (widgets) and `mms_app` (QML) **both compile the same backend sources** (everything in `src/` except the `_main.cpp` files). The only differences are: `MMS` uses `src/main.cpp` (QApplication + MainWindow + SplashScreen), `mms_app` uses `src/app_main.cpp` (QGuiApplication + QQmlApplicationEngine + QmlServices context property).

---

## Section 2 — Module Map (key deliverable)

Each module below is a self-contained vertical slice: QWidgets View → Dialog → Service → Repository → Model → SQL table.

### 2.1 Dashboard

| Field | Value |
|---|---|
| Module Name | Dashboard |
| Widget View File | `src/views/DashboardView.cpp` / `.h` |
| Dialog File(s) | none |
| Service | `DashboardService` — `load()`, `monthlyCollections(months)`, `monthlyDonations(months)`, `monthlyExpenses(months)`, `membershipGrowth(months)`, `donationsByCategory(from,to)`, `familiesByWard()`, `membersByAgeGroup()`, `incomeVsExpense(months)` |
| Repository | none (queries DB directly via `Database::instance().execute`) |
| Database Table(s) | `v_dashboard_summary` (view), `families`, `members`, `subscriptions`, `donations`, `transactions`, `welfare_requests`, `marriages`, `deaths` |
| Model | `DashboardStats` struct (declared inline in `DashboardService.h`) |
| CRUD operations | Read-only — 10 stat cards + 4 charts + recent activity table |
| Validation rules | none |
| Signals/slots | `refresh()` public slot, `navigateToView(int index)` signal (lets dashboard quick-action buttons jump to other pages) |
| Special features | QChart-based bar/line/pie charts; "Quick action" buttons that request navigation to other views via signal; greet-by-time-of-day |
| Dependencies | All other modules (it's an aggregator) |
| QML screen status | **Visual only** — `qml/design/DashboardPage.qml` has hardcoded mock values (`"248"`, `"1,142"`, `"₹48,200"` etc.). No call to `DashboardService`. Quick-action buttons are non-functional. |

### 2.2 Families

| Field | Value |
|---|---|
| Module Name | Families |
| Widget View File | `src/views/FamilyView.cpp` / `.h` |
| Dialog File(s) | `src/views/FamilyEditDialog.cpp` / `.h` |
| Service | `FamilyService` — `createFamily(Family&, QString*)`, `updateFamily(Family, QString*)`, `archiveFamily(id)`, `restoreFamily(id)`, `deleteFamily(id, QString*)`, `searchFamilies(term,page,size,status,ward,int*)`, `getFamily(id)`, `totalFamilies()`, `activeFamilies()`, `wards()` |
| Repository | `FamilyRepository` — `findById`, `findByNumber`, `list(page,size,term,status,ward,int*)`, `listAll(status)`, `count`, `generateNextFamilyNumber`, `create`, `update`, `remove` (soft=archive), `hardDelete` (blocks if members exist), `archive`, `restore`, `countByStatus`, `countByWard`, `listWards` |
| Database Table(s) | `families` |
| Model | `Family` struct — `id, familyNumber, houseName, houseNumber, ward, area, address, pincode, phone, alternativePhone, status, notes, createdAt, updatedAt` + joined `memberCount, headName` |
| CRUD operations | Create, Read (paginated search), Update, Archive (soft), Restore, Hard Delete (gated on no members) |
| Validation rules | (from `FamilyService::createFamily`) Either `houseName` OR `address` required; at least one of `phone`/`alternativePhone` required; phone must match `^(\+?\d{1,3}[-\s]?)?\d{10}$`; pincode must be 6 digits (`^\d{6}$`); family number must be unique (auto-generated as `FAM-NNNN` if empty) |
| Signals/slots | `FamilyView::refresh()` public slot; dialog `onSave()`/`onCancel()` private slots |
| Special features | Family number auto-generated as `FAM-NNNN` (zero-padded, based on max id); ward filter dropdown populated from `SELECT DISTINCT ward FROM families`; print/export via `ReportService::familyRegister`; double-click row to edit |
| Dependencies | `AuditLogRepository` (writes ADD/EDIT/DELETE/ARCHIVE/RESTORE entries), `AuthSession` (gets current user for audit log) |
| QML screen status | **Partial** — `qml/pages/FamiliesPage.qml` calls `Services.searchFamilies`, `Services.totalFamilies`, `Services.wards`, `Services.deleteFamily`, `Services.getFamily`. `qml/pages/FamilyEditDialog.qml` calls `Services.createFamily` / `Services.updateFamily` but **does NOT check the return value** (see Section 5). Ward combo is **hardcoded** `["Ward 1".."Ward 4"]` instead of using `Services.wards`. The `notes` field is missing from the QML form (always empty). |

### 2.3 Members

| Field | Value |
|---|---|
| Module Name | Members |
| Widget View File | `src/views/MemberView.cpp` / `.h` |
| Dialog File(s) | `src/views/MemberEditDialog.cpp` / `.h` |
| Service | `MemberService` — `createMember`, `updateMember`, `deleteMember` (blocks if `isHead`), `searchMembers`, `familyMembers`, `getMember`, `setFamilyHead`, `totalMembers`, `activeMembers`, `maleMembers`, `femaleMembers`, `savePhoto` |
| Repository | `MemberRepository` — `findById`, `findByCode`, `listByFamily`, `list(page,size,term,gender,status,familyId,int*)`, `listAll`, `generateNextMemberCode`, `create`, `update`, `remove` (hard), `setStatus`, `count`, `countByStatus`, `countByGender`, `countActiveMembers`, `findFamilyHead`, `setFamilyHead` (transaction: clears old head, sets new) |
| Database Table(s) | `members` |
| Model | `Member` struct — `id, familyId, memberCode, photoPath, name, arabicName, gender, dateOfBirth, age, bloodGroup, occupation, education, maritalStatus, mobile, email, nationality, address, emergencyContact, relationship, isHead, status, createdAt, updatedAt` + joined `familyNumber, houseName` |
| CRUD operations | Create, Read, Update, Hard Delete (gated: cannot delete head) |
| Validation rules | `name` required; `familyId > 0` required; gender ∈ {Male,Female,Other}; mobile must match phone regex (optional); email must match email regex (optional); auto-compute age from DOB if not provided |
| Signals/slots | `MemberView::refresh()`; dialog `onSave/onUploadPhoto/onFamilyChanged` slots |
| Special features | Photo upload — copies file to `dataDir/attachments/photos/member_<id>.<ext>`; family combo in dialog loads all Active families; when family changes, shows family info; auto-compute age; "is_head" derived from `relationship == "Head"` |
| Dependencies | `FamilyRepository` (for combo box), `AuditLogRepository`, `AuthSession`, `Config` (for attachment dir) |
| QML screen status | **Not started** — no QML Members page exists. AppShell sidebar lists "Members" but AppShell StackLayout shows "Coming soon" placeholder. |

### 2.4 Subscriptions

| Field | Value |
|---|---|
| Module Name | Subscriptions |
| Widget View File | `src/views/SubscriptionView.cpp` / `.h` |
| Dialog File(s) | `src/views/SubscriptionEditDialog.cpp` / `.h` |
| Service | `SubscriptionService` — `createSubscription`, `updateSubscription`, `deleteSubscription`, `list`, `defaulters`, `markOverdue`, `plans`, `totalCollected(from,to)`, `totalPending`, `monthlyCollection`, `nextReceiptNumber` |
| Repository | `SubscriptionRepository` — `findById`, `findByReceiptNumber`, `listPlans`, `findPlan`, `list(page,size,status,from,to,familyId,int*)`, `generateNextReceiptNumber`, `create` (also creates a linked Income transaction if Paid), `update`, `remove`, `markOverdue`, `defaulters` (uses `v_defaulters` view), `totalCollected`, `totalPending`, `totalCollectedThisMonth` |
| Database Table(s) | `subscriptions`, `subscription_plans` (lookup), `transactions` (auto-creates Income row on Paid) |
| Model | `Subscription` struct — `id, familyId, memberId, planId, periodStart, periodEnd, amount, amountPaid, paymentDate, receiptNumber, paymentMethod, transactionRef, status, collectedBy, remarks, createdAt, updatedAt` + joined `familyNumber, memberName, planName`. Also `SubscriptionPlan` struct. |
| CRUD operations | Create, Read, Update, Delete (cascade-deletes linked transaction), Mark Overdue |
| Validation rules | `familyId > 0` required; `planId > 0` required; `amount > 0` required; `amountPaid <= amount`; if status=="Paid" and `amountPaid < amount`, force status to "Partial"; auto-set `paymentDate` to today if Paid and missing; auto-set `collectedBy` to current user |
| Signals/slots | `SubscriptionView::refresh()`; tab switch slot (Subscriptions tab vs Defaulters tab) |
| Special features | Two-tab UI (Subscriptions / Defaulters); "Mark Overdue" batch action updates all Pending subs whose `period_end < today`; auto-creates linked `transactions` row of type Income to `INC-SUB` ledger account on Paid; receipt number auto-generated as `RCP-XXXXXX` (6-char random) |
| Dependencies | `FamilyRepository`, `MemberRepository`, `AuditLogRepository`, `AuthSession` |
| QML screen status | **Not started** — AppShell shows placeholder. |

### 2.5 Donations

| Field | Value |
|---|---|
| Module Name | Donations |
| Widget View File | `src/views/DonationView.cpp` / `.h` |
| Dialog File(s) | `DonationEditDialog` (inline class in `DonationView.cpp` — no separate header) |
| Service | `DonationService` — `createDonation`, `updateDonation`, `deleteDonation`, `list`, `categories`, `donorHistory`, `totalDonations(from,to)`, `nextReceiptNumber` |
| Repository | `DonationRepository` — `findById`, `findByReceipt`, `listCategories`, `findCategory`, `list`, `generateReceiptNumber` ("DON-XXXXXX"), `create` (auto-creates Income transaction to `INC-DON`), `update`, `remove` (cascade-deletes linked transaction), `totalDonations`, `totalByCategory`, `donorHistory` |
| Database Table(s) | `donations`, `donation_categories` (lookup), `transactions` (auto Income) |
| Model | `Donation` struct — `id, donorName, donorPhone, donorAddress, familyId, memberId, categoryId, amount, donationDate, receiptNumber, purpose, remarks, paymentMethod, receivedBy, createdAt` + joined `categoryName, familyNumber`. Also `DonationCategory` struct. |
| CRUD operations | Create, Read, Update, Delete |
| Validation rules | `donorName` required; `amount > 0`; `categoryId > 0`; auto-set `donationDate` to today if missing; auto-set `receivedBy` to current user |
| Signals/slots | `DonationView::refresh()` |
| Special features | Date range + category + search-term filter; auto-creates linked `transactions` Income row to `INC-DON` on insert; print/export via `ReportService::donationReport` |
| Dependencies | `FamilyRepository`, `MemberRepository`, `AuditLogRepository`, `AuthSession` |
| QML screen status | **Not started** — AppShell shows placeholder. |

### 2.6 Accounting

| Field | Value |
|---|---|
| Module Name | Accounting |
| Widget View File | `src/views/AccountingView.cpp` / `.h` |
| Dialog File(s) | Inline transaction dialog (within `AccountingView.cpp`) |
| Service | `AccountingService` — `accounts(typeFilter)`, `account(id)`, `createTransaction`, `updateTransaction`, `deleteTransaction`, `listTransactions`, `totalIncome(from,to)`, `totalExpense(from,to)`, `balance(from,to)`, `monthlySummary(year)`, `accountTotals(from,to)` |
| Repository | `AccountingRepository` — `listAccounts`, `findAccount`, `findAccountByCode`, `createAccount`, `updateAccount`, `findTransaction`, `listTransactions`, `createTransaction`, `updateTransaction`, `removeTransaction`, `totalIncome`, `totalExpense`, `balance`, `monthlySummary` (group by `strftime('%Y-%m')`), `accountTotals` |
| Database Table(s) | `transactions`, `ledger_accounts` |
| Model | `Transaction` struct — `id, txnDate, accountId, type, amount, paymentMethod, reference, description, linkedModule, linkedId, receiptNumber, createdBy, createdAt` + joined `accountName, accountCode`. Also `LedgerAccount` struct. |
| CRUD operations | Create transaction, Read, Update, Delete (account create/update also supported but no UI) |
| Validation rules | `accountId > 0` required; `amount > 0` required; auto-set `txnDate` to today if missing; auto-set `createdBy` to current user; `type` is derived from `LedgerAccount.type` (Expense ledger → Expense txn) |
| Signals/slots | `AccountingView::refresh()`; tab-switch (Transactions / Summary) |
| Special features | Two-tab UI; summary table aggregates per account; auto-derive type from account; print/export via `ReportService::cashBookReport` / `incomeReport` / `expenseReport` / `financialSummary` |
| Dependencies | `AuditLogRepository`, `AuthSession` |
| QML screen status | **Not started** — AppShell shows placeholder. |

### 2.7 Marriage Register

| Field | Value |
|---|---|
| Module Name | Marriage |
| Widget View File | `src/views/RegisterViews.cpp` (`MarriageView` class) |
| Dialog File(s) | `MarriageEditDialog` (inline in `RegisterViews.cpp`) |
| Service | `MarriageService` (declared in `RegisterServices.h`) — `createMarriage`, `updateMarriage`, `deleteMarriage`, `list`, `getMarriage`, `nextMarriageNumber`, `countThisYear` |
| Repository | `MarriageRepository` — `findById`, `findByNumber`, `list`, `generateNextNumber` (`MRG-YYYY-NNN`), `create`, `update`, `remove`, `countThisYear`, `countByYear` |
| Database Table(s) | `marriages` |
| Model | `Marriage` struct — `id, marriageNumber, brideName, brideFather, brideAddress, groomName, groomFather, groomAddress, witness1..4, mahar, nikahDate, registrationDate, imamId, place, remarks, createdAt` + joined `imamName` |
| CRUD operations | Create, Read, Update, Delete |
| Validation rules | `brideName` required; `groomName` required; `nikahDate` required; auto-set `registrationDate` to today if missing; auto-generate `marriageNumber` as `MRG-YYYY-NNN` if empty |
| Signals/slots | `MarriageView::refresh()` |
| Special features | "Certificate" button issues a Marriage certificate via `CertificateService::generateMarriageCertificatePdf`; search by bride/groom/father names; date range filter; print/export via `ReportService::marriageRegisterReport` |
| Dependencies | `CertificateService`, `AuditLogRepository`, `AuthSession` |
| QML screen status | **Not started** |

### 2.8 Death Register

| Field | Value |
|---|---|
| Module Name | Death |
| Widget View File | `src/views/RegisterViews.cpp` (`DeathView` class) |
| Dialog File(s) | `DeathEditDialog` (inline) |
| Service | `DeathService` (`RegisterServices.h`) — `createDeath`, `updateDeath`, `deleteDeath`, `list`, `getDeath`, `nextDeathNumber` (`DTH-YYYY-NNN`), `countThisYear` |
| Repository | `DeathRepository` — `findById`, `findByNumber`, `list`, `generateNextNumber`, `create` (auto-marks linked member as Deceased by name match!), `update`, `remove`, `countThisYear`, `countByYear` |
| Database Table(s) | `deaths`, `members` (side-effect: status → Deceased) |
| Model | `Death` struct — `id, deathNumber, deceasedName, fatherName, familyId, gender, dateOfDeath, burialDate, causeOfDeath, burialPlace, age, remarks, createdAt` + joined `familyNumber, houseName` |
| CRUD operations | Create, Read, Update, Delete |
| Validation rules | `deceasedName` required; `dateOfDeath` required; auto-generate `deathNumber` |
| Signals/slots | `DeathView::refresh()` |
| Special features | On create, runs `UPDATE members SET status='Deceased' WHERE family_id=? AND name=?` — fragile (name match, not member_id link); "Certificate" button generates death certificate PDF |
| Dependencies | `CertificateService`, `AuditLogRepository`, `AuthSession` |
| QML screen status | **Not started** |

### 2.9 Welfare

| Field | Value |
|---|---|
| Module Name | Welfare |
| Widget View File | `src/views/RegisterViews.cpp` (`WelfareView` class) |
| Dialog File(s) | `WelfareEditDialog` + `WelfareApproveDialog` (inline) |
| Service | `WelfareService` (`RegisterServices.h`) — `createRequest`, `updateRequest`, `deleteRequest`, `approveRequest(id,amount,remarks)`, `rejectRequest`, `disburseRequest` (auto-creates Expense transaction to `EXP-WEL`), `list`, `getRequest`, `nextRequestNumber` |
| Repository | `WelfareRepository` — `findById`, `findByNumber`, `list`, `generateNextNumber` (`WEL-YYYY-NNN`), `create`, `update`, `remove`, `approve`, `reject`, `disburse` (transaction: update status + create Expense txn), `countByStatus`, `totalDisbursedThisYear`, `listByFamily` |
| Database Table(s) | `welfare_requests`, `transactions` (auto Expense on disburse) |
| Model | `WelfareRequest` struct — `id, requestNumber, applicantName, familyId, category, amountRequested, amountApproved, reason, status, approvedBy, disbursedDate, remarks, createdAt, updatedAt` + joined `familyNumber, approvedByName` |
| CRUD operations | Create, Read, Update, Delete, Approve, Reject, Disburse (workflow: Pending→Approved→Disbursed or Pending→Rejected) |
| Validation rules | `applicantName` required; `amountRequested > 0`; `reason` required; `category` ∈ {Medical Aid, Education Aid, Marriage Assistance, Financial Assistance} (matches DB CHECK constraint) |
| Signals/slots | `WelfareView::refresh()` |
| Special features | Status filter + category filter; disburse creates linked `transactions` Expense row to `EXP-WEL` ledger |
| Dependencies | `AuditLogRepository`, `AuthSession` |
| QML screen status | **Not started** |
| **⚠ Critical data bug** | `sql/seed.sql` inserts welfare categories as `'Medical', 'Housing', 'Education', 'General'` — **NONE of these match the schema CHECK constraint** `'Medical Aid','Education Aid','Marriage Assistance','Financial Assistance'`. The seed insert would FAIL with a CHECK constraint violation. See Section 3. |

### 2.10 Certificates

| Field | Value |
|---|---|
| Module Name | Certificates |
| Widget View File | `src/views/OtherViews.cpp` (`CertificateView` class) |
| Dialog File(s) | None — uses QInputDialog for member/family selection |
| Service | `CertificateService` — `issueCertificate`, `list`, `generatePdf(certId)`, `generateMarriageCertificatePdf(marriageId)`, `generateDeathCertificatePdf(deathId)`, `typeToString`/`stringToType` |
| Repository | `CertificateRepository` + `DocumentRepository` (declared together in `CertificateRepository.h`) — `findById`, `findByNumber`, `list`, `generateNumber` (`<PREFIX>-YYYY-NNNN`), `create` (auto-fills QR payload, updates with cert id after insert), `remove`, `countByType`, `countThisYear`. Document repo: `listFor`, `findById`, `create`, `remove` (also deletes file), `removeForLink`, `countForLink` |
| Database Table(s) | `certificates`, `documents` (polymorphic attachments) |
| Model | `Certificate` struct (declared in `src/models/AuditLog.h`!) — `id, certificateNumber, type, memberId, familyId, marriageId, deathId, issuedTo, issuedDate, issuedBy, qrPayload, notes, createdAt` + joined `issuedByName`. Also `Document` struct. |
| CRUD operations | Create (issue), Read, Delete. No Update. |
| Validation rules | `type` required; auto-set `issuedDate` to today; auto-set `issuedBy` to current user; auto-fill `issuedTo` from member if missing |
| Signals/slots | `CertificateView::refresh()` |
| Special features | 6 cert types (Membership/Residence/Marriage/Death/Character/Income); QR code is a **fake QR** — `drawQrCode()` paints 3 finder squares + pseudo-random data cells seeded by `qHash(payload)`. Comment in code admits "For production-grade QR codes, integrate qrcodegen library". PDF generated via `QPdfWriter` at 300 DPI with decorative border, mahallu seal, signature line. |
| Dependencies | `MemberRepository`, `FamilyRepository`, `MarriageRepository`, `DeathRepository`, `AuditLogRepository`, `AuthSession` |
| QML screen status | **Not started** |

### 2.11 Tokens (Meat/Food Distribution)

| Field | Value |
|---|---|
| Module Name | Tokens |
| Widget View File | `src/views/TokenView.cpp` / `.h` |
| Dialog File(s) | `TokenEventDialog`, `FamilySelectDialog` (inline in `TokenView.cpp`) |
| Service | `TokenService` — `createEvent`, `updateEvent`, `deleteEvent`, `listEvents`, `getEvent`, `generateTokens(eventId, familyIds)`, `getAssignments`, `markCollected`, `markUncollected`, `getStats`, `getAllActiveFamilies`, `getFamiliesByWard`, `getWards` |
| Repository | `TokenRepository` — `createEvent`, `updateEvent`, `deleteEvent`, `listEvents`, `findEventById`, `updateEventStatus`, `createAssignments` (generates unique 4-digit codes 1000-9999 with collision retry, max 10000 attempts), `listAssignments`, `markCollected`, `markUncollected`, `collectedCount`, `pendingCount`, `logPrint`, `findByCode` |
| Database Table(s) | **`token_events`, `token_assignments`, `token_print_log`** — **⚠ NOT DEFINED in `sql/schema.sql`!** See Section 3 critical finding. |
| Model | `TokenEvent` (`src/models/TokenEvent.h`) and `TokenAssignment` (`src/models/TokenAssignment.h`). Both declared `Q_DECLARE_METATYPE`. |
| CRUD operations | Event: Create, Read, Update, Delete (blocked if Active/Completed). Assignment: Create (batch), Read, Update (mark collected/uncollected). |
| Validation rules | `eventName` required; `eventDate` required; tokens can only be generated for Draft events; family list non-empty |
| Signals/slots | `TokenView::refresh()`; `navigateToView(int)` signal |
| Special features | Two-page stacked widget (event list / event detail); 4-digit unique code per family per event; collection progress bar; PDF generation via `TokenPdfEngine` (token sheet with cuttable 2×4 grid + collection sheet with checkboxes); **fake QR code** (same approach as certificates) |
| Dependencies | `FamilyRepository`, `MemberRepository` (via JOIN), `AuditLogRepository`, `AuthSession` |
| **⚠ CRITICAL — Token is not in the widgets sidebar!** | `MainWindow::setupViews()` builds 15 nav entries — Dashboard, Families, Members, Subscriptions, Donations, Accounting, Marriage, Death, Welfare, Certificates, Reports, Settings, Users, Audit, Backup. **Token is missing**. TokenView.cpp exists but is unreachable from the widgets UI. The QML `AppShell.qml` sidebar (line 88) **does** include "Tokens" — so QML is ahead of widgets here. |
| QML screen status | **Not started** (and cannot work — schema missing) |

### 2.12 Reports

| Field | Value |
|---|---|
| Module Name | Reports |
| Widget View File | `src/views/OtherViews.cpp` (`ReportsView` class) |
| Dialog File(s) | none — uses combo box for report type |
| Service | `ReportService` — 13 report builders: `familyRegister`, `memberRegister`, `activeMembers`, `familyDirectory`, `subscriptionReport`, `defaultersReport`, `donationReport`, `incomeReport`, `expenseReport`, `cashBookReport`, `financialSummary`, `marriageRegisterReport`, `deathRegisterReport`, `welfareReport`. Exporters: `exportToCsv`, `exportToPdf` (uses `QPdfWriter`), `exportToExcel` (UTF-8 BOM CSV), `ensureExportPath`. |
| Repository | none — queries DB directly |
| Database Table(s) | All (read-only) |
| Model | `ReportService::ReportRow` struct — `headers, cells (flattened), rowCount` |
| CRUD operations | Read-only |
| Validation rules | none |
| Signals/slots | `ReportsView::refresh()` |
| Special features | 13 built-in reports; combo-box selector; date range filter; PDF export with title + subtitle + zebra-striped table + auto-pagination + header reprint; CSV export with proper escaping; "Excel" export is actually CSV with UTF-8 BOM (opens in Excel) |
| Dependencies | `AuditLogRepository`, `AuthSession`, `Config` (export dir) |
| QML screen status | **Not started** |

### 2.13 Settings

| Field | Value |
|---|---|
| Module Name | Settings |
| Widget View File | `src/views/OtherViews.cpp` (`SettingsView` class) |
| Dialog File(s) | none |
| Service | `SettingsService` (singleton) — `load()`, `save(MahalluSettings)`, `applyTheme(name)`, `currentTheme()`, `receiptPrefix()`, `currencySymbol()`, `currentLanguage()`, `setLanguage(code)` |
| Repository | none — uses `Database::instance().execute` directly against single-row `settings` table (id=1) |
| Database Table(s) | `settings` (single row, id=1) |
| Model | `MahalluSettings` struct — `mahalluName, address, phone, email, logoPath, sealPath, financialYearStart, currencySymbol, theme, language, autoBackup, backupIntervalHours, receiptPrefix` |
| CRUD operations | Read + Update only (no insert — `INSERT OR IGNORE INTO settings (id) VALUES (1)` in schema) |
| Validation rules | none in service layer |
| Signals/slots | `SettingsView::refresh()`; `onSave/onUploadLogo/onUploadSeal` slots |
| Special features | Mahallu name/address/phone/email/logo/seal; financial year start (MM-DD); currency symbol; theme (light/dark); language (en/ml); auto-backup toggle + interval; receipt prefix; logo/seal upload (file picker). Save() writes to DB + syncs `Config` (QSettings) + applies font. **Has a fallback UPDATE that omits `language` column** if the column doesn't exist (legacy DB compat). |
| Dependencies | `Config`, `FontManager`, `I18N`, `AuditLogRepository`, `AuthSession` |
| QML screen status | **Not started** |

### 2.14 Users (User Management)

| Field | Value |
|---|---|
| Module Name | Users |
| Widget View File | `src/views/OtherViews.cpp` (`UserManagementView` class) |
| Dialog File(s) | `UserEditDialog` + `UserPasswordDialog` (inline) |
| Service | `AuthService` — `login`, `logout`, `changePassword`, `resetPassword`, `adminResetPassword`, `createUser`, `updateUserProfile`, `deleteUser`, `unlockUser`, `passwordPolicyDescription` |
| Repository | `UserRepository` — `findByUsername`, `findById`, `listAll`, `listByRole`, `create`, `update`, `updatePassword`, `updateLastLogin`, `incrementFailedAttempts(lockThreshold=5, lockMinutes=15)`, `resetFailedAttempts`, `setActive`, `unlock`, `remove` (blocks last Administrator delete), `hasPermission`, `roleHasPermission` (Administrator always true), `count`, `countByRole` |
| Database Table(s) | `users`, `permissions` |
| Model | `User` struct — `id, username, fullName, passwordHash, passwordSalt, role, email, phone, isActive, isLocked, failedAttempts, lockedUntil, lastLoginAt, mustChangePwd, createdAt, updatedAt` |
| CRUD operations | Create, Read, Update, Delete (gated), Unlock, Reset Password |
| Validation rules | `username` ≥ 3 chars; password must be ≥ 8 chars + uppercase + lowercase + digit + special; role must be in valid list; username unique; cannot delete last Administrator; cannot delete own account |
| Signals/slots | `UserManagementView::refresh()` |
| Special features | 7 roles (Administrator/President/Secretary/Treasurer/Imam/Staff/Auditor); account lockout after 5 failed attempts (15 min); must-change-password flag; fine-grained permission matrix (`permissions` table); password strength scoring (0-5) |
| Dependencies | `Security` (PBKDF2 hashing), `AuditLogRepository`, `AuthSession` |
| QML screen status | **Not started** |

### 2.15 Audit Log

| Field | Value |
|---|---|
| Module Name | Audit Log |
| Widget View File | `src/views/OtherViews.cpp` (`AuditLogView` class) |
| Dialog File(s) | none |
| Service | none — `AuditLogRepository` is called directly by all other services |
| Repository | `AuditLogRepository` — `log(userId, username, action, module, entityId, description, ipAddress)`, `list(page,size,action,module,user,from,to,int*)`, `countToday`, `countByAction` |
| Database Table(s) | `audit_log` |
| Model | `AuditLog` struct — `id, userId, username, action, module, entityId, description, ipAddress, createdAt` |
| CRUD operations | Read + Insert only (no update, no delete) |
| Validation rules | none |
| Signals/slots | `AuditLogView::refresh()` |
| Special features | Filter by action / module / username / date range; CSV export; every service writes audit entries automatically |
| Dependencies | none |
| QML screen status | **Not started** |

### 2.16 Backup & Restore

| Field | Value |
|---|---|
| Module Name | Backup |
| Widget View File | `src/views/OtherViews.cpp` (`BackupView` class) |
| Dialog File(s) | none |
| Service | `BackupService` (QObject with signals) — `createBackup()`, `createBackupAt(path)`, `restoreBackup(zipPath)`, `listBackups()`, `pruneOldBackups(keep=10)`, `verifyBackup(zipPath)`. Signals: `backupStarted/Progress(int)/Completed(path)/Failed(error)`, `restoreStarted/Completed/Failed` |
| Repository | none |
| Database Table(s) | none (operates on `mms.db` file) |
| Model | `BackupService::BackupInfo` struct — `fileName, fullPath, created, sizeBytes` |
| CRUD operations | Create backup, Restore backup, Verify, Delete, Prune |
| Validation rules | none |
| Signals/slots | `BackupView::refresh()`; service emits progress signals |
| Special features | **Custom minizip-style ZIP writer** (ziputil namespace in `BackupService.cpp`): uses zlib `compress2` + manual local/central/end ZIP headers. Restores verify CRC32. Pre-restore: backs up current DB to `mms.db.pre_restore`. Post-restore: closes DB connection and reopens. Auto-backup timer in `MainWindow` ticks every `intervalHours`. |
| Dependencies | `Database`, `Config`, `AuditLogRepository`, `AuthSession`, zlib |
| QML screen status | **Not started** |

### 2.17 Authentication / Login

| Field | Value |
|---|---|
| Module Name | Authentication |
| Widget View File | `src/views/LoginView.cpp` / `.h` |
| Dialog File(s) | `ChangePasswordDialog` (in `OtherViews.cpp`) |
| Service | `AuthService` (QObject) — `login(username,password) → LoginResult{success,errorMessage,mustChangePassword,accountLocked,remainingAttempts}`, `logout`, `changePassword`, `resetPassword`, `adminResetPassword`, `createUser`, `updateUserProfile`, `deleteUser`, `unlockUser` |
| Repository | `UserRepository` (see Users module) + `AuthSession` singleton |
| Database Table(s) | `users`, `audit_log` |
| Model | `AuthService::LoginResult` struct; `User` struct |
| CRUD operations | Login (verify), Logout, Change Password, Reset Password |
| Validation rules | Account must be active; lock check (auto-unlock if lock expired); PBKDF2 password verify; 5 failed attempts → 15-min lock; constant-time compare |
| Signals/slots | `LoginView::loginSuccessful()` signal (caught by `MainWindow::showApp`); `AuthSession::loggedIn(User)` / `loggedOut()` / `permissionDenied(module,action)` signals |
| Special features | Theme + language toggle on login screen; "forgot password" hint; password strength meter in ChangePasswordDialog; `AuthSession` is a singleton accessible everywhere — `AuthSession::instance().user()` returns the current user |
| Dependencies | `Security`, `UserRepository`, `AuditLogRepository`, `SettingsService` (theme/lang) |
| QML screen status | **Not started** — the QML `AppShell` has no login screen. The sidebar shows a hardcoded user "Abdul Kareem / Administrator" regardless of who's logged in. `AuthSession` is **not exposed to QML** at all. |

---

## Section 3 — Database Schema Summary

### Tables (from `sql/schema.sql`)
| # | Table | Columns | Foreign Keys / Notes |
|---|---|---|---|
| 1 | `schema_version` | version (PK), applied_at, description | Migration tracking |
| 2 | `users` | id, username (UNIQUE NOCASE), full_name, password_hash, password_salt, role (CHECK 7 values), email, phone, is_active, is_locked, failed_attempts, locked_until, last_login_at, must_change_pwd, created_at, updated_at | — |
| 3 | `permissions` | id, role, module, action, allowed | UNIQUE(role, module, action) |
| 4 | `settings` | id (CHECK id=1), mahallu_name, address, phone, email, logo_path, seal_path, financial_year_start, currency_symbol, theme, language, backup_dir, auto_backup, backup_interval_hours, receipt_prefix, updated_at | Single-row table. `INSERT OR IGNORE INTO settings (id) VALUES (1)` |
| 5 | `families` | id, family_number (UNIQUE), house_name, house_number, ward, area, address, pincode, phone, alternative_phone, status (CHECK Active/Inactive/Archived), notes, created_at, updated_at | — |
| 6 | `members` | id, family_id (FK→families RESTRICT), member_code (UNIQUE), photo_path, name, arabic_name, gender (CHECK), date_of_birth, age, blood_group, occupation, education, marital_status (CHECK), mobile, email, nationality, address, emergency_contact, relationship, is_head, status (CHECK Active/Inactive/Deceased), created_at, updated_at | FK family_id RESTRICT |
| 7 | `subscription_plans` | id, name (UNIQUE), frequency (CHECK Monthly/Yearly/OneTime), default_amount, is_active, description | Seeded with Monthly/Yearly/Special |
| 8 | `subscriptions` | id, family_id (FK RESTRICT), member_id (FK SET NULL), plan_id (FK), period_start, period_end, amount, amount_paid, payment_date, receipt_number (UNIQUE), payment_method (CHECK), transaction_ref, status (CHECK Paid/Pending/Overdue/Partial), collected_by (FK→users), remarks, created_at, updated_at | Multiple FKs |
| 9 | `donation_categories` | id, name (UNIQUE), description, is_active | Seeded with 5 categories |
| 10 | `donations` | id, donor_name, donor_phone, donor_address, family_id (FK SET NULL), member_id (FK SET NULL), category_id (FK), amount, donation_date, receipt_number (UNIQUE), purpose, remarks, payment_method (CHECK), received_by (FK→users), created_at | — |
| 11 | `ledger_accounts` | id, code (UNIQUE), name, type (CHECK Income/Expense/Asset/Liability), category, is_active | Seeded with 10 accounts (INC-SUB, INC-DON, INC-RENT, INC-OTH, EXP-SAL, EXP-ELC, EXP-WAT, EXP-MAINT, EXP-WEL, EXP-OTH) |
| 12 | `transactions` | id, txn_date, account_id (FK), type (CHECK Income/Expense), amount, payment_method, reference, description, linked_module, linked_id, receipt_number, created_by (FK→users), created_at | Polymorphic link via `linked_module`+`linked_id` |
| 13 | `marriages` | id, marriage_number (UNIQUE), bride_name, bride_father, bride_address, groom_name, groom_father, groom_address, witness1..4, mahar, nikah_date, registration_date, imam_id (FK→users), place, remarks, created_at | — |
| 14 | `deaths` | id, death_number (UNIQUE), deceased_name, father_name, family_id (FK SET NULL), gender, date_of_death, burial_date, cause_of_death, burial_place, age, remarks, created_at | — |
| 15 | `welfare_requests` | id, request_number (UNIQUE), applicant_name, family_id (FK SET NULL), category (**CHECK Medical Aid/Education Aid/Marriage Assistance/Financial Assistance**), amount_requested, amount_approved, reason, status (CHECK Pending/Approved/Rejected/Disbursed/Closed), approved_by (FK→users), disbursed_date, remarks, created_at, updated_at | — |
| 16 | `certificates` | id, certificate_number (UNIQUE), type (CHECK 6 types), member_id, family_id, marriage_id, death_id, issued_to, issued_date, issued_by (FK→users), qr_payload, notes, created_at | All entity FKs ON DELETE SET NULL |
| 17 | `documents` | id, linked_module, linked_id, file_name, file_path, file_type, file_size, uploaded_by (FK→users), uploaded_at | Polymorphic |
| 18 | `audit_log` | id, user_id (FK SET NULL), username, action, module, entity_id, description, ip_address, created_at | — |
| 19 | `sessions` | id, user_id (FK CASCADE), token (UNIQUE), started_at, expires_at, is_active | Server-side session invalidation (not currently used by app) |
| 20 | `notifications` | id, user_id (FK CASCADE), title, message, severity (CHECK), is_read, created_at | — |

### Views
- `v_defaulters` — families with pending/overdue subscriptions + due amount
- `v_member_directory` — members JOIN families
- `v_dashboard_summary` — 10 scalar aggregates for dashboard

### Triggers
- `trg_users_updated`, `trg_families_updated`, `trg_members_updated`, `trg_subs_updated`, `trg_welfare_updated` — auto-update `updated_at` on row update

### Migration files
| File | Description |
|---|---|
| `sql/migrations/V001_*` | (implicit) Initial schema, applied directly from `schema.sql` |
| `sql/migrations/V002_add_language_column.sql` | `ALTER TABLE settings ADD COLUMN language TEXT NOT NULL DEFAULT 'en' CHECK (language IN ('en','ml'))` |
| `sql/migrations/README.sql` | Documents naming convention `V<NNN>_<description>.sql` |

**Note:** `Database::ensureSchema()` skips migrations entirely on a fresh DB (the schema.sql already includes the `language` column), so V002 only runs on pre-existing V001 databases.

### ⚠ CRITICAL SCHEMA ISSUES DISCOVERED

1. **Token tables missing.** `TokenRepository` references `token_events`, `token_assignments`, `token_print_log` — **none of these are defined in `schema.sql`**. Grep confirms the only files mentioning these table names are `TokenRepository.cpp` and `TokenView.cpp` (which calls TokenRepository). The schema must be missing a `V003_add_token_tables.sql` migration (or the token CREATE TABLEs were never added to `schema.sql`). The Token module is **broken at runtime** — every TokenRepository method will fail with "no such table: token_events".

2. **`sql/seed.sql` is partially broken.** Three seed INSERTs reference columns that don't exist in `schema.sql`:
   - Line 12: `INSERT OR IGNORE INTO subscription_plans (id, name, default_amount, **period_months**, description) VALUES (1,'Monthly',100,1,'Monthly')` — `period_months` doesn't exist (schema has `frequency`).
   - Line 17: `INSERT OR IGNORE INTO ledger_accounts (id, name, type, **balance**) VALUES (1,'General Fund','Asset',0),…` — `balance` doesn't exist (schema has `code, name, type, category, is_active`).
   - Line 156: `INSERT OR IGNORE INTO welfare_requests (request_number, applicant_name, family_id, category, …) VALUES ('WEL-001','Kareem',14,'Medical',…)` — `'Medical'` violates the CHECK constraint (only `'Medical Aid'` etc. are allowed). Same for 'Housing', 'Education', 'General'.

   `Database::executeSqlScript()` returns false on the first failing statement and aborts the rest of the script. Since `seedIfEmpty()` runs `seed.sql` only on a fresh DB (when families table is empty), the **first** failure (subscription_plans INSERT at line 12) aborts seed.sql. Lines 1-11 (admin user + settings row) succeed; lines 13+ (families, members, donations, subscriptions, transactions, marriages, deaths, welfare_requests, audit_log) **never run**. This means on a fresh install, the demo dataset is incomplete — only the admin user is seeded, no demo families/members/etc. The seed file appears to have been written against an older schema version and never reconciled.

---

## Section 4 — Current QML ↔ C++ Bridge Analysis

### What `QmlServices.h/.cpp` currently exposes to QML

Registered as **context property** `"Services"` in `src/app_main.cpp` (line 127):
```cpp
engine.rootContext()->setContextProperty("Services", services);
```

#### Q_PROPERTY
- `QString lastError` (NOTIFY `lastErrorChanged`)
- `QStringList wards` (CONSTANT)
- `int totalFamilies` (NOTIFY `dataChanged`)

#### Q_INVOKABLE methods — **Families only**
| Method | Signature | Backend call |
|---|---|---|
| `searchFamilies` | `(term, page, pageSize, statusFilter, wardFilter) → QVariantList` | `FamilyService::searchFamilies` |
| `getFamily` | `(id) → QVariantMap` | `FamilyService::getFamily` (throws → caught) |
| `getFamilyMembers` | `(familyId) → QVariantList` | `MemberService::familyMembers` (instantiates `MemberService` locally — does NOT own it) |
| `createFamily` | `(data: QVariantMap) → qint64` | `FamilyService::createFamily` |
| `updateFamily` | `(id, data: QVariantMap) → bool` | `FamilyService::updateFamily` |
| `deleteFamily` | `(id) → bool` | `FamilyService::deleteFamily` |
| `archiveFamily` | `(id) → bool` | `FamilyService::archiveFamily` |
| `restoreFamily` | `(id) → bool` | `FamilyService::restoreFamily` |

#### Signals
- `lastErrorChanged()` — fired when an operation fails
- `dataChanged()` — fired after every successful create/update/delete/archive/restore

### What's MISSING from the bridge (every other module)

The following modules have **zero** QML exposure:

| Module | Service exists? | Exposed to QML? |
|---|---|---|
| Members (CRUD, photo, family head) | `MemberService` ✓ | ❌ Only `getFamilyMembers` (read-only) is callable |
| Subscriptions | `SubscriptionService` ✓ | ❌ |
| Donations | `DonationService` ✓ | ❌ |
| Accounting | `AccountingService` ✓ | ❌ |
| Marriage | `MarriageService` ✓ | ❌ |
| Death | `DeathService` ✓ | ❌ |
| Welfare | `WelfareService` ✓ | ❌ |
| Certificates | `CertificateService` ✓ | ❌ |
| Tokens | `TokenService` ✓ | ❌ |
| Reports | `ReportService` ✓ | ❌ |
| Dashboard | `DashboardService` ✓ | ❌ (DashboardPage.qml uses hardcoded mock data) |
| Settings | `SettingsService` ✓ | ❌ |
| Users / Auth | `AuthService` + `AuthSession` ✓ | ❌ (no login screen in QML; no current-user info) |
| Audit Log | `AuditLogRepository` ✓ | ❌ |
| Backup | `BackupService` ✓ | ❌ |
| I18N | `I18N` singleton ✓ | ❌ (no `TR()` accessible from QML — strings hardcoded in QML) |
| Config | `Config` singleton ✓ | ❌ |
| Logger | `Logger` ✓ | ❌ |

### Bridge architecture observations

- **Facade pattern, not singletons.** `QmlServices` is a single QObject facade that owns a `FamilyService*` (only). All other services would need to be either added as members of `QmlServices` or registered as separate QML singletons.
- **No `QAbstractListModel` subclasses exist anywhere** in the codebase. Confirmed by grep — no `QAbstractListModel`, no `QAbstractTableModel`. All data crosses the C++/QML boundary as `QVariantList` (lists of `QVariantMap`s).
- **No `qmlRegisterType` / `qmlRegisterSingletonType` for backend types.** Only `MMS.Theme` (the QML-only `Theme.qml`) is registered as a singleton in `app_main.cpp` line 82.
- **`QVariantMap` keys use camelCase** in QmlServices (`familyNumber`, `houseName`) but **snake_case** in `Family::toMap()` (`family_number`, `house_name`). This is intentional — `QmlServices` does the conversion in `familyToMap()` / `mapToFamily()`. Any new facade methods must follow the same camelCase convention.
- **`AuthSession` is a singleton but not registered with QML.** The QML app has no way to know who's logged in, what their role is, or to call `hasPermission`. The hardcoded "Abdul Kareem / Administrator" in `AppShell.qml` (line 126-127) is purely visual.
- **Error handling is one-way.** `lastError` is a Q_PROPERTY, so QML *could* bind to it, but no QML file currently does. Errors are silently dropped at the QML layer.

---

## Section 5 — Add Family Persistence Diagnosis

### Exact code path (QML → SQL)

#### Step 1: `qml/pages/FamilyEditDialog.qml` "Add Family" button clicked
Lines 162-189:
```qml
AppButton {
    text: dialog.familyId > 0 ? "Save Changes" : "Add Family"
    variant: "primary"; iconName: "check"
    onClicked: {
        if (dialog.readOnly) { dialog.visible = false; return }
        var data = {
            familyNumber: dialog._familyNumber,
            houseName: dialog._houseName,
            // ... 10 more fields ...
            notes: dialog._notes      // ⚠ always "" — no UI binds to _notes
        }
        if (dialog.familyId > 0) {
            Services.updateFamily(dialog.familyId, data)
        } else {
            Services.createFamily(data)   // ⚠ return value DISCARDED
        }
        dialog.saved()                    // ⚠ emitted UNCONDITIONALLY
        dialog.visible = false            // ⚠ dialog closed UNCONDITIONALLY
    }
}
```

#### Step 2: `QmlServices::createFamily(data)` in `src/services/QmlServices.cpp`
Lines 103-111:
```cpp
qint64 QmlServices::createFamily(const QVariantMap& data) {
    Family f = mapToFamily(data);
    QString err;
    qint64 id = familySvc_->createFamily(f, &err);
    if (id > 0) { emit dataChanged(); return id; }
    lastError_ = err;
    emit lastErrorChanged();
    return 0;   // returns 0 on failure (NOT -1, NOT the id from service)
}
```

#### Step 3: `FamilyService::createFamily(f, &err)` in `src/services/FamilyService.cpp`
Lines 14-48 — runs validation, auto-generates family number if empty, checks uniqueness, then calls `FamilyRepository::create()`. Writes an audit log entry on success.

Validation rules enforced (returns `-1` + sets `err` if any fail):
1. `houseName` AND `address` both empty → "Either House Name or Address is required."
2. `phone` AND `alternativePhone` both empty → "At least one phone number is required."
3. `phone` not empty and not matching `^(\+?\d{1,3}[-\s]?)?\d{10}$` → "Phone number format is invalid."
4. `pincode` not empty and not 6 digits → "Pincode must be a 6-digit number."
5. If `familyNumber` was provided (non-empty) and already exists → "Family number already exists."

#### Step 4: `FamilyRepository::create(f)` in `src/repositories/FamilyRepository.cpp`
Lines 112-120 — calls `Database::instance().insert(SQL, params)`. Returns new row id, or `-1` if SQL fails.

#### Step 5: `Database::insert()` in `src/core/Database.cpp`
Lines 200-212 — prepares statement, binds params, execs. On failure: sets `lastError_`, logs error, returns `-1`. On success: returns `q.lastInsertId()`.

### Failure-mode analysis

| Failure | Where it fails | What happens |
|---|---|---|
| **DB not initialized** (e.g. `sql/schema.sql` not found at exe dir, fallback also fails — see `app_main.cpp` line 99-104 which catches the failure non-fatally) | `Database::insert()` — connection not open, prepare fails | `Database::lastError_` set, returns `-1`. **But wait** — actually `QSqlDatabase::database(connectionName_)` returns the default connection which may not exist; the query will fail silently. `FamilyRepository::create` returns -1. `FamilyService::createFamily` returns -1 with err set. `QmlServices::createFamily` sets `lastError_` + emits `lastErrorChanged()` + returns 0. QML discards the 0, fires `saved()`, closes dialog, refreshes table — **user sees no error, no row added**. |
| **Validation fails** (no house name, no address, no phone) | `FamilyService::createFamily` returns -1 with err | Same as above — `QmlServices` returns 0, `lastError` set but no UI reads it, dialog closes silently, user thinks it worked |
| **Phone format invalid** (e.g. user typed "abc") | `FamilyService::createFamily` returns -1 | Same as above |
| **Pincode not 6 digits** | `FamilyService::createFamily` returns -1 | Same as above |
| **Family number collision** (user typed an existing FAM-0001) | `FamilyService::createFamily` returns -1 | Same as above |
| **SQL constraint violation** (NOT NULL, CHECK, UNIQUE) | `Database::insert()` returns -1 | Same as above |
| **Success** | All steps return OK | `QmlServices` emits `dataChanged()`, returns new id (>0). QML discards it, fires `saved()`, closes dialog. `FamiliesPage.onSaved` calls `page.refresh()` → table reloads with new row. |

### Critical bugs in this path

1. **QML never checks the return value of `Services.createFamily()`**. The `0` return on failure is silently discarded.
2. **`dialog.saved()` is emitted unconditionally**, even on failure. This triggers `FamiliesPage.onSaved → page.refresh()`, which makes the table flash (clear + reload) — giving the user false visual feedback that something happened.
3. **`dialog.visible = false` runs unconditionally**, so the dialog closes even if nothing was saved. The user's input is lost.
4. **`Services.lastError` is set but never displayed**. No QML code binds to `lastError` or `lastErrorChanged`. The error message sits in the property, invisible.
5. **The `notes` field is missing from the QML form**. The dialog has `_notes` property (initialized to `""`) and includes it in the `data` map, but no `AppTextField` or `TextArea` is bound to it. Notes are always saved as empty.
6. **The Ward combo is hardcoded** to `["Ward 1", "Ward 2", "Ward 3", "Ward 4"]` in `FamilyEditDialog.qml` line 118 — but `Services.wards()` returns actual wards from the DB (in seed data, wards are `"1"` through `"7"` as strings). A new family saved from QML would get `"Ward 1"` as its ward, while existing data uses `"1"`. The ward filter on `FamiliesPage` (which uses `Services.wards()`) wouldn't match.
7. **QML form lacks client-side validation**. The user can submit an empty form and the C++ side rejects it silently. There's no red border, no inline error message, no `AppTextField.showError` usage.
8. **DB initialization is non-fatal** in `app_main.cpp` (lines 91-104 — wrapped in `try/catch (...)` with comment "Database FAILED (non-fatal)"). If schema.sql isn't found, the app launches with an empty/nonexistent DB and every service call fails silently. This is the **most likely root cause** of "Add Family doesn't persist" if the user is running `mms_app` without the `sql/` directory next to the exe.

### What needs to change for this path to be production-ready

- `FamilyEditDialog.qml` must capture the return value: `var newId = Services.createFamily(data); if (newId > 0) { dialog.saved(); dialog.visible = false } else { /* show Services.lastError */ }`.
- The dialog should bind `Services.lastError` to a visible error banner.
- Client-side validation should mirror the C++ rules (house name OR address, phone required + format, pincode 6 digits) so the user gets instant feedback.
- The `notes` field needs a `TextArea` bound to `_notes`.
- The Ward combo should populate from `Services.wards()` (with a free-text fallback for new wards).
- `app_main.cpp` should fail loudly if the DB can't be initialized (or at least expose a `Services.databaseReady` property the QML can check).

---

## Section 6 — Architecture Recommendations

### 6.1 Bridge structure for production

**Recommendation: Replace the `QmlServices` facade with a hybrid approach:**

1. **Per-module `QAbstractListModel` subclasses** for list views. These give QML the standard `model.data(index, role)` / `model.rowCount()` API, support `QML_ELEMENT`/`QML_ATTACHED` declarative registration, and emit `dataChanged`/`rowsInserted`/`rowsRemoved` signals that QML `ListView`/`TableView` bind to automatically. This eliminates the "clear + reload whole list" pattern currently in `FamiliesPage.refresh()`.

   Proposed classes (one per list-backed module):
   - `FamilyListModel : QAbstractListModel` — roles: id, familyNumber, houseName, ward, area, phone, memberCount, headName, status
   - `MemberListModel : QAbstractListModel`
   - `SubscriptionListModel : QAbstractListModel`
   - `DonationListModel : QAbstractListModel`
   - `TransactionListModel : QAbstractListModel`
   - `MarriageListModel`, `DeathListModel`, `WelfareListModel`, `CertificateListModel`, `TokenEventListModel`, `TokenAssignmentListModel`, `AuditLogListModel`

   Each model should expose `Q_INVOKABLE void setSearchTerm(QString)`, `Q_INVOKABLE void setStatusFilter(QString)`, `Q_INVOKABLE void loadPage(int page)`, and a `Q_PROPERTY(int totalCount)`. Internally it calls the existing service+repository and emits `beginResetModel`/`endResetModel` (or finer-grained `beginInsertRows`/`endInsertRows` for incremental updates).

2. **Per-module controller QObjects** for non-list operations (create/update/delete/dialog state). Proposed:
   - `FamilyController : QObject` — `Q_INVOKABLE qint64 create(QVariantMap)`, `Q_INVOKABLE bool update(qint64, QVariantMap)`, `Q_INVOKABLE bool delete_(qint64)`, `Q_INVOKABLE QVariantMap get(qint64)`, `Q_INVOKABLE QString nextFamilyNumber()`. Emits `created(qint64)`, `updated(qint64)`, `deleted(qint64)`, `error(QString)`.
   - Same pattern for each module.

3. **Global singletons registered via `qmlRegisterSingletonType`**:
   - `AuthSession` (already a singleton) — expose `user`, `isLoggedIn`, `role`, `hasPermission(module, action)`, signals `loggedIn`/`loggedOut`. **Critical for permission-gating QML UI.**
   - `SettingsService` — expose `mahalluName`, `currencySymbol`, `theme`, `language`, etc. as Q_PROPERTYs.
   - `I18N` — expose `tr(key)` as `Q_INVOKABLE` and a `languageChanged` signal. Or better, port to a proper `.ts`/`QML_TR()` setup using `QTranslator` + `qsTr()`.
   - `DashboardService` — expose `load()` returning a `DashboardStats`-as-`QVariantMap` plus chart data lists.
   - `BackupService` — already a QObject with signals; just register as singleton.
   - `Config` — expose paths (dataDir, backupDir) for QML file dialogs.

4. **Keep `QmlServices` as a thin entry point ONLY during migration** — don't add more methods to it. New modules go directly to their own controller/model singletons. Once Families is fully migrated to `FamilyController` + `FamilyListModel`, delete `QmlServices` entirely.

### 6.2 Real-time model updates

Currently `QmlServices::dataChanged()` is a single signal fired on any create/update/delete. QML has no way to know *which* family changed. This leads to the brute-force "clear + repopulate" refresh pattern.

**Recommended pattern:**
- `FamilyController` emits `familyCreated(qint64 id)`, `familyUpdated(qint64 id)`, `familyArchived(qint64 id)`, `familyDeleted(qint64 id)`.
- `FamilyListModel` connects to those signals. On `familyCreated`, it can either:
  - **Lazy:** set a `dirty_` flag and reload on next `loadPage()` call.
  - **Eager:** call `SELECT * FROM families WHERE id = ?` and `beginInsertRows`/`insertRow`/`endInsertRows` for just that row.
- For cross-module updates (e.g. adding a Member should bump `families.member_count`), the `MemberController` can emit a `familyTouched(qint64 familyId)` signal that `FamilyListModel` listens to.

### 6.3 Validation error propagation

**Current state:** C++ validates, sets `lastError` string property, QML ignores it.

**Recommended pattern:**
- Each controller's `create()`/`update()` returns a `QVariantMap` (not a bare `qint64`/`bool`):
  ```cpp
  Q_INVOKABLE QVariantMap create(const QVariantMap& data) {
      QString err;
      qint64 id = svc_.createFamily(f, &err);
      if (id > 0) return {{"success", true}, {"id", id}};
      return {{"success", false}, {"error", err}, {"field", guessField(err)}};
  }
  ```
- QML checks `result.success` and either closes the dialog or shows an error banner with `result.error` and highlights `result.field`.
- For client-side pre-validation, expose validators as `Q_INVOKABLE` on a `Validators` singleton: `Validators.isValidPhone(s)`, `Validators.isValidPincode(s)`, etc. QML calls these on `onTextEdited` for live feedback.

### 6.4 Loading states

**Current state:** All QML service calls are synchronous (block the UI thread). For a SQLite DB this is usually fast, but on large datasets or slow disks, the UI freezes.

**Recommended pattern:**
- For reads: add a `Q_PROPERTY(bool loading)` to each list model. Set true at start of `loadPage()`, false at end. QML shows a `BusyIndicator` overlay when `loading == true`.
- For writes: the controller's `create()` should be synchronous (it's a single INSERT), but the dialog should disable its Save button while the call is in flight (prevent double-clicks).
- For reports/backup/restore: these can be slow. Move to a worker thread via `QThreadPool` + `QtConcurrent::run`, emit progress signals, and let QML show a modal progress dialog.
- For backup specifically, `BackupService` already has `backupProgress(int percent)` — wire it to a QML `ProgressBar`.

### 6.5 Additional recommendations

- **Register types declaratively** with `QML_ELEMENT`/`QML_SINGLETON` in headers (cleaner than `qmlRegisterSingletonType` calls in main). Requires adding `qt_add_qml_module` to CMake.
- **Move `Certificate` struct out of `models/AuditLog.h`** — it's confusing. Create `models/Certificate.h` and `models/Document.h`.
- **Move `MarriageService`/`DeathService`/`WelfareService` out of `RegisterServices.h`** into their own headers — current bundling makes it hard to include one without the others.
- **Fix the seed.sql schema drift** (Section 3 critical issue #2) before migration. Otherwise QML pages will have no demo data to render during development.
- **Add the missing token tables** to `schema.sql` (or as a `V003_add_token_tables.sql` migration) before migrating the Token module.
- **Port I18N to .ts/.qm** — the current hardcoded hash is fine for 2 languages but won't scale. Use `QTranslator` + `qsTr()` in QML.

---

## Section 7 — Migration Order Recommendation

Based on the dependency graph and the user's stated priority (Families first), here is the recommended migration order. Each phase is independently shippable.

### Phase 0 — Pre-migration fixes (BLOCKER, must do first)
1. **Fix `sql/seed.sql`** to match current schema (remove `period_months`, fix `ledger_accounts` columns, fix welfare categories to match CHECK constraint). Without this, fresh installs have no demo data and developers can't test QML pages.
2. **Add token tables to `schema.sql`** (or `V003_add_token_tables.sql`). Otherwise the Token module is unreachable.
3. **Decide on DB init failure policy** in `app_main.cpp` — currently non-fatal, which masks bugs. At minimum, expose `Services.databaseReady` to QML so the UI can show an error screen.
4. **Fix the Add Family persistence bug** (Section 5) — this is the user's reported pain point and a 1-day fix.

### Phase 1 — Foundation (1-2 weeks)
**Goal:** Build the bridge infrastructure that all modules will use.

1. Expose `AuthSession` as a QML singleton (`user`, `isLoggedIn`, `role`, `hasPermission`, `loggedIn`/`loggedOut` signals).
2. Build a `FamilyController` + `FamilyListModel` pair (replaces `QmlServices` family methods). Use this as the template for all future modules.
3. Build a `Validators` singleton (phone, pincode, email, required-field).
4. Build an `ErrorBanner` QML component that binds to a controller's `error` property.
5. Migrate `FamiliesPage.qml` + `FamilyEditDialog.qml` to the new controller/model. Fix all the bugs in Section 5.
6. Once Families is solid, **delete `QmlServices`** (or leave it as a deprecated shim during transition).

### Phase 2 — Dashboard + Members (1-2 weeks)
**Why Dashboard next:** it's the landing page, currently full of mock data — fixing it gives immediate visible value.
**Why Members next:** Members depend on Families (FK), and almost every other module references Members.

1. Expose `DashboardService` as a singleton. Wire `DashboardPage.qml` to real data.
2. Build `MemberController` + `MemberListModel`. Migrate `MemberView` + `MemberEditDialog` to QML.
3. Build the family-detail view (click a family → see its members) — this is a natural extension and exercises the member list model.

### Phase 3 — Subscriptions + Donations + Accounting (2-3 weeks)
**Why together:** these three are financially intertwined. Subscriptions and Donations both auto-create `transactions` rows. Accounting displays those transactions. Migrating them together ensures the auto-linking logic stays consistent.

1. Build `SubscriptionController` + `SubscriptionListModel` + `SubscriptionPlanListModel`. Migrate `SubscriptionView` + `SubscriptionEditDialog`. Include the Defaulters tab.
2. Build `DonationController` + `DonationListModel` + `DonationCategoryListModel`. Migrate `DonationView` + `DonationEditDialog`.
3. Build `AccountingController` + `TransactionListModel` + `LedgerAccountListModel`. Migrate `AccountingView` + transaction dialog. Include the Summary tab.

### Phase 4 — Marriage + Death + Welfare + Certificates (2-3 weeks)
**Why together:** Marriage and Death both feed into Certificates (you can issue a marriage or death cert directly from those registers). Welfare is independent but shares the same register-style UI.

1. Build `MarriageController` + `MarriageListModel`. Migrate `MarriageView` + edit dialog. Wire "Issue Certificate" button to call `CertificateController.issueMarriageCert(marriageId)`.
2. Build `DeathController` + `DeathListModel`. Migrate `DeathView` + edit dialog. Wire cert button.
3. Build `WelfareController` + `WelfareListModel`. Migrate `WelfareView` + edit/approve/disburse dialogs.
4. Build `CertificateController` + `CertificateListModel`. Migrate `CertificateView`. Wire PDF generation (consider moving `CertificateService::generatePdf` to a worker thread for non-blocking UX).

### Phase 5 — Tokens (1-2 weeks)
**Why last among data modules:** Token depends on Families (it assigns tokens to families) and Members (for head name display). Also requires the missing schema fix from Phase 0.

1. Fix the missing `token_events`/`token_assignments`/`token_print_log` schema.
2. Build `TokenEventController` + `TokenEventListModel` + `TokenAssignmentListModel`. Migrate `TokenView` (the two-page stacked widget — event list + event detail).
3. Wire PDF generation (token sheet + collection sheet) to `TokenPdfEngine`. Consider QML `Qt.createQmlObject` for the print preview, or generate to a temp file and open with `QDesktopServices::openUrl`.

### Phase 6 — Reports + Settings + Users + Audit + Backup + Login (2-3 weeks)
**Why last:** these are mostly admin/utility screens. They can be migrated in any order.

1. **Login screen** — build `AuthController` wrapping `AuthService`. Migrate `LoginView` to QML. Add a "must change password" flow. This is a prerequisite for shipping — without it, the QML app has no auth.
2. **Settings** — expose `SettingsService` as singleton. Migrate `SettingsView` (mahallu info, theme, language, backup config).
3. **Users** — build `UserController` + `UserListModel`. Migrate `UserManagementView` + edit/password dialogs.
4. **Audit Log** — build `AuditLogController` + `AuditLogListModel`. Migrate `AuditLogView`.
5. **Backup** — expose `BackupService` (already a QObject). Migrate `BackupView` (list, create, restore, verify, delete, prune). Wire `backupProgress` signal to a QML `ProgressBar`.
6. **Reports** — build `ReportController` with `Q_INVOKABLE QVariantList generate(reportType, from, to)` + `Q_INVOKABLE QString exportCsv(row, path)` / `exportPdf` / `exportExcel`. Migrate `ReportsView`. Reports can take time — consider a worker thread with progress.

### Phase 7 — Polish + Cutover (1 week)
1. Remove all `Coming soon` placeholders in `AppShell.qml`.
2. Delete the widgets `MMS` target from `CMakeLists.txt` (and all `src/views/*.cpp` files) once QML parity is confirmed.
3. Update `app.qrc` to include all new QML pages.
4. Run the 70-point verification matrix from `MMS-FINAL-VERIFY` against the QML build.
5. Package as `MinzMahallu-Windows-x86_64-2.0.0.zip`.

### Total estimated effort
**10-15 weeks** for a single developer, assuming 4 hours/day focused on migration. Can be parallelized: Phases 2-6 can overlap if multiple developers work on different modules (each module is self-contained once the Phase 1 foundation is in place).

### Dependency graph (visual)
```
Phase 0 (fixes) → Phase 1 (foundation)
                   ↓
                   Phase 2 (Dashboard + Members)
                   ↓
                   Phase 3 (Subscriptions + Donations + Accounting)
                   ↓
                   Phase 4 (Marriage + Death + Welfare + Certificates)
                   ↓
                   Phase 5 (Tokens)  ← requires Phase 0 token schema fix
                   ↓
                   Phase 6 (Reports + Settings + Users + Audit + Backup + Login)
                   ↓
                   Phase 7 (Polish + Cutover)
```

---

## Appendix A — Files read during this audit

### Core (`src/core/`)
- `Database.h/.cpp`, `Config.h/.cpp`, `Security.h/.cpp`, `Logger.h`, `I18N.h/.cpp` (partial), `IconUtils.h`, `FontManager.h`

### Models (`src/models/`)
- `Family.h`, `Member.h`, `Subscription.h`, `Donation.h`, `Transaction.h`, `User.h`, `AuditLog.h` (also declares `Certificate` + `Document`), `Marriage.h`, `Death.h`, `Welfare.h`, `TokenAssignment.h`, `TokenEvent.h`

### Repositories (`src/repositories/`)
- `FamilyRepository.h/.cpp`, `MemberRepository.h/.cpp`, `SubscriptionRepository.h/.cpp`, `DonationRepository.h/.cpp`, `AccountingRepository.h/.cpp`, `UserRepository.h/.cpp`, `AuditLogRepository.h/.cpp`, `CertificateRepository.h/.cpp`, `MarriageRepository.h/.cpp`, `DeathRepository.h/.cpp`, `WelfareRepository.h/.cpp`, `TokenRepository.h/.cpp`

### Services (`src/services/`)
- `FamilyService.h/.cpp`, `MemberService.h/.cpp`, `SubscriptionService.h/.cpp`, `DonationService.h/.cpp`, `AccountingService.h/.cpp`, `DashboardService.h/.cpp`, `ReportService.h/.cpp`, `CertificateService.h/.cpp`, `AuthService.h/.cpp`, `AuthSession.h/.cpp`, `SettingsService.h/.cpp`, `BackupService.h/.cpp`, `TokenService.h/.cpp`, `TokenPdfEngine.h/.cpp`, `QmlServices.h/.cpp`, `RegisterServices.h/.cpp` (Marriage/Death/Welfare)

### Views (`src/views/`)
- `MainWindow.h/.cpp` (full), `DashboardView.h/.cpp` (partial), `LoginView.h/.cpp` (partial), `FamilyView.h/.cpp` (full), `FamilyEditDialog.h/.cpp` (full), `MemberView.h/.cpp` (full), `MemberEditDialog.h/.cpp` (full), `SubscriptionView.h`, `SubscriptionEditDialog.h/.cpp` (partial), `DonationView.h/.cpp` (partial), `AccountingView.h`, `RegisterViews.h/.cpp` (partial), `OtherViews.h/.cpp` (partial), `TokenView.h/.cpp` (partial), `SplashScreen.h`, `FlowLayout.h`

### SQL
- `sql/schema.sql`, `sql/seed.sql`, `sql/migrations/V002_add_language_column.sql`, `sql/migrations/README.sql`

### QML
- `qml/design/AppShell.qml`, `qml/design/DashboardPage.qml`, `qml/design/FamilyEditDialog.qml` (older design preview), `qml/pages/FamiliesPage.qml`, `qml/pages/FamilyEditDialog.qml` (active), `qml/components/AppButton.qml`, `qml/components/AppTextField.qml`, `qml/components/AppComboBox.qml`, `qml/components/StatusBadge.qml`, `qml/components/ConfirmDialog.qml`

### Build
- `CMakeLists.txt`, `resources/mms.qrc`, `app.qrc`

### Entry points
- `src/main.cpp` (widgets), `src/app_main.cpp` (QML)

---

## Appendix B — Glossary

- **Mahallu** — a local Muslim congregation / parish, typically organized around a single mosque. The unit of administration for this app.
- **Ward** — a sub-geographic division of a mahallu (often numbered 1, 2, 3…).
- **Nikah** — Islamic marriage contract; the marriage ceremony.
- **Mahar** — the mandatory gift from groom to bride in an Islamic marriage (also spelled mahr, mehr).
- **Imam** — the prayer leader of a mosque; often officiates nikah.
- **PBKDF2** — Password-Based Key Derivation Function 2, used for password hashing with 200,000 iterations of HMAC-SHA256.
- **QSS** — Qt Style Sheets, the CSS-like styling language for Qt Widgets.
- **QML** — Qt Modeling Language, the declarative JS-like language for Qt Quick.
- **Facade** — a design pattern where a single "front" object wraps multiple underlying services (`QmlServices` is a facade).
- **QAbstractListModel** — the Qt base class for list models that QML `ListView`/`GridView` can bind to.
