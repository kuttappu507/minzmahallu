/*
 * MainWindow.cpp - Main application shell implementation
 *
 * Styling: All visual styling lives in resources/styles/light.qss and
 * dark.qss. Widgets are identified by object names (setObjectName) and
 * dynamic cssClass properties (set via StyleProps::set). No inline
 * setStyleSheet() calls anywhere in this file.
 */
#include "MainWindow.h"
#include "../core/Database.h"
#include "../core/Logger.h"
#include "../core/Config.h"
#include "../core/I18N.h"
#include "../core/FontManager.h"
#include "../core/IconUtils.h"
#include "../core/StyleProps.h"
#include "../core/ThemeColors.h"
#include "../services/AuthService.h"
#include "../services/AuthSession.h"
#include "../services/SettingsService.h"
#include "../services/BackupService.h"
#include "../repositories/UserRepository.h"
#include "../repositories/AuditLogRepository.h"

#include "LoginView.h"
#include "DashboardView.h"
#include "FamilyView.h"
#include "MemberView.h"
#include "SubscriptionView.h"
#include "DonationView.h"
#include "AccountingView.h"
#include "RegisterViews.h"
#include "OtherViews.h"

#include <QApplication>
#include <QCloseEvent>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QToolButton>
#include <QLineEdit>
#include <QLabel>
#include <QMessageBox>
#include <QAction>
#include <QActionGroup>
#include <QIcon>
#include <QStyle>
#include <QScreen>
#include <QGuiApplication>
#include <QInputDialog>
#include <QFileDialog>
#include <QStatusBar>
#include <QSettings>
#include <QSvgRenderer>
#include <QPainter>
#include <QListWidgetItem>
#include <QCursor>
#include <QToolTip>
#include <QComboBox>
#include <QResizeEvent>

