# MMS Developer Guide

## 1. Development Environment Setup

### Prerequisites

- **Visual Studio 2022** with:
  - Desktop development with C++ workload
  - C++ CMake tools for Windows
  - Windows 10/11 SDK
- **Qt 6.8+** (msvc2022_64 kit) — install via Qt Online Installer
- **CMake 3.21+** (bundled with VS 2022)
- **OpenSSL 3.x** — install via vcpkg or pre-built binaries
- **zlib** — install via vcpkg
- **Git** for source control

### Setting up vcpkg (recommended for OpenSSL + zlib)

```bat
git clone https://github.com/Microsoft/vcpkg.git C:\vcpkg
cd C:\vcpkg
bootstrap-vcpkg.bat
vcpkg install openssl:x64-windows zlib:x64-windows
```

### Cloning & Configuring

```bat
git clone <repo-url> MMS
cd MMS

cmake -B build -S . ^
  -DCMAKE_PREFIX_PATH="C:/Qt/6.8.0/msvc2022_64" ^
  -DCMAKE_TOOLCHAIN_FILE="C:/vcpkg/scripts/buildsystems/vcpkg.cmake" ^
  -DCMAKE_BUILD_TYPE=Debug ^
  -DBUILD_TESTS=ON
```

### Building

```bat
:: Open the generated solution in VS:
build\MMS.sln

:: Or build from CLI:
cmake --build build --config Debug

:: Run the app:
build\Debug\MMS.exe

:: Run tests:
build\Debug\mms_tests.exe
```

## 2. Source Code Organization

```
src/
├── core/           # Infrastructure (no Qt Widgets dependency)
│   ├── Database.h/cpp      - SQLite wrapper, transactions, migrations
│   ├── Logger.h/cpp        - Rotating file logger
│   ├── Config.h/cpp        - Path & settings management
│   └── Security.h/cpp      - Password hashing (PBKDF2/Argon2), validation
├── models/         # Plain-old-data structs
│   ├── User.h, Family.h, Member.h, Subscription.h, Donation.h
│   ├── Transaction.h, Marriage.h, Death.h, Welfare.h, AuditLog.h
├── repositories/   # SQL data access
│   ├── UserRepository.h/cpp
│   ├── FamilyRepository.h/cpp
│   └── ...
├── services/       # Business logic
│   ├── AuthService.h/cpp
│   ├── AuthSession.h/cpp    - Current user session singleton
│   ├── FamilyService.h/cpp
│   └── ...
├── views/          # Qt Widgets UI
│   ├── MainWindow.h/cpp
│   ├── LoginView.h/cpp
│   ├── DashboardView.h/cpp
│   ├── FamilyView.h/cpp + FamilyEditDialog.h/cpp
│   └── ...
└── main.cpp        # Application entry point
```

## 3. Coding Standards

### C++ Style

- **C++20** features allowed (concepts, ranges, `<=>`, etc.) but use judiciously.
- **Header guards:** Use `#pragma once`.
- **Naming:**
  - Classes: `PascalCase` (e.g. `FamilyRepository`)
  - Methods: `camelCase` (e.g. `findByNumber`)
  - Member variables: `camelCase_` (trailing underscore)
  - Constants: `UPPER_SNAKE_CASE`
  - Namespaces: `mms::`
- **Smart pointers:** Use `std::unique_ptr`, `std::shared_ptr` for ownership. Qt parent-child ownership for UI objects.
- **RAII:** All resources (DB connections, file handles) should be RAII-managed.
- **Const correctness:** Mark methods `const` when they don't modify state.
- **No raw `new`/`delete`** for member fields — use Qt parent ownership or smart pointers.

### Qt-Specific

- Use `Q_OBJECT` macro in all QObject subclasses.
- Use signals/slots for cross-component communication.
- Use `QSqlQuery::prepare` + `addBindValue` for all SQL (prevents injection).
- Use `Qt::SkipEmptyParts` when splitting strings.
- Use `QStringConverter::Utf8` for text streams.

### File Organization

- One class per file (with exceptions for tightly-coupled dialogs in same .cpp).
- Header files: declarations only.
- Implementation files: include corresponding header first, then Qt headers, then project headers.

