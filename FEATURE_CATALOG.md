# MMS — Legacy Qt Widgets Feature Catalog (for QML Migration)

**Task ID:** AUDIT-2
**Agent:** general-purpose (research sub-agent)
**Scope:** Catalog every function/feature in the legacy Qt Widgets views at `src/views/*.cpp` so the QML migration team has a one-shot implementation checklist.
**Constraint:** RESEARCH ONLY — no files were modified.
**Source files read end-to-end:** `DashboardView.cpp`, `FamilyView.cpp`, `FamilyEditDialog.cpp`, `MemberView.cpp`, `MemberEditDialog.cpp`, `SubscriptionView.cpp`, `SubscriptionEditDialog.cpp`, `DonationView.cpp`, `AccountingView.cpp`, `RegisterViews.cpp` (Marriage + Death + Welfare), `TokenView.cpp`, `OtherViews.cpp` (Certificate + Reports + Settings + AuditLog + Backup + UserManagement + ChangePasswordDialog), `MainWindow.cpp`, `LoginView.cpp`.

**QML status legend:**
- ✅ **done** — feature exists in production QML (`qml/pages/*.qml`) and works against a real C++ controller.
- 🟡 **partial** — feature exists but is incomplete (placeholder, missing controller, or mock data).
- ❌ **missing** — feature does not exist in QML yet.

---

## Section 1 — Feature Inventory by Module

### Dashboard  *(legacy: `DashboardView.cpp`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| D1 | Greeting header | Shows `dash_greeting` + `AuthSession::user().fullName` + `dash_subtitle` | 🟡 `DashboardV3.qml` design preview only — not wired to `AuthSession`. Production `Main.qml` is a smoke test. |
| D2 | Current date chip | Localized "dddd, dd MMMM yyyy" pill (slate background, slate border) | ❌ |
| D3 | Refresh button | Chip button with refresh SVG icon, calls `refresh()` → reloads stats + charts + recent activity | ❌ |
| D4 | 5 Quick-action buttons | White card + solid colored icon square + title + subtitle. Each emits `navigateToView(index)` to switch the central stack: Add Family (1), Add Member (2), Record Payment (3), Add Donation (4), Generate Report (10) | ❌ Quick-action row absent from production QML. |
| D5 | 10 stat cards in 5×2 grid | Each card has tinted background + colored border + solid-color icon (37×37) + ▲/▼ delta badge + large value + uppercase label. Stats: totalFamilies, totalMembers, activeMembers, monthlyCollection, pendingDues, monthlyDonations, welfareBeneficiaries, marriagesThisYear, deathsThisYear, balanceThisMonth | 🟡 `DashboardPage.qml` / `DashboardV3.qml` render the cards visually with hardcoded mock numbers; no `DashboardController` exists. |
| D6 | 4 chart cards in 2×2 | (a) Collections line chart (emerald, 12 months) via `DashboardService::monthlyCollections(12)`; (b) Donations line chart (gold, by category) via `donationsByCategory(...)`; (c) Income vs Expense bar chart (6 months) via `incomeVsExpense(6)` with legend; (d) Membership growth line chart (sky blue, 12 months) via `membershipGrowth(12)`. Each chart card has title + colored left-border + subtitle. Theme switches to `QChart::ChartThemeDark` when palette is dark. | ❌ No QtCharts equivalent in QML yet. |
| D7 | Recent activity table | 4-column `QTableWidget` (Time, User, Action, Description) populated from `audit_log ORDER BY id DESC LIMIT 15` | ❌ |
| D8 | Currency symbol | Pulled from `SettingsService::currencySymbol()` and prepended to money values | ❌ |
| D9 | Navigate-to-view signal | `emit navigateToView(int)` connected to `navList_->setCurrentRow(index)` in MainWindow | ❌ |

### Families  *(legacy: `FamilyView.cpp` + `FamilyEditDialog.cpp`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| F1 | Page title (h1) | `family_title` i18n string | ✅ |
| F2 | Search box | Placeholder "Search by family no, house name, phone, area…", clear button, height 32, triggers `page_=1; refresh()` on textChanged | ✅ |
| F3 | Status filter combo | `""`, Active, Inactive, Archived | ✅ |
| F4 | Ward filter combo | Loaded from `FamilyService::wards()` at construction | ✅ |
| F5 | Add Family button (primary) | Opens `FamilyEditDialog`; on accept calls `refresh()` | ✅ |
| F6 | Edit button (chip) | Reads selected row ID; if none, shows warning; opens `FamilyEditDialog(familyId)` | ✅ |
| F7 | **Archive button** (chip) | Confirmation dialog "Are you sure… It can be restored later"; calls `FamilyService::archiveFamily(id)`; on success shows info + refresh | ❌ QML `FamiliesPage` has no Archive action (only Delete). |
| F8 | Delete button (ghostDanger) | Warning dialog "This will permanently delete… You can only delete a family with no members"; calls `FamilyService::deleteFamily(id, &err)`; on error shows the err message | ✅ |
| F9 | **Print button** (chip) | Calls `ReportService::familyRegister(statusFilter)` then `exportToPdf(row, "Family Register", path)` and `QDesktopServices::openUrl(path)` | ❌ |
| F10 | **Export button** (chip) | `QFileDialog::getSaveFileName` → `ReportService::exportToCsv` → info dialog with path | ❌ |
| F11 | Table columns | ID, family_number, house_name, ward, area, phone, members_count, status — 8 cols, with section resize modes (Stretch / ResizeToContents) | ✅ |
| F12 | **Column sorting** | `setSortingEnabled(true)` — click header to sort | ❌ QML ListView has no column-sort. |
| F13 | Status color coding | Archived = whole row muted; Inactive = status cell red; Active = status cell green | 🟡 QML uses `StatusBadge` (badge only); no full-row tint for Archived. |
| F14 | Row double-click → edit | `cellDoubleClicked` signal connected to `onEdit()` | ❌ QML rows are not double-clickable (only action icons). |
| F15 | Pagination | Prev/Next + "Page X / Y (N records)" label, enables/disables buttons | ✅ |
| F16 | Ward filter reload | `loadWardFilter()` rebuilds combo from `FamilyService::wards()` | ✅ |

**FamilyEditDialog (`FamilyEditDialog.cpp`):**

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| FE1 | Auto-generated family number | `FamilyRepository::generateNextFamilyNumber()` on add | ✅ (`FamilyController.create` handles server-side) |
| FE2 | Fields | familyNumber (ro), houseName, houseNumber, ward, area, address (TextEdit), pincode (QIntValidator 100000–999999), phone (placeholder "10-digit mobile number"), altPhone, statusCombo (Active/Inactive/Archived), notes (TextEdit) | ✅ all fields present |
| FE3 | Pincode int range validator | `QIntValidator(100000, 999999)` — 6-digit Indian pincode | 🟡 QML uses regex `^\d{6}$` (equivalent). |
| FE4 | Status mapping | Translates TR("member_active") etc. ↔ "Active" enum before save | ✅ |
| FE5 | Save/Cancel QDialogButtonBox | `action_save` / `action_cancel` translated buttons | ✅ |

### Members  *(legacy: `MemberView.cpp` + `MemberEditDialog.cpp`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| M1 | Page title | `member_title` | ✅ |
| M2 | Search box | Placeholder `member_search_placeholder`, clear button | ✅ |
| M3 | Gender filter | `""`, Male, Female, Other | ✅ |
| M4 | Status filter | `""`, Active, Inactive, Deceased | ✅ |
| M5 | Add Member (primary) | Opens `MemberEditDialog` | ✅ |
| M6 | Edit (chip) | Warning if no row selected; opens dialog with memberId | ✅ |
| M7 | Delete (ghostDanger) | Warning "Permanently delete this member record?"; calls `MemberService::deleteMember(id, &err)` | ✅ |
| M8 | **Print** | `ReportService::memberRegister(statusFilter)` → PDF → auto-open | ❌ |
| M9 | **Export** | CSV file dialog | ❌ |
| M10 | Table columns | ID, Code, Name, Gender, Age, Mobile, Family (concat familyNumber + " / " + houseName), Status | ✅ |
| M11 | Row double-click → edit | `cellDoubleClicked` | ❌ |
| M12 | Pagination | Prev/Next + "Page X of Y (N members)" | ✅ |

