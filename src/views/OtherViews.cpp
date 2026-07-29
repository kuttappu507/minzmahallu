/*
 * OtherViews.cpp - Implementations for Certificate, Reports, Settings,
 * AuditLog, Backup, UserManagement views, and ChangePasswordDialog
 */
#include "OtherViews.h"
#include "../services/CertificateService.h"
#include "../services/ReportService.h"
#include "../services/SettingsService.h"
#include "../services/AuthService.h"
#include "../services/BackupService.h"
#include "../services/AuthSession.h"
#include "../services/MemberService.h"
#include "../services/FamilyService.h"
#include "../repositories/CertificateRepository.h"
#include "../repositories/UserRepository.h"
#include "../repositories/AuditLogRepository.h"
#include "../repositories/MemberRepository.h"
#include "../repositories/FamilyRepository.h"
#include "../repositories/MarriageRepository.h"
#include "../repositories/DeathRepository.h"
#include "../core/Database.h"
#include "../core/Security.h"
#include "../core/Config.h"

#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QComboBox>
#include <QDateEdit>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QGroupBox>
#include <QFormLayout>
#include <QTextEdit>
#include <QSpinBox>
#include <QCheckBox>
#include <QDialogButtonBox>
#include <QMessageBox>
#include <QFileDialog>
#include <QDesktopServices>
#include <QUrl>
#include <QInputDialog>
#include <QPixmap>
#include <QFrame>
#include <QScrollArea>
#include "../core/I18N.h"

namespace mms {

// ============================================================================
// CertificateView
// ============================================================================
CertificateView::CertificateView(QWidget* parent) : QWidget(parent) {
    setupUi(); refresh();
}
void CertificateView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(new QLabel(TR("cert_title"), this));

    auto* bb = new QHBoxLayout();
    issueMemBtn_ = new QPushButton(TR("cert_membership"), this);
    issueMemBtn_->setObjectName("action_add");
    issueResBtn_ = new QPushButton(TR("cert_residence"), this);
    issueResBtn_->setObjectName("action_edit");
    issueMarrBtn_ = new QPushButton(TR("cert_marriage"), this);
    issueMarrBtn_->setObjectName("action_print");
    issueDeathBtn_ = new QPushButton(TR("cert_death"), this);
    issueDeathBtn_->setObjectName("action_export");
    generateBtn_ = new QPushButton("Generate PDF", this);
    generateBtn_->setObjectName("action_generate");
    deleteBtn_ = new QPushButton(TR("action_delete"), this);
    deleteBtn_->setObjectName("action_delete");
    exportBtn_ = new QPushButton("Export List", this);
    exportBtn_->setObjectName("action_export");
    for (auto* b : {issueMemBtn_, issueResBtn_, issueMarrBtn_, issueDeathBtn_,
                    generateBtn_, deleteBtn_, exportBtn_}) {
        b->setMinimumHeight(32); bb->addWidget(b);
    }
    bb->addStretch();
    layout->addLayout(bb);

    auto* fb = new QHBoxLayout();
    typeFilter_ = new QComboBox(this);
    typeFilter_->addItems({"", "Membership", "Residence", "Marriage", "Death", "Character", "Income"});
    typeFilter_->setMinimumHeight(32);
    connect(typeFilter_, &QComboBox::currentTextChanged, this, [this]{ refresh(); });
    fromDate_ = new QDateEdit(QDate::currentDate().addMonths(-12), this);
    fromDate_->setCalendarPopup(true); fromDate_->setDisplayFormat("yyyy-MM-dd");
    toDate_ = new QDateEdit(QDate::currentDate(), this);
    toDate_->setCalendarPopup(true); toDate_->setDisplayFormat("yyyy-MM-dd");
    connect(fromDate_, &QDateEdit::dateChanged, this, [this]{ refresh(); });
    connect(toDate_, &QDateEdit::dateChanged, this, [this]{ refresh(); });
    fb->addWidget(new QLabel("Type:", this));
    fb->addWidget(typeFilter_);
    fb->addWidget(new QLabel("From:", this));
    fb->addWidget(fromDate_);
    fb->addWidget(new QLabel("To:", this));
    fb->addWidget(toDate_);
    fb->addStretch();
    layout->addLayout(fb);

    table_ = new QTableWidget(this);
    table_->setColumnCount(6);
    table_->setHorizontalHeaderLabels({"ID","Cert No","Type","Issued To","Date","Issued By"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    layout->addWidget(table_, 1);

    connect(issueMemBtn_, &QPushButton::clicked, this, &CertificateView::onIssueMembership);
    connect(issueResBtn_, &QPushButton::clicked, this, &CertificateView::onIssueResidence);
    connect(issueMarrBtn_, &QPushButton::clicked, this, &CertificateView::onIssueMarriage);
    connect(issueDeathBtn_, &QPushButton::clicked, this, &CertificateView::onIssueDeath);
    connect(generateBtn_, &QPushButton::clicked, this, &CertificateView::onGenerate);
    connect(deleteBtn_, &QPushButton::clicked, this, &CertificateView::onDelete);
    connect(exportBtn_, &QPushButton::clicked, this, &CertificateView::onExport);
}
void CertificateView::refresh() { loadTable(); }
void CertificateView::loadTable() {
    CertificateService svc;
    int total;
    auto items = svc.list(1, 200, typeFilter_->currentText(),
                          fromDate_->date().toString(Qt::ISODate),
                          toDate_->date().toString(Qt::ISODate), &total);
    table_->setRowCount(0);
    for (const auto& c : items) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(QString::number(c.id)));
        table_->setItem(r, 1, new QTableWidgetItem(c.certificateNumber));
        table_->setItem(r, 2, new QTableWidgetItem(c.type));
        table_->setItem(r, 3, new QTableWidgetItem(c.issuedTo));
        table_->setItem(r, 4, new QTableWidgetItem(c.issuedDate));
        table_->setItem(r, 5, new QTableWidgetItem(c.issuedByName));
    }
}

