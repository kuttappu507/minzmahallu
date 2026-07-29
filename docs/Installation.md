# MMS Installation Guide

## 1. System Requirements

### Minimum

- **OS:** Windows 10 64-bit (or Windows 11)
- **RAM:** 4 GB
- **Disk:** 200 MB free (for application + small database)
- **Display:** 1366 × 768
- **.NET:** Not required (pure C++/Qt)

### Recommended

- **OS:** Windows 11 64-bit
- **RAM:** 8 GB
- **Disk:** 1 GB free (for attachments, backups, exports)
- **Display:** 1920 × 1080 or higher (scales to 2K/4K)
- **Printer:** For receipt and certificate printing

### Supported Resolutions

- 1366 × 768 (minimum)
- 1920 × 1080
- 2560 × 1440 (2K)
- 3840 × 2160 (4K) — DPI scaling supported

## 2. Installation Methods

### Method A: Installer (Recommended)

1. Download `MMS-Setup-1.0.0.exe` from your vendor.
2. Right-click → **Run as administrator**.
3. Follow the wizard:
   - Accept license agreement
   - Choose install location (default: `C:\Program Files\MMS`)
   - Choose data location (default: `%APPDATA%\MMS`)
   - Create desktop shortcut
   - Create Start Menu entry
4. Click **Install**.
5. Launch from desktop or Start Menu.

### Method B: Portable ZIP

1. Download `MMS-1.0.0-portable.zip`.
2. Extract to any folder (e.g., `D:\MMS` or a USB drive).
3. Create a file named `mms.portable` in the same folder as `MMS.exe`.
4. Launch `MMS.exe`.

The portable version stores all data (database, logs, backups, attachments) in a `data/` subfolder next to the executable. No registry entries are created.

### Method C: Build from Source

See the Developer Guide for build instructions.

## 3. Post-Install Setup

### First Launch

1. The application creates the database and seeds default data on first launch.
2. Log in with `admin` / `admin123`.
3. Change the admin password (mandatory).
4. Configure organization settings (see Administrator Manual Section 2).
5. Create user accounts for staff.

### Data Directory Location

| Mode | Path |
|------|------|
| Installed | `%APPDATA%\MMS\` (e.g., `C:\Users\<user>\AppData\Roaming\MMS\`) |
| Portable | `<exe folder>\data\` |

The data directory contains:
- `mms.db` — the SQLite database
- `mms.ini` — user preferences
- `logs/mms.log` — application log
- `backups/mms_backup_*.zip` — auto & manual backups
- `attachments/photos/` — member photos
- `attachments/<module>/<id>/` — other attachments
- `exports/` — exported PDFs, CSVs

## 4. Network & Firewall

MMS is a **fully offline desktop application**. No internet connection is required for any core functionality.

- No inbound ports needed.
- No outbound network traffic.
- No telemetry or analytics sent.

If Windows Firewall prompts, you can safely block all network access.

## 5. Antivirus Considerations

MMS may be flagged by some antivirus software because:

- It writes files to the user's AppData directory (database, logs).
- It uses OpenSSL (sometimes flagged due to malware reuse).

To whitelist:

1. Add the MMS installation folder to exclusions.
2. Add the data directory to exclusions.
3. If using Windows Defender: Settings → Update & Security → Windows Security → Virus & threat protection → Manage settings → Exclusions.

## 6. Printer Setup

For receipt and certificate printing:

1. Install printer drivers normally via Windows Settings.
2. Set the default printer.
3. In MMS, printing uses `QPrinter` which respects the system default.
4. For PDF certificates, MMS generates the PDF file and opens it with the system's default PDF viewer (Edge, Adobe Reader, etc.) — print from there.

## 7. Multi-User Access (Single-Office)

MMS uses SQLite, which supports concurrent reads but only one writer at a time. For multi-user access in a single office:

### Option A: Shared Network Drive (NOT recommended)

- Place the data directory on a network share.
- Only ONE user can write at a time; others get "database is locked" errors.
- Risk of corruption if network hiccups.

### Option B: Terminal Server (Recommended)

- Install MMS on a Windows machine acting as Terminal Server (Remote Desktop Services).
- Each user logs in via Remote Desktop.
- All users share the same SQLite file locally on the server.
- SQLite handles concurrent access from RDP sessions correctly.

### Option C: Single Workstation with Shared Login

- One staff member uses MMS at a time on a dedicated PC.
- Other staff wait their turn or use the audit log to coordinate.

## 8. Uninstalling

### Installed version

1. Control Panel → Programs and Features → MMS → Uninstall, OR
2. Settings → Apps → MMS → Uninstall.
3. The data directory is preserved (in case you reinstall).
4. To fully remove: delete `%APPDATA%\MMS\` manually.

### Portable version

1. Delete the folder containing `MMS.exe` and the `data/` subfolder.

## 9. Upgrading

### To upgrade MMS to a newer version:

1. **Backup** the database via Backup & Restore → Create Backup Now.
2. Note the current version (Help → About).
3. Close MMS.
4. Run the new installer (it overwrites the executable).
5. Launch MMS. Schema migrations auto-apply on first launch.
6. Verify the new version in Help → About.

### Rollback

If the new version has issues:

1. Close MMS.
2. Restore the pre-upgrade backup via Backup & Restore → Restore.
3. Reinstall the previous version's executable.

## 10. Common Installation Issues

### "Missing DLL" errors on launch

Install the **Microsoft Visual C++ Redistributable 2015-2022 (x64)** from Microsoft.

### "Failed to initialize database" on first launch

- Check that the data directory is writable.
- Check that the SQL files are present alongside the executable (`sql/schema.sql`).
- Check the log file at `<data dir>/logs/mms.log` for details.

### Application crashes immediately

- Check `logs/mms.log` for the error.
- Try running as administrator once (to create the data directory).
- Reinstall if the issue persists.

### Qt platform plugin error

- Ensure the `platforms/` folder is alongside `MMS.exe` (the installer handles this).
- Try setting `QT_QPA_PLATFORM_PLUGIN_PATH` environment variable to the plugins folder.

## 11. Silent Installation (for IT admins)

The installer (Inno Setup) supports silent install:

```bat
MMS-Setup-1.0.0.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
```

To install to a custom directory:

```bat
MMS-Setup-1.0.0.exe /VERYSILENT /DIR="D:\MMS"
```

## 12. Verification

After installation, verify by:

1. Launch MMS — should reach the login screen in under 3 seconds.
2. Log in as `admin` / `admin123`.
3. Check that the Dashboard shows seed data (5 families, 15 members).
4. Click each sidebar item — each view should load without errors.
5. Try creating a backup — should appear in the Backup & Restore table.
6. Check `logs/mms.log` — should show initialization messages without errors.

If all checks pass, the installation is successful.
