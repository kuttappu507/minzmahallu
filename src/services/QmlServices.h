/*
 * QmlServices.h - Single facade exposing all MMS services to QML
 *
 * Registered as context property "Services" in main.cpp:
 *   engine.rootContext()->setContextProperty("Services", new QmlServices(&engine));
 *
 * Usage in QML:
 *   var families = Services.searchFamilies("term", 1, 50, "Active", "Ward 1")
 *   var id = Services.createFamily({houseName: "...", ward: "...", ...})
 *   var ok = Services.updateFamily(id, {houseName: "...", ...})
 *   Services.deleteFamily(id)
 *
 * All methods return QVariantList or QVariantMap (QML-friendly types).
 * Errors are returned via the lastError property.
 */
#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QStringList>

namespace mms {
    struct Family;
    struct Member;
    class FamilyService;
    class MemberService;
    class DonationService;
    class SubscriptionService;
    class AccountingService;
    class AuthService;
    class BackupService;
    class CertificateService;
    class DashboardService;
    class ReportService;
    class SettingsService;
    class TokenService;
}

class QmlServices : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    Q_PROPERTY(QString currentUserName READ currentUserName NOTIFY currentUserChanged)
    Q_PROPERTY(QString currentUserRole READ currentUserRole NOTIFY currentUserChanged)
    Q_PROPERTY(QVariantMap dashboardStats READ dashboardStats NOTIFY dashboardStatsChanged)
    Q_PROPERTY(QStringList wards READ wards CONSTANT)
    Q_PROPERTY(QVariantList donationCategories READ donationCategories CONSTANT)
    Q_PROPERTY(QVariantList subscriptionPlans READ subscriptionPlans CONSTANT)
    Q_PROPERTY(QVariantList accountingAccounts READ accountingAccounts CONSTANT)
    Q_PROPERTY(QVariantList users READ users CONSTANT)