void CertificateView::onIssueMembership() {
    bool ok = false;
    QString memberCode = QInputDialog::getText(this, "Membership Certificate",
        "Enter member code (e.g. MEM-0001):", QLineEdit::Normal, "", &ok);
    if (!ok || memberCode.isEmpty()) return;
    MemberService ms;
    MemberRepository mrepo;
    auto m = mrepo.findByCode(memberCode);
    if (!m) { QMessageBox::warning(this, "Not Found", "Member not found."); return; }
    Certificate c;
    c.type = "Membership";
    c.memberId = m->id;
    c.familyId = m->familyId;
    c.issuedTo = m->name;
    c.issuedDate = QDate::currentDate().toString(Qt::ISODate);
    CertificateService svc;
    QString err;
    qint64 id = svc.issueCertificate(c, &err);
    if (id > 0) {
        QString path = svc.generatePdf(id, &err);
        if (!path.isEmpty()) QDesktopServices::openUrl(QUrl::fromLocalFile(path));
        refresh();
    } else QMessageBox::warning(this, "Failed", err);
}

void CertificateView::onIssueResidence() {
    bool ok = false;
    QString famNo = QInputDialog::getText(this, "Residence Certificate",
        "Enter family number (e.g. FAM-0001):", QLineEdit::Normal, "", &ok);
    if (!ok || famNo.isEmpty()) return;
    FamilyRepository frepo;
    auto f = frepo.findByNumber(famNo);
    if (!f) { QMessageBox::warning(this, "Not Found", "Family not found."); return; }
    QString head = QInputDialog::getText(this, "Residence Certificate", "Issued to (name):");
    Certificate c;
    c.type = "Residence";
    c.familyId = f->id;
    c.issuedTo = head.isEmpty() ? f->houseName : head;
    c.issuedDate = QDate::currentDate().toString(Qt::ISODate);
    CertificateService svc;
    QString err;
    qint64 id = svc.issueCertificate(c, &err);
    if (id > 0) {
        QString path = svc.generatePdf(id, &err);
        if (!path.isEmpty()) QDesktopServices::openUrl(QUrl::fromLocalFile(path));
        refresh();
    } else QMessageBox::warning(this, "Failed", err);
}

void CertificateView::onIssueMarriage() {
    bool ok = false;
    QString num = QInputDialog::getText(this, "Marriage Certificate",
        "Enter marriage number (e.g. MRG-2024-001):", QLineEdit::Normal, "", &ok);
    if (!ok || num.isEmpty()) return;
    MarriageRepository mrepo;
    auto m = mrepo.findByNumber(num);
    if (!m) { QMessageBox::warning(this, "Not Found", "Marriage record not found."); return; }
    QString path = CertificateService().generateMarriageCertificatePdf(m->id);
    if (!path.isEmpty()) QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    refresh();
}

void CertificateView::onIssueDeath() {
    bool ok = false;
    QString num = QInputDialog::getText(this, "Death Certificate",
        "Enter death number (e.g. DTH-2024-001):", QLineEdit::Normal, "", &ok);
    if (!ok || num.isEmpty()) return;
    DeathRepository drepo;
    auto d = drepo.findByNumber(num);
    if (!d) { QMessageBox::warning(this, "Not Found", "Death record not found."); return; }
    QString path = CertificateService().generateDeathCertificatePdf(d->id);
    if (!path.isEmpty()) QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    refresh();
}

void CertificateView::onGenerate() {
    int r = table_->currentRow();
    if (r < 0) { QMessageBox::warning(this, "Generate", "Select a certificate first."); return; }
    qint64 id = table_->item(r, 0)->text().toLongLong();
    CertificateService svc;
    QString err;
    QString path = svc.generatePdf(id, &err);
    if (!path.isEmpty()) QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    else QMessageBox::warning(this, "Failed", err);
}

void CertificateView::onDelete() {
    int r = table_->currentRow();
    if (r < 0) return;
    if (QMessageBox::question(this, "Delete", "Delete this certificate record?") == QMessageBox::Yes) {
        CertificateRepository repo;
        repo.remove(table_->item(r, 0)->text().toLongLong());
        refresh();
    }
}

void CertificateView::onExport() {
    QString path = QFileDialog::getSaveFileName(this, "Export Certificate List",
        "certificates.csv", "CSV (*.csv)");
    if (path.isEmpty()) return;
    CertificateService svc;
    int total;
    auto items = svc.list(1, 10000, typeFilter_->currentText(),
                          fromDate_->date().toString(Qt::ISODate),
                          toDate_->date().toString(Qt::ISODate), &total);
    QFile f(path);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) return;
    QTextStream out(&f);
    out << "Cert No,Type,Issued To,Date,Issued By\n";
    for (const auto& c : items) {
        out << c.certificateNumber << "," << c.type << "," << c.issuedTo << ","
            << c.issuedDate << "," << c.issuedByName << "\n";
    }
    f.close();
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}

