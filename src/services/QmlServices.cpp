/*
 * QmlServices.cpp - Implementation of the QML services facade.
 * Wraps all C++ services into QVariant-friendly calls for QML.
 */
#include "QmlServices.h"
#include "FamilyService.h"
#include "MemberService.h"
#include "DonationService.h"
#include "SubscriptionService.h"
#include "AccountingService.h"
#include "AuthService.h"
#include "AuthSession.h"
#include "BackupService.h"
#include "CertificateService.h"
#include "DashboardService.h"
#include "ReportService.h"
#include "SettingsService.h"
#include "TokenService.h"
#include "RegisterServices.h"

#include "../models/Family.h"
#include "../models/Member.h"
#include "../models/Donation.h"
#include "../models/Subscription.h"
#include "../models/Marriage.h"
#include "../models/Death.h"
#include "../models/Welfare.h"
#include "../models/Transaction.h"
#include "../models/User.h"
#include "../models/TokenEvent.h"

#include <QDateTime>
#include <QDebug>

using namespace mms;

// ============================================================================
// Helpers: model structs → QVariantMap
// ============================================================================
static QVariantMap familyToMap(const Family& f) {
    QVariantMap m;
    m["id"] = f.id;
    m["familyNumber"] = f.familyNumber;
    m["houseName"] = f.houseName;
    m["houseNumber"] = f.houseNumber;
    m["ward"] = f.ward;
    m["area"] = f.area;
    m["address"] = f.address;
    m["pincode"] = f.pincode;
    m["phone"] = f.phone;
    m["alternativePhone"] = f.alternativePhone;
    m["status"] = f.status;
    m["notes"] = f.notes;
    m["memberCount"] = f.memberCount;
    m["headName"] = f.headName;
    return m;
}

static QVariantMap memberToMap(const Member& m) {
    QVariantMap v;
    v["id"] = m.id;
    v["familyId"] = m.familyId;
    v["memberCode"] = m.memberCode;
    v["name"] = m.name;
    v["arabicName"] = m.arabicName;
    v["gender"] = m.gender;
    v["dateOfBirth"] = m.dateOfBirth;
    v["age"] = m.age;
    v["bloodGroup"] = m.bloodGroup;
    v["occupation"] = m.occupation;
    v["education"] = m.education;
    v["maritalStatus"] = m.maritalStatus;
    v["mobile"] = m.mobile;
    v["email"] = m.email;
    v["nationality"] = m.nationality;
    v["address"] = m.address;
    v["emergencyContact"] = m.emergencyContact;
    v["relationship"] = m.relationship;
    v["isHead"] = m.isHead;
    v["status"] = m.status;
    v["familyNumber"] = m.familyNumber;
    v["houseName"] = m.houseName;
    return v;
}

static Family mapToFamily(const QVariantMap& d) {
    Family f;
    f.id = d.value("id").toLongLong();
    f.familyNumber = d.value("familyNumber").toString();
    f.houseName = d.value("houseName").toString();
    f.houseNumber = d.value("houseNumber").toString();
    f.ward = d.value("ward").toString();
    f.area = d.value("area").toString();
    f.address = d.value("address").toString();
    f.pincode = d.value("pincode").toString();
    f.phone = d.value("phone").toString();
    f.alternativePhone = d.value("alternativePhone").toString();
    f.status = d.value("status", "Active").toString();
    f.notes = d.value("notes").toString();
    return f;
}

static Member mapToMember(const QVariantMap& d) {
    Member m;
    m.id = d.value("id").toLongLong();
    m.familyId = d.value("familyId").toLongLong();
    m.memberCode = d.value("memberCode").toString();
    m.name = d.value("name").toString();
    m.arabicName = d.value("arabicName").toString();
    m.gender = d.value("gender").toString();
    m.dateOfBirth = d.value("dateOfBirth").toString();
    m.age = d.value("age").toInt();
    m.bloodGroup = d.value("bloodGroup").toString();
    m.occupation = d.value("occupation").toString();
    m.education = d.value("education").toString();
    m.maritalStatus = d.value("maritalStatus").toString();
    m.mobile = d.value("mobile").toString();
    m.email = d.value("email").toString();
    m.nationality = d.value("nationality", "Indian").toString();
    m.address = d.value("address").toString();
    m.emergencyContact = d.value("emergencyContact").toString();
    m.relationship = d.value("relationship").toString();
    m.status = d.value("status", "Active").toString();
    return m;
}

