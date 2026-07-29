/*
 * TestAuth.cpp - Authentication service tests
 */
#include <QtTest/QtTest>
#include "../src/services/AuthService.h"
#include "../src/services/AuthSession.h"
#include "../src/repositories/UserRepository.h"
#include "../src/core/Security.h"

class TestAuth : public QObject {
    Q_OBJECT
private slots:
    void testPasswordHashing();
    void testStrongPasswordValidation();
    void testLoginSuccess();
    void testLoginWrongPassword();
    void testLoginUnknownUser();
    void testChangePassword();
    void testCreateUser();
    void testPermissions();
};

void TestAuth::testPasswordHashing() {
    QByteArray salt = mms::Security::generateSalt(32);
    QVERIFY(salt.size() == 32);
    QString hash = mms::Security::instance().hashPassword("TestPassword123!", salt);
    QVERIFY(hash.contains('$'));
    QVERIFY(hash.split('$').size() == 4);
    QVERIFY(mms::Security::instance().verifyPassword("TestPassword123!", hash));
    QVERIFY(!mms::Security::instance().verifyPassword("WrongPassword!", hash));
}

void TestAuth::testStrongPasswordValidation() {
    QVERIFY(mms::Security::isStrongPassword("Abcd1234!"));
    QVERIFY(!mms::Security::isStrongPassword("weak"));
    QVERIFY(!mms::Security::isStrongPassword("alllowercase"));
    QVERIFY(!mms::Security::isStrongPassword("ALLUPPERCASE"));
    QVERIFY(!mms::Security::isStrongPassword("NoSpecialChar123"));
}

void TestAuth::testLoginSuccess() {
    // Create a test user
    mms::AuthService auth;
    qint64 id = auth.createUser("testuser1", "Test User 1", "Test@1234",
                                "Staff", "test1@example.com", "9999999991", false);
    QVERIFY(id > 0);

    auto result = auth.login("testuser1", "Test@1234");
    QVERIFY(result.success);
    QVERIFY(!result.mustChangePassword);
    QVERIFY(mms::AuthSession::instance().isLoggedIn());
    QCOMPARE(mms::AuthSession::instance().user().username, QString("testuser1"));
    auth.logout();
    QVERIFY(!mms::AuthSession::instance().isLoggedIn());
}

void TestAuth::testLoginWrongPassword() {
    mms::AuthService auth;
    auth.createUser("testuser2", "Test User 2", "Test@1234", "Staff");
    auto result = auth.login("testuser2", "WrongPassword!");
    QVERIFY(!result.success);
    QVERIFY(result.errorMessage.contains("Invalid"));
    QVERIFY(result.remainingAttempts > 0);
}

void TestAuth::testLoginUnknownUser() {
    mms::AuthService auth;
    auto result = auth.login("nonexistent_user", "anything");
    QVERIFY(!result.success);
}

void TestAuth::testChangePassword() {
    mms::AuthService auth;
    auth.createUser("testuser3", "Test User 3", "OldPass@123", "Staff", "", "", false);
    QVERIFY(auth.changePassword(mms::UserRepository().findByUsername("testuser3")->id,
                                "OldPass@123", "NewPass@456"));
    auto r = auth.login("testuser3", "NewPass@456");
    QVERIFY(r.success);
    auth.logout();
}

void TestAuth::testCreateUser() {
    mms::AuthService auth;
    // Weak password should fail
    qint64 id = auth.createUser("weakpwd", "Weak", "weak", "Staff");
    QVERIFY(id <= 0);

    // Duplicate username should fail
    qint64 dup = auth.createUser("testuser1", "Dup", "Test@1234", "Staff");
    QVERIFY(dup <= 0);

    // Invalid role should fail
    qint64 badRole = auth.createUser("testuser4", "Bad Role", "Test@1234", "InvalidRole");
    QVERIFY(badRole <= 0);
}

void TestAuth::testPermissions() {
    mms::UserRepository repo;
    QVERIFY(repo.roleHasPermission("Administrator", "family", "view"));
    QVERIFY(repo.roleHasPermission("Administrator", "anything", "anything"));
    QVERIFY(repo.roleHasPermission("Auditor", "family", "view"));
    QVERIFY(!repo.roleHasPermission("Auditor", "family", "delete"));
    QVERIFY(repo.roleHasPermission("Treasurer", "subscription", "add"));
    QVERIFY(!repo.roleHasPermission("Imam", "settings", "edit"));
}

int runTestAuth(int argc, char* argv[]) {
    TestAuth t;
    return QTest::qExec(&t, argc, argv);
}

#include "TestAuth.moc"
