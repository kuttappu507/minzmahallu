/*
 * CertificateView.h + ReportsView.h + SettingsView.h + AuditLogView.h
 * + BackupView.h + UserManagementView.h + ChangePasswordDialog.h
 *
 * Combined header for compactness. Each class is implemented in its own .cpp.
 */
#pragma once

#include <QWidget>
#include <QDialog>

class QTableWidget;
class QLineEdit;
class QComboBox;
class QDateEdit;
class QPushButton;
class QLabel;
class QTextEdit;
class QSpinBox;
class QCheckBox;

namespace mms {

class CertificateView : public QWidget {
    Q_OBJECT
public:
    explicit CertificateView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onIssueMembership();
    void onIssueResidence();
    void onIssueMarriage();
    void onIssueDeath();
    void onGenerate();
    void onDelete();
    void onExport();
private:
    void setupUi();
    void loadTable();
    QTableWidget* table_;
    QComboBox* typeFilter_;
    QDateEdit* fromDate_, *toDate_;
    QPushButton* issueMemBtn_, *issueResBtn_, *issueMarrBtn_, *issueDeathBtn_;
    QPushButton* generateBtn_, *deleteBtn_, *exportBtn_;
};

class ReportsView : public QWidget {
    Q_OBJECT
public:
    explicit ReportsView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onGenerate();
    void onExportCsv();
    void onExportPdf();
    void onExportExcel();
private:
    void setupUi();
    void loadReport();
    QComboBox* reportCombo_;
    QDateEdit* fromDate_, *toDate_;
    QTableWidget* table_;
    QPushButton* generateBtn_, *csvBtn_, *pdfBtn_, *excelBtn_;
};

class SettingsView : public QWidget {
    Q_OBJECT
public:
    explicit SettingsView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onSave();
    void onUploadLogo();
    void onUploadSeal();
private:
    void setupUi();
    void load();
    QLineEdit* nameEdit_, *phoneEdit_, *emailEdit_, *fyStartEdit_, *currencyEdit_;
    QLineEdit* receiptPrefixEdit_;
    QTextEdit* addressEdit_;
    QComboBox* themeCombo_;
    QSpinBox* backupIntervalSpin_;
    QCheckBox* autoBackupCheck_;
    QLabel* logoLabel_, *sealLabel_;
    QString logoPath_, sealPath_;
};

class AuditLogView : public QWidget {
    Q_OBJECT
public:
    explicit AuditLogView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onExport();
    void onNextPage();
    void onPrevPage();
private:
    void setupUi();
    void loadTable();
    QTableWidget* table_;
    QLineEdit* searchEdit_;
    QComboBox* actionFilter_, *moduleFilter_;
    QDateEdit* fromDate_, *toDate_;
    QPushButton* exportBtn_, *prevBtn_, *nextBtn_;
    QLabel* pageLabel_;
    int page_ = 1, pageSize_ = 50, total_ = 0;
};

class BackupView : public QWidget {
    Q_OBJECT
public:
    explicit BackupView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onBackup();
    void onRestore();
    void onVerify();
    void onDelete();
    void onPrune();
private:
    void setupUi();
    void loadTable();
    QTableWidget* table_;
    QPushButton* backupBtn_, *restoreBtn_, *verifyBtn_, *deleteBtn_, *pruneBtn_;
};

class UserManagementView : public QWidget {
    Q_OBJECT
public:
    explicit UserManagementView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onAdd();
    void onEdit();
    void onDelete();
    void onUnlock();
    void onResetPassword();
private:
    void setupUi();
    void loadTable();
    QTableWidget* table_;
    QPushButton* addBtn_, *editBtn_, *deleteBtn_, *unlockBtn_, *resetBtn_;
};

class ChangePasswordDialog : public QDialog {
    Q_OBJECT
public:
    explicit ChangePasswordDialog(QWidget* parent = nullptr);
private slots:
    void onChange();
private:
    void setupUi();
    QLineEdit* oldEdit_, *newEdit_, *confirmEdit_;
    QLabel* strengthLabel_;
};

} // namespace mms
