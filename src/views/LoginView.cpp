/*
 * LoginView.cpp - Modern login with live language + theme toggle
 */
#include "LoginView.h"
#include "../services/AuthService.h"
#include "../services/SettingsService.h"
#include "../core/Logger.h"
#include "../core/I18N.h"
#include "../core/Config.h"
#include "../core/StyleProps.h"
#include "../core/ThemeColors.h"
#include "../core/IconUtils.h"

#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QFormLayout>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QToolButton>
#include <QFrame>
#include <QMessageBox>
#include <QShowEvent>
#include <QFile>
#include <QPixmap>

namespace mms {

LoginView::LoginView(QWidget* parent) : QWidget(parent) {
    setObjectName("loginRight");
    setupUi();
    retranslateUi();
}

void LoginView::setupUi() {
    auto* outer = new QVBoxLayout(this);
    outer->setAlignment(Qt::AlignCenter);
    outer->setContentsMargins(0, 0, 0, 0);

    // Top-right corner: theme + language toggles
    auto* cornerBar = new QHBoxLayout();
    cornerBar->setContentsMargins(16, 16, 16, 0);
    cornerBar->addStretch();

    themeButton_ = new QToolButton(this);
    themeButton_->setAutoRaise(true);
    themeButton_->setMinimumSize(40, 40);
    themeButton_->setCursor(Qt::PointingHandCursor);
    connect(themeButton_, &QToolButton::clicked, this, &LoginView::onToggleTheme);
    cornerBar->addWidget(themeButton_);

    langButton_ = new QPushButton(this);
    langButton_->setFlat(true);
    langButton_->setCursor(Qt::PointingHandCursor);
    langButton_->setMinimumSize(60, 36);
    
    connect(langButton_, &QPushButton::clicked, this, &LoginView::onToggleLanguage);
    cornerBar->addWidget(langButton_);

    outer->addLayout(cornerBar);
    outer->addStretch();

    // Login Card
    auto* card = new QFrame(this);
    card->setObjectName("loginCard");
    card->setFixedSize(480, 580);
    auto* cardLayout = new QVBoxLayout(card);
    cardLayout->setContentsMargins(44, 40, 44, 36);
    cardLayout->setSpacing(10);

    auto* logoLabel = new QLabel(card);
    logoLabel->setAlignment(Qt::AlignCenter);
    QPixmap logoPix;
    if (QFile::exists(":/icons/mms_icon.png")) logoPix.load(":/icons/mms_icon.png");
    else if (QFile::exists(":/icons/mms.png")) logoPix.load(":/icons/mms.png");
    if (!logoPix.isNull())
        logoLabel->setPixmap(logoPix.scaled(96, 96, Qt::KeepAspectRatio, Qt::SmoothTransformation));
    else logoLabel->setText("");
    cardLayout->addWidget(logoLabel);

    appNameLabel_ = new QLabel(card);
    StyleProps::set(appNameLabel_, "h1");
    appNameLabel_->setAlignment(Qt::AlignCenter);
    cardLayout->addWidget(appNameLabel_);

    appSubLabel_ = new QLabel(card);
    StyleProps::set(appSubLabel_, "viewSub");
    appSubLabel_->setAlignment(Qt::AlignCenter);
    cardLayout->addWidget(appSubLabel_);

    cardLayout->addSpacing(16);

    auto* form = new QFormLayout();
    form->setSpacing(10);
    form->setLabelAlignment(Qt::AlignRight);
    userRowLabel_ = new QLabel(card);
    usernameEdit_ = new QLineEdit(card);
    usernameEdit_->setMinimumHeight(40);
    form->addRow(userRowLabel_, usernameEdit_);
    passRowLabel_ = new QLabel(card);
    passwordEdit_ = new QLineEdit(card);
    passwordEdit_->setEchoMode(QLineEdit::Password);
    passwordEdit_->setMinimumHeight(40);
    form->addRow(passRowLabel_, passwordEdit_);
    cardLayout->addLayout(form);

    errorLabel_ = new QLabel(card);
    StyleProps::set(errorLabel_, "errorBox");
    errorLabel_->setWordWrap(true);
    errorLabel_->hide();
    cardLayout->addWidget(errorLabel_);

    cardLayout->addSpacing(8);

    loginButton_ = new QPushButton(card);
    StyleProps::set(loginButton_, "primary");
    loginButton_->setMinimumHeight(44);
    loginButton_->setDefault(true);
    loginButton_->setCursor(Qt::PointingHandCursor);
    cardLayout->addWidget(loginButton_);

    forgotButton_ = new QPushButton(card);
    forgotButton_->setFlat(true);
    forgotButton_->setCursor(Qt::PointingHandCursor);
    cardLayout->addWidget(forgotButton_, 0, Qt::AlignCenter);

    cardLayout->addStretch();

    hintLabel_ = new QLabel(card);
    hintLabel_->setAlignment(Qt::AlignCenter);
    StyleProps::set(hintLabel_, "loginHintCode");
    cardLayout->addWidget(hintLabel_);

    outer->addWidget(card, 0, Qt::AlignCenter);
    outer->addStretch();

    connect(loginButton_, &QPushButton::clicked, this, &LoginView::attemptLogin);
    connect(forgotButton_, &QPushButton::clicked, this, &LoginView::showForgotPassword);
    connect(passwordEdit_, &QLineEdit::returnPressed, this, &LoginView::attemptLogin);
}

void LoginView::retranslateUi() {
    QString curLang = I18N::instance().currentLanguage();
    appNameLabel_->setText(TR("app_name"));
    appSubLabel_->setText(TR("app_subtitle"));
    userRowLabel_->setText(TR("login_username"));
    passRowLabel_->setText(TR("login_password"));
    loginButton_->setText(TR("login_button"));
    forgotButton_->setText(TR("login_forgot"));
    hintLabel_->setText(TR("login_default_hint"));
    usernameEdit_->setPlaceholderText(TR("login_username"));
    passwordEdit_->setPlaceholderText(TR("login_password"));
    themeButton_->setToolTip(TR("action_toggle_theme"));
    langButton_->setText(curLang == "ml" ? "EN" : QString::fromUtf8("\xe0\xb4\xae\xe0\xb4\xb2"));
    }

void LoginView::onToggleLanguage() {
    QString newLang = (I18N::instance().currentLanguage() == "en") ? "ml" : "en";
    SettingsService::instance().setLanguage(newLang);
    retranslateUi();
    errorLabel_->hide();
    loginButton_->setEnabled(true);
}

void LoginView::onToggleTheme() {
    QString currentTheme = Config::instance().theme();
    QString newTheme = (currentTheme == "dark") ? "light" : "dark";
    SettingsService::instance().applyTheme(newTheme);
    if (themeButton_) themeButton_->setText(newTheme == "dark" ? "️" : "");
        qApp->processEvents();
}

void LoginView::attemptLogin() {
    QString username = usernameEdit_->text().trimmed();
    QString password = passwordEdit_->text();
    if (username.isEmpty() || password.isEmpty()) {
        errorLabel_->setText(TR("login_error_empty"));
        errorLabel_->show();
        return;
    }
    errorLabel_->hide();
    loginButton_->setEnabled(false);
    loginButton_->setText(TR("login_signing_in"));
    AuthService auth;
    auto result = auth.login(username, password);
    if (result.success) {
        Logger::info("Login successful for user: " + username);
        if (result.mustChangePassword)
            QMessageBox::information(this, TR("login_must_change"), TR("val_password_policy"));
        emit loginSuccessful();
    } else {
        errorLabel_->setText(result.errorMessage);
        errorLabel_->show();
        passwordEdit_->clear();
        passwordEdit_->setFocus();
    }
    loginButton_->setEnabled(true);
    loginButton_->setText(TR("login_button"));
}

void LoginView::showForgotPassword() {
    QMessageBox::information(this, TR("login_forgot"),
        "<h3>" + TR("login_forgot") + "</h3><p>" +
        (I18N::instance().currentLanguage() == "ml"
         ? "രഹസ്യവാക്ക് മറന്നെങ്കിൽ, ദയവായി മഹല്ല് അഡ്മിനിസ്ട്രേറ്ററെ സമീപിക്കുക."
         : "If you have forgotten your password, please contact the Mahallu Administrator.") + "</p>");
}

void LoginView::showEvent(QShowEvent* e) {
    QWidget::showEvent(e);
    usernameEdit_->clear();
    passwordEdit_->clear();
    errorLabel_->hide();
    usernameEdit_->setFocus();
    retranslateUi();
}

} // namespace mms
