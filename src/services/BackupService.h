/*
 * BackupService.h - Database backup & restore (ZIP)
 */
#pragma once

#include <QObject>
#include <QString>
#include <QDateTime>

namespace mms {

class BackupService : public QObject {
    Q_OBJECT
public:
    explicit BackupService(QObject* parent = nullptr);

    // Create a backup ZIP containing the .db file + attachment dir.
    // Returns the path to the created ZIP, or empty on failure.
    QString createBackup(QString* errorMsg = nullptr);

    // Create a backup at a specific path
    QString createBackupAt(const QString& targetPath, QString* errorMsg = nullptr);

    // Restore a backup ZIP; closes DB, replaces file, reopens.
    bool restoreBackup(const QString& zipPath, QString* errorMsg = nullptr);

    // List recent backups in the backup dir
    struct BackupInfo {
        QString fileName;
        QString fullPath;
        QDateTime created;
        qint64 sizeBytes;
    };
    std::vector<BackupInfo> listBackups();

    // Delete old backups beyond retention count
    int pruneOldBackups(int keepCount = 10);

    // Verify backup integrity (tries to open as zip and checks the .db inside)
    bool verifyBackup(const QString& zipPath, QString* errorMsg = nullptr);

signals:
    void backupStarted();
    void backupProgress(int percent);
    void backupCompleted(const QString& path);
    void backupFailed(const QString& error);
    void restoreStarted();
    void restoreCompleted();
    void restoreFailed(const QString& error);

private:
    QString defaultBackupPath() const;
};

} // namespace mms
