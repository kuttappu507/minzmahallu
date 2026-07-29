/*
 * Logger.cpp - Implementation
 */
#include "Logger.h"
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

namespace mms {

Logger& Logger::instance() {
    static Logger inst;
    return inst;
}

Logger::Logger() {
    // Default to console output until initialize() is called
}

Logger::~Logger() {
    shutdown();
}

void Logger::initialize(const QString& logDir, Level minLevel) {
    QMutexLocker lock(&mutex_);
    minLevel_ = minLevel;
    logDir_ = logDir;
    QDir().mkpath(logDir_);

    logFile_ = QDir(logDir_).absoluteFilePath("mms.log");

    if (file_.isOpen()) file_.close();
    file_.setFileName(logFile_);
    file_.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text);
    stream_.setDevice(&file_);
    stream_.setEncoding(QStringConverter::Utf8);

    log(Level::Info, "=== MMS Logger initialized ===", "system");
}

void Logger::shutdown() {
    QMutexLocker lock(&mutex_);
    if (file_.isOpen()) {
        stream_.flush();
        file_.close();
    }
}

QString Logger::levelString(Level l) const {
    switch (l) {
    case Level::Trace: return "TRACE";
    case Level::Debug: return "DEBUG";
    case Level::Info:  return "INFO ";
    case Level::Warn:  return "WARN ";
    case Level::Error: return "ERROR";
    case Level::Fatal: return "FATAL";
    }
    return "?    ";
}

void Logger::rotateIfNeeded() {
    if (!file_.isOpen()) return;
    if (file_.size() < maxSize_) return;

    stream_.flush();
    file_.close();

    // Rotate: mms.log.5 -> delete, mms.log.4 -> .5, ... mms.log -> .1
    for (int i = maxBackups_; i >= 1; --i) {
        QString from = logFile_ + (i == 1 ? QString() : QString(".%1").arg(i - 1));
        QString to   = logFile_ + QString(".%1").arg(i);
        if (i == maxBackups_) QFile::remove(to);
        if (QFile::exists(from)) QFile::rename(from, to);
    }

    file_.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text);
}

void Logger::log(Level level, const QString& message, const QString& category) {
    if (static_cast<int>(level) < static_cast<int>(minLevel_)) return;

    QMutexLocker lock(&mutex_);
    QDateTime now = QDateTime::currentDateTime();
    QString line = QString("[%1] [%2] [%3] %4")
                       .arg(now.toString(Qt::ISODateWithMs))
                       .arg(levelString(level))
                       .arg(category.isEmpty() ? QStringLiteral("app") : category)
                       .arg(message);

    if (file_.isOpen()) {
        stream_ << line << '\n';
        stream_.flush();
        rotateIfNeeded();
    }

    // Also echo to stderr in debug builds
#ifdef QT_DEBUG
    fprintf(stderr, "%s\n", qPrintable(line));
#endif

    emit logMessage(level, message, now);
}

} // namespace mms