// ============================================================================
// Constructor / Destructor
// ============================================================================
QmlServices::QmlServices(QObject* parent) : QObject(parent) {
    familySvc_ = new FamilyService();
    memberSvc_ = new MemberService();
    donationSvc_ = new DonationService();
    subscriptionSvc_ = new SubscriptionService();
    accountingSvc_ = new AccountingService();
    authSvc_ = new AuthService(this);
    backupSvc_ = new BackupService(this);
    certSvc_ = new CertificateService();
    dashSvc_ = new DashboardService();
    reportSvc_ = new ReportService();
    settingsSvc_ = new SettingsService(this);
    tokenSvc_ = new TokenService(this);
}

QmlServices::~QmlServices() {
    delete familySvc_;
    delete memberSvc_;
    delete donationSvc_;
    delete subscriptionSvc_;
    delete accountingSvc_;
    delete certSvc_;
    delete dashSvc_;
    delete reportSvc_;
}

// ============================================================================
// Auth
// ============================================================================
QString QmlServices::currentUserName() const {
    return AuthSession::instance().user().fullName;
}

QString QmlServices::currentUserRole() const {
    return AuthSession::instance().user().role;
}

bool QmlServices::login(const QString& username, const QString& password) {
    auto result = authSvc_->login(username, password);
    if (result.success) {
        emit currentUserChanged();
        emit dashboardStatsChanged();
        return true;
    }
    setLastError(result.errorMessage);
    return false;
}

void QmlServices::logout() {
    authSvc_->logout();
    emit currentUserChanged();
}

bool QmlServices::changePassword(const QString& oldPwd, const QString& newPwd) {
    qint64 uid = AuthSession::instance().user().id;
    if (authSvc_->changePassword(uid, oldPwd, newPwd)) return true;
    setLastError("Password change failed");
    return false;
}

// ============================================================================
// Dashboard
// ============================================================================
QVariantMap QmlServices::dashboardStats() const {
    QVariantMap m;
    try {
        auto s = dashSvc_->load();
        m["totalFamilies"] = s.totalFamilies;
        m["totalMembers"] = s.totalMembers;
        m["activeMembers"] = s.activeMembers;
        m["maleMembers"] = s.maleMembers;
        m["femaleMembers"] = s.femaleMembers;
        m["monthlyCollection"] = s.monthlyCollection;
        m["pendingDues"] = s.pendingDues;
        m["monthlyDonations"] = s.monthlyDonations;
        m["welfareBeneficiaries"] = s.welfareBeneficiaries;
        m["marriagesThisYear"] = s.marriagesThisYear;
        m["deathsThisYear"] = s.deathsThisYear;
        m["incomeThisMonth"] = s.incomeThisMonth;
        m["expenseThisMonth"] = s.expenseThisMonth;
        m["balanceThisMonth"] = s.balanceThisMonth;
    } catch (...) {}
    return m;
}

QVariantList QmlServices::monthlyCollections(int months) {
    try { return dashSvc_->monthlyCollections(months); } catch (...) {}
    return {};
}

QVariantList QmlServices::monthlyDonations(int months) {
    try { return dashSvc_->monthlyDonations(months); } catch (...) {}
    return {};
}

QVariantList QmlServices::monthlyExpenses(int months) {
    try { return dashSvc_->monthlyExpenses(months); } catch (...) {}
    return {};
}

// ============================================================================
// Families
// ============================================================================
QVariantList QmlServices::searchFamilies(const QString& term, int page, int pageSize,
                                          const QString& statusFilter, const QString& wardFilter) {
    QVariantList out;
    try {
        auto families = familySvc_->searchFamilies(term, page, pageSize, statusFilter, wardFilter);
        for (const auto& f : families) out.append(familyToMap(f));
    } catch (const std::exception& e) {
        setLastError(e.what());
    }
    return out;
}

QVariantMap QmlServices::getFamily(qint64 id) {
    try { return familyToMap(familySvc_->getFamily(id)); }
    catch (const std::exception& e) { setLastError(e.what()); }
    return {};
}

