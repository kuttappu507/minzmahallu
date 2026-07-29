# MMS Administrator Manual

## 1. Administrator Role

The Administrator has full control over the MMS installation, including:

- User account management (create, edit, delete, unlock, reset password)
- Audit log access
- Backup management
- Organization settings
- All module access (equivalent to other roles combined)

## 2. First-Time Setup

After installing MMS:

1. **Launch the application** and log in with `admin` / `admin123`.
2. **Change the default password** immediately:
   - User menu (top-right) → **Change Password...**
   - Current: `admin123`
   - New: must be at least 8 chars with uppercase, lowercase, digit, and special character.
3. **Configure organization settings:**
   - Settings sidebar item
   - Enter Mahallu Name, Address, Phone, Email
   - Upload Logo (PNG/JPG, square recommended)
   - Upload Seal image (circular PNG with transparency)
   - Set Financial Year Start (e.g. `04-01` for April 1)
   - Set Receipt Prefix (default `RCP`)
   - Choose Theme (Light/Dark)
   - Enable Auto Backup (recommended)
4. **Create user accounts** for each staff member:
   - Users sidebar item → Add User
   - Assign appropriate role (see Section 4)
   - Force password change on first login (`must_change_pwd=1`)
5. **Verify sample data:** The seed data includes 5 families, 15 members, and sample donations/subscriptions. Delete or modify these to match your actual Mahallu records.

## 3. User Management

### Creating a User

1. Users → **➕ Add User**
2. Required fields:
   - **Username** (3+ chars, unique, case-insensitive)
   - **Full Name**
   - **Password** (8+ chars, with upper/lower/digit/special)
   - **Role** (one of 7 roles)
3. Optional: Email, Phone, Active flag
4. Save. New users must change password on first login by default.

### Editing Users

- Change role, email, phone, or active status.
- To reset password, enter a new password in the password field (leave blank to keep current).

### Deleting Users

- Cannot delete your own account.
- Cannot delete the last Administrator account.
- Deletion is permanent; consider deactivating instead (uncheck Active).

### Unlocking Users

Accounts auto-lock after 5 failed login attempts for 15 minutes. To unlock immediately:

1. Select the locked user.
2. Click **🔓 Unlock**.

## 4. Roles & Permissions Matrix

The default permission matrix (editable directly in the `permissions` table for advanced customization):

| Module | Admin | President | Secretary | Treasurer | Imam | Staff | Auditor |
|--------|-------|-----------|-----------|-----------|------|-------|---------|
| Family | CRUD+Print | View+Print | CRUD+Print | View | View | CRUD+Print | View+Print |
| Member | CRUD+Print | View+Print | CRUD+Print | View | View | CRUD+Print | View+Print |
| Subscription | CRUD+Print | View+Print | CRUD+Print | CRUD+Print | View | CRUD+Print | View+Print |
| Donation | CRUD+Print | View+Print | CRUD+Print | CRUD+Print | View | CRUD+Print | View+Print |
| Accounting | CRUD+Print+Export | View+Print+Export | CRUD+Print | CRUD+Print+Export | View | View | View+Print+Export |
| Marriage | CRUD+Print | View+Print | CRUD+Print | View | CRUD+Print | Add+View | View+Print |
| Death | CRUD+Print | View+Print | CRUD+Print | View | CRUD+Print | Add+View | View+Print |
| Welfare | CRUD+Approve+Print | View+Approve+Print | CRUD+Print | View+Approve | View | Add+View | View+Print |
| Certificate | CRUD+Print | View+Print | CRUD+Print | View | CRUD+Print | CRUD+Print | View |
| Report | View+Export+Print | View+Export+Print | View+Export+Print | View+Export+Print | View+Print | View+Print | View+Export+Print |
| Settings | View+Edit | — | — | — | — | — | — |
| Users | CRUD | — | — | — | — | — | — |
| Audit | View | View | — | — | — | — | View |
| Backup | View+Create | — | — | — | — | — | — |

## 5. Backup Strategy

### Recommended Backup Policy

1. **Auto-backup enabled** (default 24-hour interval).
2. **On-exit backup** also runs if auto-backup is enabled.
3. **Manual backup before major changes** (e.g., before restoring old data, before bulk imports).
4. **Off-site copy:** Copy the latest ZIP from `<data dir>/backups/` to:
   - USB drive
   - Cloud storage (Google Drive, Dropbox)
   - Another computer

