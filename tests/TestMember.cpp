/*
 * TestMember.cpp - Member service tests
 */
#include <QtTest/QtTest>
#include "../src/services/MemberService.h"
#include "../src/services/FamilyService.h"
#include "../src/repositories/MemberRepository.h"
#include "../src/services/AuthSession.h"
#include "../src/models/User.h"

class TestMember : public QObject {
    Q_OBJECT
private slots:
    void testCreateMember();
    void testUpdateMember();
    void testFamilyMembers();
    void testSetFamilyHead();
    void testSearchMembers();
    void testValidation();
};

void setupAuth() {
    mms::User u; u.id = 1; u.username = "test_admin"; u.role = "Administrator";
    mms::AuthSession::instance().setUser(u);
}

void TestMember::testCreateMember() {
    setupAuth();
    mms::MemberService svc;
    mms::Member m;
    m.familyId = 1;  // FAM-001 from seed
    m.name = "Test Member Alpha";
    m.gender = "Male";
    m.mobile = "9847008001";
    QString err;
    qint64 id = svc.createMember(m, &err);
    QVERIFY2(id > 0, qPrintable(err));

    auto loaded = mms::MemberRepository().findById(id);
    QVERIFY(loaded.has_value());
    QCOMPARE(loaded->name, QString("Test Member Alpha"));
    QVERIFY(!loaded->memberCode.isEmpty());
}

void TestMember::testUpdateMember() {
    setupAuth();
    mms::MemberService svc;
    mms::Member m;
    m.familyId = 1;
    m.name = "Test Member Beta";
    m.gender = "Female";
    QString err;
    qint64 id = svc.createMember(m, &err);
    QVERIFY(id > 0);

    m.id = id;
    m.name = "Updated Member Beta";
    m.occupation = "Engineer";
    QVERIFY(svc.updateMember(m, &err));

    auto loaded = mms::MemberRepository().findById(id);
    QCOMPARE(loaded->name, QString("Updated Member Beta"));
    QCOMPARE(loaded->occupation, QString("Engineer"));
}

void TestMember::testFamilyMembers() {
    mms::MemberRepository repo;
    auto members = repo.listByFamily(1);  // FAM-001 has 3 seed members
    QVERIFY(members.size() >= 3);
}

void TestMember::testSetFamilyHead() {
    setupAuth();
    mms::MemberService svc;
    mms::Member m;
    m.familyId = 1;
    m.name = "Test Head Candidate";
    m.gender = "Male";
    QString err;
    qint64 id = svc.createMember(m, &err);
    QVERIFY(id > 0);
    QVERIFY(svc.setFamilyHead(1, id));

    auto head = mms::MemberRepository().findFamilyHead(1);
    QVERIFY(head.has_value());
    QCOMPARE(head->id, id);
    QCOMPARE(head->isHead, true);
}

void TestMember::testSearchMembers() {
    mms::MemberService svc;
    int total = 0;
    auto results = svc.searchMembers("Abdul", 1, 50, "", "Active", 0, &total);
    QVERIFY(total >= 1);
    QVERIFY(results.size() >= 1);
}

void TestMember::testValidation() {
    setupAuth();
    mms::MemberService svc;
    mms::Member m;
    m.familyId = 1;
    m.name = "";  // Empty name
    QString err;
    QVERIFY(svc.createMember(m, &err) <= 0);
    QVERIFY(err.contains("name"));

    m.name = "Test Validation";
    m.gender = "InvalidGender";
    QVERIFY(svc.createMember(m, &err) <= 0);
}

int runTestMember(int argc, char* argv[]) {
    TestMember t;
    return QTest::qExec(&t, argc, argv);
}

#include "TestMember.moc"