qint64 QmlServices::createFamily(const QVariantMap& data) {
    Family f = mapToFamily(data);
    QString err;
    qint64 id = familySvc_->createFamily(f, &err);
    if (id > 0) { emit dataChanged(); emit dashboardStatsChanged(); return id; }
    setLastError(err);
    return 0;
}

bool QmlServices::updateFamily(qint64 id, const QVariantMap& data) {
    Family f = mapToFamily(data);
    f.id = id;
    QString err;
    if (familySvc_->updateFamily(f, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

bool QmlServices::deleteFamily(qint64 id) {
    QString err;
    if (familySvc_->deleteFamily(id, &err)) { emit dataChanged(); emit dashboardStatsChanged(); return true; }
    setLastError(err);
    return false;
}

int QmlServices::totalFamilies() { return familySvc_->totalFamilies(); }
int QmlServices::activeFamilies() { return familySvc_->activeFamilies(); }

QStringList QmlServices::wards() const {
    try { return const_cast<FamilyService*>(familySvc_)->wards(); } catch (...) {}
    return {};
}

// ============================================================================
// Members
// ============================================================================
QVariantList QmlServices::searchMembers(const QString& term, int page, int pageSize,
                                         const QString& genderFilter, const QString& statusFilter,
                                         qint64 familyIdFilter) {
    QVariantList out;
    try {
        auto members = memberSvc_->searchMembers(term, page, pageSize, genderFilter, statusFilter, familyIdFilter);
        for (const auto& m : members) out.append(memberToMap(m));
    } catch (const std::exception& e) { setLastError(e.what()); }
    return out;
}

QVariantMap QmlServices::getMember(qint64 id) {
    try { return memberToMap(memberSvc_->getMember(id)); }
    catch (const std::exception& e) { setLastError(e.what()); }
    return {};
}

QVariantList QmlServices::familyMembers(qint64 familyId) {
    QVariantList out;
    try {
        auto members = memberSvc_->familyMembers(familyId);
        for (const auto& m : members) out.append(memberToMap(m));
    } catch (...) {}
    return out;
}

qint64 QmlServices::createMember(const QVariantMap& data) {
    Member m = mapToMember(data);
    QString err;
    qint64 id = memberSvc_->createMember(m, &err);
    if (id > 0) { emit dataChanged(); emit dashboardStatsChanged(); return id; }
    setLastError(err);
    return 0;
}

bool QmlServices::updateMember(qint64 id, const QVariantMap& data) {
    Member m = mapToMember(data);
    m.id = id;
    QString err;
    if (memberSvc_->updateMember(m, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

bool QmlServices::deleteMember(qint64 id) {
    QString err;
    if (memberSvc_->deleteMember(id, &err)) { emit dataChanged(); emit dashboardStatsChanged(); return true; }
    setLastError(err);
    return false;
}

int QmlServices::totalMembers() { return memberSvc_->totalMembers(); }
int QmlServices::activeMembers() { return memberSvc_->activeMembers(); }

bool QmlServices::setFamilyHead(qint64 familyId, qint64 memberId) {
    return memberSvc_->setFamilyHead(familyId, memberId);
}

// ============================================================================
// Subscriptions
// ============================================================================
QVariantList QmlServices::searchSubscriptions(const QString& term, int page, int pageSize,
                                               qint64 familyId, const QString& status) {
    QVariantList out;
    try {
        auto subs = subscriptionSvc_->list(page, pageSize, status, QString(), QString(), familyId);
        for (const auto& s : subs) {
            QVariantMap m;
            m["id"] = s.id;
            m["familyId"] = s.familyId;
            m["receiptNumber"] = s.receiptNumber;
            m["periodStart"] = s.periodStart;
            m["periodEnd"] = s.periodEnd;
            m["amount"] = s.amount;
            m["amountPaid"] = s.amountPaid;
            m["paymentDate"] = s.paymentDate;
            m["paymentMethod"] = s.paymentMethod;
            m["status"] = s.status;
            m["familyNumber"] = s.familyNumber;
            m["memberName"] = s.memberName;
            m["planName"] = s.planName;
            out.append(m);
        }
    } catch (const std::exception& e) { setLastError(e.what()); }
    return out;
}

qint64 QmlServices::createSubscription(const QVariantMap& data) {
    Subscription s;
    s.familyId = data.value("familyId").toLongLong();
    s.memberId = data.value("memberId").toLongLong();
    s.planId = data.value("planId").toLongLong();
    s.periodStart = data.value("periodStart").toString();
    s.periodEnd = data.value("periodEnd").toString();
    s.amount = data.value("amount").toDouble();
    s.amountPaid = data.value("amountPaid").toDouble();
    s.paymentDate = data.value("paymentDate").toString();
    s.paymentMethod = data.value("paymentMethod", "Cash").toString();
    s.status = data.value("status", "Paid").toString();
    s.remarks = data.value("remarks").toString();
    QString err;
    qint64 id = subscriptionSvc_->createSubscription(s, &err);
    if (id > 0) { emit dataChanged(); return id; }
    setLastError(err);
    return 0;
}

bool QmlServices::updateSubscription(qint64 id, const QVariantMap& data) {
    Subscription s;
    s.id = id;
    s.familyId = data.value("familyId").toLongLong();
    s.amount = data.value("amount").toDouble();
    s.paymentDate = data.value("paymentDate").toString();
    s.status = data.value("status").toString();
    QString err;
    if (subscriptionSvc_->updateSubscription(s, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

bool QmlServices::deleteSubscription(qint64 id) {
    if (subscriptionSvc_->deleteSubscription(id)) { emit dataChanged(); return true; }
    return false;
}

int QmlServices::markOverdueSubscriptions() { return subscriptionSvc_->markOverdue(); }
QString QmlServices::nextSubscriptionReceiptNumber() { return subscriptionSvc_->nextReceiptNumber(); }

QVariantList QmlServices::subscriptionPlans() const {
    QVariantList out;
    try {
        auto plans = const_cast<SubscriptionService*>(subscriptionSvc_)->plans();
        for (const auto& p : plans) {
            QVariantMap m;
            m["id"] = p.id;
            m["name"] = p.name;
            m["frequency"] = p.frequency;
            m["defaultAmount"] = p.defaultAmount;
            m["description"] = p.description;
            out.append(m);
        }
    } catch (...) {}
    return out;
}

// ============================================================================
// Donations
// ============================================================================
QVariantList QmlServices::searchDonations(const QString& term, int page, int pageSize,
                                           qint64 categoryId, const QString& dateFrom, const QString& dateTo) {
    QVariantList out;
    try {
        auto dons = donationSvc_->list(page, pageSize, dateFrom, dateTo, categoryId, term);
        for (const auto& d : dons) {
            QVariantMap m;
            m["id"] = d.id;
            m["receiptNumber"] = d.receiptNumber;
            m["donorName"] = d.donorName;
            m["donorPhone"] = d.donorPhone;
            m["donorAddress"] = d.donorAddress;
            m["familyId"] = d.familyId;
            m["categoryId"] = d.categoryId;
            m["categoryName"] = d.categoryName;
            m["amount"] = d.amount;
            m["donationDate"] = d.donationDate;
            m["paymentMethod"] = d.paymentMethod;
            m["purpose"] = d.purpose;
            m["remarks"] = d.remarks;
            out.append(m);
        }
    } catch (const std::exception& e) { setLastError(e.what()); }
    return out;
}

qint64 QmlServices::createDonation(const QVariantMap& data) {
    Donation d;
    d.donorName = data.value("donorName").toString();
    d.donorPhone = data.value("donorPhone").toString();
    d.donorAddress = data.value("donorAddress").toString();
    d.familyId = data.value("familyId").toLongLong();
    d.memberId = data.value("memberId").toLongLong();
    d.categoryId = data.value("categoryId").toLongLong();
    d.amount = data.value("amount").toDouble();
    d.donationDate = data.value("donationDate", QDate::currentDate().toString("yyyy-MM-dd")).toString();
    d.paymentMethod = data.value("paymentMethod", "Cash").toString();
    d.purpose = data.value("purpose").toString();
    d.remarks = data.value("remarks").toString();
    QString err;
    qint64 id = donationSvc_->createDonation(d, &err);
    if (id > 0) { emit dataChanged(); emit dashboardStatsChanged(); return id; }
    setLastError(err);
    return 0;
}

bool QmlServices::updateDonation(qint64 id, const QVariantMap& data) {
    Donation d;
    d.id = id;
    d.donorName = data.value("donorName").toString();
    d.donorPhone = data.value("donorPhone").toString();
    d.amount = data.value("amount").toDouble();
    d.donationDate = data.value("donationDate").toString();
    d.paymentMethod = data.value("paymentMethod").toString();
    d.remarks = data.value("remarks").toString();
    QString err;
    if (donationSvc_->updateDonation(d, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

bool QmlServices::deleteDonation(qint64 id) {
    if (donationSvc_->deleteDonation(id)) { emit dataChanged(); emit dashboardStatsChanged(); return true; }
    return false;
}

QString QmlServices::nextDonationReceiptNumber() { return donationSvc_->nextReceiptNumber(); }

QVariantList QmlServices::donationCategories() const {
    QVariantList out;
    try {
        auto cats = const_cast<DonationService*>(donationSvc_)->categories();
        for (const auto& c : cats) {
            QVariantMap m;
            m["id"] = c.id;
            m["name"] = c.name;
            m["description"] = c.description;
            out.append(m);
        }
    } catch (...) {}
    return out;
}

// ============================================================================
// Accounting
// ============================================================================
QVariantList QmlServices::searchTransactions(const QString& term, int page, int pageSize,
                                              qint64 accountId, const QString& dateFrom, const QString& dateTo) {
    QVariantList out;
    try {
        auto txns = accountingSvc_->listTransactions(page, pageSize, dateFrom, dateTo, QString(), accountId);
        for (const auto& t : txns) {
            QVariantMap m;
            m["id"] = t.id;
            m["txnDate"] = t.txnDate;
            m["accountId"] = t.accountId;
            m["type"] = t.type;
            m["amount"] = t.amount;
            m["paymentMethod"] = t.paymentMethod;
            m["reference"] = t.reference;
            m["description"] = t.description;
            out.append(m);
        }
    } catch (const std::exception& e) { setLastError(e.what()); }
    return out;
}

qint64 QmlServices::createTransaction(const QVariantMap& data) {
    Transaction t;
    t.txnDate = data.value("txnDate", QDate::currentDate().toString("yyyy-MM-dd")).toString();
    t.accountId = data.value("accountId").toLongLong();
    t.type = data.value("type").toString();
    t.amount = data.value("amount").toDouble();
    t.paymentMethod = data.value("paymentMethod", "Cash").toString();
    t.description = data.value("description").toString();
    QString err;
    qint64 id = accountingSvc_->createTransaction(t, &err);
    if (id > 0) { emit dataChanged(); return id; }
    setLastError(err);
    return 0;
}

bool QmlServices::updateTransaction(qint64 id, const QVariantMap& data) {
    Transaction t;
    t.id = id;
    t.txnDate = data.value("txnDate").toString();
    t.accountId = data.value("accountId").toLongLong();
    t.type = data.value("type").toString();
    t.amount = data.value("amount").toDouble();
    t.description = data.value("description").toString();
    QString err;
    if (accountingSvc_->updateTransaction(t, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

bool QmlServices::deleteTransaction(qint64 id) {
    if (accountingSvc_->deleteTransaction(id)) { emit dataChanged(); return true; }
    return false;
}

QVariantList QmlServices::accountingAccounts() const {
    QVariantList out;
    try {
        auto accs = const_cast<AccountingService*>(accountingSvc_)->accounts();
        for (const auto& a : accs) {
            QVariantMap m;
            m["id"] = a.id;
            m["code"] = a.code;
            m["name"] = a.name;
            m["type"] = a.type;
            m["category"] = a.category;
            out.append(m);
        }
    } catch (...) {}
    return out;
}

// ============================================================================
// Marriage / Death / Welfare
// ============================================================================
QVariantList QmlServices::searchMarriages(const QString& term, int page, int pageSize) {
    QVariantList out;
    try {
        MarriageService svc;
        auto ms = svc.list(page, pageSize, term);
        for (const auto& m : ms) {
            QVariantMap v;
            v["id"] = m.id;
            v["marriageNumber"] = m.marriageNumber;
            v["groomName"] = m.groomName;
            v["groomFather"] = m.groomFather;
            v["brideName"] = m.brideName;
            v["brideFather"] = m.brideFather;
            v["date"] = m.nikahDate;
            v["mahallu"] = m.place;
            v["status"] = "Active";
            out.append(v);
        }
    } catch (...) {}
    return out;
}

qint64 QmlServices::createMarriage(const QVariantMap& data) {
    Marriage m;
    m.marriageNumber = data.value("marriageNumber").toString();
    m.groomName = data.value("groomName").toString();
    m.groomFather = data.value("groomFather").toString();
    m.groomAddress = data.value("groomAddress").toString();
    m.brideName = data.value("brideName").toString();
    m.brideFather = data.value("brideFather").toString();
    m.brideAddress = data.value("brideAddress").toString();
    m.nikahDate = data.value("date").toString();
    m.place = data.value("mahallu").toString();
    m.witness1 = data.value("witness1").toString();
    m.witness2 = data.value("witness2").toString();
    QString err;
    MarriageService svc;
    qint64 id = svc.createMarriage(m, &err);
    if (id > 0) { emit dataChanged(); return id; }
    setLastError(err);
    return 0;
}

bool QmlServices::updateMarriage(qint64 id, const QVariantMap& data) {
    Marriage m;
    m.id = id;
    m.marriageNumber = data.value("marriageNumber").toString();
    m.groomName = data.value("groomName").toString();
    m.brideName = data.value("brideName").toString();
    m.nikahDate = data.value("date").toString();
    QString err;
    MarriageService svc;
    if (svc.updateMarriage(m, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

bool QmlServices::deleteMarriage(qint64 id) {
    MarriageService svc;
    if (svc.deleteMarriage(id)) { emit dataChanged(); return true; }
    return false;
}

QVariantList QmlServices::searchDeaths(const QString& term, int page, int pageSize) {
    QVariantList out;
    try {
        DeathService svc;
        auto ds = svc.list(page, pageSize, term);
        for (const auto& d : ds) {
            QVariantMap v;
            v["id"] = d.id;
            v["deathNumber"] = d.deathNumber;
            v["deceasedName"] = d.deceasedName;
            v["fatherName"] = d.fatherName;
            v["gender"] = d.gender;
            v["dateOfDeath"] = d.dateOfDeath;
            v["burialDate"] = d.burialDate;
            v["causeOfDeath"] = d.causeOfDeath;
            v["burialPlace"] = d.burialPlace;
            v["age"] = d.age;
            v["status"] = "Active";
            out.append(v);
        }
    } catch (...) {}
    return out;
}

qint64 QmlServices::createDeath(const QVariantMap& data) {
    Death d;
    d.deathNumber = data.value("deathNumber").toString();
    d.deceasedName = data.value("deceasedName").toString();
    d.fatherName = data.value("fatherName").toString();
    d.gender = data.value("gender").toString();
    d.dateOfDeath = data.value("dateOfDeath").toString();
    d.burialDate = data.value("burialDate").toString();
    d.causeOfDeath = data.value("causeOfDeath").toString();
    d.burialPlace = data.value("burialPlace").toString();
    d.age = data.value("age").toInt();
    QString err;
    DeathService svc;
    qint64 id = svc.createDeath(d, &err);
    if (id > 0) { emit dataChanged(); return id; }
    setLastError(err);
    return 0;
}

bool QmlServices::updateDeath(qint64 id, const QVariantMap& data) {
    Death d;
    d.id = id;
    d.deceasedName = data.value("deceasedName").toString();
    d.dateOfDeath = data.value("dateOfDeath").toString();
    QString err;
    DeathService svc;
    if (svc.updateDeath(d, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

bool QmlServices::deleteDeath(qint64 id) {
    DeathService svc;
    if (svc.deleteDeath(id)) { emit dataChanged(); return true; }
    return false;
}

QVariantList QmlServices::searchWelfare(const QString& term, int page, int pageSize, const QString& status) {
    QVariantList out;
    try {
        WelfareService svc;
        auto ws = svc.list(page, pageSize, status);
        for (const auto& w : ws) {
            QVariantMap v;
            v["id"] = w.id;
            v["requestNumber"] = w.requestNumber;
            v["applicantName"] = w.applicantName;
            v["category"] = w.category;
            v["amountRequested"] = w.amountRequested;
            v["amountApproved"] = w.amountApproved;
            v["reason"] = w.reason;
            v["status"] = w.status;
            v["remarks"] = w.remarks;
            out.append(v);
        }
    } catch (...) {}
    return out;
}

qint64 QmlServices::createWelfareRequest(const QVariantMap& data) {
    WelfareRequest w;
    w.applicantName = data.value("applicantName").toString();
    w.category = data.value("category").toString();
    w.amountRequested = data.value("amountRequested").toDouble();
    w.reason = data.value("reason").toString();
    w.status = "Pending";
    QString err;
    WelfareService svc;
    qint64 id = svc.createRequest(w, &err);
    if (id > 0) { emit dataChanged(); return id; }
    setLastError(err);
    return 0;
}

bool QmlServices::updateWelfareRequest(qint64 id, const QVariantMap& data) {
    WelfareRequest w;
    w.id = id;
    w.applicantName = data.value("applicantName").toString();
    w.amountRequested = data.value("amountRequested").toDouble();
    w.reason = data.value("reason").toString();
    QString err;
    WelfareService svc;
    if (svc.updateRequest(w, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

bool QmlServices::approveWelfareRequest(qint64 id, double amount, const QString& remarks) {
    WelfareService svc;
    if (svc.approveRequest(id, amount, remarks)) { emit dataChanged(); return true; }
    return false;
}

bool QmlServices::rejectWelfareRequest(qint64 id, const QString& remarks) {
    WelfareService svc;
    if (svc.rejectRequest(id, remarks)) { emit dataChanged(); return true; }
    return false;
}

// ============================================================================
// Certificates (placeholder - requires more complex model)
// ============================================================================
QVariantList QmlServices::searchCertificates(const QString& term, int page, int pageSize, const QString& type) {
    return {};
}

qint64 QmlServices::issueCertificate(const QVariantMap& data) {
    setLastError("Certificate issuance not yet wired");
    return 0;
}

QString QmlServices::generateCertificatePdf(qint64 id) {
    QString err;
    QString path = certSvc_->generatePdf(id, &err);
    if (path.isEmpty()) setLastError(err);
    return path;
}

QString QmlServices::generateMarriageCertificatePdf(qint64 marriageId) {
    QString err;
    QString path = certSvc_->generateMarriageCertificatePdf(marriageId, &err);
    if (path.isEmpty()) setLastError(err);
    return path;
}

QString QmlServices::generateDeathCertificatePdf(qint64 deathId) {
    QString err;
    QString path = certSvc_->generateDeathCertificatePdf(deathId, &err);
    if (path.isEmpty()) setLastError(err);
    return path;
}

// ============================================================================
// Tokens
// ============================================================================
QVariantList QmlServices::searchTokenEvents(const QString& term) {
    QVariantList out;
    try {
        auto events = tokenSvc_->listEvents();
        for (const auto& e : events) {
            QVariantMap m;
            m["id"] = e.id;
            m["eventName"] = e.eventName;
            m["eventType"] = e.eventType;
            m["eventDate"] = e.eventDate;
            m["eventTime"] = e.eventTime;
            m["venue"] = e.venue;
            m["description"] = e.description;
            m["status"] = e.status;
            m["totalFamilies"] = e.totalFamilies;
            out.append(m);
        }
    } catch (...) {}
    return out;
}

qint64 QmlServices::createTokenEvent(const QVariantMap& data) {
    TokenEvent e;
    e.eventName = data.value("eventName").toString();
    e.eventType = data.value("eventType", "Meat Distribution").toString();
    e.eventDate = data.value("eventDate").toString();
    e.eventTime = data.value("eventTime").toString();
    e.venue = data.value("venue").toString();
    e.description = data.value("description").toString();
    e.notes = data.value("notes").toString();
    e.status = "Draft";
    QString err;
    auto created = tokenSvc_->createEvent(e, &err);
    if (created.id > 0) { emit dataChanged(); return created.id; }
    setLastError(err);
    return 0;
}

bool QmlServices::updateTokenEvent(qint64 id, const QVariantMap& data) {
    TokenEvent e;
    e.id = (int)id;
    e.eventName = data.value("eventName").toString();
    e.eventDate = data.value("eventDate").toString();
    e.venue = data.value("venue").toString();
    QString err;
    if (tokenSvc_->updateEvent(e, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

bool QmlServices::deleteTokenEvent(qint64 id) {
    QString err;
    if (tokenSvc_->deleteEvent((int)id, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

// ============================================================================
// Users (simplified — AuthService doesn't have listUsers, so return empty)
// ============================================================================
QVariantList QmlServices::users() const {
    return {};
}

qint64 QmlServices::createUser(const QString& username, const QString& fullName,
                                const QString& password, const QString& role,
                                const QString& email, const QString& phone) {
    qint64 id = authSvc_->createUser(username, fullName, password, role, email, phone, false);
    if (id > 0) { emit dataChanged(); return id; }
    setLastError("Failed to create user");
    return 0;
}

bool QmlServices::updateUser(qint64 id, const QString& fullName, const QString& role,
                             const QString& email, const QString& phone) {
    if (authSvc_->updateUserProfile(id, fullName, role, email, phone, true)) { emit dataChanged(); return true; }
    return false;
}

bool QmlServices::deleteUser(qint64 id) {
    if (authSvc_->deleteUser(id)) { emit dataChanged(); return true; }
    return false;
}

bool QmlServices::unlockUser(qint64 id) {
    return authSvc_->unlockUser(id);
}

bool QmlServices::resetUserPassword(qint64 id, const QString& newPwd) {
    return authSvc_->adminResetPassword(id, newPwd);
}

// ============================================================================
// Audit Log (placeholder)
// ============================================================================
QVariantList QmlServices::searchAuditLog(const QString& term, int page, int pageSize, const QString& module) {
    return {};
}

// ============================================================================
// Backup
// ============================================================================
QString QmlServices::createBackup() {
    QString err;
    QString path = backupSvc_->createBackup(&err);
    if (path.isEmpty()) setLastError(err);
    return path;
}

bool QmlServices::restoreBackup(const QString& zipPath) {
    QString err;
    if (backupSvc_->restoreBackup(zipPath, &err)) { emit dataChanged(); return true; }
    setLastError(err);
    return false;
}

QVariantList QmlServices::listBackups() {
    QVariantList out;
    try {
        auto backups = backupSvc_->listBackups();
        for (const auto& b : backups) {
            QVariantMap m;
            m["fileName"] = b.fileName;
            m["fullPath"] = b.fullPath;
            m["sizeBytes"] = (qint64)b.sizeBytes;
            m["created"] = b.created;
            out.append(m);
        }
    } catch (...) {}
    return out;
}

bool QmlServices::verifyBackup(const QString& zipPath) {
    QString err;
    return backupSvc_->verifyBackup(zipPath, &err);
}

// ============================================================================
// Reports (placeholder)
// ============================================================================
bool QmlServices::exportReport(const QString& reportName, const QString& format,
                               const QString& outputPath, const QVariantMap& params) {
    setLastError("Report export not yet wired");
    return false;
}

// ============================================================================
// Settings
// ============================================================================
QVariantMap QmlServices::getSettings() {
    QVariantMap m;
    try {
        auto s = settingsSvc_->load();
        m["mahalluName"] = s.mahalluName;
        m["address"] = s.address;
        m["phone"] = s.phone;
        m["email"] = s.email;
        m["logoPath"] = s.logoPath;
        m["sealPath"] = s.sealPath;
        m["financialYearStart"] = s.financialYearStart;
        m["currencySymbol"] = s.currencySymbol;
        m["theme"] = s.theme;
        m["language"] = s.language;
        m["autoBackup"] = s.autoBackup;
        m["backupIntervalHours"] = s.backupIntervalHours;
        m["receiptPrefix"] = s.receiptPrefix;
    } catch (...) {}
    return m;
}

bool QmlServices::saveSettings(const QVariantMap& data) {
    MahalluSettings s;
    s.mahalluName = data.value("mahalluName").toString();
    s.address = data.value("address").toString();
    s.phone = data.value("phone").toString();
    s.email = data.value("email").toString();
    s.financialYearStart = data.value("financialYearStart").toString();
    s.currencySymbol = data.value("currencySymbol").toString();
    s.theme = data.value("theme", "emerald").toString();
    s.language = data.value("language", "en").toString();
    s.autoBackup = data.value("autoBackup", true).toBool();
    s.backupIntervalHours = data.value("backupIntervalHours", 6).toInt();
    s.receiptPrefix = data.value("receiptPrefix").toString();
    return settingsSvc_->save(s);
}