### Backup Retention

- Default: keeps all backups until manually pruned.
- **🧹 Prune Old** removes all but the 10 most recent.
- For long-term retention, archive monthly backups separately.

### Restoring a Backup

⚠️ **Restoring replaces your current database.** Always create a fresh backup first.

1. Backup & Restore → Select the backup ZIP.
2. Click **♻ Restore From Backup**.
3. Confirm the warning.
4. The current database is preserved as `mms.db.pre_restore` (rename it back to `mms.db` to undo).
5. Restart MMS.

### Verifying Backup Integrity

Before relying on a backup, click **✓ Verify** to confirm the ZIP is valid.

## 6. Audit Log Management

The audit log is append-only and grows continuously. To manage its size:

### Monitoring

- View entries in the **Audit Log** sidebar item.
- Filter by user, action, module, date range.

### Cleanup

For long-running installations, the audit log can grow large. To prune old entries (e.g., older than 2 years):

```sql
DELETE FROM audit_log WHERE created_at < datetime('now', '-2 years');
VACUUM;
```

Run this from a SQLite client after creating a backup.

## 7. Performance Tuning

### For large Mahallus (1000+ families, 5000+ members)

- Keep auto-backup interval at 24h or longer.
- Run `PRAGMA optimize;` periodically (monthly) to update query planner statistics.
- Consider increasing `cache_size` in `Database.cpp` if memory allows.
- For 25,000+ members, consider adding FTS5 virtual tables for full-text search (not yet implemented).

### Index Maintenance

After bulk imports or deletions:

```sql
ANALYZE;
VACUUM;
```

## 8. Security Best Practices

1. **Strong passwords:** Enforce the policy (already done). Encourage users to use password managers.
2. **Regular password changes:** Recommend every 90 days. Reset passwords for users who leave the Mahallu.
3. **Limit Administrator accounts:** Have 1-2 admin accounts max. Use Secretary role for routine operations.
4. **Audit log review:** Periodically review the audit log for unusual activity (e.g., logins outside office hours, bulk deletions).
5. **Backup encryption:** ZIP files are not encrypted. For sensitive data, store backups on encrypted drives.
6. **Physical security:** The desktop running MMS should be in a secure office. Lock the screen when stepping away.

## 9. Data Migration

### From Excel/CSV

To import existing family/member data from spreadsheets:

1. Format your CSV to match the `families` and `members` table columns.
2. Use a SQLite client (e.g., DB Browser for SQLite) to import the CSV.
3. Run the import inside a transaction.
4. Verify counts in MMS.

> ⚠️ Always backup before bulk imports.

### To Another System

Export via the Reports module (CSV/PDF) or directly query the SQLite database file.

## 10. Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| User cannot log in | Account locked | Users → Unlock |
| User cannot log in | Account deactivated | Users → Edit → Active = Yes |
| Database locked | Another process holds the file | Close any other SQLite clients; restart MMS |
| Application slow | Cache saturated | Restart MMS; check log file size |
| Disk full | Backups accumulated | Prune old backups; clean logs |
| PDF generation fails | Disk full or no write permission | Check `<data dir>/exports/` directory |
| Charts not showing | Data missing for the period | Check if any subscriptions/donations exist in the date range |

### Log Files

Located at `<data dir>/logs/mms.log`. Rotates at 10 MB, keeps 5 backups. Levels: Trace/Debug/Info/Warn/Error/Fatal.

For production, set level to `Info` (default). For debugging, set to `Debug` or `Trace` in `Logger::initialize`.

### Database Recovery

If the database becomes corrupted:

1. Stop MMS.
2. Backup the corrupted `mms.db` file.
3. Try the WAL files: rename `mms.db-wal` to `.bak` and reopen.
4. If still corrupt, restore from the most recent valid backup.
5. As a last resort, use SQLite's `.recover` command:
   ```bat
   sqlite3 mms.db ".recover" > recovered.sql
   sqlite3 new_mms.db < recovered.sql
   ```

## 11. Software Updates

### To update MMS:

1. **Backup** the database (Backup & Restore → Create Backup Now).
2. Note the current schema version (Settings shows in logs on startup).
3. Replace the executable.
4. The application auto-applies migrations on next launch.

### Rollback

If the new version fails:

1. Restore the pre-update database backup.
2. Revert to the previous executable.

## 12. Contact

For technical support, contact your MMS vendor or refer to the Developer Guide for source-level debugging.