## 4. Adding a New Module

To add a new module (e.g., "Events"):

### Step 1: Database Schema

Add to `sql/schema.sql`:
```sql
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    event_date TEXT NOT NULL,
    description TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);
```

For existing installations, create `sql/migrations/V002_add_events.sql` with the same SQL.

### Step 2: Model

Create `src/models/Event.h`:
```cpp
#pragma once
#include <QString>
#include <QSqlQuery>

namespace mms {

struct Event {
    qint64 id = 0;
    QString title;
    QString eventDate;
    QString description;
    QDateTime createdAt;

    static Event fromQuery(const QSqlQuery& q) {
        Event e;
        e.id = q.value("id").toLongLong();
        e.title = q.value("title").toString();
        e.eventDate = q.value("event_date").toString();
        e.description = q.value("description").toString();
        e.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);
        return e;
    }
};

} // namespace mms
```

### Step 3: Repository

Create `src/repositories/EventRepository.h` and `.cpp`:
```cpp
#pragma once
#include "../models/Event.h"
#include <vector>
#include <optional>

namespace mms {

class EventRepository {
public:
    std::optional<Event> findById(qint64 id);
    std::vector<Event> list(int page = 1, int pageSize = 50, int* totalOut = nullptr);
    qint64 create(const Event& e);
    bool update(const Event& e);
    bool remove(qint64 id);
};

} // namespace mms
```

### Step 4: Service

Create `src/services/EventService.h` and `.cpp` with validation + audit logging.

### Step 5: View

Create `src/views/EventView.h` and `.cpp` (use `FamilyView` as a template).

### Step 6: Register in MainWindow

Add to `MainWindow::showApp()`:
```cpp
struct NavEntry {
    QString title;
    QWidget* view;
    QString module;
    QString action;
};

std::vector<NavEntry> entries = {
    // ... existing entries ...
    {"📅  Events", new EventView(this), "event", "view"},
};
```

Also add to `MainWindow.h`:
```cpp
class EventView;
// ...
EventView* eventView_ = nullptr;
```

### Step 7: Permissions

Add to `sql/seed.sql`:
```sql
INSERT OR IGNORE INTO permissions (role, module, action, allowed) VALUES
('Administrator','event','view',1),
('Administrator','event','add',1),
-- ... etc.
```

## 5. Database Access Patterns

### Basic Query

```cpp
QSqlQuery q = Database::instance().execute(
    "SELECT * FROM families WHERE status = ? ORDER BY family_number",
    { "Active" });
while (q.next()) {
    Family f = Family::fromQuery(q);
    // use f
}
```

### Insert with returning ID

```cpp
qint64 id = Database::instance().insert(
    "INSERT INTO families (family_number, house_name, ...) VALUES (?, ?, ...)",
    { familyNumber, houseName, ... });
```

### Transaction

```cpp
bool ok = Database::instance().transaction([&]() {
    qint64 id = Database::instance().insert(/* ... */);
    if (id <= 0) return false;
    Database::instance().insert(/* ... */);
    return true;
});
```

### Pagination

```cpp
int offset = (page - 1) * pageSize;
QString sql = "SELECT * FROM table WHERE ... ORDER BY id LIMIT ? OFFSET ?";
QSqlQuery q = Database::instance().execute(sql, { pageSize, offset });
```

## 6. UI Patterns

### Standard View Layout

```cpp
void setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);

    // 1. Title
    layout->addWidget(new QLabel("<h1>Module Name</h1>", this));

    // 2. Filter bar (search + filters)
    // 3. Action buttons (Add/Edit/Delete/Print/Export)
    // 4. Table (QTableWidget)
    // 5. Pagination (Prev/Next + page label)
}
```

### Edit Dialog Pattern

```cpp
class XxxEditDialog : public QDialog {
    // Form fields
    void onSave() {
        // 1. Validate
        // 2. Build model
        // 3. Call service
        // 4. accept() or show error
    }
};
```

## 7. Audit Logging

Every state-changing operation should log to audit:

```cpp
AuditLogRepository audit;
auto u = AuthSession::instance().user();
audit.log(u.id, u.username, "ADD", "family", newId,
          QString("Created family %1").arg(familyNumber), "");
```

