/*
 * LoginView.h
 */
#pragma once
#include <QWidget>
#include <QShowEvent>

class QLineEdit;
class QLabel;
class QPushButton;
class QToolButton;

namespace mms {
class LoginView : public QWidget {
    Q_OBJECT
public:
    explicit LoginView(QWidget* parent = nullptr);
signals:
    void loginSuccessful();
private slots:
    void attemptLogin();
    void showForgotPassword();
    void onToggleLanguage();
    void onToggleTheme();
protected:
    void showEvent(QShowEvent* e) override;
private:
    void setupUi();
    void retranslateUi();
    void applyThemeStyles();
    QLineEdit* usernameEdit_ = nullptr;
    QLineEdit* passwordEdit_ = nullptr;
    QPushButton* loginButton_ = nullptr;
    QPushButton* forgotButton_ = nullptr;
    QPushButton* langButton_ = nullptr;
    QToolButton* themeButton_ = nullptr;
    QLabel* errorLabel_ = nullptr;
    QLabel* appNameLabel_ = nullptr;
    QLabel* appSubLabel_ = nullptr;
    QLabel* hintLabel_ = nullptr;
    QLabel* userRowLabel_ = nullptr;
    QLabel* passRowLabel_ = nullptr;
};
} // namespace mms