**MemberEditDialog (`MemberEditDialog.cpp`):**

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| ME1 | **Photo box** | 120×150 QLabel showing member photo (or "No Photo" placeholder), with `Upload Photo` button below | ❌ QML dialog has no photo upload UI at all. |
| ME2 | **Photo file dialog** | `QFileDialog::getOpenFileName` for `Images (*.jpg *.jpeg *.png *.bmp)`; validates `QPixmap::isNull`; on success sets `photoPath_` and scales preview | ❌ |
| ME3 | **Photo persistence** | On save calls `MemberService::savePhoto(photoPath_, memberId_)` which copies the chosen file into the app data dir and returns the saved path | ❌ `MemberController` in QML has no `savePhoto` exposed. |
| ME4 | Family combo | Width 300, items "F-0001 - HouseName", data = family id | ✅ |
| ME5 | **Family info label** | Below the combo, shows ` %1 |  %2, %3` (familyNumber + address + area) updated via `onFamilyChanged()` when family changes | ❌ QML dialog has no family-info preview line. |
| ME6 | Auto-generated member code | `MemberRepository::generateNextMemberCode()` on add | ✅ (server-side) |
| ME7 | Gender combo | Male, Female, Other | ✅ |
| ME8 | DOB calendar popup | `QDateEdit` with `setCalendarPopup(true)`, ISO format | 🟡 QML uses text field with YYYY-MM-DD placeholder (no calendar popup). |
| ME9 | Age spin | `QSpinBox` range 0–150 | 🟡 QML uses text field (no spin). |
| ME10 | Blood group combo | `""`, A+, A-, B+, B-, AB+, AB-, O+, O- | ✅ |
| ME11 | Marital status combo | Single, Married, Divorced, Widowed | ✅ |
| ME12 | Relationship combo | Head, Spouse, Son, Daughter, Parent, Sibling, Other | ✅ |
| ME13 | Status combo | Active, Inactive, Deceased | ✅ |
| ME14 | Nationality default | "Indian" prefilled | ✅ |
| ME15 | Validation | family required, name required, `Security::isValidPhone(mobile)`, `Security::isValidEmail(email)` | ✅ |
| ME16 | **Auto-set family head** | On create: if `relationship == "Head"`, calls `MemberService::setFamilyHead(familyId, id)` after creating | ❌ `MemberController.create` does not expose this hook. |
| ME17 | Photo path stored on member | `member_.photoPath = savedPath` after save | ❌ |
| ME18 | Photo loaded on edit | `QPixmap(photoPath_).scaled(120,150,...)` if file exists | ❌ |

### Subscriptions  *(legacy: `SubscriptionView.cpp` + `SubscriptionEditDialog.cpp`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| S1 | Page title | `sub_title` | ✅ |
| S2 | Summary label | `"Collected (from to): ₹X | Total Pending Dues: ₹Y"` recomputed on every refresh | 🟡 QML shows two summary cards (collected / pending) but no date-range label. |
| S3 | **Tabs**: Collections / Defaulters | `QTabWidget` with 2 tabs | ❌ QML has no Defaulters tab. |
| S4 | Search box | "Search by receipt, family…" | ✅ |
| S5 | Status filter | `""`, Paid, Pending, Overdue, Partial | ✅ |
| S6 | **From date picker** | `QDateEdit` default `currentDate().addMonths(-1)`, calendar popup | ❌ |
| S7 | **To date picker** | `QDateEdit` default today | ❌ |
| S8 | Add/Record Payment (primary) | `sub_record_payment` label | ✅ |
| S9 | Edit (chip) | — | ✅ |
| S10 | Delete (ghostDanger) | — | ✅ |
| S11 | **Mark Overdue** (ghostDanger) | Calls `SubscriptionService::markOverdue()`; shows info dialog "N subscription(s) marked as overdue"; refresh | ✅ (QML does this with a toast instead of a modal info dialog). |
| S12 | **Print** | `ReportService::subscriptionReport(from,to)` → `subscription_report.pdf` → auto-open | ❌ |
| S13 | **Export** | CSV dialog | ❌ |
| S14 | Table columns | ID, Receipt, Family, Member, Plan, Amount, Paid, Status (color-coded: Paid=green, Overdue=red, Pending=yellow, else accent) | ✅ |
| S15 | Tab change handler | `onTabChanged` → refresh (re-loads the appropriate table) | ❌ |
| S16 | **Defaulters table** | Columns: Family No, House Name, Phone, Pending Count, Due Amount (red). Tooltip shows running total due. Calls `SubscriptionService::defaulters()`. | ❌ Entire tab missing. |
| S17 | Pagination | Prev/Next + "Page X of Y (N records)" | ✅ |

**SubscriptionEditDialog (`SubscriptionEditDialog.cpp`):**

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| SE1 | Family combo (cascading) | Loads active families; on `currentIndexChanged` calls `onFamilyChanged()` → `loadMembers(familyId)` | ✅ |
| SE2 | Member combo | `loadMembers(familyId)` queries `MemberRepository::listByFamily`; items "Name (relationship)" | ✅ |
| SE3 | Plan combo | `SubscriptionRepository::listPlans()`; items "PlanName (₹X)"; selecting first plan auto-sets `amountEdit_->setValue(plans.front().defaultAmount)` | ✅ |
| SE4 | Period start/end (date pickers) | Defaults: today / today+1 month | ✅ |
| SE5 | Amount (double spin) | Range 0–10,000,000, step 10, decimals 2 | 🟡 QML uses text field (no spin). |
| SE6 | Amount Paid (double spin) | Same range; auto-filled by `onStatusChanged` | 🟡 QML uses text field. |
| SE7 | **Status-driven auto-fill** | When status = "Paid" → `amountPaid = amount`; when "Pending" → `amountPaid = 0` | ❌ Not implemented in QML dialog. |
| SE8 | Payment date | Default today | ✅ |
| SE9 | Receipt number (auto) | `SubscriptionService::nextReceiptNumber()` | ✅ (server-side) |
| SE10 | Payment method combo | Cash, Cheque, UPI, Bank Transfer, Card, Other | ✅ |
| SE11 | Status combo | Paid, Pending, Overdue, Partial | ✅ |
| SE12 | Remarks (TextEdit) | — | ✅ |
| SE13 | Validation | family + plan + amount>0; amountPaid ≤ amount | ✅ |

### Donations  *(legacy: `DonationView.cpp` + inline `DonationEditDialog`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| DN1 | Page title | `don_title` | ✅ |
| DN2 | Summary label | `"Total Donations (from to): ₹X"` | 🟡 QML shows summary card with no date range. |
| DN3 | Search box | "Search by donor, receipt…" | ✅ |
| DN4 | Category combo | `"All Categories"` + items from `DonationService::categories()` (id+name) | ✅ |
| DN5 | **From date picker** | Default `currentDate().addMonths(-1)` | ❌ |
| DN6 | **To date picker** | Default today | ❌ |
| DN7 | Add Donation (primary) | `don_add` | ✅ |
| DN8 | Edit (chip) | — | ✅ |
| DN9 | Delete (ghostDanger) | — | ✅ |
| DN10 | **Print** | `ReportService::donationReport(from,to)` → `donation_report.pdf` → auto-open | ❌ |
| DN11 | **Export** | CSV dialog | ❌ |
| DN12 | Table columns | ID, Receipt, Donor, Category, Amount (positive color), Date, Purpose | ✅ |
| DN13 | Pagination | — | ✅ |

**DonationEditDialog (inline):**

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| DE1 | Donor name* | — | ✅ |
| DE2 | Donor phone | — | ✅ |
| DE3 | Donor address (TextEdit) | — | ✅ |
| DE4 | Category combo | From `DonationService::categories()` | ✅ |
| DE5 | Amount (double spin) | Range 1–10M, step 100, decimals 2 | 🟡 Text field. |
| DE6 | Donation date (calendar popup) | Default today | 🟡 Text field, no calendar. |
| DE7 | Receipt number (auto) | `DonationService::nextReceiptNumber()` | ✅ (server-side) |
| DE8 | Purpose | — | ✅ |
| DE9 | Payment method combo | Cash, Cheque, UPI, Bank Transfer, Card, Other | ✅ |
| DE10 | Remarks (TextEdit) | — | ✅ |

