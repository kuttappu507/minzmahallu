# Mahallu Management System (MMS)

**Version 1.0.0** — A complete desktop application for Mosque Community Administration.

## Download Pre-built Binary (Windows)

The latest `MMS.exe` is built automatically by GitHub Actions on every push to `main`.

### Option A — Download from Actions runs (latest build)
1. Go to <https://github.com/kuttappu507/minzmahallu/actions/workflows/build-windows.yml>
2. Click the most recent successful run
3. Scroll to **Artifacts** at the bottom
4. Download **`MMS-portable-windows-x64`** (zip, ~50 MB) — includes MMS.exe + all Qt DLLs + SQL scripts + resources, ready to unzip and run
5. OR download **`MMS-exe`** (~4 MB) — just the bare executable, requires the portable folder's DLLs

### Option B — Download from Releases (stable versions)
1. Go to <https://github.com/kuttappu507/minzmahallu/releases>
2. Download `MMS-portable-windows-x64.zip` from the latest release
3. Unzip and run `MMS.exe`

### Quick start (after download)
1. Unzip the downloaded archive to any folder (e.g. `C:\MMS`)
2. Double-click `run_mms.bat` (or `MMS.exe` directly)
3. Log in with **username:** `admin`  /  **password:** `admin123`

> No installation required — the portable distribution is fully self-contained.

---

## Overview

MMS is a production-ready desktop application designed for small-to-medium Mahallu (Mosque Community) offices. It handles family and member records, subscription collection, donation management, accounting, marriage/death/welfare registers, certificate generation, reports, audit logging, and backup/restore.

## Technology Stack

- **Language:** C++20
- **Framework:** Qt 6.8+ (Widgets, SQL, Charts, PrintSupport, Svg, Network)
- **Database:** SQLite 3.35+
- **Build:** CMake 3.21+
- **IDE:** Visual Studio 2022
- **Crypto:** OpenSSL 3.x (for password hashing)
- **Compression:** zlib (for backups)

## Architecture

The application follows a layered MVVM + Repository + Service architecture:

```
┌──────────────────────────────────────┐
│   View Layer (Qt Widgets)            │
│   - MainWindow, LoginView,           │
│     DashboardView, FamilyView, ...   │
├──────────────────────────────────────┤
│   ViewModel Layer (Qt models)        │
│   - Table models, form models        │
├──────────────────────────────────────┤
│   Service Layer (Business logic)     │
│   - AuthService, FamilyService,      │
│     SubscriptionService, ...         │
├──────────────────────────────────────┤
│   Repository Layer (Data access)     │
│   - FamilyRepository,                │
│     MemberRepository, ...            │
├──────────────────────────────────────┤
│   Core (Database, Logger, Config,    │
│         Security)                    │
├──────────────────────────────────────┤
│   SQLite Database + Audit Log        │
└──────────────────────────────────────┘
```

## Quick Start

### Build Options

Three ways to build MMS:

| Option | When to use | How |
|---|---|---|
| **GitHub Actions** (recommended) | You just want the binary | Push to `main` — Actions builds & uploads automatically |
| **Cross-compile from Linux** | You're on Linux but need a Windows binary | Run `./build-scripts/ci-build.sh` after setting up Qt + MinGW |
| **Visual Studio 2022 (Windows)** | You're developing on Windows | Use CMake + Qt msvc2022_64 kit |

### Build on Windows (Visual Studio 2022)

1. Install prerequisites:
   - Visual Studio 2022 (with C++ CMake tools for Windows)
   - Qt 6.8+ (msvc2022_64 kit)
   - CMake 3.21+
   - OpenSSL 3.x (via vcpkg or pre-built)
   - zlib

2. Clone the repository:
   ```bat
   git clone <repo-url> MMS
   cd MMS
   ```

3. Configure CMake:
   ```bat
   cmake -B build -S . ^
         -DCMAKE_PREFIX_PATH="C:/Qt/6.8.0/msvc2022_64" ^
         -DCMAKE_BUILD_TYPE=Release
   ```

4. Build:
   ```bat
   cmake --build build --config Release
   ```

5. Run:
   ```bat
   build\Release\MMS.exe
   ```

### Cross-Compile from Linux (Ubuntu)

The repository includes a CI build script that cross-compiles to Windows using MinGW-w64 + Qt 6.8 mingw_64.

