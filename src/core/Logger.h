/*
 * Logger.h - Thread-safe leveled logging for MMS
 *
 * Logs to both stderr (debug builds) and a rotating log file inside
 * the user's data directory.
 */
#pragma once

#include <QObject>
#include <QString>
#include <QFile>
#include <QTextStream>
#include <QMutex>
#include <QDateTime>

namespace mms {

class Logger : public QObject {
    Q_OBJECT
public:
    enum class Level {
        Trace, Debug, Info, Warn, Error, Fatal
    };

    static Logger& instance();

    void initialize(const QString& logDir, Level minLevel = Level::Info);
    void shutdown();

    void log(Level level, const QString& message, const QString& category = QString());

    // Convenience static methods
    static void trace(const QString& msg) { instance().log(Level::Trace, msg); }
    static void debug(const QString& msg) { instance().log(Level::Debug, msg); }
    static void info (const QString& msg) { instance().log(Level::Info,  msg); }
    static void warn (const QString& msg) { instance().log(Level::Warn,  msg); }
    static void error(const QString& msg) { instance().log(Level::Error, msg); }
    static void fatal(const QString& msg) { instance().log(Level::Fatal, msg); }

    void setMinLevel(Level level) { minLevel_ = level; }
    Level minLevel() const { return minLevel_; }

    QString logFile() const { return logFile_; }

signals:
    void logMessage(Level level, const QString& message, const QDateTime& timestamp);

private:
    Logger();
    ~Logger() override;
    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;

    QString levelString(Level l) const;
    void rotateIfNeeded();

    QFile file_;
    QTextStream stream_;
    QRecursiveMutex mutex_;
    QString logDir_;
    QString logFile_;
    Level minLevel_ = Level::Info;
    qint64 maxSize_ = 10 * 1024 * 1024; // 10 MB
    int maxBackups_ = 5;
};

} // namespace mms
