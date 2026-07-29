# MMS User Manual

## 1. Getting Started

### Logging In

1. Launch MMS from the Start Menu or desktop shortcut.
2. On the login screen, enter your **Username** and **Password**.
3. Click **Login** or press Enter.

**Default admin credentials:** `admin` / `admin123`

> ⚠️ **IMPORTANT:** Change the default password immediately after first login.
> Use the user menu (top-right) → **Change Password...**

### Logging Out

Click your username in the top-right corner → **🚪 Logout**.

If you close the application window while logged in, you will be prompted to confirm exit and an automatic backup will be created (if enabled).

## 2. Dashboard

The Dashboard provides an at-a-glance overview of the Mahallu:

- **Stat cards:** Total Families, Total Members, Active Members, Monthly Collection, Pending Dues, Donations, Welfare, Marriages (this year), Deaths (this year), Balance (this month).
- **Charts:** Monthly collections, donations by category, income vs expense, membership growth.
- **Recent Activity:** Latest 15 audit log entries.
- **Quick Actions:** Add Family / Member / Payment / Donation / Report buttons at the top.

Click **🔄 Refresh** to update all numbers.

## 3. Family Management

### Adding a Family

1. Click **Families** in the sidebar.
2. Click **➕ Add Family**.
3. Fill in the form:
   - **Family Number** auto-generates (e.g. FAM-0006) but can be edited.
   - **House Name**, **Phone**, and **Address** are required.
   - **Ward**, **Area**, **Pincode** are optional but recommended.
4. Click **Save**.

### Editing a Family

1. Select a family in the table.
2. Click **✏ Edit** (or double-click the row).
3. Modify fields and Save.

### Archiving a Family

Archiving keeps the record but hides it from active lists.

1. Select the family.
2. Click **📦 Archive**.
3. Confirm.

To view archived families, set the **Status** filter to "Archived". Use **restore** via the Administrator.

### Deleting a Family

Permanent deletion is only allowed for families with **no members**. Use Archive instead for families with member history.

## 4. Member Management

### Adding a Member

1. Click **Members** in the sidebar.
2. Click **➕ Add Member**.
3. Select the **Family** from the dropdown.
4. Fill in:
   - **Name** (required)
   - **Gender** (required: Male/Female/Other)
   - **Date of Birth** (age auto-computes)
   - Mobile, Email, Occupation, Education, Blood Group, etc.
   - **Relationship** (Head/Spouse/Son/Daughter/...)
   - Upload **Photo** (JPG/PNG).
5. Save.

### Setting the Family Head

The first member added with Relationship = "Head" becomes the family head automatically. To change the head:

1. Edit the new head member.
2. Set Relationship to "Head".
3. Save. (The previous head is automatically demoted.)

## 5. Subscription Collection

### Recording a Payment

1. Click **Subscriptions** → **💰 Collections** tab.
2. Click **➕ Record Payment**.
3. Select:
   - **Family** (and optionally a Member)
   - **Plan** (Monthly / Yearly / Special)
   - **Amount** and **Amount Paid**
   - **Payment Date**
   - **Method** (Cash / Cheque / UPI / Bank Transfer / Card)
   - **Status** (Paid / Pending / Overdue / Partial)
4. Receipt number auto-generates.
5. Save.

When status = Paid, the application automatically creates a linked income transaction in the accounting ledger.

### Tracking Defaulters

Click the **⚠ Defaulters** tab to see all families with pending or overdue subscriptions, with the total due amount.

### Marking Overdue

Click **⚠ Mark Overdue** to automatically transition all pending subscriptions whose period has ended to "Overdue" status.

## 6. Donation Management

1. Click **Donations** in the sidebar.
2. Click **➕ Add Donation**.
3. Enter donor details (name required), category, amount, date, payment method.
4. Save. An accounting income transaction is auto-created.

Filter by date range, category, or search by donor name. Use **📤 Export** to save the filtered list as CSV.

## 7. Accounting

### Recording Income

1. Click **Accounting** → **📒 Transactions** tab.
2. Click **➕ Add Income**.
3. Select an Income account (Subscription / Donation / Rent / Other).
4. Enter amount, date, description, method.
5. Save.

### Recording Expenses

Same as income, but click **➖ Add Expense**. Select from Salary, Electricity, Water, Maintenance, Welfare, Other accounts.

### Viewing Summary

Click the **📊 Summary** tab to see totals per account for the selected period. The top of the page shows Income / Expense / Balance summary.