// ============================================================================
// ReportsView
// ============================================================================
ReportsView::ReportsView(QWidget* parent) : QWidget(parent) {
    setupUi(); refresh();
}
void ReportsView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(new QLabel(TR("rpt_title"), this));

    auto* fb = new QHBoxLayout();
    reportCombo_ = new QComboBox(this);
    reportCombo_->addItems({
        "Family Register", "Member Register", "Active Members", "Family Directory",
        "Subscription Report", "Defaulters Report", "Donation Report",
        "Income Report", "Expense Report", "Cash Book Report",
        "Financial Summary", "Marriage Register Report",
        "Death Register Report", "Welfare Report"
    });
    reportCombo_->setMinimumHeight(32);
    fromDate_ = new QDateEdit(QDate::currentDate().addMonths(-3), this);
    fromDate_->setCalendarPopup(true); fromDate_->setDisplayFormat("yyyy-MM-dd");
    toDate_ = new QDateEdit(QDate::currentDate(), this);
    toDate_->setCalendarPopup(true); toDate_->setDisplayFormat("yyyy-MM-dd");
    connect(fromDate_, &QDateEdit::dateChanged, this, [this]{ refresh(); });
    connect(toDate_, &QDateEdit::dateChanged, this, [this]{ refresh(); });
    connect(reportCombo_, &QComboBox::currentTextChanged, this, [this]{ refresh(); });
    fb->addWidget(new QLabel("Report:", this));
    fb->addWidget(reportCombo_);
    fb->addWidget(new QLabel("From:", this));
    fb->addWidget(fromDate_);
    fb->addWidget(new QLabel("To:", this));
    fb->addWidget(toDate_);
    fb->addStretch();
    layout->addLayout(fb);

    auto* bb = new QHBoxLayout();
    generateBtn_ = new QPushButton(TR("rpt_generate"), this);
    csvBtn_ = new QPushButton(TR("rpt_generate"), this);
    csvBtn_->setObjectName("action_export");
    pdfBtn_ = new QPushButton(TR("rpt_generate"), this);
    pdfBtn_->setObjectName("action_print");
    excelBtn_ = new QPushButton(TR("rpt_generate"), this);
    excelBtn_->setObjectName("action_export");
    for (auto* b : {generateBtn_, csvBtn_, pdfBtn_, excelBtn_}) {
        b->setMinimumHeight(32); bb->addWidget(b);
    }
    bb->addStretch();
    layout->addLayout(bb);

    table_ = new QTableWidget(this);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setAlternatingRowColors(true);
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    layout->addWidget(table_, 1);

    connect(generateBtn_, &QPushButton::clicked, this, &ReportsView::onGenerate);
    connect(csvBtn_, &QPushButton::clicked, this, &ReportsView::onExportCsv);
    connect(pdfBtn_, &QPushButton::clicked, this, &ReportsView::onExportPdf);
    connect(excelBtn_, &QPushButton::clicked, this, &ReportsView::onExportExcel);
}
void ReportsView::refresh() { loadReport(); }

void ReportsView::loadReport() {
    ReportService svc;
    QString from = fromDate_->date().toString(Qt::ISODate);
    QString to = toDate_->date().toString(Qt::ISODate);
    QString sel = reportCombo_->currentText();
    ReportService::ReportRow row;

    if (sel == "Family Register") row = svc.familyRegister();
    else if (sel == "Member Register") row = svc.memberRegister();
    else if (sel == "Active Members") row = svc.activeMembers();
    else if (sel == "Family Directory") row = svc.familyDirectory();
    else if (sel == "Subscription Report") row = svc.subscriptionReport(from, to);
    else if (sel == "Defaulters Report") row = svc.defaultersReport();
    else if (sel == "Donation Report") row = svc.donationReport(from, to);
    else if (sel == "Income Report") row = svc.incomeReport(from, to);
    else if (sel == "Expense Report") row = svc.expenseReport(from, to);
    else if (sel == "Cash Book Report") row = svc.cashBookReport(from, to);
    else if (sel == "Financial Summary") row = svc.financialSummary(from, to);
    else if (sel == "Marriage Register Report") row = svc.marriageRegisterReport(from, to);
    else if (sel == "Death Register Report") row = svc.deathRegisterReport(from, to);
    else if (sel == "Welfare Report") row = svc.welfareReport(from, to);

    table_->setColumnCount(row.headers.size());
    table_->setHorizontalHeaderLabels(row.headers);
    table_->setRowCount(row.rowCount);
    for (int r = 0; r < row.rowCount; ++r) {
        for (int c = 0; c < row.headers.size(); ++c) {
            table_->setItem(r, c, new QTableWidgetItem(row.cell(r, c).toString()));
        }
    }
}

void ReportsView::onGenerate() { refresh(); }

void ReportsView::onExportCsv() {
    QString path = QFileDialog::getSaveFileName(this, "Export CSV",
        reportCombo_->currentText().toLower().replace(' ', '_') + ".csv", "CSV (*.csv)");
    if (path.isEmpty()) return;
    ReportService svc;
    QString from = fromDate_->date().toString(Qt::ISODate);
    QString to = toDate_->date().toString(Qt::ISODate);
    QString sel = reportCombo_->currentText();
    ReportService::ReportRow row;
    if (sel == "Family Register") row = svc.familyRegister();
    else if (sel == "Member Register") row = svc.memberRegister();
    else if (sel == "Subscription Report") row = svc.subscriptionReport(from, to);
    else if (sel == "Defaulters Report") row = svc.defaultersReport();
    else if (sel == "Donation Report") row = svc.donationReport(from, to);
    else if (sel == "Income Report") row = svc.incomeReport(from, to);
    else if (sel == "Expense Report") row = svc.expenseReport(from, to);
    else if (sel == "Cash Book Report") row = svc.cashBookReport(from, to);
    else if (sel == "Financial Summary") row = svc.financialSummary(from, to);
    else if (sel == "Marriage Register Report") row = svc.marriageRegisterReport(from, to);
    else if (sel == "Death Register Report") row = svc.deathRegisterReport(from, to);
    else if (sel == "Welfare Report") row = svc.welfareReport(from, to);
    else row = svc.familyRegister();

    svc.exportToCsv(row, path);
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}

void ReportsView::onExportPdf() {
    ReportService svc;
    QString from = fromDate_->date().toString(Qt::ISODate);
    QString to = toDate_->date().toString(Qt::ISODate);
    QString sel = reportCombo_->currentText();
    ReportService::ReportRow row;
    if (sel == "Family Register") row = svc.familyRegister();
    else if (sel == "Subscription Report") row = svc.subscriptionReport(from, to);
    else if (sel == "Donation Report") row = svc.donationReport(from, to);
    else if (sel == "Cash Book Report") row = svc.cashBookReport(from, to);
    else if (sel == "Financial Summary") row = svc.financialSummary(from, to);
    else if (sel == "Defaulters Report") row = svc.defaultersReport();
    else row = svc.familyRegister();

    QString path = svc.ensureExportPath(sel.toLower().replace(' ', '_') + ".pdf");
    if (!svc.exportToPdf(row, sel, path, from, to).isEmpty())
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}