### Accounting  *(legacy: `AccountingView.cpp` + inline `TransactionEditDialog`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| A1 | Page title | `acc_title` | ✅ |
| A2 | Summary label | `"Income: ₹X | Expense: ₹Y | Balance: ₹Z (Period: from to)"` | 🟡 QML shows 3 summary cards but no period label. |
| A3 | **Tabs**: Transactions / Summary | `QTabWidget` | ❌ QML has no Summary tab. |
| A4 | Type filter | `""`, Income, Expense | ✅ |
| A5 | **From date picker** | Default today−1 month | ❌ |
| A6 | **To date picker** | Default today | ❌ |
| A7 | **Add Income** (primary) | Opens `TransactionEditDialog` with preset "Income" — type combo disabled | ❌ QML has single "Add Transaction" button. |
| A8 | **Add Expense** (primary) | Opens `TransactionEditDialog` with preset "Expense" | ❌ |
| A9 | Delete (ghostDanger) | — | ✅ |
| A10 | **Print** | `ReportService::cashBookReport(from,to)` → `cash_book.pdf` → auto-open | ❌ |
| A11 | **Export** | CSV dialog `cash_book.csv` | ❌ |
| A12 | Table columns | ID, Date, Type (color-coded: Income=green, Expense=red), Account, Description, Amount, Receipt | ✅ |
| A13 | Pagination | — | ✅ |
| A14 | **Summary table** | Columns: Code, Name, Type, Total (color-coded). Calls `AccountingService::accountTotals(from,to)`. | ❌ Entire tab missing. |
| A15 | Tab change handler | `onTabChanged` → refresh | ❌ |

**TransactionEditDialog (inline):**

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| TE1 | Date (calendar popup) | Default today | 🟡 |
| TE2 | Type combo | Income/Expense; if `presetType_` non-empty, locked | ❌ QML dialog has no type lock. |
| TE3 | Account combo | Filtered by type via `AccountingService::accounts(type)`; items "CODE - Name" with id data; reloads when type changes | 🟡 |
| TE4 | Amount (double spin) | Range 1–100M, step 100, decimals 2 | 🟡 |
| TE5 | Payment method combo | Cash, Cheque, UPI, Bank Transfer, Card, Other | ✅ |
| TE6 | Reference, Receipt, Description* | Description placeholder "e.g., Imam salary April 2024" | ✅ |
| TE7 | Description required validation | Shows "Description is required." | ✅ |

### Marriage Register  *(legacy: `RegisterViews.cpp` — `MarriageView` + `MarriageEditDialog`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| MR1 | Page title | `mrg_title` | ✅ |
| MR2 | Search box | "Search by number, names, father…" | ✅ |
| MR3 | **From date picker** | Default today−1 year | ❌ |
| MR4 | **To date picker** | Default today | ❌ |
| MR5 | Register Marriage (primary) | `mrg_register` label | ❌ QML `MarriagePage` has no Add button at all. |
| MR6 | Edit (chip) | — | ❌ |
| MR7 | Delete | — | ✅ |
| MR8 | **Certificate button** (primary) | Reads selected id; calls `CertificateService::generateMarriageCertificatePdf(id, &err)`; auto-opens PDF | ❌ |
| MR9 | **Print** | `ReportService::marriageRegisterReport(from,to)` → `marriage_register.pdf` → auto-open | ❌ |
| MR10 | **Export** | CSV `marriages.csv` | ❌ |
| MR11 | Table columns | ID, No, Bride, Groom, Nikah Date, Place, Registration | ✅ |
| MR12 | Pagination | — | ✅ |

**MarriageEditDialog:**

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| ME_M1 | Marriage number (auto) | `MarriageService::nextMarriageNumber()` | ❌ No dialog exists. |
| ME_M2 | Bride name*, bride father, bride address | — | ❌ |
| ME_M3 | Groom name*, groom father, groom address | — | ❌ |
| ME_M4 | Witness 1-4 | Four separate QLineEdit fields | ❌ |
| ME_M5 | Mahar | — | ❌ |
| ME_M6 | Nikah date* (calendar popup), registration date | Defaults today | ❌ |
| ME_M7 | Place, Remarks | — | ❌ |

### Death Register  *(legacy: `RegisterViews.cpp` — `DeathView` + `DeathEditDialog`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| DR1 | Page title | `dth_title` | ✅ |
| DR2 | Search box | "Search by name, number…" | ✅ |
| DR3 | **From date picker** | Default today−1 year | ❌ |
| DR4 | **To date picker** | Default today | ❌ |
| DR5 | Register Death (primary) | `mrg_register` label reused | ❌ No Add button. |
| DR6 | Edit | — | ❌ |
| DR7 | Delete | — | ✅ |
| DR8 | **Certificate button** (primary) | `CertificateService::generateDeathCertificatePdf(id, &err)` → auto-open | ❌ |
| DR9 | **Print** | `ReportService::deathRegisterReport(from,to)` → `death_register.pdf` → auto-open | ❌ |
| DR10 | **Export** | CSV `deaths.csv` | ❌ |
| DR11 | Table columns | ID, No, Name, Father, Date of Death, Burial, Cause | ✅ |
| DR12 | Pagination | — | ✅ |

**DeathEditDialog:**

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| DE_D1 | Death number (auto) | `DeathService::nextDeathNumber()` | ❌ No dialog exists. |
| DE_D2 | Deceased name*, father name | — | ❌ |
| DE_D3 | Family combo | `FamilyRepository::listAll("Active")` items "F-0001 - HouseName" | ❌ |
| DE_D4 | Gender combo | `""`, Male, Female, Other | ❌ |
| DE_D5 | Date of death*, burial date | Calendar popup; defaults today | ❌ |
| DE_D6 | Cause of death | — | ❌ |
| DE_D7 | Burial place | Default "Mahallu Cemetery" | ❌ |
| DE_D8 | Age spin | Range 0–150 | ❌ |
| DE_D9 | Remarks | — | ❌ |

### Welfare  *(legacy: `RegisterViews.cpp` — `WelfareView` + `WelfareEditDialog`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| W1 | Page title | `wel_title` | ✅ |
| W2 | Search box | "Search by applicant, request no…" | ✅ |
| W3 | Status filter | `""`, Pending, Approved, Rejected, Disbursed, Closed | ✅ |
| W4 | Category filter | `""`, Medical Aid, Education Aid, Marriage Assistance, Financial Assistance | ✅ |
| W5 | New Request (primary) | `wel_new_request` | ❌ No Add button. |
| W6 | Edit | — | ❌ |
| W7 | Delete | — | ✅ |
| W8 | **Approve button** (primary) | `action_approve` — opens `QInputDialog::getDouble` for approved amount (0–10M, 2 decimals) → `QInputDialog::getText` for approval remarks → `WelfareService::approveRequest(id, amt, remarks)` → refresh | ❌ |
| W9 | **Reject button** (ghostDanger) | `action_reject` — `QInputDialog::getText` "Reason for rejection:" → `WelfareService::rejectRequest(id, remarks)` → refresh | ❌ |
| W10 | **Disburse button** (primary) | `action_disburse` — confirmation dialog "Confirm disbursement…?" → `WelfareService::disburseRequest(id, today's ISO date)` → refresh | ❌ |
| W11 | **Print** | `ReportService::welfareReport("", today)` → `welfare_report.pdf` → auto-open | ❌ |
| W12 | **Export** | CSV `welfare.csv` | ❌ |
| W13 | Table columns | ID, Request No, Applicant, Category, Requested, Approved, Status (color-coded: Approved=green, Rejected=red, Disbursed=info/blue, Pending=yellow) | ✅ |
| W14 | Pagination | — | ✅ |

**WelfareEditDialog:**

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| WE1 | Request number (auto) | `WelfareService::nextRequestNumber()` | ❌ No dialog exists. |
| WE2 | Applicant name*, family combo | — | ❌ |
| WE3 | Category combo | Medical Aid, Education Aid, Marriage Assistance, Financial Assistance | ❌ |
| WE4 | Amount requested (double spin) | Range 1–10M, step 1000, decimals 2 | ❌ |
| WE5 | Reason* (TextEdit) | — | ❌ |
| WE6 | Status combo | Pending, Approved, Rejected, Disbursed, Closed | ❌ |
| WE7 | Remarks (TextEdit) | — | ❌ |

