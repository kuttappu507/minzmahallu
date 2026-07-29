/*
 * TestSubscription.cpp - Subscription service tests
 */
#include <QtTest/QtTest>
#include "../src/services/SubscriptionService.h"
#include "../src/repositories/SubscriptionRepository.h"
#include "../src/services/AuthSession.h"
#include "../src/models/User.h"

class TestSubscription : public QObject {
    Q_OBJECT
private slots:
    void testCreateSubscription();
    void testMarkOverdue();
    void testDefaulters();
    void testReceiptNumberGeneration();
    void testTotalCollected();
};

void setupAuth() {
    mms::User u; u.id = 1; u.username = "test_admin"; u.role = "Administrator";
    mms::AuthSession::instance().setUser(u);
}

void TestSubscription::testCreateSubscription() {
    setupAuth();
    mms::SubscriptionService svc;
    mms::Subscription s;
    s.familyId = 1;
    s.planId = 1;
    s.amount = 100;
    s.amountPaid = 100;
    s.status = "Paid";
    s.paymentDate = QDate::currentDate().toString(Qt::ISODate);
    s.periodStart = QDate::currentDate().toString(Qt::ISODate);
    s.periodEnd = QDate::currentDate().addMonths(1).toString(Qt::ISODate);
    QString err;
    qint64 id = svc.createSubscription(s, &err);
    QVERIFY2(id > 0, qPrintable(err));
    QVERIFY(!s.receiptNumber.isEmpty());
}

void TestSubscription::testMarkOverdue() {
    mms::SubscriptionService svc;
    int n = svc.markOverdue();
    QVERIFY(n >= 0);
}

void TestSubscription::testDefaulters() {
    mms::SubscriptionService svc;
    auto defs = svc.defaulters();
    // Seed data has 2 defaulters (FAM-003 pending, FAM-005 overdue)
    QVERIFY(defs.size() >= 2);
}

void TestSubscription::testReceiptNumberGeneration() {
    mms::SubscriptionService svc;
    QString r1 = svc.nextReceiptNumber();
    QString r2 = svc.nextReceiptNumber();
    QVERIFY(r1.startsWith("RCP-"));
    QVERIFY(r1 != r2);
}

void TestSubscription::testTotalCollected() {
    mms::SubscriptionService svc;
    QString from = QDate::currentDate().addYears(-1).toString(Qt::ISODate);
    QString to = QDate::currentDate().toString(Qt::ISODate);
    double total = svc.totalCollected(from, to);
    QVERIFY(total >= 0);
}

int runTestSubscription(int argc, char* argv[]) {
    TestSubscription t;
    return QTest::qExec(&t, argc, argv);
}

#include "TestSubscription.moc"