void ReportsView::onExportExcel() {
    QString path = QFileDialog::getSaveFileName(this, "Export Excel",
        reportCombo_->currentText().toLower().replace(' ', '_') + ".csv", "Excel-compatible CSV (*.csv)");
    if (path.isEmpty()) return;
    ReportService svc;
    QString from = fromDate_->date().toString(Qt::ISODate);
    QString to = toDate_->date().toString(Qt::ISODate);
    QString sel = reportCombo_->currentText();
    ReportService::ReportRow row;
    if (sel == "Family Register") row = svc.familyRegister();
    else if (sel == "Subscription Report") row = svc.subscriptionReport(from, to);
    else if (sel == "Donation Report") row = svc.donationReport(from, to);
    else if (sel == "Cash Book Report") row = svc.cashBookReport(from, to);
    else if (sel == "Defaulters Report") row = svc.defaultersReport();
    else row = svc.familyRegister();
    svc.exportToExcel(row, sel, path);
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}

// ============================================================================
// SettingsView
// ============================================================================
SettingsView::SettingsView(QWidget* parent) : QWidget(parent) {
    setupUi(); load();
}
void SettingsView::setupUi() {
    auto* scroll = new QScrollArea(this);
    scroll->setWidgetResizable(true);
    auto* content = new QWidget(scroll);
    auto* layout = new QVBoxLayout(content);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);

    layout->addWidget(new QLabel(TR("set_title"), content));

    auto* orgGroup = new QGroupBox("Mahallu Organization", content);
    auto* of = new QFormLayout(orgGroup);
    nameEdit_ = new QLineEdit(content);
    addressEdit_ = new QTextEdit(content); addressEdit_->setMaximumHeight(70);
    phoneEdit_ = new QLineEdit(content);
    emailEdit_ = new QLineEdit(content);
    fyStartEdit_ = new QLineEdit(content);
    fyStartEdit_->setPlaceholderText("MM-DD (e.g. 04-01 for April 1)");
    currencyEdit_ = new QLineEdit(content);
    currencyEdit_->setText(QString::fromUtf8("₹"));
    receiptPrefixEdit_ = new QLineEdit(content);

    of->addRow("Mahallu Name:", nameEdit_);
    of->addRow(TR("family_address") + ":", addressEdit_);
    of->addRow(TR("family_phone") + ":", phoneEdit_);
    of->addRow(TR("member_email") + ":", emailEdit_);
    of->addRow("Financial Year Start:", fyStartEdit_);
    of->addRow("Currency Symbol:", currencyEdit_);
    of->addRow("Receipt Prefix:", receiptPrefixEdit_);
    layout->addWidget(orgGroup);

    auto* logoGroup = new QGroupBox("Logo & Seal", content);
    auto* lf = new QFormLayout(logoGroup);
    auto* logoRow = new QHBoxLayout();
    logoLabel_ = new QLabel(content);
    logoLabel_->setFixedSize(80, 80);
    logoLabel_->setAlignment(Qt::AlignCenter);
    logoLabel_->setText("Logo");
    auto* logoBtn = new QPushButton("Upload Logo", content);
    logoBtn->setObjectName("action_upload");
    connect(logoBtn, &QPushButton::clicked, this, &SettingsView::onUploadLogo);
    logoRow->addWidget(logoLabel_);
    logoRow->addWidget(logoBtn);
    logoRow->addStretch();
    lf->addRow("Logo:", logoRow);

    auto* sealRow = new QHBoxLayout();
    sealLabel_ = new QLabel(content);
    sealLabel_->setFixedSize(80, 80);
    sealLabel_->setAlignment(Qt::AlignCenter);
    sealLabel_->setText("Seal");
    auto* sealBtn = new QPushButton("Upload Seal", content);
    sealBtn->setObjectName("action_upload");
    connect(sealBtn, &QPushButton::clicked, this, &SettingsView::onUploadSeal);
    sealRow->addWidget(sealLabel_);
    sealRow->addWidget(sealBtn);
    sealRow->addStretch();
    lf->addRow("Seal:", sealRow);
    layout->addWidget(logoGroup);

    auto* uiGroup = new QGroupBox("User Interface", content);
    auto* uf = new QFormLayout(uiGroup);
    themeCombo_ = new QComboBox(content);
    themeCombo_->addItems({"light", "dark"});
    uf->addRow("Theme:", themeCombo_);
    layout->addWidget(uiGroup);

    auto* backupGroup = new QGroupBox("Backup", content);
    auto* bf = new QFormLayout(backupGroup);
    autoBackupCheck_ = new QCheckBox("Enable automatic backup", content);
    backupIntervalSpin_ = new QSpinBox(content);
    backupIntervalSpin_->setRange(1, 168);
    backupIntervalSpin_->setSuffix(" hours");
    bf->addRow("Auto Backup:", autoBackupCheck_);
    bf->addRow("Interval:", backupIntervalSpin_);
    layout->addWidget(backupGroup);

    auto* saveBtn = new QPushButton("Save Settings", content);
    saveBtn->setMinimumHeight(36);
    connect(saveBtn, &QPushButton::clicked, this, &SettingsView::onSave);
    layout->addWidget(saveBtn);

    layout->addStretch();
    scroll->setWidget(content);

    auto* outerLayout = new QVBoxLayout(this);
    outerLayout->setContentsMargins(0, 0, 0, 0);
    outerLayout->addWidget(scroll);
}
void SettingsView::load() {
    auto s = SettingsService::instance().load();
    nameEdit_->setText(s.mahalluName);
    addressEdit_->setPlainText(s.address);
    phoneEdit_->setText(s.phone);
    emailEdit_->setText(s.email);
    fyStartEdit_->setText(s.financialYearStart);
    currencyEdit_->setText(s.currencySymbol);
    receiptPrefixEdit_->setText(s.receiptPrefix);
    themeCombo_->setCurrentText(s.theme);
    autoBackupCheck_->setChecked(s.autoBackup);
    backupIntervalSpin_->setValue(s.backupIntervalHours);
    logoPath_ = s.logoPath;
    sealPath_ = s.sealPath;
    if (!logoPath_.isEmpty() && QFile::exists(logoPath_)) {
        QPixmap p(logoPath_);
        logoLabel_->setPixmap(p.scaled(80, 80, Qt::KeepAspectRatio, Qt::SmoothTransformation));
    }
    if (!sealPath_.isEmpty() && QFile::exists(sealPath_)) {
        QPixmap p(sealPath_);
        sealLabel_->setPixmap(p.scaled(80, 80, Qt::KeepAspectRatio, Qt::SmoothTransformation));
    }
}
void SettingsView::onSave() {
    MahalluSettings s;
    s.mahalluName = nameEdit_->text().trimmed();
    s.address = addressEdit_->toPlainText().trimmed();
    s.phone = phoneEdit_->text().trimmed();
    s.email = emailEdit_->text().trimmed();
    s.financialYearStart = fyStartEdit_->text().trimmed();
    s.currencySymbol = currencyEdit_->text().trimmed();
    s.receiptPrefix = receiptPrefixEdit_->text().trimmed();
    s.theme = themeCombo_->currentText();
    s.autoBackup = autoBackupCheck_->isChecked();
    s.backupIntervalHours = backupIntervalSpin_->value();
    s.logoPath = logoPath_;
    s.sealPath = sealPath_;

    if (SettingsService::instance().save(s)) {
        SettingsService::instance().applyTheme(s.theme);
        QMessageBox::information(this, "Saved", "Settings saved successfully.");
    } else {
        QMessageBox::warning(this, "Save Failed", "Could not save settings.");
    }
}
void SettingsView::onUploadLogo() {
    QString path = QFileDialog::getOpenFileName(this, "Select Logo",
        QString(), "Images (*.png *.jpg *.jpeg *.bmp)");
    if (path.isEmpty()) return;
    logoPath_ = path;
    QPixmap p(path);
    logoLabel_->setPixmap(p.scaled(80, 80, Qt::KeepAspectRatio, Qt::SmoothTransformation));
}
void SettingsView::onUploadSeal() {
    QString path = QFileDialog::getOpenFileName(this, "Select Seal",
        QString(), "Images (*.png *.jpg *.jpeg *.bmp)");
    if (path.isEmpty()) return;
    sealPath_ = path;
    QPixmap p(path);
    sealLabel_->setPixmap(p.scaled(80, 80, Qt::KeepAspectRatio, Qt::SmoothTransformation));
}
void SettingsView::refresh() { load(); }