## 8. Marriage Register

1. Click **Marriage Register**.
2. Click **➕ Register**.
3. Fill bride & groom details, fathers, addresses, witnesses (up to 4), mahar, nikah date, place.
4. Save. Marriage number auto-generates (e.g. MRG-2024-006).

To generate a marriage certificate, click **📜 Certificate**. The PDF opens automatically.

## 9. Death Register

1. Click **Death Register**.
2. Click **➕ Register**.
3. Enter deceased name, father, date of death, burial date, cause, place, age.
4. Optionally link to a Family (this auto-marks the matching member as Deceased).
5. Save. Death number auto-generates (e.g. DTH-2024-006).

To generate a death certificate, click **📜 Certificate**.

## 10. Welfare Management

### Creating a Request

1. Click **Welfare** → **➕ New Request**.
2. Enter applicant name, category (Medical/Education/Marriage/Financial), amount requested, reason.
3. Save. Request number auto-generates (e.g. WEL-2024-006).

### Approval Workflow

- **✓ Approve:** Select a pending request, click Approve, enter approved amount and remarks.
- **✗ Reject:** Select, click Reject, enter reason.
- **💸 Disburse:** Only for approved requests. Click Disburse to record the payment date. This also creates an accounting expense transaction.

## 11. Certificates

The Certificates module generates PDF certificates with QR codes for verification.

1. Click **Certificates**.
2. Choose certificate type:
   - **👤 Membership** — enter member code (e.g. MEM-0001)
   - **🏠 Residence** — enter family number (e.g. FAM-0001) + recipient name
   - **💍 Marriage** — enter marriage number
   - **🕯 Death** — enter death number
3. PDF opens automatically after generation.

Each issued certificate is recorded in the database with a unique number and QR payload.

## 12. Reports

1. Click **Reports** in the sidebar.
2. Select a report type from the dropdown (14 types available).
3. Set the date range (some reports ignore date range).
4. Click **🔄 Generate** to view in the table.
5. Click **📤 CSV**, **🖨 PDF**, or **📊 Excel** to export.

## 13. Audit Log

The Audit Log records every state-changing action. Filter by:

- **Action** (LOGIN, ADD, EDIT, DELETE, etc.)
- **Module** (family, member, subscription, etc.)
- **Date range**

Click **📤 Export** to save the filtered log as CSV.

## 14. Backup & Restore

### Creating a Backup

1. Click **Backup & Restore**.
2. Click **💾 Create Backup Now**.
3. The ZIP file is saved in your data directory under `backups/`.

### Restoring a Backup

1. Select a backup from the table.
2. Click **♻ Restore From Backup**.
3. Confirm the warning. The current database will be preserved as `.pre_restore`.
4. Restart the application after restore.

### Verifying a Backup

Select a backup → **✓ Verify** to check ZIP integrity.

### Pruning Old Backups

Click **🧹 Prune Old** to delete all but the 10 most recent backups.

## 15. Settings

1. Click **Settings** in the sidebar.
2. **Mahallu Organization:** Name, address, phone, email, financial year start, currency symbol, receipt prefix.
3. **Logo & Seal:** Upload images for use on certificates.
4. **Theme:** Light or Dark.
5. **Backup:** Enable auto-backup and set interval (hours).
6. Click **💾 Save Settings**.

## 16. User Management (Administrators Only)

1. Click **Users** in the sidebar (visible only to Administrators).
2. **➕ Add User:** Enter username, full name, password, role, contact.
3. **✏ Edit:** Update name, role, active status, or reset password.
4. **🔓 Unlock:** Manually unlock a locked account.
5. **🔑 Reset Password:** Set a new password for a user.

## 17. Keyboard Shortcuts

- **Enter** — Confirm dialog / Submit form
- **Esc** — Cancel dialog
- **F5** — Refresh current view (when focus is in a table)
- **Ctrl+F** — Focus the global search bar

## 18. Troubleshooting

| Problem | Solution |
|---------|----------|
| Cannot login after 5 attempts | Account locked for 15 minutes. Ask admin to unlock. |
| Forgot password | Ask admin to reset via User Management. |
| Backup fails | Check disk space in data directory. |
| PDF doesn't open | Ensure default PDF viewer is set. |
| Application crashes | Check the log file at `<data dir>/logs/mms.log`. |
| Slow search | Re-index: contact administrator to run `PRAGMA optimize`. |
