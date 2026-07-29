/*
 * Database.h - SQLite database wrapper for MMS
 *
 * Provides singleton-style access to the application database, transaction
 * support, prepared statement helpers, and schema bootstrap/migration.
 */
#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QString>
#include <QStringList>
#include <QVariant>
#include <QVariantList>
#include <functional>
#include <optional>

namespace mms {

class Database : public QObject {
    Q_OBJECT
public:
    static Database& instance();

    // Initialize the database: opens connection, runs schema.sql, applies migrations.
    // Returns true on success. Sets lastError on failure.
    bool initialize(const QString& dbPath, const QString& sqlDir);

    // Open a connection (named for thread-local usage)
    bool openConnection(const QString& connectionName = "qt_sql_default_connection");

    // Close all connections
    void closeAll();

    // Transaction helpers
    bool beginTransaction();
    bool commitTransaction();
    bool rollbackTransaction();

    // Run a function inside a transaction; auto-commits or rolls back
    bool transaction(const std::function<bool()>& work);

    // Execute raw SQL (multiple statements split by ';')
    bool executeSqlScript(const QString& scriptPath);

    // Execute a single prepared statement; returns the QSqlQuery for iteration
    QSqlQuery execute(const QString& sql, const QVariantList& params = {});

    // Insert helper: returns the new row id, or -1 on failure
    qint64 insert(const QString& sql, const QVariantList& params = {});

    // Update/Delete helper: returns number of affected rows
    int update(const QString& sql, const QVariantList& params = {});
    int remove(const QString& sql, const QVariantList& params = {});

    // Scalar query: returns first column of first row
    QVariant scalar(const QString& sql, const QVariantList& params = {});

    // Check if a row exists
    bool exists(const QString& sql, const QVariantList& params = {});

    // Last error
    QSqlError lastError() const { return lastError_; }
    QString lastErrorText() const { return lastError_.text(); }

    // Database info
    QString databasePath() const { return dbPath_; }
    QString connectionName() const { return connectionName_; }
    bool isInitialized() const { return initialized_; }

    // Schema version
    int schemaVersion();
    bool applyMigrations(const QString& migrationsDir);

signals:
    void databaseError(const QString& message);
    void schemaMigrated(int fromVersion, int toVersion);

private:
    Database();
    ~Database() override;
    Database(const Database&) = delete;
    Database& operator=(const Database&) = delete;

    bool ensureSchema();
    bool createSchemaFromScript(const QString& schemaPath);
    bool seedIfEmpty(const QString& seedPath);

    QString dbPath_;
    QString sqlDir_;
    QString connectionName_;
    QSqlError lastError_;
    bool initialized_ = false;
};

} // namespace mms