### Certificates  *(legacy: `OtherViews.cpp` — `CertificateView`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| C1 | Page title | `cert_title` | ✅ (placeholder only) |
| C2 | **Issue Membership** (primary) | `QInputDialog::getText` for member code → `MemberRepository::findByCode` → if found, build Certificate{type="Membership", memberId, familyId, issuedTo=name, issuedDate=today} → `CertificateService::issueCertificate` → `generatePdf(id)` → auto-open | ❌ |
| C3 | **Issue Residence** (chip) | `QInputDialog::getText` for family number → `FamilyRepository::findByNumber` → `QInputDialog::getText` "Issued to (name):" → issue cert + generate PDF | ❌ |
| C4 | **Issue Marriage** (chip) | `QInputDialog::getText` for marriage number → `MarriageRepository::findByNumber` → `CertificateService::generateMarriageCertificatePdf(id)` → auto-open | ❌ |
| C5 | **Issue Death** (chip) | `QInputDialog::getText` for death number → `DeathRepository::findByNumber` → `CertificateService::generateDeathCertificatePdf(id)` → auto-open | ❌ |
| C6 | **Generate PDF** (primary) | Regenerates PDF for the selected existing certificate (`CertificateService::generatePdf(id)`) → auto-open | ❌ |
| C7 | Delete (ghostDanger) | Confirmation → `CertificateRepository::remove(id)` | ❌ |
| C8 | **Export List** (chip) | CSV of certificates with columns Cert No, Type, Issued To, Date, Issued By | ❌ |
| C9 | Type filter combo | `""`, Membership, Residence, Marriage, Death, Character, Income | ❌ |
| C10 | **From date / To date pickers** | Default range: today−12 months to today | ❌ |
| C11 | Table columns | ID, Cert No, Type, Issued To, Date, Issued By | ❌ |

> The entire `CertificatesPage.qml` is a placeholder. **All** certificate functionality is missing.

### Reports  *(legacy: `OtherViews.cpp` — `ReportsView`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| R1 | Page title | `rpt_title` | ✅ (placeholder only) |
| R2 | **Report type combo** | 14 entries: Family Register, Member Register, Active Members, Family Directory, Subscription Report, Defaulters Report, Donation Report, Income Report, Expense Report, Cash Book Report, Financial Summary, Marriage Register Report, Death Register Report, Welfare Report | ❌ QML `ReportsPage` shows a 10-card grid (read-only), no combo. |
| R3 | **From date picker** | Default today−3 months | ❌ |
| R4 | **To date picker** | Default today | ❌ |
| R5 | **Generate button** (primary) | `rpt_generate` — calls the matching `ReportService::*Report()` method and populates the table | ❌ |
| R6 | **CSV export button** (chip) | File dialog → `ReportService::exportToCsv(row, path)` | ❌ |
| R7 | **PDF export button** (chip) | `ensureExportPath(reportName + ".pdf")` → `exportToPdf(row, title, path, from, to)` → auto-open | ❌ |
| R8 | **Excel-compatible CSV export** (chip) | `exportToExcel(row, title, path)` (UTF-8 BOM CSV) | ❌ |
| R9 | **Dynamic results table** | Column count + headers change with the selected report; populated from `ReportRow::cell(r,c)` | ❌ |
| R10 | Auto-refresh on combo/date change | `currentTextChanged` and `dateChanged` both trigger `refresh()` | ❌ |

> The QML `ReportsPage.qml` shows a static 10-card grid with descriptions; clicking a card shows a toast "use the legacy app for now". **All** report-generation functionality is missing.

### Settings  *(legacy: `OtherViews.cpp` — `SettingsView`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| ST1 | Page title | `set_title` | ✅ (placeholder only) |
| ST2 | **Mahallu Organization group** | Mahallu name, address (TextEdit), phone, email, financial year start (placeholder "MM-DD"), currency symbol (default ₹), receipt prefix | ❌ |
| ST3 | **Logo & Seal group** | 80×80 preview QLabel each + Upload Logo / Upload Seal buttons; `QFileDialog` for `*.png *.jpg *.jpeg *.bmp`; preview updated on selection; paths persisted via `MahalluSettings::logoPath/sealPath` | ❌ |
| ST4 | **User Interface group** | Theme combo (light, dark) | ❌ |
| ST5 | **Backup group** | Auto-backup checkbox + interval spin (1–168 hours, suffix " hours") | ❌ |
| ST6 | **Save Settings button** | Calls `SettingsService::save(s)` + `applyTheme(s.theme)` + info dialog "Settings saved successfully." | ❌ |
| ST7 | Load on construction | `SettingsService::instance().load()` populates all fields | ❌ |
| ST8 | Scrollable content | Wrapped in `QScrollArea` | ❌ |

> The QML `SettingsPage.qml` is a placeholder. **All** settings functionality is missing.

### Audit Log  *(legacy: `OtherViews.cpp` — `AuditLogView`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| AL1 | Page title | `audit_title` | ✅ |
| AL2 | **Search box** | "Search description…"; client-side filter on description | ❌ |
| AL3 | Action filter combo | `""`, LOGIN, LOGOUT, LOGIN_FAILED, ADD, EDIT, DELETE, PRINT, EXPORT, BACKUP, RESTORE, PASSWORD_CHANGE | 🟡 QML has a shorter list (no LOGIN_FAILED, PASSWORD_CHANGE). |
| AL4 | **Module filter combo** | `""`, auth, family, member, subscription, donation, accounting, marriage, death, welfare, certificate, user, settings, system | ❌ |
| AL5 | **From date / To date pickers** | Default today−30 days to today | ❌ |
| AL6 | **Export button** (chip) | CSV `audit_log.csv` with all filtered entries | ❌ |
| AL7 | Table columns | Time, User, Action (color-coded: DELETE/LOGIN_FAILED/REJECT=red, ADD/APPROVE/LOGIN=green, EDIT=yellow), Module, Description | 🟡 QML has 5 columns but no Module column visible (actually present in code, just narrower). |
| AL8 | Pagination | Prev/Next + "Page X of Y (N entries)" | ❌ QML has no pagination; uses `currentPage=1, pageSize=50`. |
| AL9 | Count today subtitle | (not in legacy; QML addition via `AuditLogController.countToday()`) | ✅ QML-only feature. |

### Backup  *(legacy: `OtherViews.cpp` — `BackupView`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| B1 | Page title | `bak_title` | ✅ (placeholder only) |
| B2 | Info label | Two-paragraph HTML explaining ZIP storage + restore semantics | ❌ |
| B3 | **Create Now button** (primary) | `BackupService::createBackup(&err)` → info dialog with path or warning with err | ❌ |
| B4 | **Restore button** (chip) | Reads selected row path; warning dialog "REPLACE current database… .pre_restore saved… All users logged out… Continue?" → `BackupService::restoreBackup(path, &err)` → info "Please restart the application" | ❌ |
| B5 | **Verify button** (chip) | `BackupService::verifyBackup(path, &err)` → info "Backup file is valid." or warning with err | ❌ |
| B6 | **Delete button** | Confirmation → `QFile::remove(path)` → refresh | ❌ |
| B7 | **Prune Old button** (ghostDanger) | `BackupService::pruneOldBackups(10)` → info "Removed N old backup(s)." | ❌ |
| B8 | Table columns | File, Created (formatted "yyyy-MM-dd hh:mm"), Size (B/KB/MB auto), Path | ❌ |
| B9 | Refresh | `BackupService::listBackups()` on every refresh | ❌ |

> The QML `BackupPage.qml` is a placeholder. **All** backup functionality is missing.

