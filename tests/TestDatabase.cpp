/*
 * TestDatabase.cpp - Database integration tests
 */
#include <QtTest/QtTest>
#include <QTemporaryFile>
#include <QFileInfo>
#include "../src/core/Database.h"

class TestDatabase : public QObject {
    Q_OBJECT
private slots:
    void testSchemaLoaded();
    void testTablesExist();
    void testSettingsRow();
    void testSeedData();
    void testTransaction();
    void testPreparedStatements();
};

void TestDatabase::testSchemaLoaded() {
    QVERIFY(mms::Database::instance().isInitialized());
    QVERIFY(mms::Database::instance().schemaVersion() >= 1);
}

void TestDatabase::testTablesExist() {
    QStringList expectedTables = {
        "users", "permissions", "settings", "families", "members",
        "subscription_plans", "subscriptions", "donation_categories", "donations",
        "ledger_accounts", "transactions", "marriages", "deaths",
        "welfare_requests", "certificates", "documents", "audit_log",
        "sessions", "notifications"
    };
    QSqlQuery q = mms::Database::instance().execute(
        "SELECT name FROM sqlite_master WHERE type='table'");
    QStringList found;
    while (q.next()) found << q.value(0).toString();
    for (const auto& t : expectedTables) {
        QVERIFY2(found.contains(t), qPrintable("Missing table: " + t));
    }
}

void TestDatabase::testSettingsRow() {
    QVariant v = mms::Database::instance().scalar("SELECT COUNT(*) FROM settings WHERE id = 1");
    QCOMPARE(v.toInt(), 1);
}

void TestDatabase::testSeedData() {
    QVariant c = mms::Database::instance().scalar("SELECT COUNT(*) FROM users");
    QVERIFY(c.toInt() >= 1);

    QVariant p = mms::Database::instance().scalar("SELECT COUNT(*) FROM permissions");
    QVERIFY(p.toInt() >= 50);

    QVariant f = mms::Database::instance().scalar("SELECT COUNT(*) FROM families");
    QVERIFY(f.toInt() >= 5);

    QVariant m = mms::Database::instance().scalar("SELECT COUNT(*) FROM members");
    QVERIFY(m.toInt() >= 15);
}

void TestDatabase::testTransaction() {
    bool ok = mms::Database::instance().transaction([&]() {
        mms::Database::instance().insert(
            "INSERT INTO families (family_number, house_name, phone, status) VALUES ('TEST-TXN', 'Test House', '9999999999', 'Active')");
        return true;
    });
    QVERIFY(ok);
    QVariant v = mms::Database::instance().scalar(
        "SELECT COUNT(*) FROM families WHERE family_number = 'TEST-TXN'");
    QCOMPARE(v.toInt(), 1);

    bool rollback = mms::Database::instance().transaction([&]() {
        mms::Database::instance().insert(
            "INSERT INTO families (family_number, house_name, phone, status) VALUES ('TEST-ROLLBACK', 'X', 'Y', 'Active')");
        return false;  // force rollback
    });
    QVERIFY(!rollback);
    QVariant c = mms::Database::instance().scalar(
        "SELECT COUNT(*) FROM families WHERE family_number = 'TEST-ROLLBACK'");
    QCOMPARE(c.toInt(), 0);
}

void TestDatabase::testPreparedStatements() {
    qint64 id = mms::Database::instance().insert(
        "INSERT INTO families (family_number, house_name, phone, status) VALUES (?, ?, ?, 'Active')",
        {"TEST-PS-1", "Prepared House", "8888888888"});
    QVERIFY(id > 0);

    QSqlQuery q = mms::Database::instance().execute(
        "SELECT house_name FROM families WHERE id = ?", { id });
    QVERIFY(q.next());
    QCOMPARE(q.value(0).toString(), QString("Prepared House"));
}

int runTestDatabase(int argc, char* argv[]) {
    TestDatabase t;
    return QTest::qExec(&t, argc, argv);
}

#include "TestDatabase.moc"