```bash
# 1. Install prerequisites
sudo apt install mingw-w64 libz-mingw-w64-dev cmake ninja-build python3-pip
pipx install aqtinstall
export PATH="$HOME/.local/bin:$PATH"

# 2. Install Qt 6.8.0 (both Linux host tools + Windows target libs)
aqt install-qt linux   desktop 6.8.0 gcc_64    --outputdir /opt/Qt
aqt install-qt windows desktop 6.8.0 win64_mingw --outputdir /opt/Qt   --modules qtcharts qtsvg qtprintsupport

# 3. Install OpenSSL for MinGW (extract from MSYS2 packages)
mkdir -p /opt/openssl-win
cd /tmp
wget https://repo.msys2.org/mingw/mingw64/mingw-w64-x86_64-openssl-3.0.13-1-any.pkg.tar.zst
wget https://repo.msys2.org/mingw/mingw64/mingw-w64-x86_64-zlib-1.3.1-1-any.pkg.tar.zst
sudo apt install zstd
for f in *.pkg.tar.zst; do zstd -d "$f" -o "${f%.zst}"; tar -xf "${f%.zst}" -C /opt/openssl-win/; done
mv /opt/openssl-win/mingw64 /opt/openssl-win/mingw64.tmp && mkdir -p /opt/openssl-win/mingw64 && mv /opt/openssl-win/mingw64.tmp/* /opt/openssl-win/mingw64/

# 4. Create symlinks (toolchain-mingw.cmake expects these paths)
sudo ln -sfn /opt/Qt /home/z/Qt-win
sudo ln -sfn /opt/Qt /home/z/Qt-linux
sudo ln -sfn /usr /home/z/mingw
sudo ln -sfn /opt/openssl-win /home/z/openssl-win

# 5. Build
cd /path/to/MMS
./build-scripts/ci-build.sh
# Output: build-win/MMS.exe
```

The same script is used by GitHub Actions — see `.github/workflows/build-windows.yml`.

### Default Login

- **Username:** `admin`
- **Password:** `admin123`
- ⚠️ You will be prompted to change the password on first login.

## Project Structure

```
MMS/
├── CMakeLists.txt              # Build configuration
├── sql/
│   ├── schema.sql              # Full database schema
│   ├── seed.sql                # Default users, permissions, sample data
│   └── migrations/             # Versioned migrations
├── src/
│   ├── core/                   # Database, Logger, Config, Security
│   ├── models/                 # Domain entities (POD structs)
│   ├── repositories/           # Data access layer
│   ├── services/               # Business logic layer
│   ├── viewmodels/             # (placeholder for Qt models)
│   ├── views/                  # UI screens
│   └── main.cpp                # Entry point
├── resources/                  # Icons, QSS, certificate templates
├── tests/                      # Unit & integration tests
├── docs/                       # Documentation
└── installer/                  # NSIS/Inno Setup scripts
```

## Modules

| Module | Description |
|--------|-------------|
| Authentication | Login, logout, password change/reset, role-based permissions |
| Dashboard | Stats overview, charts, quick actions, recent activity |
| Family Management | CRUD for families with archive/restore, search, print |
| Member Management | CRUD for members with photo, family link, head designation |
| Subscription | Collection entry, receipts, defaulters tracking, overdue marking |
| Donation | Donations by category, receipts, donor history |
| Accounting | Income/expense transactions, ledger accounts, monthly summary |
| Marriage Register | Marriage registration with certificate generation |
| Death Register | Death registration with auto member status update |
| Welfare | Request approval workflow (Pending → Approved → Disbursed) |
| Certificates | Membership, Residence, Marriage, Death certificates (PDF + QR) |
| Reports | 14 report types with PDF/CSV/Excel export |
| Audit Log | All user actions logged and searchable |
| Backup | ZIP backup with restore, verify, prune |
| Settings | Organization info, theme, backup config |

## Roles & Permissions

Seven built-in roles with fine-grained per-module permissions:

- **Administrator** — full access
- **President** — view-all + welfare approval
- **Secretary** — full CRUD on operational registers
- **Treasurer** — subscription + donation + accounting
- **Imam** — marriage + death + certificate
- **Staff** — data entry across modules
- **Auditor** — read-only with export

## Security Features

- PBKDF2-HMAC-SHA256 password hashing (200,000 iterations) via OpenSSL
- Argon2id support when OpenSSL 3.2+ is available
- Account locking after 5 failed login attempts (15-min lockout)
- Strong password policy enforcement
- Per-action audit logging with user, timestamp, IP
- SQL injection protection via Qt prepared statements
- Session tokens for active sessions

## Documentation

Detailed docs in the `docs/` directory:

- [Architecture Document](docs/Architecture.md)
- [Database Documentation](docs/Database.md)
- [User Manual](docs/UserManual.md)
- [Administrator Manual](docs/AdminManual.md)
- [Installation Guide](docs/Installation.md)
- [Developer Guide](docs/DeveloperGuide.md)

## License

© 2024 Mahallu Management System. All rights reserved.

## Support

For issues, contact the Mahallu office administrator or refer to the Administrator Manual.
