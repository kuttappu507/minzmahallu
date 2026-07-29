/*
 * Database.cpp - Implementation
 */
#include "Database.h"
#include "Logger.h"
#include <QFile>
#include <QTextStream>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QSqlRecord>
#include <QThread>

namespace mms {

Database& Database::instance() {
    static Database inst;
    return inst;
}

Database::Database() = default;
Database::~Database() {
    closeAll();
}

bool Database::initialize(const QString& dbPath, const QString& sqlDir) {
    dbPath_  = dbPath;
    sqlDir_  = sqlDir;

    // Ensure parent directory exists
    QDir().mkpath(QFileInfo(dbPath).absolutePath());

    if (!openConnection()) {
        return false;
    }

    if (!ensureSchema()) {
        return false;
    }

    initialized_ = true;
    Logger::info(QString("Database initialized at %1 (schema v%2)")
                 .arg(dbPath_).arg(schemaVersion()));
    return true;
}

bool Database::openConnection(const QString& connectionName) {
    connectionName_ = connectionName;

    if (QSqlDatabase::contains(connectionName)) {
        QSqlDatabase::removeDatabase(connectionName);
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", connectionName);
    db.setDatabaseName(dbPath_);
    db.setConnectOptions("QSQLITE_ENABLE_REGEXP=1;QSQLITE_BUSY_TIMEOUT=5000");

    if (!db.open()) {
        lastError_ = db.lastError();
        Logger::error("Failed to open database: " + lastError_.text());
        return false;
    }

    // Performance pragmas
    QSqlQuery q(db);
    q.exec("PRAGMA journal_mode = WAL;");
    q.exec("PRAGMA synchronous = NORMAL;");
    q.exec("PRAGMA foreign_keys = ON;");
    q.exec("PRAGMA encoding = 'UTF-8';");
    q.exec("PRAGMA temp_store = MEMORY;");
    q.exec("PRAGMA cache_size = -64000;");  // 64 MB cache

    return true;
}

void Database::closeAll() {
    {
        QSqlDatabase db = QSqlDatabase::database(connectionName_, false);
        if (db.isOpen()) db.close();
    }
    if (QSqlDatabase::contains(connectionName_)) {
        QSqlDatabase::removeDatabase(connectionName_);
    }
}

bool Database::beginTransaction() {
    QSqlDatabase db = QSqlDatabase::database(connectionName_);
    if (!db.isOpen()) return false;
    return db.transaction();
}

bool Database::commitTransaction() {
    QSqlDatabase db = QSqlDatabase::database(connectionName_);
    return db.commit();
}

bool Database::rollbackTransaction() {
    QSqlDatabase db = QSqlDatabase::database(connectionName_);
    return db.rollback();
}

bool Database::transaction(const std::function<bool()>& work) {
    if (!beginTransaction()) return false;
    try {
        if (work()) {
            return commitTransaction();
        }
        rollbackTransaction();
        return false;
    } catch (...) {
        rollbackTransaction();
        throw;
    }
}

bool Database::executeSqlScript(const QString& scriptPath) {
    QFile f(scriptPath);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        lastError_ = QSqlError("File error", "Cannot open: " + scriptPath);
        return false;
    }
    QString script = QString::fromUtf8(f.readAll());
    f.close();

    // Strip line comments
    QStringList lines = script.split('\n');
    for (QString& line : lines) {
        int idx = line.indexOf("--");
        if (idx >= 0) line = line.left(idx);
    }
    script = lines.join('\n');

    // Split into statements. CREATE TRIGGER ... END; bodies contain internal ';',
    // so we treat "END;" as a statement terminator for triggers.
    QSqlDatabase db = QSqlDatabase::database(connectionName_);
    QStringList stmts;
    {
        // Tokenize by scanning for either ';' (normal) or 'END;' (trigger end),
        // ignoring delimiters inside single-quoted string literals.
        QString current;
        bool inTrigger = false;
        bool inString = false;
        for (int i = 0; i < script.size(); ++i) {
            QChar ch = script[i];
            if (ch == '\'' && (i == 0 || script[i-1] != '\\')) {
                inString = !inString;
            }
            current += ch;
            if (!inString) {
                // Detect entering a trigger body
                if (current.contains("CREATE TRIGGER", Qt::CaseInsensitive) &&
                    current.endsWith("BEGIN", Qt::CaseInsensitive)) {
                    inTrigger = true;
                }
                if (ch == ';') {
                    if (inTrigger) {
                        // Check if previous non-space chars form "END"
                        QString trimmed = current.left(current.size() - 1).trimmed();
                        if (trimmed.endsWith("END", Qt::CaseInsensitive)) {
                            inTrigger = false;
                            stmts << current;
                            current.clear();
                        }
                    } else {
                        stmts << current;
                        current.clear();
                    }
                }
            }
        }
        if (!current.trimmed().isEmpty()) stmts << current;
    }

    for (const QString& raw : stmts) {
        QString stmt = raw.trimmed();
        if (stmt.isEmpty()) continue;
        QSqlQuery q(db);
        if (!q.exec(stmt)) {
            lastError_ = q.lastError();
            Logger::error(QString("SQL error in %1: %2 | stmt: %3")
                          .arg(scriptPath).arg(lastError_.text()).arg(stmt.left(120)));
            return false;
        }
    }
    return true;
}

QSqlQuery Database::execute(const QString& sql, const QVariantList& params) {
    QSqlDatabase db = QSqlDatabase::database(connectionName_);
    QSqlQuery q(db);
    q.prepare(sql);
    for (const auto& p : params) q.addBindValue(p);
    if (!q.exec()) {
        lastError_ = q.lastError();
        Logger::error("SQL execute error: " + lastError_.text() + " | sql: " + sql.left(200));
    }
    return q;
}

qint64 Database::insert(const QString& sql, const QVariantList& params) {
    QSqlDatabase db = QSqlDatabase::database(connectionName_);
    QSqlQuery q(db);
    q.prepare(sql);
    for (const auto& p : params) q.addBindValue(p);
    if (!q.exec()) {
        lastError_ = q.lastError();
        Logger::error("SQL insert error: " + lastError_.text() + " | sql: " + sql.left(200));
        return -1;
    }
    QVariant id = q.lastInsertId();
    return id.isValid() ? id.toLongLong() : -1;
}

int Database::update(const QString& sql, const QVariantList& params) {
    QSqlDatabase db = QSqlDatabase::database(connectionName_);
    QSqlQuery q(db);
    q.prepare(sql);
    for (const auto& p : params) q.addBindValue(p);
    if (!q.exec()) {
        lastError_ = q.lastError();
        Logger::error("SQL update error: " + lastError_.text() + " | sql: " + sql.left(200));
        return -1;
    }
    return q.numRowsAffected();
}

int Database::remove(const QString& sql, const QVariantList& params) {
    return update(sql, params);
}

QVariant Database::scalar(const QString& sql, const QVariantList& params) {
    QSqlQuery q = execute(sql, params);
    if (q.next() && q.record().count() > 0) {
        return q.value(0);
    }
    return {};
}

bool Database::exists(const QString& sql, const QVariantList& params) {
    QSqlQuery q = execute(sql, params);
    return q.next();
}

int Database::schemaVersion() {
    QSqlQuery q = execute("SELECT MAX(version) FROM schema_version");
    if (q.next()) return q.value(0).toInt();
    return 0;
}

bool Database::applyMigrations(const QString& migrationsDir) {
    QDir dir(migrationsDir);
    if (!dir.exists()) return true;

    QStringList filters;
    filters << "V*.sql";
    QStringList files = dir.entryList(filters, QDir::Files, QDir::Name);

    int current = schemaVersion();
    for (const QString& file : files) {
        QString numPart = file.mid(1, 3);
        bool ok = false;
        int v = numPart.toInt(&ok);
        if (!ok || v <= current) continue;

        // Try to run the migration. If it fails on "duplicate column" or
        // "already exists" errors, that's OK — it means the schema.sql
        // already included the change. Log a warning and continue.
        if (!executeSqlScript(dir.absoluteFilePath(file))) {
            QString err = lastError_.text();
            if (err.contains("duplicate column", Qt::CaseInsensitive) ||
                err.contains("already exists", Qt::CaseInsensitive)) {
                Logger::warn(QString("Migration %1: column already exists, continuing").arg(file));
            } else {
                // Real error — abort
                return false;
            }
        }
        execute(
            "INSERT INTO schema_version (version, description) VALUES (?, ?)",
            { v, file }
        );
        emit schemaMigrated(current, v);
        current = v;
        Logger::info(QString("Applied migration %1 (v%2)").arg(file).arg(v));
    }
    return true;
}

bool Database::ensureSchema() {
    // Check if schema_version table exists
    QSqlDatabase db = QSqlDatabase::database(connectionName_);
    QSqlQuery check(db);
    check.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='schema_version'");

    bool needsBootstrap = !check.next();

    if (needsBootstrap) {
        QString schemaPath = QDir(sqlDir_).absoluteFilePath("schema.sql");
        if (!createSchemaFromScript(schemaPath)) return false;

        QString seedPath = QDir(sqlDir_).absoluteFilePath("seed.sql");
        if (QFile::exists(seedPath)) {
            seedIfEmpty(seedPath);
        }
        // For a fresh database, the schema.sql already includes all columns
        // (including 'language'). Skip migrations entirely to avoid
        // "duplicate column" errors.
        return true;
    }

    // Only apply migrations for EXISTING databases that need upgrading
    QString migDir = QDir(sqlDir_).absoluteFilePath("migrations");
    return applyMigrations(migDir);
}

bool Database::createSchemaFromScript(const QString& schemaPath) {
    Logger::info("Bootstrapping database schema from " + schemaPath);
    return executeSqlScript(schemaPath);
}

bool Database::seedIfEmpty(const QString& seedPath) {
    // Only seed if users table is empty
    QVariant c = scalar("SELECT COUNT(*) FROM families");
    if (c.isValid() && c.toInt() > 0) return true;
    Logger::info("Seeding initial data from " + seedPath);
    return executeSqlScript(seedPath);
}

} // namespace mms
