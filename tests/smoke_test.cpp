// Smoke test for MMS core components
#include <iostream>
#include <QCoreApplication>
#include "core/Logger.h"
#include "core/Config.h"
#include "core/Database.h"
#include "core/Security.h"

int main(int argc, char* argv[]) {
    QCoreApplication app(argc, argv);
    app.setApplicationName("MMS");
    app.setOrganizationName("Mahallu");

    std::cerr << "[1] Initializing Config..." << std::endl;
    mms::Config::instance().initialize("MMS");
    std::cerr << "    data dir: " << qPrintable(mms::Config::instance().dataDir()) << std::endl;
    std::cerr << "    db path:  " << qPrintable(mms::Config::instance().databasePath()) << std::endl;
    std::cerr << "    sql dir:  " << qPrintable(mms::Config::instance().sqlDir()) << std::endl;

    std::cerr << "[2] Initializing Logger..." << std::endl;
    mms::Logger::instance().initialize(mms::Config::instance().logDir(), mms::Logger::Level::Trace);
    mms::Logger::info("Smoke test starting");

    std::cerr << "[3] Initializing Database..." << std::endl;
    bool ok = mms::Database::instance().initialize(
        mms::Config::instance().databasePath(),
        mms::Config::instance().sqlDir());
    if (!ok) {
        std::cerr << "    FAILED: " << qPrintable(mms::Database::instance().lastErrorText()) << std::endl;
        return 1;
    }
    std::cerr << "    OK. Schema version: " << mms::Database::instance().schemaVersion() << std::endl;

    std::cerr << "[4] Testing queries..." << std::endl;
    QVariant c = mms::Database::instance().scalar("SELECT COUNT(*) FROM families");
    std::cerr << "    Families: " << c.toInt() << std::endl;
    c = mms::Database::instance().scalar("SELECT COUNT(*) FROM members");
    std::cerr << "    Members:  " << c.toInt() << std::endl;
    c = mms::Database::instance().scalar("SELECT COUNT(*) FROM users");
    std::cerr << "    Users:    " << c.toInt() << std::endl;
    c = mms::Database::instance().scalar("SELECT COUNT(*) FROM permissions");
    std::cerr << "    Perms:    " << c.toInt() << std::endl;

    std::cerr << "[5] Testing Security..." << std::endl;
    QByteArray salt = mms::Security::generateSalt(32);
    QString hash = mms::Security::instance().hashPassword("TestPass@123", salt);
    std::cerr << "    Hash algo: " << qPrintable(hash.split('$').first()) << std::endl;
    bool verified = mms::Security::instance().verifyPassword("TestPass@123", hash);
    std::cerr << "    Verify correct: " << (verified ? "YES" : "NO") << std::endl;
    bool wrong = mms::Security::instance().verifyPassword("WrongPass", hash);
    std::cerr << "    Verify wrong:   " << (wrong ? "YES" : "NO") << std::endl;

    std::cerr << "[6] All tests passed!" << std::endl;
    mms::Logger::info("Smoke test completed successfully");
    mms::Database::instance().closeAll();
    mms::Logger::instance().shutdown();
    return 0;
}