### Users  *(legacy: `OtherViews.cpp` — `UserManagementView` + `UserEditDialog`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| U1 | Page title | `usr_title` | ✅ |
| U2 | Add User (primary) | `usr_add` — opens `UserEditDialog`; if password empty, validation error; otherwise `AuthService::createUser(username, fullName, password, role, email, phone, true)` | ❌ |
| U3 | Edit (chip) | Opens `UserEditDialog(id)`; username read-only; if password non-empty, calls `auth.adminResetPassword(id, password)` after profile update | ❌ |
| U4 | Delete | Prevents self-delete (`id == AuthSession::user().id` → warning "You cannot delete your own account.") | ✅ (delete works; self-delete protection unknown in QML) |
| U5 | **Unlock button** (chip) | `AuthService::unlockUser(id)` → refresh | ❌ |
| U6 | **Reset Password button** (ghostDanger) | `QInputDialog::getText` (password mode) for new password → `AuthService::adminResetPassword(id, pwd)`; on failure shows password policy message | ❌ |
| U7 | Table columns | ID, Username, Full Name, Role, Email, Active (Yes/No), Locked ("LOCKED" in red or "—") | 🟡 QML shows Username, FullName, Role, Email, Phone, Status (badge), Last Login — slightly different but adequate. |
| U8 | **Change Password dialog** (`ChangePasswordDialog`) | Old/New/Confirm password fields (echo mode Password), live strength label (`Security::passwordStrength` 0–5 → "Very Weak"/"Weak"/"Fair"/"Good"/"Strong"/"Very Strong" with color), password policy description label, OK/Cancel; on submit calls `AuthService::changePassword(userId, old, new)` | ❌ No equivalent in QML. Reached from the user menu in MainWindow. |

### Tokens  *(legacy: `TokenView.cpp`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| T1 | Two-page stack | `QStackedWidget` switching between Event List page and Event Detail page | ❌ QML `TokensPage` is a single placeholder. |
| T2 | Event List page header | Title `token_events` + New Event button (primary) + Delete Event button (ghostDanger) | ❌ |
| T3 | Event table | 6 cols: ID, Event Name, Type, Date, Total Families, Status | ❌ |
| T4 | **Row double-click → detail** | `cellDoubleClicked` opens detail page for that event | ❌ |
| T5 | **New Event dialog** (`TokenEventDialog`) | Fields: event name*, type combo (Meat/Food/Aid/Ration/Gift/Other Distribution), date* (calendar), time (`QTimeEdit` "hh:mm AP"), venue, description (TextEdit), notes (LineEdit) | ❌ |
| T6 | Delete event | Confirmation → `TokenService::deleteEvent(id, &err)` | ❌ |
| T7 | Detail page header | Back button (chip) + dynamic title (event name) + info label (Date / Time / Venue / Status) | ❌ |
| T8 | **Progress bar** | `QProgressBar` showing `stats.percentage` collected | ❌ |
| T9 | Stats label | `"Total Families: X | Collected: Y | Pending: Z"` from `TokenService::getStats(eventId)` | ❌ |
| T10 | **Select Families dialog** (`FamilySelectionDialog`) | Two-pane multi-select: available (left) + selected (right). Ward filter combo. Search box. Buttons: Add Selected, Add All Ward, Add All Active, Remove, Clear All. Count label. OK = "Generate". Filters out families already assigned to this event. | ❌ |
| T11 | **Generate Tokens** | After family selection, confirmation dialog → `TokenService::generateTokens(eventId, familyIds, &err)` → success toast + reload detail | ❌ |
| T12 | Assignment table | 6 cols: Serial No, Head Name, House Name, Unique Code (Courier New bold, centered), Ward, Collected (color-coded) | ❌ |
| T13 | **Print Tokens button** (chip) | Custom `QMessageBox` with 3 buttons: Print to Printer / Save PDF / Cancel. PDF branch: file dialog → `TokenPdfEngine::generateTokenSheet(event, assignments, path, &err)` → auto-open. Printer branch: `printTokenSheet(event, assignments, &err)` | ❌ |
| T14 | **Print Collection Sheet** (chip) | Same 3-button dialog; PDF: `generateCollectionSheet`; printer: `printCollectionSheet` | ❌ |
| T15 | **Mark Collected** (primary) | Reads serial no from selected row; finds assignment; `TokenService::markCollected(a.id, &err)` → reload | ❌ |
| T16 | **Mark Uncollected** (ghostDanger) | Same flow with `markUncollected` | ❌ |
| T17 | Toggle collected on row | `onToggleCollected(row, col)` toggles based on current state | ❌ |

> The entire `TokensPage.qml` is a placeholder. The legacy Token tables **do** exist in schema (per `TokenRepository.cpp`); the QML comment "token tables missing from schema" is **incorrect** — see §3 Token Distribution workflow below.

### MainWindow  *(legacy: `MainWindow.cpp`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| MW1 | Window default 1366×768, min 1200×700 | Centered on primary screen at startup | ❌ `Main.qml` is 400×200 smoke test. |
| MW2 | Window title + icon | "Minz Mahallu Management" + `:/icons/mms_icon.png` | ❌ |
| MW3 | Auto-backup timer | `QTimer` started at `Config::autoBackupIntervalHours() * 3600 * 1000`; on tick creates backup if logged in, shows status message + logs | ❌ |
| MW4 | **Top bar** (54px) | Breadcrumbs (small "MMS" + big current-view label), global search box (clear button, max width 320), theme toggle (sun/moon icon), language toggle (EN/മല), backup button (instant backup), user menu button (popup menu) | ❌ `AppShell.qml` exists in `qml/design/` but is design preview only — no production shell. |
| MW5 | **Global search** | On Enter: queries `families` (family_number/house_name/phone LIKE) and `members` (name/member_code/mobile LIKE), shows results dialog with up to 10 of each | ❌ |
| MW6 | **Theme toggle** | Toggles `currentTheme_` light↔dark, calls `SettingsService::applyTheme`, updates icon, persists to `settings.theme` via direct SQL | ❌ |
| MW7 | **Language toggle** | Toggles en↔ml, calls `SettingsService::setLanguage`, calls `onLanguageChanged` which re-renders the whole app (showApp) to retranslate all labels | ❌ |
| MW8 | **Instant backup button** | `BackupService::createBackup(&err)` → info or warning dialog | ❌ |
| MW9 | **User menu** (popup) | "Change Password…", "Toggle Theme", "Logout" | ❌ |
| MW10 | **Sidebar** (260px, collapsible to 80px) | Header (48×48 logo), nav list (15 items with white SVG icons), user card at bottom (avatar initial 40×40, full name, role, Logout button) | ❌ |
| MW11 | **Sidebar collapse flap** | 26×62 `QToolButton` on the sidebar's right edge; chevron-left when expanded, chevron-right when collapsed; repositions on resize | ❌ |
| MW12 | Collapsed mode | Hides labels, hides app name/sub, hides user name/role, replaces Logout text with icon, shrinks logo to 56×56, hides nav item text | ❌ |
| MW13 | **Nav permission filtering** | Always shows Dashboard + Settings. Shows Users/Audit/Backup only if `role == "Administrator"`. All other modules gated by `session.hasPermission(module, "view")` | ❌ |
| MW14 | Nav item changed | Sets stack widget; updates breadcrumb; status bar shows "Loaded: X" for 2 seconds | ❌ |
| MW15 | **Status bar** | `statusBar()->showMessage(...)` for transient messages; permanent label "Minz Mahallu Management v{APP_VERSION_STR}" | ❌ |
| MW16 | Update user menu | Button text = "FullName (Role)"; sidebar user card fields populated; avatar initial = first letter of fullName (or "U") | ❌ |
| MW17 | **Change Password dialog** | Opens `ChangePasswordDialog` (see U8) | ❌ |
| MW18 | **Auto-backup on close** | In `closeEvent`, if logged in + `Config::autoBackupEnabled()`, creates a final backup before logout | ❌ |
| MW19 | Close confirmation | "Are you sure you want to exit?" Yes/No (default No) | ❌ |
| MW20 | retranslateUi | Re-applies all i18n strings to nav items, tooltips, status bar, app title | ❌ |
| MW21 | refreshAll() | Calls `refresh()` on every view (called on showApp and after language change) | ❌ |
| MW22 | Apply combo shadow | Iterates all `QComboBox` children and calls `icons::applyComboShadow` | ❌ |
| MW23 | Dashboard quick-action hookup | Connects `DashboardView::navigateToView(int)` → `navList_->setCurrentRow(index)` | ❌ |

### Login  *(legacy: `LoginView.cpp`)*