// ============================================================================
// AuditLogView
// ============================================================================
AuditLogView::AuditLogView(QWidget* parent) : QWidget(parent) {
    setupUi(); refresh();
}
void AuditLogView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(new QLabel(TR("audit_title"), this));

    auto* fb = new QHBoxLayout();
    searchEdit_ = new QLineEdit(this);
    searchEdit_->setPlaceholderText(" Search description...");
    searchEdit_->setMinimumHeight(32);
    connect(searchEdit_, &QLineEdit::textChanged, this, [this]{ page_=1; refresh(); });
    actionFilter_ = new QComboBox(this);
    actionFilter_->addItems({"", "LOGIN", "LOGOUT", "LOGIN_FAILED", "ADD", "EDIT", "DELETE",
                             "PRINT", "EXPORT", "BACKUP", "RESTORE", "PASSWORD_CHANGE"});
    connect(actionFilter_, &QComboBox::currentTextChanged, this, [this]{ page_=1; refresh(); });
    moduleFilter_ = new QComboBox(this);
    moduleFilter_->addItems({"", "auth", "family", "member", "subscription", "donation",
                             "accounting", "marriage", "death", "welfare", "certificate",
                             "user", "settings", "system"});
    connect(moduleFilter_, &QComboBox::currentTextChanged, this, [this]{ page_=1; refresh(); });
    fromDate_ = new QDateEdit(QDate::currentDate().addDays(-30), this);
    fromDate_->setCalendarPopup(true); fromDate_->setDisplayFormat("yyyy-MM-dd");
    toDate_ = new QDateEdit(QDate::currentDate(), this);
    toDate_->setCalendarPopup(true); toDate_->setDisplayFormat("yyyy-MM-dd");
    connect(fromDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    connect(toDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });

    fb->addWidget(searchEdit_, 2);
    fb->addWidget(new QLabel("Action:", this));
    fb->addWidget(actionFilter_);
    fb->addWidget(new QLabel("Module:", this));
    fb->addWidget(moduleFilter_);
    fb->addWidget(new QLabel("From:", this));
    fb->addWidget(fromDate_);
    fb->addWidget(new QLabel("To:", this));
    fb->addWidget(toDate_);
    layout->addLayout(fb);

    exportBtn_ = new QPushButton(TR("action_export"), this);
    auto* btnBar = new QHBoxLayout();
    btnBar->addWidget(exportBtn_);
    btnBar->addStretch();
    layout->addLayout(btnBar);

    table_ = new QTableWidget(this);
    table_->setColumnCount(5);
    table_->setHorizontalHeaderLabels({"Time","User","Action","Module","Description"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(1, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(2, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(3, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setAlternatingRowColors(true);
    layout->addWidget(table_, 1);

    auto* pb = new QHBoxLayout();
    prevBtn_ = new QPushButton(TR("action_previous"), this);
    prevBtn_->setObjectName("action_prev");
    nextBtn_ = new QPushButton(TR("action_next") + " ", this);
    nextBtn_->setObjectName("action_next");
    pageLabel_ = new QLabel(this); pageLabel_->setAlignment(Qt::AlignCenter);
    connect(prevBtn_, &QPushButton::clicked, this, &AuditLogView::onPrevPage);
    connect(nextBtn_, &QPushButton::clicked, this, &AuditLogView::onNextPage);
    pb->addWidget(prevBtn_); pb->addStretch(); pb->addWidget(pageLabel_); pb->addStretch(); pb->addWidget(nextBtn_);
    layout->addLayout(pb);

    connect(exportBtn_, &QPushButton::clicked, this, &AuditLogView::onExport);
}
void AuditLogView::refresh() { loadTable(); }
void AuditLogView::loadTable() {
    AuditLogRepository repo;
    int total = 0;
    auto items = repo.list(page_, pageSize_, actionFilter_->currentText(),
                           moduleFilter_->currentText(), QString(),
                           fromDate_->date().toString(Qt::ISODate),
                           toDate_->date().toString(Qt::ISODate), &total);
    total_ = total;
    table_->setRowCount(0);
    for (const auto& a : items) {
        if (!searchEdit_->text().trimmed().isEmpty() &&
            !a.description.contains(searchEdit_->text(), Qt::CaseInsensitive)) continue;
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(a.createdAt.toString(Qt::ISODate)));
        table_->setItem(r, 1, new QTableWidgetItem(a.username));
        auto* actItem = new QTableWidgetItem(a.action);
        if (a.action == "DELETE" || a.action == "LOGIN_FAILED" || a.action == "REJECT")
            actItem->setForeground(QColor("#c0392b"));
        else if (a.action == "ADD" || a.action == "APPROVE" || a.action == "LOGIN")
            actItem->setForeground(QColor("#2a7a3a"));
        else if (a.action == "EDIT")
            actItem->setForeground(QColor("#8a5a1a"));
        table_->setItem(r, 2, actItem);
        table_->setItem(r, 3, new QTableWidgetItem(a.module));
        table_->setItem(r, 4, new QTableWidgetItem(a.description));
    }
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    pageLabel_->setText(QString("Page %1 of %2  (%3 entries)").arg(page_).arg(tp).arg(total_));
    prevBtn_->setEnabled(page_ > 1);
    nextBtn_->setEnabled(page_ < tp);
}
void AuditLogView::onExport() {
    QString path = QFileDialog::getSaveFileName(this, "Export Audit Log", "audit_log.csv", "CSV (*.csv)");
    if (path.isEmpty()) return;
    AuditLogRepository repo;
    auto items = repo.list(1, 100000, actionFilter_->currentText(),
                           moduleFilter_->currentText(), QString(),
                           fromDate_->date().toString(Qt::ISODate),
                           toDate_->date().toString(Qt::ISODate));
    QFile f(path);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) return;
    QTextStream out(&f);
    out << "Time,User,Action,Module,Description\n";
    for (const auto& a : items) {
        out << a.createdAt.toString(Qt::ISODate) << "," << a.username << ","
            << a.action << "," << a.module << ",\"" << a.description << "\"\n";
    }
    f.close();
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}
void AuditLogView::onPrevPage() { if (page_ > 1) { --page_; refresh(); } }
void AuditLogView::onNextPage() {
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    if (page_ < tp) { ++page_; refresh(); }
}

// ============================================================================
// BackupView
// ============================================================================
BackupView::BackupView(QWidget* parent) : QWidget(parent) {
    setupUi(); refresh();
}
void BackupView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(new QLabel(TR("bak_title"), this));

    auto* infoLabel = new QLabel(
        "<p>Backups are stored as ZIP files in your data directory.</p>"
        "<p>Each backup contains the full database file. To restore, select a backup ZIP.</p>", this);
    layout->addWidget(infoLabel);

    auto* bb = new QHBoxLayout();
    backupBtn_ = new QPushButton(TR("bak_create_now"), this);
    backupBtn_->setObjectName("action_save");
    restoreBtn_ = new QPushButton(TR("bak_restore"), this);
    restoreBtn_->setObjectName("action_restore");
    verifyBtn_ = new QPushButton(TR("bak_verify"), this);
    verifyBtn_->setObjectName("action_verify");
    deleteBtn_ = new QPushButton(TR("action_delete"), this);
    pruneBtn_ = new QPushButton(TR("bak_prune"), this);
    pruneBtn_->setObjectName("action_prune");
    for (auto* b : {backupBtn_, restoreBtn_, verifyBtn_, deleteBtn_, pruneBtn_}) {
        b->setMinimumHeight(34); bb->addWidget(b);
    }
    bb->addStretch();
    layout->addLayout(bb);

    table_ = new QTableWidget(this);
    table_->setColumnCount(4);
    table_->setHorizontalHeaderLabels({"File","Created","Size","Path"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(1, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(2, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    layout->addWidget(table_, 1);

    connect(backupBtn_, &QPushButton::clicked, this, &BackupView::onBackup);
    connect(restoreBtn_, &QPushButton::clicked, this, &BackupView::onRestore);
    connect(verifyBtn_, &QPushButton::clicked, this, &BackupView::onVerify);
    connect(deleteBtn_, &QPushButton::clicked, this, &BackupView::onDelete);
    connect(pruneBtn_, &QPushButton::clicked, this, &BackupView::onPrune);
}
void BackupView::refresh() {
    BackupService svc;
    auto backups = svc.listBackups();
    table_->setRowCount(0);
    for (const auto& b : backups) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(b.fileName));
        table_->setItem(r, 1, new QTableWidgetItem(b.created.toString("yyyy-MM-dd hh:mm")));
        QString sizeStr;
        if (b.sizeBytes < 1024) sizeStr = QString::number(b.sizeBytes) + " B";
        else if (b.sizeBytes < 1024*1024) sizeStr = QString::number(b.sizeBytes/1024) + " KB";
        else sizeStr = QString::number(b.sizeBytes/(1024*1024)) + " MB";
        table_->setItem(r, 2, new QTableWidgetItem(sizeStr));
        table_->setItem(r, 3, new QTableWidgetItem(b.fullPath));
    }
}
void BackupView::onBackup() {
    BackupService svc;
    QString err;
    QString path = svc.createBackup(&err);
    if (!path.isEmpty()) {
        QMessageBox::information(this, "Backup Created", "Backup saved to:\n" + path);
        refresh();
    } else {
        QMessageBox::warning(this, "Backup Failed", err);
    }
}
void BackupView::onRestore() {
    int r = table_->currentRow();
    if (r < 0) { QMessageBox::warning(this, "Restore", "Select a backup first."); return; }
    QString path = table_->item(r, 3)->text();
    auto reply = QMessageBox::warning(this, "Restore Backup",
        "WARNING: This will REPLACE your current database with the selected backup.\n"
        "The current database will be saved as .pre_restore.\n\n"
        "All users will be logged out after restore.\n\nContinue?",
        QMessageBox::Yes | QMessageBox::No, QMessageBox::No);
    if (reply != QMessageBox::Yes) return;
    BackupService svc;
    QString err;
    if (svc.restoreBackup(path, &err)) {
        QMessageBox::information(this, "Restored", "Backup restored successfully. Please restart the application.");
    } else {
        QMessageBox::warning(this, "Restore Failed", err);
    }
}
void BackupView::onVerify() {
    int r = table_->currentRow();
    if (r < 0) return;
    QString path = table_->item(r, 3)->text();
    BackupService svc;
    QString err;
    if (svc.verifyBackup(path, &err)) {
        QMessageBox::information(this, "Verified", "Backup file is valid.");
    } else {
        QMessageBox::warning(this, "Invalid", err);
    }
}
void BackupView::onDelete() {
    int r = table_->currentRow();
    if (r < 0) return;
    QString path = table_->item(r, 3)->text();
    if (QMessageBox::question(this, "Delete", "Delete this backup file?") == QMessageBox::Yes) {
        QFile::remove(path);
        refresh();
    }
}
void BackupView::onPrune() {
    int n = BackupService().pruneOldBackups(10);
    QMessageBox::information(this, "Pruned", QString("Removed %1 old backup(s).").arg(n));
    refresh();
}

// ============================================================================
// UserManagementView
// ============================================================================
UserManagementView::UserManagementView(QWidget* parent) : QWidget(parent) {
    setupUi(); refresh();
}
void UserManagementView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(new QLabel(TR("usr_title"), this));

    auto* bb = new QHBoxLayout();
    addBtn_ = new QPushButton(TR("usr_add"), this);
    addBtn_->setObjectName("action_add");
    editBtn_ = new QPushButton(TR("action_edit"), this);
    editBtn_->setObjectName("action_edit");
    deleteBtn_ = new QPushButton(TR("action_delete"), this);
    unlockBtn_ = new QPushButton(TR("action_unlock"), this);
    unlockBtn_->setObjectName("action_unlock");
    resetBtn_ = new QPushButton(TR("action_reset_password"), this);
    resetBtn_->setObjectName("action_reset");
    for (auto* b : {addBtn_, editBtn_, deleteBtn_, unlockBtn_, resetBtn_}) {
        b->setMinimumHeight(32); bb->addWidget(b);
    }
    bb->addStretch();
    layout->addLayout(bb);

    table_ = new QTableWidget(this);
    table_->setColumnCount(7);
    table_->setHorizontalHeaderLabels({"ID","Username","Full Name","Role","Email","Active","Locked"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    layout->addWidget(table_, 1);

    connect(addBtn_, &QPushButton::clicked, this, &UserManagementView::onAdd);
    connect(editBtn_, &QPushButton::clicked, this, &UserManagementView::onEdit);
    connect(deleteBtn_, &QPushButton::clicked, this, &UserManagementView::onDelete);
    connect(unlockBtn_, &QPushButton::clicked, this, &UserManagementView::onUnlock);
    connect(resetBtn_, &QPushButton::clicked, this, &UserManagementView::onResetPassword);
}
void UserManagementView::refresh() {
    UserRepository repo;
    auto users = repo.listAll();
    table_->setRowCount(0);
    for (const auto& u : users) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(QString::number(u.id)));
        table_->setItem(r, 1, new QTableWidgetItem(u.username));
        table_->setItem(r, 2, new QTableWidgetItem(u.fullName));
        table_->setItem(r, 3, new QTableWidgetItem(u.role));
        table_->setItem(r, 4, new QTableWidgetItem(u.email));
        table_->setItem(r, 5, new QTableWidgetItem(u.isActive ? "Yes" : "No"));
        table_->setItem(r, 6, new QTableWidgetItem(u.isLocked ? "LOCKED" : "—"));
        if (u.isLocked) table_->item(r, 6)->setForeground(QColor("#c0392b"));
    }
}

// Inline User Edit dialog
class UserEditDialog : public QDialog {
public:
    UserEditDialog(QWidget* parent, qint64 id = 0) : QDialog(parent), id_(id) {
        setWindowTitle(id > 0 ? "Edit User" : "Add User");
        setMinimumWidth(440);
        setupUi();
        if (id > 0) load();
    }
    QString username() const { return usernameEdit_->text().trimmed(); }
    QString fullName() const { return fullNameEdit_->text().trimmed(); }
    QString password() const { return passwordEdit_->text(); }
    QString role() const { return roleCombo_->currentText(); }
    QString email() const { return emailEdit_->text().trimmed(); }
    QString phone() const { return phoneEdit_->text().trimmed(); }
    bool isActive() const { return activeCheck_->isChecked(); }
    bool changePassword() const { return !passwordEdit_->text().isEmpty(); }
private:
    void setupUi() {
        auto* layout = new QVBoxLayout(this);
        auto* g = new QGroupBox(TR("usr_title"), this);
        auto* f = new QFormLayout(g);
        usernameEdit_ = new QLineEdit(this);
        if (id_ > 0) usernameEdit_->setReadOnly(true);
        fullNameEdit_ = new QLineEdit(this);
        passwordEdit_ = new QLineEdit(this);
        passwordEdit_->setEchoMode(QLineEdit::Password);
        passwordEdit_->setPlaceholderText(id_ > 0 ? "(leave blank to keep current)" : "Set password");
        roleCombo_ = new QComboBox(this);
        roleCombo_->addItems({"Administrator","President","Secretary","Treasurer","Imam","Staff","Auditor"});
        emailEdit_ = new QLineEdit(this);
        phoneEdit_ = new QLineEdit(this);
        activeCheck_ = new QCheckBox("Active", this);
        activeCheck_->setChecked(true);
        f->addRow(TR("usr_username") + "*:", usernameEdit_);
        f->addRow(TR("usr_full_name") + "*:", fullNameEdit_);
        f->addRow(TR("login_password") + ":", passwordEdit_);
        f->addRow(TR("usr_role") + "*:", roleCombo_);
        f->addRow(TR("member_email") + ":", emailEdit_);
        f->addRow(TR("family_phone") + ":", phoneEdit_);
        f->addRow("", activeCheck_);
        layout->addWidget(g);
        auto* btns = new QDialogButtonBox(QDialogButtonBox::Save | QDialogButtonBox::Cancel, this);
    btns->button(QDialogButtonBox::Save)->setText(TR("action_save"));
    btns->button(QDialogButtonBox::Cancel)->setText(TR("action_cancel"));
        connect(btns, &QDialogButtonBox::accepted, this, &QDialog::accept);
        connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
        layout->addWidget(btns);
    }
    void load() {
        UserRepository repo;
        auto u = repo.findById(id_);
        if (!u) return;
        usernameEdit_->setText(u->username);
        fullNameEdit_->setText(u->fullName);
        roleCombo_->setCurrentText(u->role);
        emailEdit_->setText(u->email);
        phoneEdit_->setText(u->phone);
        activeCheck_->setChecked(u->isActive);
    }
    qint64 id_ = 0;
    QLineEdit* usernameEdit_, *fullNameEdit_, *passwordEdit_, *emailEdit_, *phoneEdit_;
    QComboBox* roleCombo_;
    QCheckBox* activeCheck_;
};

void UserManagementView::onAdd() {
    UserEditDialog dlg(this);
    if (dlg.exec() != QDialog::Accepted) return;
    if (dlg.password().isEmpty()) {
        QMessageBox::warning(this, "Validation", "Password is required for new users.");
        return;
    }
    AuthService auth;
    qint64 id = auth.createUser(dlg.username(), dlg.fullName(), dlg.password(),
                                dlg.role(), dlg.email(), dlg.phone(), true);
    if (id > 0) refresh();
    else QMessageBox::warning(this, "Failed", "Could not create user. Check username uniqueness and password strength.");
}
void UserManagementView::onEdit() {
    int r = table_->currentRow();
    if (r < 0) return;
    qint64 id = table_->item(r, 0)->text().toLongLong();
    UserEditDialog dlg(this, id);
    if (dlg.exec() != QDialog::Accepted) return;
    AuthService auth;
    auth.updateUserProfile(id, dlg.fullName(), dlg.role(), dlg.email(), dlg.phone(), dlg.isActive());
    if (dlg.changePassword()) {
        auth.adminResetPassword(id, dlg.password());
    }
    refresh();
}
void UserManagementView::onDelete() {
    int r = table_->currentRow();
    if (r < 0) return;
    qint64 id = table_->item(r, 0)->text().toLongLong();
    if (id == AuthSession::instance().user().id) {
        QMessageBox::warning(this, "Cannot Delete", "You cannot delete your own account.");
        return;
    }
    if (QMessageBox::question(this, "Delete", "Delete this user permanently?") == QMessageBox::Yes) {
        AuthService().deleteUser(id);
        refresh();
    }
}
void UserManagementView::onUnlock() {
    int r = table_->currentRow();
    if (r < 0) return;
    qint64 id = table_->item(r, 0)->text().toLongLong();
    AuthService().unlockUser(id);
    refresh();
}
void UserManagementView::onResetPassword() {
    int r = table_->currentRow();
    if (r < 0) return;
    qint64 id = table_->item(r, 0)->text().toLongLong();
    bool ok = false;
    QString pwd = QInputDialog::getText(this, "Reset Password",
        "Enter new password:", QLineEdit::Password, "", &ok);
    if (!ok || pwd.isEmpty()) return;
    if (AuthService().adminResetPassword(id, pwd)) {
        QMessageBox::information(this, "Reset", "Password has been reset.");
    } else {
        QMessageBox::warning(this, "Failed",
            "Password does not meet policy: min 8 chars with upper/lower/digit/special.");
    }
}

// ============================================================================
// ChangePasswordDialog
// ============================================================================
ChangePasswordDialog::ChangePasswordDialog(QWidget* parent) : QDialog(parent) {
    setWindowTitle("Change Password");
    setMinimumWidth(400);
    setupUi();
}
void ChangePasswordDialog::setupUi() {
    auto* layout = new QVBoxLayout(this);
    auto* g = new QGroupBox("Change Your Password", this);
    auto* f = new QFormLayout(g);

    oldEdit_ = new QLineEdit(this);
    oldEdit_->setEchoMode(QLineEdit::Password);
    newEdit_ = new QLineEdit(this);
    newEdit_->setEchoMode(QLineEdit::Password);
    confirmEdit_ = new QLineEdit(this);
    confirmEdit_->setEchoMode(QLineEdit::Password);
    strengthLabel_ = new QLabel(this);

    f->addRow("Current Password:", oldEdit_);
    f->addRow("New Password:", newEdit_);
    f->addRow("Confirm:", confirmEdit_);
    f->addRow("Strength:", strengthLabel_);

    connect(newEdit_, &QLineEdit::textChanged, this, [this](const QString& t){
        int s = Security::passwordStrength(t);
        QStringList labels = {"Very Weak", "Weak", "Fair", "Good", "Strong", "Very Strong"};
        QStringList colors = {"#c0392b","#c0392b","#8a5a1a","#2a7a3a","#2a7a3a","#1a4a8a"};
        strengthLabel_->setText(labels[s]);
    });

    layout->addWidget(g);

    auto* policyLbl = new QLabel(AuthService::passwordPolicyDescription(), this);
    policyLbl->setWordWrap(true);
    layout->addWidget(policyLbl);

    auto* btns = new QDialogButtonBox(QDialogButtonBox::Ok | QDialogButtonBox::Cancel, this);
    connect(btns, &QDialogButtonBox::accepted, this, &ChangePasswordDialog::onChange);
    connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
    layout->addWidget(btns);
}
void ChangePasswordDialog::onChange() {
    if (newEdit_->text() != confirmEdit_->text()) {
        QMessageBox::warning(this, "Mismatch", "New password and confirmation do not match.");
        return;
    }
    AuthService auth;
    if (auth.changePassword(AuthSession::instance().user().id,
                            oldEdit_->text(), newEdit_->text())) {
        accept();
    } else {
        QMessageBox::warning(this, "Failed",
            "Could not change password. Verify your current password is correct and the new one meets the policy.");
    }
}

} // namespace mms