namespace mms {

MainWindow::MainWindow(QWidget* parent) : QMainWindow(parent) {
    setWindowTitle("Minz Mahallu Management");
    setWindowIcon(QIcon(":/icons/mms_icon.png"));
    resize(1366, 768);
    setMinimumSize(1200, 700);

    setupUi();
    setupStatusBar();

    QScreen* screen = QGuiApplication::primaryScreen();
    if (screen) {
        QRect sg = screen->availableGeometry();
        move((sg.width() - width()) / 2, (sg.height() - height()) / 2);
    }

    currentTheme_ = SettingsService::instance().currentTheme();
    if (currentTheme_.isEmpty()) currentTheme_ = "light";
    applyTheme(currentTheme_);

    connect(&autoBackupTimer_, &QTimer::timeout, this, &MainWindow::onAutoBackupTick);
    if (Config::instance().autoBackupEnabled()) {
        int hours = Config::instance().autoBackupIntervalHours();
        autoBackupTimer_.start(std::max(1, hours) * 60 * 60 * 1000);
    }

    showLogin();
}

MainWindow::~MainWindow() = default;

QWidget* MainWindow::makeTopBar() {
    auto* bar = new QFrame(this);
    bar->setObjectName("topBar");
    bar->setFixedHeight(54);

    auto* layout = new QHBoxLayout(bar);
    layout->setContentsMargins(14, 8, 14, 8);
    layout->setSpacing(10);

    crumbSmall_ = new QLabel(bar);
    crumbSmall_->setText("MMS");
    StyleProps::set(crumbSmall_, "crumbSmall");
    layout->addWidget(crumbSmall_);

    crumbBig_ = new QLabel(bar);
    crumbBig_->setText(TR("nav_dashboard"));
    StyleProps::set(crumbBig_, "crumbBig");
    layout->addWidget(crumbBig_);

    layout->addStretch();

    searchEdit_ = new QLineEdit(bar);
    searchEdit_->setObjectName("searchBox");
    searchEdit_->setPlaceholderText(TR("search_placeholder"));
    searchEdit_->setClearButtonEnabled(true);
    searchEdit_->setMinimumHeight(36);
    searchEdit_->setMaximumWidth(320);
    connect(searchEdit_, &QLineEdit::returnPressed, this, &MainWindow::onSearch);
    layout->addWidget(searchEdit_, 1);

    themeButton_ = new QToolButton(bar);
    QString savedTheme = Config::instance().theme();
    themeButton_->setIcon(QIcon(icons::renderSvgIcon(savedTheme == "dark" ? ":/icons/sun.svg" : ":/icons/moon.svg", colors::topbarIconTint, 48)));
    themeButton_->setIconSize(QSize(22, 22));
    themeButton_->setToolTip(TR("action_toggle_theme"));
    themeButton_->setAutoRaise(true);
    themeButton_->setMinimumSize(38, 38);
    connect(themeButton_, &QToolButton::clicked, this, &MainWindow::onToggleTheme);
    layout->addWidget(themeButton_);

    langButton_ = new QToolButton(bar);
    QString curLang = I18N::instance().currentLanguage();
    langButton_->setText(curLang == "ml" ? "EN" : QString::fromUtf8("\xe0\xb4\xae\xe0\xb4\xb2"));
    langButton_->setToolTip(TR("action_toggle_language"));
    langButton_->setAutoRaise(true);
    langButton_->setMinimumSize(38, 38);
    connect(langButton_, &QToolButton::clicked, this, &MainWindow::onToggleLanguage);
    layout->addWidget(langButton_);

    backupButton_ = new QToolButton(bar);
    backupButton_->setIcon(QIcon(icons::renderSvgIcon(":/icons/backup.svg", colors::topbarIconTint, 48)));
    backupButton_->setIconSize(QSize(22, 22));
    backupButton_->setToolTip(TR("bak_create_now"));
    backupButton_->setAutoRaise(true);
    backupButton_->setMinimumSize(38, 38);
    connect(backupButton_, &QToolButton::clicked, this, &MainWindow::onBackup);
    layout->addWidget(backupButton_);

    userButton_ = new QToolButton(bar);
    userButton_->setPopupMode(QToolButton::InstantPopup);
    userButton_->setAutoRaise(true);
    userButton_->setToolButtonStyle(Qt::ToolButtonTextOnly);
    userButton_->setMinimumHeight(38);
    layout->addWidget(userButton_);

    return bar;
}

void MainWindow::setupUi() {
    auto* central = new QWidget(this);
    auto* outer = new QHBoxLayout(central);
    outer->setContentsMargins(0, 0, 0, 0);
    outer->setSpacing(0);

    setupSidebar();
    outer->addWidget(sidebarWidget_, 0);

    sidebarToggleBtn_ = new QToolButton(central);
    sidebarToggleBtn_->setObjectName("flap");
    sidebarToggleBtn_->setAutoRaise(false);
    sidebarToggleBtn_->setCursor(Qt::PointingHandCursor);
    sidebarToggleBtn_->setFixedSize(26, 62);
    sidebarToggleBtn_->setIcon(icons::renderSvgIcon(":/icons/chevron-left.svg", QColor("#ffffff"), 20));
    sidebarToggleBtn_->setIconSize(QSize(20, 20));
    sidebarToggleBtn_->setToolTip(TR("action_collapse_sidebar"));
    connect(sidebarToggleBtn_, &QToolButton::clicked, this, &MainWindow::onToggleSidebar);
    sidebarToggleBtn_->raise();
    sidebarToggleBtn_->hide();

    auto* rightCol = new QVBoxLayout();
    rightCol->setContentsMargins(0, 0, 0, 0);
    rightCol->setSpacing(0);

    rightCol->addWidget(makeTopBar());
    topBar_ = rightCol->itemAt(rightCol->count() - 1)->widget();

    stack_ = new QStackedWidget(this);
    rightCol->addWidget(stack_, 1);
    outer->addLayout(rightCol, 1);

    setCentralWidget(central);
    setupViews();
}

void MainWindow::setupSidebar() {
    sidebarWidget_ = new QFrame(this);
    sidebarWidget_->setObjectName("sidebar");
    sidebarWidget_->setFixedWidth(260);
    auto* sbLayout = new QVBoxLayout(sidebarWidget_);
    sbLayout->setContentsMargins(0, 0, 0, 0);
    sbLayout->setSpacing(0);

    auto* header = new QFrame(sidebarWidget_);
    auto* hLayout = new QVBoxLayout(header);
    hLayout->setContentsMargins(20, 22, 20, 18);
    hLayout->setSpacing(6);

    auto* logoRow = new QHBoxLayout();
    logoRow->setSpacing(12);
    sidebarLogoLabel_ = new QLabel(header);
    sidebarLogoLabel_->setFixedSize(64, 64);
    sidebarLogoLabel_->setAlignment(Qt::AlignCenter);
    QPixmap logoPix;
    if (QFile::exists(":/icons/mms_white.png")) logoPix.load(":/icons/mms_white.png");
    else if (QFile::exists(":/icons/mms.png")) logoPix.load(":/icons/mms.png");
    if (!logoPix.isNull())
        sidebarLogoLabel_->setPixmap(logoPix.scaled(64, 64, Qt::KeepAspectRatio, Qt::SmoothTransformation));
    else sidebarLogoLabel_->setText("");
    logoRow->addWidget(sidebarLogoLabel_);
    auto* titleCol = new QVBoxLayout();
    titleCol->setSpacing(1);
    sidebarAppName_ = new QLabel(header);
    StyleProps::set(sidebarAppName_, "logoTitle");
    sidebarAppName_->hide();
    sidebarAppSub_ = new QLabel(header);
    StyleProps::set(sidebarAppSub_, "logoSub");
    sidebarAppSub_->hide();
    titleCol->addWidget(sidebarAppName_);
    titleCol->addWidget(sidebarAppSub_);
    logoRow->addLayout(titleCol);
    logoRow->addStretch();
    hLayout->addLayout(logoRow);
    sbLayout->addWidget(header);

    navList_ = new QListWidget(sidebarWidget_);
    navList_->setObjectName("sidebarNav");
    navList_->setIconSize(QSize(22, 22));
    navList_->setFrameShape(QFrame::NoFrame);
    navList_->setFocusPolicy(Qt::NoFocus);
    navList_->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    connect(navList_, &QListWidget::currentRowChanged, this, &MainWindow::onNavItemChanged);
    sbLayout->addWidget(navList_, 1);

    auto* userCard = new QFrame(sidebarWidget_);
    userCard->setObjectName("userCard");
    auto* ucLayout = new QVBoxLayout(userCard);
    ucLayout->setContentsMargins(14, 14, 14, 14);
    ucLayout->setSpacing(10);

    auto* userRow = new QHBoxLayout();
    userRow->setSpacing(10);
    sidebarUserInitial_ = new QLabel("A", userCard);
    StyleProps::set(sidebarUserInitial_, "avatar");
    sidebarUserInitial_->setFixedSize(40, 40);
    sidebarUserInitial_->setAlignment(Qt::AlignCenter);
    userRow->addWidget(sidebarUserInitial_);
    auto* userInfo = new QVBoxLayout();
    userInfo->setSpacing(1);
    sidebarUserName_ = new QLabel("Administrator", userCard);
    StyleProps::set(sidebarUserName_, "userName");
    userInfo->addWidget(sidebarUserName_);
    sidebarUserRole_ = new QLabel("Administrator", userCard);
    StyleProps::set(sidebarUserRole_, "userRole");
    userInfo->addWidget(sidebarUserRole_);
    userRow->addLayout(userInfo);
    userRow->addStretch();
    ucLayout->addLayout(userRow);

    sidebarLogoutBtn_ = new QPushButton("Logout", userCard);
    StyleProps::set(sidebarLogoutBtn_, "primary");
    sidebarLogoutBtn_->setCursor(Qt::PointingHandCursor);
    connect(sidebarLogoutBtn_, &QPushButton::clicked, this, &MainWindow::onLogout);
    ucLayout->addWidget(sidebarLogoutBtn_);
    sbLayout->addWidget(userCard);

    sidebarWidget_->hide();
}

void MainWindow::setupStatusBar() {
    statusBar()->showMessage(TR("ui_success"));
    statusBar()->setSizeGripEnabled(false);
    auto* statusLabel = new QLabel("Minz Mahallu Management v" APP_VERSION_STR);
    statusBar()->addPermanentWidget(statusLabel);
}

void MainWindow::setupViews() {
    loginView_ = new LoginView(this);
    stack_->addWidget(loginView_);
    connect(loginView_, &LoginView::loginSuccessful, this, [this]() {
        showApp();
    });
}

void MainWindow::showLogin() {
    if (sidebarWidget_) sidebarWidget_->hide();
    if (sidebarToggleBtn_) sidebarToggleBtn_->hide();
    if (topBar_) topBar_->hide();
    stack_->setCurrentWidget(loginView_);
}

void MainWindow::showApp() {
    navList_->clear();
    if (dashboardView_)    stack_->removeWidget(dashboardView_);
    if (familyView_)      stack_->removeWidget(familyView_);
    if (memberView_)      stack_->removeWidget(memberView_);
    if (subscriptionView_)stack_->removeWidget(subscriptionView_);
    if (donationView_)    stack_->removeWidget(donationView_);
    if (accountingView_)  stack_->removeWidget(accountingView_);
    if (marriageView_)    stack_->removeWidget(marriageView_);
    if (deathView_)       stack_->removeWidget(deathView_);
    if (welfareView_)     stack_->removeWidget(welfareView_);
    if (certificateView_) stack_->removeWidget(certificateView_);
    if (reportsView_)     stack_->removeWidget(reportsView_);
    if (settingsView_)    stack_->removeWidget(settingsView_);
    if (auditLogView_)    stack_->removeWidget(auditLogView_);
    if (backupView_)      stack_->removeWidget(backupView_);
    if (userMgmtView_)    stack_->removeWidget(userMgmtView_);

    dashboardView_     = new DashboardView(this);
    familyView_        = new FamilyView(this);
    memberView_        = new MemberView(this);
    subscriptionView_  = new SubscriptionView(this);
    donationView_      = new DonationView(this);
    accountingView_    = new AccountingView(this);
    marriageView_      = new MarriageView(this);
    deathView_         = new DeathView(this);
    welfareView_       = new WelfareView(this);
    certificateView_   = new CertificateView(this);
    reportsView_       = new ReportsView(this);
    settingsView_      = new SettingsView(this);
    auditLogView_      = new AuditLogView(this);
    backupView_        = new BackupView(this);
    userMgmtView_      = new UserManagementView(this);

    auto& session = AuthSession::instance();

    struct NavEntry {
        QString title;
        QString iconPath;
        QWidget* view;
        QString module;
        QString action;
    };

    std::vector<NavEntry> entries = {
        {TR("nav_dashboard"),       ":/icons/dashboard.svg",      dashboardView_,    "dashboard",   "view"},
        {TR("nav_families"),        ":/icons/families.svg",       familyView_,       "family",      "view"},
        {TR("nav_members"),         ":/icons/members.svg",        memberView_,       "member",      "view"},
        {TR("nav_subscriptions"),   ":/icons/subscriptions.svg",  subscriptionView_, "subscription","view"},
        {TR("nav_donations"),       ":/icons/donations.svg",      donationView_,     "donation",    "view"},
        {TR("nav_accounting"),      ":/icons/accounting.svg",     accountingView_,   "accounting",  "view"},
        {TR("nav_marriage"),        ":/icons/marriage.svg",       marriageView_,     "marriage",    "view"},
        {TR("nav_death"),           ":/icons/death.svg",          deathView_,        "death",       "view"},
        {TR("nav_welfare"),         ":/icons/welfare.svg",        welfareView_,      "welfare",     "view"},
        {TR("nav_certificates"),    ":/icons/certificates.svg",   certificateView_,  "certificate", "view"},
        {TR("nav_reports"),         ":/icons/reports.svg",        reportsView_,      "report",      "view"},
        {TR("nav_settings"),        ":/icons/settings.svg",       settingsView_,     "settings",    "view"},
        {TR("nav_users"),           ":/icons/users.svg",          userMgmtView_,     "user",        "view"},
        {TR("nav_audit"),           ":/icons/audit.svg",          auditLogView_,     "audit",       "view"},
        {TR("nav_backup"),          ":/icons/backup.svg",         backupView_,       "backup",      "view"},
    };

    for (auto& e : entries) {
        bool allowed = (e.module == "dashboard" || e.module == "settings")
                     ? true
                     : (e.module == "user" || e.module == "audit" || e.module == "backup")
                        ? (session.user().role == "Administrator")
                        : session.hasPermission(e.module, e.action);
        if (!allowed) continue;
        QPixmap iconPix(48, 48);
        iconPix.fill(Qt::transparent);
        QSvgRenderer renderer(e.iconPath);
        if (renderer.isValid()) {
            QImage img(48, 48, QImage::Format_ARGB32);
            img.fill(Qt::transparent);
            QPainter hp(&img);
            hp.setRenderHint(QPainter::Antialiasing);
            hp.setRenderHint(QPainter::SmoothPixmapTransform);
            renderer.render(&hp, QRectF(0, 0, 48, 48));
            hp.end();
            for (int y = 0; y < img.height(); y++)
                for (int x = 0; x < img.width(); x++) {
                    int a = qAlpha(img.pixel(x, y));
                    if (a > 0) img.setPixel(x, y, qRgba(255, 255, 255, a));
                }
            iconPix = QPixmap::fromImage(img).scaled(24, 24, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        }
        auto* item = new QListWidgetItem(e.title, navList_);
        item->setIcon(QIcon(iconPix));
        item->setData(Qt::UserRole, QVariant::fromValue(static_cast<void*>(e.view)));
        stack_->addWidget(e.view);
    }

    navList_->show();
    if (sidebarWidget_) sidebarWidget_->show();
    if (topBar_) topBar_->show();
    searchEdit_->setVisible(true);
    navList_->setCurrentRow(0);
    sidebarCollapsed_ = false;
    applySidebarMode(false);
    if (sidebarToggleBtn_) { sidebarToggleBtn_->show(); sidebarToggleBtn_->raise(); repositionSidebarFlap(); }
    QList<QComboBox*> allCombos = findChildren<QComboBox*>();
    for (auto* c2 : allCombos) icons::applyComboShadow(c2);

    if (dashboardView_) {
        connect(dashboardView_, &DashboardView::navigateToView,
                this, [this](int index) {
            if (index >= 0 && index < navList_->count()) {
                navList_->setCurrentRow(index);
            }
        });
    }

    updateUserMenu();
    refreshAll();
}

void MainWindow::onNavItemChanged(int index) {
    if (index < 0) return;
    auto* item = navList_->item(index);
    if (!item) return;
    auto* view = static_cast<QWidget*>(item->data(Qt::UserRole).value<void*>());
    if (view) {
        stack_->setCurrentWidget(view);
        if (crumbBig_) crumbBig_->setText(item->text().simplified());
        statusBar()->showMessage(QString("Loaded: %1").arg(item->text().simplified()), 2000);
    }
}

void MainWindow::onSearch() {
    QString term = searchEdit_->text().trimmed();
    if (term.isEmpty()) return;

    QString results;
    QSqlQuery famQ = Database::instance().execute(
        "SELECT family_number, house_name, phone FROM families "
        "WHERE family_number LIKE ? OR house_name LIKE ? OR phone LIKE ? LIMIT 10",
        { "%" + term + "%", "%" + term + "%", "%" + term + "%" });
    int famCount = 0;
    while (famQ.next()) {
        results += QString(" Family %1 - %2 (%3)\n")
                       .arg(famQ.value(0).toString())
                       .arg(famQ.value(1).toString())
                       .arg(famQ.value(2).toString());
        ++famCount;
    }

    QSqlQuery memQ = Database::instance().execute(
        "SELECT member_code, name, mobile FROM members "
        "WHERE name LIKE ? OR member_code LIKE ? OR mobile LIKE ? LIMIT 10",
        { "%" + term + "%", "%" + term + "%", "%" + term + "%" });
    int memCount = 0;
    while (memQ.next()) {
        results += QString(" Member %1 - %2 (%3)\n")
                       .arg(memQ.value(0).toString())
                       .arg(memQ.value(1).toString())
                       .arg(memQ.value(2).toString());
        ++memCount;
    }

    if (results.isEmpty()) {
        QMessageBox::information(this, "Search Results", "No results found for: " + term);
    } else {
        QMessageBox::information(this, QString("Search Results (%1 families, %2 members)")
                                            .arg(famCount).arg(memCount),
                                 results);
    }
}

void MainWindow::onLogout() {
    AuthService auth;
    auth.logout();
    showLogin();
    statusBar()->showMessage("Logged out", 2000);
}

void MainWindow::onToggleTheme() {
    currentTheme_ = (currentTheme_ == "light") ? "dark" : "light";
    SettingsService::instance().applyTheme(currentTheme_);
    if (themeButton_) themeButton_->setIcon(QIcon(icons::renderSvgIcon(currentTheme_ == "dark" ? ":/icons/sun.svg" : ":/icons/moon.svg", colors::topbarIconTint, 48)));
    QSqlQuery q = Database::instance().execute(
        "UPDATE settings SET theme = ? WHERE id = 1", { currentTheme_ });
}

void MainWindow::onToggleLanguage() {
    QString newLang = (I18N::instance().currentLanguage() == "en") ? "ml" : "en";
    SettingsService::instance().setLanguage(newLang);
    onLanguageChanged(newLang);
}

void MainWindow::onLanguageChanged(const QString& langCode) {
    if (langButton_) langButton_->setText(langCode == "ml" ? "EN" : QString::fromUtf8("\xe0\xb4\xae\xe0\xb4\xb2"));
    if (searchEdit_) searchEdit_->setPlaceholderText(TR("search_placeholder"));
    setWindowTitle(langCode == "ml" ? QString::fromUtf8("\xe0\xb4\xae\xe0\xb4\xbf\xe0\xb5\xbb\xe0\xb4\xb8\xe0\xb5\x8d \xe0\xb4\xae\xe0\xb4\xb9\xe0\xb4\xb2\xe0\xb5\x8d\xe0\xb4\xb2\xe0\xb5\x8d \xe0\xb4\xae\xe0\xb4\xbe\xe0\xb4\xa8\xe0\xb5\x87\xe0\xb4\x9c\xe0\xb5\x8d\xe0\xb4\xae\xe0\xb5\x86\xe0\xb4\xa8\xe0\xb5\x8d\xe0\xb4\xb1\xe0\xb5\x8d") : "Minz Mahallu Management");

    int savedNavIndex = navList_ ? navList_->currentRow() : 0;
    bool wasCollapsed = sidebarCollapsed_;

    if (AuthSession::instance().isLoggedIn()) {
        showApp();
        if (savedNavIndex >= 0 && savedNavIndex < navList_->count()) navList_->setCurrentRow(savedNavIndex);
        if (wasCollapsed != sidebarCollapsed_) { sidebarCollapsed_ = wasCollapsed; applySidebarMode(wasCollapsed); }
    }
}

void MainWindow::retranslateUi() {
    if (navList_) {
        QStringList labels = {
            TR("nav_dashboard"), TR("nav_families"), TR("nav_members"),
            TR("nav_subscriptions"), TR("nav_donations"), TR("nav_accounting"),
            TR("nav_marriage"), TR("nav_death"), TR("nav_welfare"),
            TR("nav_certificates"), TR("nav_reports"), TR("nav_settings"),
            TR("nav_users"), TR("nav_audit"), TR("nav_backup"),
        };
        int n = (int)labels.size() < (int)navList_->count() ? (int)labels.size() : (int)navList_->count();
        for (int i = 0; i < n; ++i) {
            navList_->item(i)->setText(labels[i]);
        }
    }
    if (sidebarAppName_) sidebarAppName_->setText(TR("app_name"));
    if (sidebarAppSub_)  sidebarAppSub_->setText(TR("app_subtitle"));
    if (sidebarLogoutBtn_) sidebarLogoutBtn_->setText(TR("action_logout"));
    if (themeButton_) themeButton_->setToolTip(TR("action_toggle_theme"));
    if (langButton_) langButton_->setToolTip(TR("action_toggle_language"));
    if (backupButton_) backupButton_->setToolTip(TR("bak_create_now"));
    statusBar()->showMessage(TR("ui_success"));
}

void MainWindow::applyTheme(const QString& theme) {
    SettingsService::instance().applyTheme(theme);
    currentTheme_ = theme;
}

void MainWindow::updateUserMenu() {
    auto& s = AuthSession::instance();
    if (userButton_) {
        QString text = QString(" %1 (%2) ").arg(s.user().fullName).arg(s.user().role);
        userButton_->setText(text);
        auto* menu = new QMenu(this);
        menu->addAction("Change Password...", this, &MainWindow::onChangePassword);
        menu->addSeparator();
        menu->addAction("Toggle Theme", this, &MainWindow::onToggleTheme);
        menu->addSeparator();
        menu->addAction(" Logout", this, &MainWindow::onLogout);
        userButton_->setMenu(menu);
    }
    if (sidebarUserName_) {
        sidebarUserName_->setText(s.user().fullName.isEmpty() ? s.user().username : s.user().fullName);
    }
    if (sidebarUserRole_) {
        sidebarUserRole_->setText(s.user().role);
    }
    if (sidebarUserInitial_) {
        QString initial;
        QString nm = s.user().fullName.isEmpty() ? s.user().username : s.user().fullName;
        if (!nm.isEmpty()) initial = nm.at(0).toUpper();
        else initial = "U";
        sidebarUserInitial_->setText(initial);
    }
}

void MainWindow::onChangePassword() {
    ChangePasswordDialog dlg(this);
    if (dlg.exec() == QDialog::Accepted) {
        QMessageBox::information(this, "Password Changed",
                                 "Your password has been changed successfully.");
    }
}

void MainWindow::onBackup() {
    BackupService svc;
    QString err;
    QString path = svc.createBackup(&err);
    if (path.isEmpty()) {
        QMessageBox::warning(this, "Backup Failed", err);
    } else {
        QMessageBox::information(this, "Backup Created",
                                 "Backup created at:\n" + path);
    }
}

void MainWindow::onAutoBackupTick() {
    if (!AuthSession::instance().isLoggedIn()) return;
    BackupService svc;
    QString err;
    QString path = svc.createBackup(&err);
    if (!path.isEmpty()) {
        statusBar()->showMessage("Auto-backup completed: " + path, 5000);
        Logger::info("Auto-backup completed: " + path);
    }
}

void MainWindow::checkPermissions() {
    showApp();
}

void MainWindow::refreshAll() {
    if (dashboardView_) dashboardView_->refresh();
    if (familyView_)   familyView_->refresh();
    if (memberView_)   memberView_->refresh();
    if (subscriptionView_) subscriptionView_->refresh();
    if (donationView_) donationView_->refresh();
    if (accountingView_) accountingView_->refresh();
    if (marriageView_) marriageView_->refresh();
    if (deathView_)    deathView_->refresh();
    if (welfareView_)  welfareView_->refresh();
    if (certificateView_) certificateView_->refresh();
    if (reportsView_)  reportsView_->refresh();
    if (auditLogView_) auditLogView_->refresh();
    if (userMgmtView_) userMgmtView_->refresh();
}

void MainWindow::closeEvent(QCloseEvent* event) {
    if (AuthSession::instance().isLoggedIn()) {
        auto reply = QMessageBox::question(this, "Confirm Exit",
            "Are you sure you want to exit the Mahallu Management System?",
            QMessageBox::Yes | QMessageBox::No, QMessageBox::No);
        if (reply != QMessageBox::Yes) {
            event->ignore();
            return;
        }
        if (Config::instance().autoBackupEnabled()) {
            BackupService svc;
            QString err;
            svc.createBackup(&err);
        }
        AuthService auth;
        auth.logout();
    }
    Logger::info("Application shutting down");
    event->accept();
}

void MainWindow::onToggleSidebar() {
    sidebarCollapsed_ = !sidebarCollapsed_;
    applySidebarMode(sidebarCollapsed_);
}

void MainWindow::applySidebarMode(bool collapsed) {
    if (!sidebarWidget_) return;
    if (collapsed) {
        sidebarWidget_->setFixedWidth(80);
        if (sidebarAppName_) sidebarAppName_->hide();
        if (sidebarAppSub_) sidebarAppSub_->hide();
        if (sidebarLogoLabel_) sidebarLogoLabel_->setFixedSize(56, 56);
        if (sidebarUserName_) sidebarUserName_->hide();
        if (sidebarUserRole_) sidebarUserRole_->hide();
        if (sidebarLogoutBtn_) {
            sidebarLogoutBtn_->setText("");
            sidebarLogoutBtn_->setIcon(QIcon(icons::renderSvgIcon(":/icons/log-out.svg", colors::sidebarIconTint, 20)));
            sidebarLogoutBtn_->setIconSize(QSize(20, 20));
            sidebarLogoutBtn_->setFixedSize(48, 40);
            sidebarLogoutBtn_->setToolTip(TR("action_logout"));
        }
        if (navList_) for (int i = 0; i < navList_->count(); ++i) { auto* it = navList_->item(i); if (it) it->setText(""); }
        if (sidebarToggleBtn_) { sidebarToggleBtn_->setIcon(icons::renderSvgIcon(":/icons/chevron-right.svg", QColor("#ffffff"), 20)); sidebarToggleBtn_->setToolTip(TR("action_expand_sidebar")); }
    } else {
        sidebarWidget_->setFixedWidth(260);
        if (sidebarLogoLabel_) sidebarLogoLabel_->setFixedSize(64, 64);
        if (sidebarAppName_)   sidebarAppName_->show();
        if (sidebarAppSub_)    sidebarAppSub_->show();
        if (sidebarUserName_) sidebarUserName_->show();
        if (sidebarUserRole_) sidebarUserRole_->show();
        if (sidebarLogoutBtn_) {
            sidebarLogoutBtn_->setText(TR("action_logout"));
            sidebarLogoutBtn_->setIcon(QIcon());
            sidebarLogoutBtn_->setFixedSize(QWIDGETSIZE_MAX, QWIDGETSIZE_MAX);
            sidebarLogoutBtn_->setMinimumHeight(32);
        }
        retranslateUi();
        if (sidebarToggleBtn_) { sidebarToggleBtn_->setIcon(icons::renderSvgIcon(":/icons/chevron-left.svg", QColor("#ffffff"), 20)); sidebarToggleBtn_->setToolTip(TR("action_collapse_sidebar")); }
    }
    repositionSidebarFlap();
}

void MainWindow::repositionSidebarFlap() {
    if (!sidebarToggleBtn_ || !sidebarWidget_) return;
    // Center the flap vertically on the sidebar
    int x = sidebarWidget_->x() + sidebarWidget_->width() - 13;
    int y = (sidebarWidget_->height() - sidebarToggleBtn_->height()) / 2;
    sidebarToggleBtn_->move(x, y);
    sidebarToggleBtn_->raise();
}

void MainWindow::resizeEvent(QResizeEvent* e) {
    QMainWindow::resizeEvent(e);
    repositionSidebarFlap();
}

} // namespace mms