| # | Feature | Description | QML status |
|---|---------|-------------|------------|
| L1 | Login card (480×580) | Logo (96×96), app name (h1), subtitle (viewSub), username/password form rows (height 40), error label (hidden by default), login button (primary, height 44, default), forgot password button (flat, centered) | ❌ No QML login screen exists. |
| L2 | Theme toggle (top-right) | Sun/moon icon, instant apply via `SettingsService::applyTheme` | ❌ |
| L3 | Language toggle (top-right) | "EN" or "മല" button, switches language + retranslates | ❌ |
| L4 | Hint label | `login_default_hint` (e.g. "Default: admin / admin123") | ❌ |
| L5 | Attempt login | Validates non-empty fields; disables button + shows `login_signing_in`; calls `AuthService::login`; on success emits `loginSuccessful()`; on `mustChangePassword` shows info dialog | ❌ |
| L6 | Forgot password | Info dialog with bilingual message ("contact Mahallu Administrator") | ❌ |
| L7 | Show event | Clears fields, hides error, focuses username, retranslates | ❌ |
| L8 | Return-pressed submits | `passwordEdit::returnPressed` → `attemptLogin` | ❌ |

---

## Section 2 — Missing Features Priority List

Priority is driven by (a) blocking the production shell, (b) blocking daily user workflows, (c) blocking admin/audit workflows. Higher = more urgent.