Standard action values: `LOGIN`, `LOGOUT`, `LOGIN_FAILED`, `ADD`, `EDIT`, `DELETE`, `PRINT`, `EXPORT`, `BACKUP`, `RESTORE`, `PASSWORD_CHANGE`, `APPROVE`, `REJECT`, `DISBURSE`, `ARCHIVE`, `UNLOCK`.

## 8. Testing

### Running Tests

```bat
cmake --build build --config Debug --target mms_tests
build\Debug\mms_tests.exe
```

### Writing Tests

Tests use Qt Test framework. Each test file declares a class with private slots for test cases:

```cpp
class TestFamily : public QObject {
    Q_OBJECT
private slots:
    void testCreateFamily();
    void testUpdateFamily();
};

void TestFamily::testCreateFamily() {
    // setup
    mms::Family f;
    f.familyNumber = "TEST-001";
    // ...
    QString err;
    qint64 id = svc.createFamily(f, &err);
    QVERIFY2(id > 0, qPrintable(err));
    QCOMPARE(svc.totalFamilies(), expectedCount);
}
```

### Test Database

Tests use a temporary SQLite database initialized with the production schema + seed data. The `TestMain.cpp` entry point handles setup/teardown.

## 9. Debugging Tips

### Enable Trace Logging

In `main.cpp`:
```cpp
mms::Logger::instance().initialize(logDir, mms::Logger::Level::Trace);
```

### Inspect Database

Use DB Browser for SQLite to open `<data dir>/mms.db` while the app is running (in WAL mode, this is safe).

### Common Pitfalls

1. **Qt parent ownership:** Always pass `this` as parent for widgets, or they leak.
2. **SQL connection threads:** QSqlDatabase is thread-local. Use `Database::openConnection(name)` per thread.
3. **QSqlQuery lifetime:** Don't store QSqlQuery across threads or store the QSqlDatabase from `database()` in a member — re-fetch each time.
4. **Signal/slot connections:** Use the function-pointer syntax (`connect(sender, &Sender::signal, receiver, &Receiver::slot)`) to catch mismatches at compile time.
5. **Lambda captures:** Be careful with `[this]` in lambdas connected to short-lived objects — prefer `QObject::connect` with explicit receiver.

## 10. Performance Profiling

### Build with profiling

```bat
cmake -B build -S . -DCMAKE_BUILD_TYPE=RelWithDebInfo
```

### Use Windows Performance Recorder

Capture ETW traces to identify slow operations.

### Database Profiling

Add to `Database.cpp`:
```cpp
QSqlQuery logq(db);
logq.exec("PRAGMA temp_store = MEMORY;");
// Or use SQLite's built-in profiling via sqlite3_profile
```

## 11. Release Build

### Pre-release Checklist

- [ ] Bump version in `CMakeLists.txt` and `README.md`
- [ ] Update CHANGELOG (if maintained)
- [ ] Run all tests: `mms_tests.exe`
- [ ] Test on a clean Windows install (no Qt installed)
- [ ] Verify auto-backup works
- [ ] Verify certificate PDF generation
- [ ] Verify all 14 reports export correctly
- [ ] Test upgrade from previous version

### Creating the Installer

Use Inno Setup (or NSIS via CPack):

```bat
:: With Inno Setup (installer/MMS.iss):
iscc installer\MMS.iss

:: With CPack (NSIS):
cmake --build build --config Release
cd build && cpack -G NSIS
```

### Portable ZIP

```bat
cmake --build build --config Release
xcopy build\Release\MMS.exe portable\
xcopy sql portable\sql\ /E /I
xcopy resources portable\resources\ /E /I
copy mms.portable portable\
:: Add Qt DLLs via windeployqt:
windeployqt --release --no-translations portable\MMS.exe
:: Zip the portable folder
```

## 12. Contributing

1. Fork the repository.
2. Create a feature branch: `feature/your-feature`.
3. Write tests for new functionality.
4. Ensure all tests pass: `mms_tests.exe`.
5. Follow the coding standards (Section 3).
6. Submit a pull request with a clear description.

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`.

Example: `feat(certificates): add income certificate type`
