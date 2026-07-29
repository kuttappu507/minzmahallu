/*
 * TestFamily.cpp - Family service/repository tests
 */
#include <QtTest/QtTest>
#include "../src/services/FamilyService.h"
#include "../src/repositories/FamilyRepository.h"
#include "../src/services/AuthSession.h"
#include "../src/models/User.h"

class TestFamily : public QObject {
    Q_OBJECT
private slots:
    void testCreateFamily();
    void testUpdateFamily();
    void testArchiveRestore();
    void testSearchFamilies();
    void testDeleteFamilyWithMembers();
    void testGenerateNextFamilyNumber();
};

void TestFamily::testCreateFamily() {
    // Need an authenticated user for audit log
    mms::User u;
    u.id = 1; u.username = "test_admin"; u.role = "Administrator";
    mms::AuthSession::instance().setUser(u);

    mms::FamilyService svc;
    mms::Family f;
    f.familyNumber = "TEST-FAM-001";
    f.houseName = "Test House Alpha";
    f.ward = "Ward 1";
    f.area = "Test Area";
    f.address = "123 Test Street";
    f.pincode = "678001";
    f.phone = "9847009999";
    QString err;
    qint64 id = svc.createFamily(f, &err);
    QVERIFY2(id > 0, qPrintable(err));

    auto loaded = mms::FamilyRepository().findById(id);
    QVERIFY(loaded.has_value());
    QCOMPARE(loaded->familyNumber, QString("TEST-FAM-001"));
    QCOMPARE(loaded->houseName, QString("Test House Alpha"));
}

void TestFamily::testUpdateFamily() {
    mms::User u; u.id = 1; u.username = "test_admin"; u.role = "Administrator";
    mms::AuthSession::instance().setUser(u);

    mms::FamilyService svc;
    mms::Family f;
    f.familyNumber = "TEST-FAM-002";
    f.houseName = "Original House";
    f.phone = "9847009998";
    QString err;
    qint64 id = svc.createFamily(f, &err);
    QVERIFY(id > 0);

    f.id = id;
    f.houseName = "Updated House";
    QVERIFY(svc.updateFamily(f, &err));

    auto loaded = mms::FamilyRepository().findById(id);
    QCOMPARE(loaded->houseName, QString("Updated House"));
}

void TestFamily::testArchiveRestore() {
    mms::User u; u.id = 1; u.username = "test_admin"; u.role = "Administrator";
    mms::AuthSession::instance().setUser(u);

    mms::FamilyService svc;
    mms::Family f;
    f.familyNumber = "TEST-FAM-003";
    f.houseName = "Archive Test";
    f.phone = "9847009997";
    QString err;
    qint64 id = svc.createFamily(f, &err);
    QVERIFY(id > 0);

    QVERIFY(svc.archiveFamily(id));
    auto loaded = mms::FamilyRepository().findById(id);
    QCOMPARE(loaded->status, QString("Archived"));

    QVERIFY(svc.restoreFamily(id));
    loaded = mms::FamilyRepository().findById(id);
    QCOMPARE(loaded->status, QString("Active"));
}

void TestFamily::testSearchFamilies() {
    mms::User u; u.id = 1; u.username = "test_admin"; u.role = "Administrator";
    mms::AuthSession::instance().setUser(u);

    mms::FamilyService svc;
    int total = 0;
    auto results = svc.searchFamilies("TEST-FAM", 1, 50, "Active", "", &total);
    QVERIFY(total >= 3);
    QVERIFY(results.size() >= 3);
}

void TestFamily::testDeleteFamilyWithMembers() {
    // FAM-001 from seed has members - should not be deletable
    mms::FamilyService svc;
    QString err;
    QVERIFY(!svc.deleteFamily(1, &err));
    QVERIFY(err.contains("members"));
}

void TestFamily::testGenerateNextFamilyNumber() {
    mms::FamilyRepository repo;
    QString num = repo.generateNextFamilyNumber();
    QVERIFY(num.startsWith("FAM-"));
    QVERIFY(num.length() >= 8);
}

int runTestFamily(int argc, char* argv[]) {
    TestFamily t;
    return QTest::qExec(&t, argc, argv);
}

#include "TestFamily.moc"
