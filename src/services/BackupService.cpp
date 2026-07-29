/*
 * BackupService.cpp - Implements ZIP backup using zlib/minizip-style approach
 * via Qt's built-in capabilities (we use QIODevice with manual ZIP framing
 * for portability without minizip dependency).
 */
#include "BackupService.h"
#include "../core/Database.h"
#include "../core/Config.h"
#include "../core/Logger.h"
#include "../repositories/AuditLogRepository.h"
#include "AuthSession.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QDateTime>
#include <QProcess>
#include <QCryptographicHash>

#include <zlib.h>
#include <cstring>

namespace mms {

// Minimal ZIP writer (_STORED + DEFLATE) - enough for our backup needs.
// We use zlib's deflate for the compression stream and write a basic
// ZIP structure. This avoids the minizip dependency.
namespace ziputil {

#pragma pack(push, 1)
struct ZipLocalHeader {
    quint32 sig = 0x04034b50;
    quint16 ver = 20;
    quint16 flags = 0;
    quint16 method = 8;     // deflate
    quint16 modTime = 0;
    quint16 modDate = 0;
    quint32 crc32 = 0;
    quint32 compSize = 0;
    quint32 uncompSize = 0;
    quint16 nameLen = 0;
    quint16 extraLen = 0;
};

struct ZipCentralHeader {
    quint32 sig = 0x02014b50;
    quint16 verMade = 20;
    quint16 verNeed = 20;
    quint16 flags = 0;
    quint16 method = 8;
    quint16 modTime = 0;
    quint16 modDate = 0;
    quint32 crc32 = 0;
    quint32 compSize = 0;
    quint32 uncompSize = 0;
    quint16 nameLen = 0;
    quint16 extraLen = 0;
    quint16 commentLen = 0;
    quint16 diskStart = 0;
    quint16 intAttr = 0;
    quint32 extAttr = 0;
    quint32 localOff = 0;
};

struct ZipEndHeader {
    quint32 sig = 0x06054b50;
    quint16 disk = 0;
    quint16 disk2 = 0;
    quint16 entries = 0;
    quint16 entries2 = 0;
    quint32 size = 0;
    quint32 offset = 0;
    quint16 commentLen = 0;
};
#pragma pack(pop)

static void dosDateTime(QDateTime dt, quint16& modTime, quint16& modDate) {
    QDate d = dt.date();
    QTime t = dt.time();
    modTime = (t.hour() << 11) | (t.minute() << 5) | (t.second() / 2);
    modDate = ((d.year() - 1980) << 9) | (d.month() << 5) | d.day();
}

static QByteArray deflateData(const QByteArray& src) {
    uLong bound = compressBound(src.size());
    QByteArray out(bound, '\0');
    uLongf outLen = bound;
    int rc = compress2(reinterpret_cast<Bytef*>(out.data()),
                       &outLen,
                       reinterpret_cast<const Bytef*>(src.constData()),
                       src.size(),
                       Z_DEFAULT_COMPRESSION);
    if (rc != Z_OK) return {};
    out.resize(outLen);
    return out;
}

} // namespace ziputil

BackupService::BackupService(QObject* parent) : QObject(parent) {}

QString BackupService::defaultBackupPath() const {
    QString dir = Config::instance().backupDir();
    QDir().mkpath(dir);
    QString ts = QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss");
    return QString("%1/mms_backup_%2.zip").arg(dir).arg(ts);
}

QString BackupService::createBackup(QString* errorMsg) {
    return createBackupAt(defaultBackupPath(), errorMsg);
}

QString BackupService::createBackupAt(const QString& targetPath, QString* errorMsg) {
    emit backupStarted();
    emit backupProgress(0);

    QString dbPath = Config::instance().databasePath();

    // Force a checkpoint to flush WAL to main DB file
    QSqlQuery q = Database::instance().execute("PRAGMA wal_checkpoint(FULL)");

    QFile dbFile(dbPath);
    if (!dbFile.open(QIODevice::ReadOnly)) {
        if (errorMsg) *errorMsg = "Cannot open database file for backup.";
        emit backupFailed(*errorMsg);
        return {};
    }
    QByteArray dbData = dbFile.readAll();
    dbFile.close();

    emit backupProgress(50);

    // Build the ZIP file manually
    QFile zipFile(targetPath);
    if (!zipFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        if (errorMsg) *errorMsg = "Cannot create backup file: " + targetPath;
        emit backupFailed(*errorMsg);
        return {};
    }

    QByteArray compressed = ziputil::deflateData(dbData);
    if (compressed.isEmpty()) {
        zipFile.close();
        QFile::remove(targetPath);
        if (errorMsg) *errorMsg = "Compression failed.";
        emit backupFailed(*errorMsg);
        return {};
    }

    quint16 modTime, modDate;
    ziputil::dosDateTime(QDateTime::currentDateTime(), modTime, modDate);
    QByteArray fileName = "mms.db";
    quint32 crc = crc32(0L, Z_NULL, 0);
    crc = crc32(crc, reinterpret_cast<const Bytef*>(dbData.constData()), dbData.size());

    ziputil::ZipLocalHeader lh;
    lh.modTime = modTime;
    lh.modDate = modDate;
    lh.crc32 = crc;
    lh.compSize = compressed.size();
    lh.uncompSize = dbData.size();
    lh.nameLen = fileName.size();

    QDataStream ds(&zipFile);
    ds.setByteOrder(QDataStream::LittleEndian);
    ds.writeRawData(reinterpret_cast<const char*>(&lh), sizeof(lh));
    ds.writeRawData(fileName.constData(), fileName.size());
    ds.writeRawData(compressed.constData(), compressed.size());

    quint32 localOff = 0;
    ziputil::ZipCentralHeader ch;
    ch.modTime = modTime;
    ch.modDate = modDate;
    ch.crc32 = crc;
    ch.compSize = compressed.size();
    ch.uncompSize = dbData.size();
    ch.nameLen = fileName.size();
    ch.localOff = localOff;
    ds.writeRawData(reinterpret_cast<const char*>(&ch), sizeof(ch));
    ds.writeRawData(fileName.constData(), fileName.size());

    ziputil::ZipEndHeader eh;
    eh.entries = 1;
    eh.size = sizeof(ch) + fileName.size();
    eh.offset = sizeof(lh) + fileName.size() + compressed.size();
    ds.writeRawData(reinterpret_cast<const char*>(&eh), sizeof(eh));

    zipFile.close();

    emit backupProgress(100);
    emit backupCompleted(targetPath);

    Config::instance().setLastBackupPath(targetPath);

    AuditLogRepository audit;
    auto u = AuthSession::instance().user();
    audit.log(u.id, u.username, "BACKUP", "system", 0,
              QString("Created backup: %1 (%2 bytes)").arg(targetPath).arg(dbFile.size()), "");

    Logger::info(QString("Backup created: %1").arg(targetPath));
    return targetPath;
}

bool BackupService::restoreBackup(const QString& zipPath, QString* errorMsg) {
    emit restoreStarted();

    QFile zip(zipPath);
    if (!zip.open(QIODevice::ReadOnly)) {
        if (errorMsg) *errorMsg = "Cannot open backup file.";
        emit restoreFailed(*errorMsg);
        return false;
    }

    // Read end-of-central-directory record (last 22 bytes minimum)
    qint64 sz = zip.size();
    if (sz < 22) {
        if (errorMsg) *errorMsg = "Backup file is too small.";
        emit restoreFailed(*errorMsg);
        return false;
    }
    zip.seek(sz - sizeof(ziputil::ZipEndHeader));
    ziputil::ZipEndHeader eh;
    zip.read(reinterpret_cast<char*>(&eh), sizeof(eh));
    if (eh.sig != 0x06054b50) {
        if (errorMsg) *errorMsg = "Invalid backup file (no end header).";
        emit restoreFailed(*errorMsg);
        return false;
    }

    // Read first central directory entry
    zip.seek(eh.offset);
    ziputil::ZipCentralHeader ch;
    zip.read(reinterpret_cast<char*>(&ch), sizeof(ch));
    if (ch.sig != 0x02014b50) {
        if (errorMsg) *errorMsg = "Invalid backup file (corrupt central header).";
        emit restoreFailed(*errorMsg);
        return false;
    }
    QByteArray name(ch.nameLen, '\0');
    zip.read(name.data(), ch.nameLen);

    // Read local file header
    zip.seek(ch.localOff);
    ziputil::ZipLocalHeader lh;
    zip.read(reinterpret_cast<char*>(&lh), sizeof(lh));
    zip.seek(ch.localOff + sizeof(lh) + lh.nameLen + lh.extraLen);

    QByteArray compressed(ch.compSize, '\0');
    zip.read(compressed.data(), ch.compSize);
    zip.close();

    // Decompress
    QByteArray uncompressed(ch.uncompSize, '\0');
    uLongf outLen = ch.uncompSize;
    int rc = uncompress(reinterpret_cast<Bytef*>(uncompressed.data()), &outLen,
                        reinterpret_cast<const Bytef*>(compressed.constData()), ch.compSize);
    if (rc != Z_OK || (qint64)outLen != ch.uncompSize) {
        if (errorMsg) *errorMsg = "Decompression failed.";
        emit restoreFailed(*errorMsg);
        return false;
    }

    // Verify CRC
    quint32 crc = crc32(0L, Z_NULL, 0);
    crc = crc32(crc, reinterpret_cast<const Bytef*>(uncompressed.constData()), uncompressed.size());
    if (crc != ch.crc32) {
        if (errorMsg) *errorMsg = "CRC mismatch - backup data corrupted.";
        emit restoreFailed(*errorMsg);
        return false;
    }

    // Backup current db, then replace
    QString dbPath = Config::instance().databasePath();
    QString backupOfCurrent = dbPath + ".pre_restore";
    if (QFile::exists(dbPath)) {
        QFile::remove(backupOfCurrent);
        QFile::rename(dbPath, backupOfCurrent);
    }

    QFile out(dbPath);
    if (!out.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        if (errorMsg) *errorMsg = "Cannot write to database location.";
        // Restore the original
        QFile::rename(backupOfCurrent, dbPath);
        emit restoreFailed(*errorMsg);
        return false;
    }
    out.write(uncompressed);
    out.close();

    Database::instance().closeAll();
    if (!Database::instance().openConnection()) {
        if (errorMsg) *errorMsg = "Failed to reopen database after restore.";
        emit restoreFailed(*errorMsg);
        return false;
    }

    AuditLogRepository audit;
    auto u = AuthSession::instance().user();
    audit.log(u.id, u.username, "RESTORE", "system", 0,
              QString("Restored backup from %1").arg(zipPath), "");

    emit restoreCompleted();
    Logger::info(QString("Backup restored from %1").arg(zipPath));
    return true;
}

std::vector<BackupService::BackupInfo> BackupService::listBackups() {
    QDir dir(Config::instance().backupDir());
    std::vector<BackupInfo> result;
    if (!dir.exists()) return result;
    QStringList files = dir.entryList({"mms_backup_*.zip"}, QDir::Files, QDir::Time);
    for (const QString& f : files) {
        BackupInfo bi;
        bi.fileName = f;
        bi.fullPath = dir.absoluteFilePath(f);
        QFileInfo fi(bi.fullPath);
        bi.created = fi.birthTime();
        if (!bi.created.isValid()) bi.created = fi.lastModified();
        bi.sizeBytes = fi.size();
        result.push_back(bi);
    }
    return result;
}

int BackupService::pruneOldBackups(int keepCount) {
    auto backups = listBackups();
    int removed = 0;
    for (int i = keepCount; i < (int)backups.size(); ++i) {
        if (QFile::remove(backups[i].fullPath)) ++removed;
    }
    return removed;
}

bool BackupService::verifyBackup(const QString& zipPath, QString* errorMsg) {
    QFile zip(zipPath);
    if (!zip.open(QIODevice::ReadOnly)) {
        if (errorMsg) *errorMsg = "Cannot open backup file.";
        return false;
    }
    qint64 sz = zip.size();
    if (sz < 22) {
        if (errorMsg) *errorMsg = "Backup file too small.";
        return false;
    }
    zip.seek(sz - sizeof(ziputil::ZipEndHeader));
    ziputil::ZipEndHeader eh;
    zip.read(reinterpret_cast<char*>(&eh), sizeof(eh));
    zip.close();
    if (eh.sig != 0x06054b50) {
        if (errorMsg) *errorMsg = "Invalid ZIP signature.";
        return false;
    }
    return true;
}

} // namespace mms
