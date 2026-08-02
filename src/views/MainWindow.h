/*
 * MainWindow.h - Main application shell with sidebar navigation
 */
#pragma once

#include <QMainWindow>
#include <QStackedWidget>
#include <QListWidget>
#include <QToolBar>
#include <QToolButton>
#include <QLabel>
#include <QLineEdit>
#include <QMenu>
#include <QPushButton>
#include <QSystemTrayIcon>
#include <QTimer>

namespace mms {

class LoginView;
class DashboardView;
class FamilyView;
class MemberView;
class SubscriptionView;
class DonationView;
class AccountingView;
class MarriageView;
class DeathView;
class WelfareView;
class CertificateView;
class ReportsView;
class SettingsView;
class AuditLogView;
class BackupView;
class UserManagementView;

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit MainWindow(QWidget* parent = nullptr);
    ~MainWindow() override;

    void showLogin();
    void showApp();

protected:
    void closeEvent(QCloseEvent* event) override;
    void resizeEvent(QResizeEvent* event) override;

private slots:
    void onNavItemChanged(int index);
    void onSearch();
    void onLogout();
    void onToggleTheme();
    void onToggleLanguage();
    void onToggleSidebar();
    void onChangePassword();
    void onBackup();
    void onAutoBackupTick();
    void onLanguageChanged(const QString& langCode);

private:
    void setupUi();
    void setupSidebar();
    QWidget* makeTopBar();
    void setupStatusBar();
    void setupViews();
    void applyTheme(const QString& theme);
    void updateUserMenu();
    void checkPermissions();
    void refreshAll();
    void retranslateUi();
    void applySidebarMode(bool collapsed);
    void repositionSidebarFlap();

    // Sidebar
    QWidget* sidebarWidget_ = nullptr;   // container (logo header + nav + bottom user card)
    QListWidget* navList_ = nullptr;
    QLabel* sidebarLogoLabel_ = nullptr;
    QLabel* sidebarAppName_ = nullptr;
    QLabel* sidebarAppSub_ = nullptr;
    QLabel* sidebarUserInitial_ = nullptr;
    QLabel* sidebarUserName_ = nullptr;
    QLabel* sidebarUserRole_ = nullptr;
    QPushButton* sidebarLogoutBtn_ = nullptr;
    QToolButton* sidebarToggleBtn_ = nullptr;
    bool sidebarCollapsed_ = false;

    // Top bar
    QWidget* topBar_ = nullptr;
    QLineEdit* searchEdit_ = nullptr;
    QLabel* crumbSmall_ = nullptr;
    QLabel* crumbBig_ = nullptr;
    QToolButton* userButton_ = nullptr;
    QToolButton* themeButton_ = nullptr;
    QToolButton* langButton_ = nullptr;
    QToolButton* backupButton_ = nullptr;

    // Center
    QStackedWidget* stack_ = nullptr;

    // Views
    LoginView* loginView_ = nullptr;
    DashboardView* dashboardView_ = nullptr;
    FamilyView* familyView_ = nullptr;
    MemberView* memberView_ = nullptr;
    SubscriptionView* subscriptionView_ = nullptr;
    DonationView* donationView_ = nullptr;
    AccountingView* accountingView_ = nullptr;
    MarriageView* marriageView_ = nullptr;
    DeathView* deathView_ = nullptr;
    WelfareView* welfareView_ = nullptr;
    CertificateView* certificateView_ = nullptr;
    ReportsView* reportsView_ = nullptr;
    SettingsView* settingsView_ = nullptr;
    AuditLogView* auditLogView_ = nullptr;
    BackupView* backupView_ = nullptr;
    UserManagementView* userMgmtView_ = nullptr;

    QTimer autoBackupTimer_;
    QString currentTheme_ = "light";
};

} // namespace mms