public:
    explicit QmlServices(QObject* parent = nullptr);
    ~QmlServices();

    QString lastError() const { return lastError_; }
    void setLastError(const QString& e) { if (lastError_ != e) { lastError_ = e; emit lastErrorChanged(); } }

    // ===== Auth / session =====
    QString currentUserName() const;
    QString currentUserRole() const;
    Q_INVOKABLE bool login(const QString& username, const QString& password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool changePassword(const QString& oldPwd, const QString& newPwd);

    // ===== Dashboard =====
    QVariantMap dashboardStats() const;
    Q_INVOKABLE QVariantList monthlyCollections(int months = 6);
    Q_INVOKABLE QVariantList monthlyDonations(int months = 6);
    Q_INVOKABLE QVariantList monthlyExpenses(int months = 6);

    // ===== Families =====
    Q_INVOKABLE QVariantList searchFamilies(const QString& term, int page = 1, int pageSize = 50,
                                             const QString& statusFilter = QString(),
                                             const QString& wardFilter = QString());
    Q_INVOKABLE QVariantMap getFamily(qint64 id);
    Q_INVOKABLE qint64 createFamily(const QVariantMap& data);
    Q_INVOKABLE bool updateFamily(qint64 id, const QVariantMap& data);
    Q_INVOKABLE bool deleteFamily(qint64 id);
    Q_INVOKABLE int totalFamilies();
    Q_INVOKABLE int activeFamilies();
    QStringList wards() const;

    // ===== Members =====
    Q_INVOKABLE QVariantList searchMembers(const QString& term, int page = 1, int pageSize = 50,
                                            const QString& genderFilter = QString(),
                                            const QString& statusFilter = QString(),
                                            qint64 familyIdFilter = 0);
    Q_INVOKABLE QVariantMap getMember(qint64 id);
    Q_INVOKABLE QVariantList familyMembers(qint64 familyId);
    Q_INVOKABLE qint64 createMember(const QVariantMap& data);
    Q_INVOKABLE bool updateMember(qint64 id, const QVariantMap& data);
    Q_INVOKABLE bool deleteMember(qint64 id);
    Q_INVOKABLE int totalMembers();
    Q_INVOKABLE int activeMembers();
    Q_INVOKABLE bool setFamilyHead(qint64 familyId, qint64 memberId);

    // ===== Subscriptions =====
    Q_INVOKABLE QVariantList searchSubscriptions(const QString& term, int page = 1, int pageSize = 50,
                                                  qint64 familyId = 0, const QString& status = QString());
    Q_INVOKABLE qint64 createSubscription(const QVariantMap& data);
    Q_INVOKABLE bool updateSubscription(qint64 id, const QVariantMap& data);
    Q_INVOKABLE bool deleteSubscription(qint64 id);
    Q_INVOKABLE int markOverdueSubscriptions();
    Q_INVOKABLE QString nextSubscriptionReceiptNumber();

    // ===== Donations =====
    Q_INVOKABLE QVariantList searchDonations(const QString& term, int page = 1, int pageSize = 50,
                                              qint64 categoryId = 0,
                                              const QString& dateFrom = QString(),
                                              const QString& dateTo = QString());
    Q_INVOKABLE qint64 createDonation(const QVariantMap& data);
    Q_INVOKABLE bool updateDonation(qint64 id, const QVariantMap& data);
    Q_INVOKABLE bool deleteDonation(qint64 id);
    Q_INVOKABLE QString nextDonationReceiptNumber();
    QVariantList donationCategories() const;

    // ===== Accounting =====
    Q_INVOKABLE QVariantList searchTransactions(const QString& term, int page = 1, int pageSize = 50,
                                                 qint64 accountId = 0,
                                                 const QString& dateFrom = QString(),
                                                 const QString& dateTo = QString());
    Q_INVOKABLE qint64 createTransaction(const QVariantMap& data);
    Q_INVOKABLE bool updateTransaction(qint64 id, const QVariantMap& data);
    Q_INVOKABLE bool deleteTransaction(qint64 id);
    QVariantList accountingAccounts() const;

    // ===== Marriage / Death / Welfare =====
    Q_INVOKABLE QVariantList searchMarriages(const QString& term, int page = 1, int pageSize = 50);
    Q_INVOKABLE qint64 createMarriage(const QVariantMap& data);
    Q_INVOKABLE bool updateMarriage(qint64 id, const QVariantMap& data);
    Q_INVOKABLE bool deleteMarriage(qint64 id);

    Q_INVOKABLE QVariantList searchDeaths(const QString& term, int page = 1, int pageSize = 50);
    Q_INVOKABLE qint64 createDeath(const QVariantMap& data);
    Q_INVOKABLE bool updateDeath(qint64 id, const QVariantMap& data);
    Q_INVOKABLE bool deleteDeath(qint64 id);

    Q_INVOKABLE QVariantList searchWelfare(const QString& term, int page = 1, int pageSize = 50,
                                           const QString& status = QString());
    Q_INVOKABLE qint64 createWelfareRequest(const QVariantMap& data);
    Q_INVOKABLE bool updateWelfareRequest(qint64 id, const QVariantMap& data);
    Q_INVOKABLE bool approveWelfareRequest(qint64 id, double amount, const QString& remarks);
    Q_INVOKABLE bool rejectWelfareRequest(qint64 id, const QString& remarks);

    // ===== Certificates =====
    Q_INVOKABLE QVariantList searchCertificates(const QString& term, int page = 1, int pageSize = 50,
                                                 const QString& type = QString());
    Q_INVOKABLE qint64 issueCertificate(const QVariantMap& data);
    Q_INVOKABLE QString generateCertificatePdf(qint64 id);
    Q_INVOKABLE QString generateMarriageCertificatePdf(qint64 marriageId);
    Q_INVOKABLE QString generateDeathCertificatePdf(qint64 deathId);

    // ===== Tokens =====
    Q_INVOKABLE QVariantList searchTokenEvents(const QString& term = QString());
    Q_INVOKABLE qint64 createTokenEvent(const QVariantMap& data);
    Q_INVOKABLE bool updateTokenEvent(qint64 id, const QVariantMap& data);
    Q_INVOKABLE bool deleteTokenEvent(qint64 id);

    // ===== Users =====
    QVariantList users() const;
    Q_INVOKABLE qint64 createUser(const QString& username, const QString& fullName,
                                   const QString& password, const QString& role,
                                   const QString& email = QString(), const QString& phone = QString());
    Q_INVOKABLE bool updateUser(qint64 id, const QString& fullName, const QString& role,
                                const QString& email = QString(), const QString& phone = QString());
    Q_INVOKABLE bool deleteUser(qint64 id);
    Q_INVOKABLE bool unlockUser(qint64 id);
    Q_INVOKABLE bool resetUserPassword(qint64 id, const QString& newPwd);

    // ===== Audit Log =====
    Q_INVOKABLE QVariantList searchAuditLog(const QString& term, int page = 1, int pageSize = 50,
                                            const QString& module = QString());

    // ===== Backup =====
    Q_INVOKABLE QString createBackup();
    Q_INVOKABLE bool restoreBackup(const QString& zipPath);
    Q_INVOKABLE QVariantList listBackups();
    Q_INVOKABLE bool verifyBackup(const QString& zipPath);

    // ===== Reports =====
    Q_INVOKABLE bool exportReport(const QString& reportName, const QString& format,
                                  const QString& outputPath, const QVariantMap& params = QVariantMap());

    // ===== Settings =====
    Q_INVOKABLE QVariantMap getSettings();
    Q_INVOKABLE bool saveSettings(const QVariantMap& data);

    // ===== Subscription plans =====
    QVariantList subscriptionPlans() const;

signals:
    void lastErrorChanged();
    void currentUserChanged();
    void dashboardStatsChanged();
    void dataChanged();

private:
    QString lastError_;
    mms::FamilyService* familySvc_ = nullptr;
    mms::MemberService* memberSvc_ = nullptr;
    mms::DonationService* donationSvc_ = nullptr;
    mms::SubscriptionService* subscriptionSvc_ = nullptr;
    mms::AccountingService* accountingSvc_ = nullptr;
    mms::AuthService* authSvc_ = nullptr;          // QObject
    mms::BackupService* backupSvc_ = nullptr;      // QObject
    mms::CertificateService* certSvc_ = nullptr;
    mms::DashboardService* dashSvc_ = nullptr;
    mms::ReportService* reportSvc_ = nullptr;
    mms::SettingsService* settingsSvc_ = nullptr;  // QObject
    mms::TokenService* tokenSvc_ = nullptr;        // QObject
};
