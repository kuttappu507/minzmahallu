/*
 * TestMain.cpp - Entry point for the MMS test suite
 */
#include <QtTest/QtTest>
#include <QCoreApplication>
#include <QTemporaryFile>
#include <QDir>
#include <QSqlDatabase>

#include "../src/core/Logger.h"
#include "../src/core/Config.h"
#include "../src/core/Database.h"

// Declare test classes
extern int runTestDatabase(int argc, char* argv[]);
extern int runTestAuth(int argc, char* argv[]);
extern int runTestFamily(int argc, char* argv[]);
extern int runTestMember(int argc, char* argv[]);
extern int runTestSubscription(int argc, char* argv[]);

int main(int argc, char* argv[]) {
    QCoreApplication app(argc, argv);

    // Use a temp directory for tests
    QString testDir = QDir::tempPath() + "/mms_tests_" +
                      QString::number(QCoreApplication::applicationPid());
    QDir().mkpath(testDir);

    mms::Config::instance().initialize("MMS_Test");
    mms::Logger::instance().initialize(testDir + "/logs", mms::Logger::Level::Trace);

    QString dbPath = testDir + "/test_mms.db";
    QFile::remove(dbPath);
    QString sqlDir = QCoreApplication::applicationDirPath() + "/../sql";
    if (!QFileInfo::exists(sqlDir + "/schema.sql")) {
        sqlDir = QString(MMS_SOURCE_DIR) + "/sql";
    }

    if (!mms::Database::instance().initialize(dbPath, sqlDir)) {
        qCritical() << "Test DB initialization failed:" << mms::Database::instance().lastErrorText();
        return 1;
    }

    int failed = 0;
    failed += runTestDatabase(argc, argv);
    failed += runTestAuth(argc, argv);
    failed += runTestFamily(argc, argv);
    failed += runTestMember(argc, argv);
    failed += runTestSubscription(argc, argv);

    mms::Database::instance().closeAll();
    QDir(testDir).removeRecursively();

    return failed;
}