| # | Feature | Module | Why it's important |
|---|---------|--------|--------------------|
| 1 | Production `Main.qml` shell with sidebar + top bar + nav + stack + status bar | MainWindow | Without this nothing else can be reached. The QML app currently cannot even boot into the real UI. |
| 2 | Login screen (QML) + AuthService binding | Login | Cannot reach any feature without authentication. |
| 3 | Permission-based nav filtering (Administrator sees Users/Audit/Backup) | MainWindow | Security: a regular Staff user must not see admin modules. |
| 4 | Theme toggle + language toggle (top bar) | MainWindow | Already half-built in legacy; users expect both. |
| 5 | Global search (families + members) | MainWindow | Single fastest path to a record; used constantly. |
| 6 | Status bar messages + version label | MainWindow | Required for the "Loaded: X" feedback and version display. |
| 7 | Change Password dialog with live strength meter | Users | First-line defense for account security; reachable from user menu. |
| 8 | User Edit dialog (Add/Edit) | Users | Cannot create new user accounts from QML today. |
| 9 | User Unlock + Reset Password actions | Users | Account lockout recovery — common admin task. |
| 10 | Self-delete protection in Users | Users | Prevents admins from locking themselves out. |
| 11 | Dashboard quick-action row (5 buttons) | Dashboard | Primary navigation path for daily data entry. |
| 12 | Dashboard stat cards wired to `DashboardController` (10 KPIs) | Dashboard | Currently shows hardcoded mock numbers. |
| 13 | Dashboard 4 charts (Collections / Donations / Income vs Expense / Membership Growth) | Dashboard | Visual analytics is the dashboard's main value. |
| 14 | Dashboard recent-activity table (last 15 audit entries) | Dashboard | Operational visibility into who did what. |
| 15 | Member photo upload (file dialog + preview + persistence) | Members | Every member record benefits from a photo; legacy has it, QML doesn't. |
| 16 | Auto-set family head on Member create when relationship=Head | Members | Head-of-family drives family-list display and certificate issuance. |
| 17 | Family info preview line in MemberEditDialog | Members | Reduces wrong-family data entry. |
| 18 | Subscription Defaulters tab + defaulters table | Subscriptions | Core operational view for collections follow-up. |
| 19 | Subscription From/To date range filter | Subscriptions | Required for monthly/period reporting. |
| 20 | Subscription status-driven auto-fill (Paid → amountPaid=amount; Pending → amountPaid=0) | Subscriptions | Eliminates a common data-entry error. |
| 21 | Welfare Approve workflow (prompt for approved amount + remarks) | Welfare | Multi-step approval is the welfare module's defining feature. |
| 22 | Welfare Reject workflow (prompt for reason) | Welfare | Required for audit trail of rejection. |
| 23 | Welfare Disburse workflow (confirmation + today's date) | Welfare | Triggers disbursement accounting entries. |
| 24 | Welfare Add/Edit dialog | Welfare | Cannot create welfare requests from QML today. |
| 25 | Marriage Add/Edit dialog (16 fields incl. witnesses, mahar) | Marriage | Cannot register new nikah records from QML today. |
| 26 | Marriage certificate generation (PDF) | Marriage | Each marriage record produces a printable certificate. |
| 27 | Death Add/Edit dialog | Death | Cannot register new death records from QML today. |
| 28 | Death certificate generation (PDF) | Death | Each death record produces a printable certificate. |
| 29 | From/To date range filters on Marriage + Death + Donations + Accounting | Multiple | All four list pages need date filtering for period reporting. |
| 30 | Accounting Summary tab (account totals) | Accounting | Required for end-of-period account reconciliation. |
| 31 | Accounting separate Add Income / Add Expense buttons (type locked in dialog) | Accounting | Faster data entry; prevents wrong-type mistakes. |
| 32 | Certificate issue workflows (Membership / Residence / Marriage / Death) | Certificates | High-value output — every membership/residence/marriage/death certificate is generated here. |
| 33 | Certificate list table + filters + delete + Export List | Certificates | Audit trail of issued certificates. |
| 34 | Reports combo (14 report types) + From/To dates + Generate + CSV/PDF/Excel export + dynamic results table | Reports | The Reports module is entirely missing in QML — every report type the legacy app supports is unavailable. |
| 35 | Print button on every list page (Families, Members, Subscriptions, Donations, Accounting, Marriage, Death, Welfare) | Multiple | Indian mahallu offices rely heavily on printed PDF registers; QML has none. |
| 36 | Export CSV button on every list page | Multiple | Same — offline Excel workflows. |
| 37 | Settings page (org info + logo/seal upload + theme + auto-backup config + save) | Settings | Without this, the mahallu cannot customize receipts/certificates with their logo & seal. |
| 38 | Backup Create / Restore / Verify / Delete / Prune workflows | Backup | Disaster-recovery capability; the QML placeholder says "use legacy app". |
| 39 | Audit Log: search box, module filter, From/To dates, Export CSV, pagination | AuditLog | Currently the QML audit page can only filter by action and shows the first 50 entries. |
| 40 | Token events: list + create + delete + detail page (master-detail) | Tokens | Token distribution (esp. Eid meat) is a high-traffic seasonal feature. |
| 41 | Token family selection multi-pane dialog (available ↔ selected) | Tokens | Required to assign which families get tokens for an event. |
| 42 | Token generation (unique 4-digit codes per family) + Mark Collected / Uncollected | Tokens | Operational tracking on distribution day. |
| 43 | Token PDF generation: token sheet + collection sheet (printer + PDF) | Tokens | Printable tokens are handed to families; printable collection sheet is used by volunteers. |
| 44 | Column sorting on every list table | Multiple | QML ListView has no built-in header sort; legacy had `setSortingEnabled(true)`. |
| 45 | Row double-click → edit on every list table | Multiple | Legacy had `cellDoubleClicked`; QML only has action icons. |
| 46 | Archive button on Families | Families | Soft-delete (archived) is a legacy feature absent in QML. |
| 47 | Auto-backup timer + close-event backup | MainWindow | Critical for data safety; legacy ran a periodic timer. |
| 48 | Date-picker component (calendar popup) for all date fields | Multiple | QML dialogs currently use plain text fields expecting "YYYY-MM-DD". |
| 49 | Numeric spin component for Amount / Age / Interval fields | Multiple | QML dialogs use plain text fields; legacy used `QDoubleSpinBox` / `QSpinBox` with min/max/step. |
| 50 | Malayalam translations re-applied live to all QML strings | MainWindow | Legacy `retranslateUi()` walks every widget; QML has no equivalent pattern yet. |

---

## Section 3 — Special Workflows

These multi-step flows must be ported as discrete state machines in QML. They are listed in the order they typically appear in real usage.

### 3.1 Authentication & Session

**Login flow** (legacy: `LoginView::attemptLogin`):
1. User enters username + password.
2. Client validates non-empty.
3. Button disabled, label → "Signing in…".
4. `AuthService::login(username, password)` returns `{success, mustChangePassword, errorMessage}`.
5. On success: `Logger::info`, emit `loginSuccessful()` → `MainWindow::showApp()` rebuilds the entire nav + view stack.
6. If `mustChangePassword` is true, show info dialog with `val_password_policy`.
7. On failure: show `errorLabel_` with `result.errorMessage`, clear password, refocus.

**Logout flow** (`MainWindow::onLogout`):
1. `AuthService::logout()` writes the audit log entry.
2. `showLogin()` hides sidebar/topbar/flap, switches stack to LoginView.

**Change Password flow** (`ChangePasswordDialog`):
1. User enters current, new, confirm.
2. As they type the new password, `Security::passwordStrength` (0–5) is polled and the label updates to "Very Weak" / "Weak" / "Fair" / "Good" / "Strong" / "Very Strong" with a matching color.
3. On submit: confirm mismatch check; `AuthService::changePassword(userId, old, new)` enforces the policy server-side; on success `accept()`, on failure show warning.

### 3.2 Certificate Generation Workflows

**Membership certificate** (`CertificateView::onIssueMembership`):
1. `QInputDialog::getText` "Enter member code (e.g. MEM-0001):".
2. `MemberRepository::findByCode(memberCode)` → if null, "Member not found." warning, abort.
3. Build `Certificate{type="Membership", memberId, familyId, issuedTo=name, issuedDate=today}`.
4. `CertificateService::issueCertificate(c, &err)` → assigns `certificateNumber` + `qrPayload`, returns id.
5. `CertificateService::generatePdf(id, &err)` → uses `resources/templates/membership_cert.html` + draws QR code → returns PDF path.
6. `QDesktopServices::openUrl(path)` — opens in the system PDF viewer.
7. `refresh()` reloads the cert list table.

**Residence certificate** (`onIssueResidence`):
1. `QInputDialog::getText` "Enter family number (e.g. FAM-0001):".
2. `FamilyRepository::findByNumber(famNo)` → if null, "Family not found." warning, abort.
3. `QInputDialog::getText` "Issued to (name):" (defaults to family's houseName if blank).
4. Build cert with `type="Residence"`, `familyId`, `issuedTo`, `issuedDate=today`.
5. Issue + generate PDF (uses `resources/templates/residence_cert.html`) + auto-open.

**Marriage certificate** (`onIssueMarriage`):
1. `QInputDialog::getText` "Enter marriage number (e.g. MRG-2024-001):".
2. `MarriageRepository::findByNumber(num)` → if null, "Marriage record not found." warning, abort.
3. `CertificateService::generateMarriageCertificatePdf(m->id)` directly (no cert record created — the marriage record IS the source). Uses `resources/templates/marriage_cert.html`.
4. Auto-open PDF.

**Death certificate** (`onIssueDeath`):
1. `QInputDialog::getText` "Enter death number (e.g. DTH-2024-001):".
2. `DeathRepository::findByNumber(num)` → if null, "Death record not found." warning, abort.
3. `CertificateService::generateDeathCertificatePdf(d->id)` directly. Uses `resources/templates/death_cert.html`.
4. Auto-open PDF.

**Re-generate existing certificate PDF** (`onGenerate`):
1. Select row in cert table; if none, warning.
2. Read `id` from row.
3. `CertificateService::generatePdf(id, &err)` → auto-open.

> **Templates available** in `resources/templates/`: `membership_cert.html`, `marriage_cert.html`, `death_cert.html`, `residence_cert.html`. The QML side needs to expose `CertificateService` as Q_INVOKABLE.

### 3.3 Backup / Restore Flow

**Create backup** (`BackupView::onBackup` and `MainWindow::onBackup`):
1. `BackupService::createBackup(&err)`.
2. Internally: closes DB, copies `.db` + attachment dir into a ZIP at `defaultBackupPath()`, reopens DB.
3. Returns the ZIP path on success.
4. Info dialog "Backup saved to: {path}" or warning dialog with err.

**Restore backup** (`BackupView::onRestore`):
1. Select row in backup table; if none, warning "Select a backup first.".
2. **Critical warning dialog**: "WARNING: This will REPLACE your current database with the selected backup. The current database will be saved as .pre_restore. All users will be logged out after restore. Continue?" Yes/No (default No).
3. `BackupService::restoreBackup(path, &err)`:
   - Closes DB.
   - Renames current `.db` → `.db.pre_restore`.
   - Extracts the ZIP's `.db` to the live path.
   - Reopens DB.
4. Info dialog "Backup restored successfully. Please restart the application.".

**Verify backup** (`onVerify`):
1. `BackupService::verifyBackup(path, &err)` tries to open as ZIP and validates the `.db` inside.
2. Info "Backup file is valid." or warning with err.

**Prune old backups** (`onPrune`):
1. `BackupService::pruneOldBackups(10)` — keeps newest 10, deletes the rest.
2. Info dialog "Removed N old backup(s).".

**Auto-backup** (`MainWindow::onAutoBackupTick` and `closeEvent`):
1. Periodic `QTimer` at `Config::autoBackupIntervalHours() * 3600 * 1000`.
2. On tick: only if logged in, calls `createBackup`, shows status message "Auto-backup completed: {path}" for 5 seconds, logs to `Logger::info`.
3. On `closeEvent` (if user confirms exit and `Config::autoBackupEnabled()`): one final `createBackup` before logout.

### 3.4 Report Generation Flow

**Generate report** (`ReportsView::loadReport`):
1. User selects report type from combo (14 options) and From/To dates.
2. `currentTextChanged` / `dateChanged` triggers `refresh()` → `loadReport()`.
3. A big if/else chain dispatches to the matching `ReportService::*Report(...)` method, returning a `ReportRow{headers, cells, rowCount}`.
4. Table columns + row count updated; cells populated from `row.cell(r, c)`.

**Export CSV** (`onExportCsv`):
1. File dialog → `reportName.toLower().replace(' ', '_') + ".csv"`.
2. Same dispatch to fetch the row.
3. `ReportService::exportToCsv(row, path)` writes the CSV.
4. Info dialog with path.

**Export PDF** (`onExportPdf`):
1. `ReportService::ensureExportPath(reportName + ".pdf")` returns full path under app data dir.
2. `exportToPdf(row, title, path, from, to)` writes a styled PDF with header + period + table.
3. `QDesktopServices::openUrl(path)` — auto-opens.

**Export Excel-compatible CSV** (`onExportExcel`):
1. File dialog → `.csv` filter labelled "Excel-compatible CSV".
2. `ReportService::exportToExcel(row, title, path)` writes UTF-8 BOM CSV (Excel-friendly).

### 3.5 Token Distribution Flow

**Create token event** (`TokenView::onNewEvent`):
1. Open `TokenEventDialog`.
2. User enters: event name*, type* (Meat/Food/Aid/Ration/Gift/Other Distribution), date*, time, venue, description, notes.
3. On accept: validate name non-empty; `TokenService::createEvent(e, &err)` returns created event with id.
4. On success: refresh list + auto-navigate to detail page (`showEventDetail(created.id)`).
5. On failure: error dialog.

**Select families + generate tokens** (`onSelectFamilies`):
1. Open `FamilySelectionDialog(eventId)`.
2. Left pane: all active families NOT already assigned to this event. Filterable by ward (combo) + search (text).
3. Buttons: "Add Selected" (selected items in left → right), "Add All Ward" (all in current ward filter), "Add All Active" (everything in left pane).
4. Right pane: selected families. "Remove" + "Clear All". Live count label.
5. OK = "Generate" → confirmation "Generate tokens for N families?" → `TokenService::generateTokens(eventId, familyIds, &err)`.
6. On success: success toast + reload detail page. Tokens get unique 4-digit codes assigned with serial numbers.

**Print tokens** (`onPrintTokens`):
1. Read event + assignments.
2. If assignments empty → warning "No tokens to print", abort.
3. Custom `QMessageBox` with 3 buttons: "Print to Printer" / "Save PDF" / "Cancel".
4. PDF branch: file dialog → `TokenPdfEngine::generateTokenSheet(event, assignments, path, &err)` → auto-open. The sheet draws one token per family with event info + unique code + QR code.
5. Printer branch: `TokenPdfEngine::printTokenSheet(event, assignments, &err)` — same drawing, sent to `QPrinter`.

**Print collection sheet** (`onPrintCollection`):
1. Same 3-button dialog.
2. PDF: `generateCollectionSheet` — paginated table of all assignments with serial/family/code/collected checkbox.
3. Printer: `printCollectionSheet`.

**Mark collected / uncollected** (`onMarkCollected` / `onMarkUncollected`):
1. Select a row in the assignment table; if none, abort.
2. Read the serial number from the row's first cell.
3. Iterate `getAssignments(eventId)` to find the assignment with that serial.
4. Call `TokenService::markCollected(a.id, &err)` or `markUncollected(a.id, &err)`.
5. On success: `loadEventDetail(currentEventId_)` refreshes the table + progress bar + stats.
6. On failure: error dialog.

**Master-detail navigation**:
- List page → double-click row → detail page.
- Detail page → Back button → list page (refresh).

> The QML comment in `TokensPage.qml` says "token tables missing from schema" — this is **inaccurate**. `src/repositories/TokenRepository.cpp/.h`, `src/services/TokenService.cpp/.h`, and `src/services/TokenPdfEngine.cpp/.h` all exist and work in the legacy app. The schema migration is already in place. The QML team only needs to expose `TokenService` + `TokenPdfEngine` as Q_INVOKABLE and build the two-page UI.

### 3.6 Welfare Approve / Reject / Disburse Flow

**Approve** (`WelfareView::onApprove`):
1. Select a row; if none, abort.
2. `QInputDialog::getDouble` "Approve Welfare Request" / "Enter approved amount:" with range 0–10,000,000, 2 decimals, default 0.
3. If dialog cancelled, abort.
4. `QInputDialog::getText` "Remarks" / "Approval remarks:".
5. `WelfareService::approveRequest(id, amt, remarks)` — updates status="Approved", `amountApproved=amt`, `remarks` appended.
6. `refresh()`.

**Reject** (`WelfareView::onReject`):
1. Select a row.
2. `QInputDialog::getText` "Rejection Reason" / "Reason for rejection:".
3. `WelfareService::rejectRequest(id, remarks)` — sets status="Rejected", records reason.
4. `refresh()`.

**Disburse** (`WelfareView::onDisburse`):
1. Select a row (typically one already Approved).
2. Confirmation dialog "Confirm disbursement of this welfare request?" Yes/No.
3. `WelfareService::disburseRequest(id, QDate::currentDate().toString(Qt::ISODate))` — sets status="Disbursed", `disbursedDate=today`, typically creates an Expense transaction.
4. `refresh()`.

### 3.7 Subscription "Mark Overdue" Batch Workflow

**Mark Overdue** (`SubscriptionView::onMarkOverdue`):
1. Click "Mark Overdue" button (no row selection needed).
2. `SubscriptionService::markOverdue()` scans all subscriptions where `paymentDate < today` AND `status == "Pending"` and flips them to "Overdue". Returns the count affected.
3. Info dialog "N subscription(s) marked as overdue.".
4. `refresh()` reloads both the collections table and the defaulters tab.

### 3.8 Member "Family Head" Auto-Set Workflow

**On Member create** (`MemberEditDialog::onSave`):
1. Validate family + name + mobile format + email format.
2. Save photo (if chosen): `MemberService::savePhoto(photoPath_, memberId_)` copies the file into the app data dir, returns the saved path; `member_.photoPath = savedPath`.
3. `MemberService::createMember(member_, &err)` inserts the row; on success `memberId_ = id`.
4. If `member_.isHead` (i.e. `relationship == "Head"`) AND this was a create: `MemberService::setFamilyHead(member_.familyId, id)` — updates the family row's `head_id` column to this new member.
5. On edit (existing member), the head-set is NOT re-triggered (legacy bug/limitation — only happens on create).

### 3.9 Close-Event / Exit Workflow

**MainWindow::closeEvent**:
1. If logged in:
   a. `QMessageBox::question` "Are you sure you want to exit the Mahallu Management System?" Yes/No (default No).
   b. If No → `event->ignore()`, return.
   c. If `Config::autoBackupEnabled()` → `BackupService::createBackup(&err)` (silent — no UI).
   d. `AuthService::logout()` — writes the LOGOUT audit entry.
2. `Logger::info("Application shutting down")`.
3. `event->accept()`.

### 3.10 Language Toggle Live Retranslation

**MainWindow::onToggleLanguage** → `onLanguageChanged(langCode)`:
1. Toggle button text: `ml` → "EN", `en` → "മല".
2. Update search placeholder.
3. Update window title (Malayalam: "മിൻസ് മഹല്ല് മാനേജ്മെൻ്റ്").
4. Save current nav index + sidebar-collapsed state.
5. If logged in: call `showApp()` — this **destroys and rebuilds every view** with the new language applied to all i18n strings.
6. Restore saved nav index + sidebar-collapsed state.
7. (Login screen handles its own `retranslateUi`.)

> In QML, this pattern requires either (a) a global `retranslate()` signal that every page binds labels to, or (b) `Binding` objects whose `value` reads `I18N.tr(key)` so a `languageChanged` signal auto-re-evaluates them.

### 3.11 Sidebar Collapse Workflow

**MainWindow::onToggleSidebar** → `applySidebarMode(collapsed)`:
- Collapsed=true:
  - Sidebar width 260 → 80.
  - Hide `sidebarAppName`, `sidebarAppSub`, `sidebarUserName`, `sidebarUserRole`.
  - Logo size 64 → 56.
  - Logout button: text → "", icon → log-out.svg, fixed size 48×40, tooltip = "Logout".
  - All nav list item texts → "" (icons remain).
  - Flap button icon → chevron-right.svg, tooltip = "Expand sidebar".
- Collapsed=false: reverse all of the above + `retranslateUi()`.
- `repositionSidebarFlap()` centers the flap vertically on the sidebar's right edge.

### 3.12 Dashboard Navigation Hookup

**DashboardView::navigateToView(int)** signal:
- Emitted by the 5 quick-action buttons with hardcoded indices: Add Family=1, Add Member=2, Record Payment=3, Add Donation=4, Generate Report=10.
- Connected in `MainWindow::showApp()` to a lambda: `navList_->setCurrentRow(index)`.
- Switching the nav row triggers `onNavItemChanged` which switches the stack widget + updates breadcrumb + status bar message.

---

## Appendix — Files Audited

**Legacy view files (read in full):**
- `src/views/DashboardView.cpp` (478 lines)
- `src/views/FamilyView.cpp` (299 lines)
- `src/views/FamilyEditDialog.cpp` (134 lines)
- `src/views/MemberView.cpp` (209 lines)
- `src/views/MemberEditDialog.cpp` (263 lines)
- `src/views/SubscriptionView.cpp` (280 lines)
- `src/views/SubscriptionEditDialog.cpp` (194 lines)
- `src/views/DonationView.cpp` (322 lines)
- `src/views/AccountingView.cpp` (367 lines)
- `src/views/RegisterViews.cpp` (822 lines — Marriage + Death + Welfare)
- `src/views/TokenView.cpp` (591 lines)
- `src/views/OtherViews.cpp` (1,091 lines — Certificate + Reports + Settings + AuditLog + Backup + UserManagement + ChangePasswordDialog)
- `src/views/MainWindow.cpp` (681 lines)
- `src/views/LoginView.cpp` (220 lines)

**Supporting service headers (read for API surface):**
- `src/services/CertificateService.h`
- `src/services/BackupService.h`
- `src/services/TokenPdfEngine.h`
- `src/services/ReportService.h`
- `src/services/QmlServices.h`

**Existing QML pages (read for status comparison):**
- `qml/Main.qml` (smoke test only)
- `qml/design/AppShell.qml` (design preview, not production)
- All 20 files under `qml/pages/`

**Migration progress docs (read for context):**
- `MIGRATION_CHECKLIST.md`
- `MIGRATION_AUDIT.md` (prior AUDIT-1)

---

**Bottom line:** The QML migration currently has the **Families** module at production quality and **Members / Subscriptions / Donations / Accounting / Marriage / Death / Welfare / AuditLog** at partial quality (list + delete only; missing dialogs, filters, print/export, and special workflows). **Certificates, Tokens, Reports, Settings, Backup** are placeholders. The production **Main shell, Login, MainWindow top bar / sidebar / status bar / theme+language toggle / global search / change-password / user edit dialog** are entirely missing. This catalog drives the implementation sequence: shell → login → users → dashboard → module dialogs → module filters → print/export → certificates → tokens → reports → settings → backup.
