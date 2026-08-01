/*
 * RegisterViews.cpp - Implementations for Marriage, Death, Welfare views + their edit dialogs
 */
#include "RegisterViews.h"
#include "../services/RegisterServices.h"
#include "../services/CertificateService.h"
#include "../services/ReportService.h"
#include "../services/FamilyService.h"
#include "../repositories/MarriageRepository.h"
#include "../repositories/DeathRepository.h"
#include "../repositories/WelfareRepository.h"
#include "../repositories/FamilyRepository.h"

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
#include <QDoubleSpinBox>
#include <QDialogButtonBox>
#include <QMessageBox>
#include <QFileDialog>
#include <QDesktopServices>
#include <QInputDialog>
#include <QUrl>
#include "../core/I18N.h"
#include "../core/StyleProps.h"
#include "../core/ThemeColors.h"

namespace mms {

// =========================================================================
// Marriage Edit Dialog
// =========================================================================
class MarriageEditDialog : public QDialog {
public:
    MarriageEditDialog(QWidget* parent, qint64 id = 0) : QDialog(parent), id_(id) {
        setWindowTitle(id > 0 ? "Edit Marriage" : "Register Marriage");
        setMinimumWidth(640);
        setupUi();
        if (id > 0) load();
        else {
            numberEdit_->setText(MarriageService().nextMarriageNumber());
            nikahDateEdit_->setDate(QDate::currentDate());
            regDateEdit_->setDate(QDate::currentDate());
        }
    }
private:
    void setupUi() {
        auto* layout = new QVBoxLayout(this);
        auto* g = new QGroupBox(TR("mrg_title"), this);
        auto* f = new QFormLayout(g);
        numberEdit_ = new QLineEdit(this);
        brideNameEdit_ = new QLineEdit(this);
        brideFatherEdit_ = new QLineEdit(this);
        brideAddrEdit_ = new QTextEdit(this); brideAddrEdit_->setMaximumHeight(50);
        groomNameEdit_ = new QLineEdit(this);
        groomFatherEdit_ = new QLineEdit(this);
        groomAddrEdit_ = new QTextEdit(this); groomAddrEdit_->setMaximumHeight(50);
        witness1Edit_ = new QLineEdit(this);
        witness2Edit_ = new QLineEdit(this);
        witness3Edit_ = new QLineEdit(this);
        witness4Edit_ = new QLineEdit(this);
        maharEdit_ = new QLineEdit(this);
        nikahDateEdit_ = new QDateEdit(QDate::currentDate(), this);
        nikahDateEdit_->setCalendarPopup(true); nikahDateEdit_->setDisplayFormat("yyyy-MM-dd");
        regDateEdit_ = new QDateEdit(QDate::currentDate(), this);
        regDateEdit_->setCalendarPopup(true); regDateEdit_->setDisplayFormat("yyyy-MM-dd");
        placeEdit_ = new QLineEdit(this);
        remarksEdit_ = new QTextEdit(this); remarksEdit_->setMaximumHeight(50);

        f->addRow(TR("mrg_number") + ":", numberEdit_);
        f->addRow(TR("mrg_bride") + "*:", brideNameEdit_);
        f->addRow(TR("mrg_bride_father") + ":", brideFatherEdit_);
        f->addRow(TR("mrg_bride") + " " + TR("family_address") + ":", brideAddrEdit_);
        f->addRow(TR("mrg_groom") + "*:", groomNameEdit_);
        f->addRow(TR("mrg_groom_father") + ":", groomFatherEdit_);
        f->addRow(TR("mrg_groom") + " " + TR("family_address") + ":", groomAddrEdit_);
        f->addRow(TR("mrg_witness") + " 1:", witness1Edit_);
        f->addRow(TR("mrg_witness") + " 2:", witness2Edit_);
        f->addRow(TR("mrg_witness") + " 3:", witness3Edit_);
        f->addRow(TR("mrg_witness") + " 4:", witness4Edit_);
        f->addRow(TR("mrg_mahar") + ":", maharEdit_);
        f->addRow(TR("mrg_nikah_date") + "*:", nikahDateEdit_);
        f->addRow(TR("mrg_registration_date") + ":", regDateEdit_);
        f->addRow(TR("mrg_place") + ":", placeEdit_);
        f->addRow(TR("family_notes") + ":", remarksEdit_);
        layout->addWidget(g);
        auto* btns = new QDialogButtonBox(QDialogButtonBox::Save | QDialogButtonBox::Cancel, this);
    btns->button(QDialogButtonBox::Save)->setText(TR("action_save"));
    btns->button(QDialogButtonBox::Cancel)->setText(TR("action_cancel"));
        connect(btns, &QDialogButtonBox::accepted, this, [this]{ onSave(); });
        connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
        layout->addWidget(btns);
    }
    void load() {
        MarriageRepository repo;
        auto m = repo.findById(id_);
        if (!m) return;
        numberEdit_->setText(m->marriageNumber);
        brideNameEdit_->setText(m->brideName);
        brideFatherEdit_->setText(m->brideFather);
        brideAddrEdit_->setPlainText(m->brideAddress);
        groomNameEdit_->setText(m->groomName);
        groomFatherEdit_->setText(m->groomFather);
        groomAddrEdit_->setPlainText(m->groomAddress);
        witness1Edit_->setText(m->witness1);
        witness2Edit_->setText(m->witness2);
        witness3Edit_->setText(m->witness3);
        witness4Edit_->setText(m->witness4);
        maharEdit_->setText(m->mahar);
        nikahDateEdit_->setDate(QDate::fromString(m->nikahDate, Qt::ISODate));
        regDateEdit_->setDate(QDate::fromString(m->registrationDate, Qt::ISODate));
        placeEdit_->setText(m->place);
        remarksEdit_->setPlainText(m->remarks);
    }
    void onSave() {
        Marriage m;
        m.id = id_;
        m.marriageNumber = numberEdit_->text().trimmed();
        m.brideName = brideNameEdit_->text().trimmed();
        m.brideFather = brideFatherEdit_->text().trimmed();
        m.brideAddress = brideAddrEdit_->toPlainText().trimmed();
        m.groomName = groomNameEdit_->text().trimmed();
        m.groomFather = groomFatherEdit_->text().trimmed();
        m.groomAddress = groomAddrEdit_->toPlainText().trimmed();
        m.witness1 = witness1Edit_->text().trimmed();
        m.witness2 = witness2Edit_->text().trimmed();
        m.witness3 = witness3Edit_->text().trimmed();
        m.witness4 = witness4Edit_->text().trimmed();
        m.mahar = maharEdit_->text().trimmed();
        m.nikahDate = nikahDateEdit_->date().toString(Qt::ISODate);
        m.registrationDate = regDateEdit_->date().toString(Qt::ISODate);
        m.place = placeEdit_->text().trimmed();
        m.remarks = remarksEdit_->toPlainText().trimmed();
        MarriageService svc;
        QString err;
        bool ok = (id_ > 0) ? svc.updateMarriage(m, &err) : (svc.createMarriage(m, &err) > 0);
        if (ok) accept();
        else QMessageBox::warning(this, "Save Failed", err);
    }
    qint64 id_ = 0;
    QLineEdit* numberEdit_, *brideNameEdit_, *brideFatherEdit_, *groomNameEdit_, *groomFatherEdit_;
    QTextEdit* brideAddrEdit_, *groomAddrEdit_;
    QLineEdit* witness1Edit_, *witness2Edit_, *witness3Edit_, *witness4Edit_;
    QLineEdit* maharEdit_, *placeEdit_;
    QDateEdit* nikahDateEdit_, *regDateEdit_;
    QTextEdit* remarksEdit_;
};

// =========================================================================
// MarriageView
// =========================================================================
MarriageView::MarriageView(QWidget* parent) : QWidget(parent) {
    setupUi(); refresh();
}
void MarriageView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(new QLabel(TR("mrg_title"), this));

    auto* fb = new QHBoxLayout();
    searchEdit_ = new QLineEdit(this);
    searchEdit_->setPlaceholderText(" Search by number, names, father...");
    searchEdit_->setMinimumHeight(32);
    connect(searchEdit_, &QLineEdit::textChanged, this, [this]{ page_=1; refresh(); });
    fromDate_ = new QDateEdit(QDate::currentDate().addYears(-1), this);
    fromDate_->setCalendarPopup(true); fromDate_->setDisplayFormat("yyyy-MM-dd");
    toDate_ = new QDateEdit(QDate::currentDate(), this);
    toDate_->setCalendarPopup(true); toDate_->setDisplayFormat("yyyy-MM-dd");
    connect(fromDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    connect(toDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    fb->addWidget(searchEdit_, 2);
    fb->addWidget(new QLabel("From:", this));
    fb->addWidget(fromDate_);
    fb->addWidget(new QLabel("To:", this));
    fb->addWidget(toDate_);
    layout->addLayout(fb);

    auto* bb = new QHBoxLayout();
    addBtn_ = new QPushButton(TR("mrg_register"), this);
    StyleProps::set(addBtn_, "primary");
    editBtn_ = new QPushButton(TR("action_edit"), this);
    StyleProps::set(editBtn_, "chip");
    deleteBtn_ = new QPushButton(TR("action_delete"), this);
    StyleProps::set(deleteBtn_, "ghostDanger");
    certBtn_ = new QPushButton(TR("cert_title"), this);
    StyleProps::set(certBtn_, "primary");
    printBtn_ = new QPushButton(TR("action_print"), this);
    StyleProps::set(printBtn_, "chip");
    exportBtn_ = new QPushButton(TR("action_export"), this);
    StyleProps::set(exportBtn_, "chip");
    for (auto* b : {addBtn_, editBtn_, deleteBtn_, certBtn_, printBtn_, exportBtn_}) {
        b->setMinimumHeight(32); bb->addWidget(b);
    }
    bb->addStretch();
    layout->addLayout(bb);

    table_ = new QTableWidget(this);
    table_->setColumnCount(7);
    table_->setHorizontalHeaderLabels({"ID","No","Bride","Groom","Nikah Date","Place","Registration"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    layout->addWidget(table_, 1);

    auto* pb = new QHBoxLayout();
    prevBtn_ = new QPushButton(TR("action_previous"), this);
    StyleProps::set(prevBtn_, "chip");
    nextBtn_ = new QPushButton(TR("action_next") + " ", this);
    StyleProps::set(nextBtn_, "chip");
    pageLabel_ = new QLabel(this); pageLabel_->setAlignment(Qt::AlignCenter);
    connect(prevBtn_, &QPushButton::clicked, this, &MarriageView::onPrevPage);
    connect(nextBtn_, &QPushButton::clicked, this, &MarriageView::onNextPage);
    pb->addWidget(prevBtn_); pb->addStretch(); pb->addWidget(pageLabel_); pb->addStretch(); pb->addWidget(nextBtn_);
    layout->addLayout(pb);

    connect(addBtn_, &QPushButton::clicked, this, &MarriageView::onAdd);
    connect(editBtn_, &QPushButton::clicked, this, &MarriageView::onEdit);
    connect(deleteBtn_, &QPushButton::clicked, this, &MarriageView::onDelete);
    connect(certBtn_, &QPushButton::clicked, this, &MarriageView::onCertificate);
    connect(printBtn_, &QPushButton::clicked, this, &MarriageView::onPrint);
    connect(exportBtn_, &QPushButton::clicked, this, &MarriageView::onExport);
}

void MarriageView::refresh() { loadTable(); }

void MarriageView::loadTable() {
    MarriageService svc;
    int total = 0;
    auto items = svc.list(page_, pageSize_, searchEdit_->text().trimmed(),
                          fromDate_->date().toString(Qt::ISODate),
                          toDate_->date().toString(Qt::ISODate), &total);
    total_ = total;
    table_->setRowCount(0);
    for (const auto& m : items) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(QString::number(m.id)));
        table_->setItem(r, 1, new QTableWidgetItem(m.marriageNumber));
        table_->setItem(r, 2, new QTableWidgetItem(m.brideName));
        table_->setItem(r, 3, new QTableWidgetItem(m.groomName));
        table_->setItem(r, 4, new QTableWidgetItem(m.nikahDate));
        table_->setItem(r, 5, new QTableWidgetItem(m.place));
        table_->setItem(r, 6, new QTableWidgetItem(m.registrationDate));
    }
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    pageLabel_->setText(QString("Page %1 of %2  (%3 records)").arg(page_).arg(tp).arg(total_));
    prevBtn_->setEnabled(page_ > 1);
    nextBtn_->setEnabled(page_ < tp);
}

void MarriageView::onAdd() { MarriageEditDialog dlg(this); if (dlg.exec() == QDialog::Accepted) refresh(); }
void MarriageView::onEdit() {
    int r = table_->currentRow(); if (r < 0) return;
    MarriageEditDialog dlg(this, table_->item(r, 0)->text().toLongLong());
    if (dlg.exec() == QDialog::Accepted) refresh();
}
void MarriageView::onDelete() {
    int r = table_->currentRow(); if (r < 0) return;
    if (QMessageBox::question(this, "Delete", "Delete this marriage record?") == QMessageBox::Yes) {
        MarriageService().deleteMarriage(table_->item(r, 0)->text().toLongLong()); refresh();
    }
}
void MarriageView::onCertificate() {
    int r = table_->currentRow(); if (r < 0) return;
    qint64 id = table_->item(r, 0)->text().toLongLong();
    CertificateService svc;
    QString err;
    QString path = svc.generateMarriageCertificatePdf(id, &err);
    if (!path.isEmpty()) QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    else QMessageBox::warning(this, "Failed", err);
}
void MarriageView::onPrint() {
    ReportService svc;
    auto row = svc.marriageRegisterReport(fromDate_->date().toString(Qt::ISODate),
                                          toDate_->date().toString(Qt::ISODate));
    QString path = svc.ensureExportPath("marriage_register.pdf");
    if (!svc.exportToPdf(row, "Marriage Register", path,
                         fromDate_->date().toString(Qt::ISODate),
                         toDate_->date().toString(Qt::ISODate)).isEmpty())
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}
void MarriageView::onExport() {
    QString path = QFileDialog::getSaveFileName(this, "Export", "marriages.csv", "CSV (*.csv)");
    if (path.isEmpty()) return;
    ReportService svc;
    auto row = svc.marriageRegisterReport(fromDate_->date().toString(Qt::ISODate),
                                          toDate_->date().toString(Qt::ISODate));
    svc.exportToCsv(row, path);
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}
void MarriageView::onPrevPage() { if (page_ > 1) { --page_; refresh(); } }
void MarriageView::onNextPage() {
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    if (page_ < tp) { ++page_; refresh(); }
}

// =========================================================================
// Death Edit Dialog
// =========================================================================
class DeathEditDialog : public QDialog {
public:
    DeathEditDialog(QWidget* parent, qint64 id = 0) : QDialog(parent), id_(id) {
        setWindowTitle(id > 0 ? "Edit Death Record" : "Register Death");
        setMinimumWidth(560);
        setupUi();
        loadFamilies();
        if (id > 0) load();
        else {
            numberEdit_->setText(DeathService().nextDeathNumber());
            dodEdit_->setDate(QDate::currentDate());
            burialEdit_->setDate(QDate::currentDate());
        }
    }
private:
    void setupUi() {
        auto* layout = new QVBoxLayout(this);
        auto* g = new QGroupBox(TR("dth_title"), this);
        auto* f = new QFormLayout(g);
        numberEdit_ = new QLineEdit(this);
        nameEdit_ = new QLineEdit(this);
        fatherEdit_ = new QLineEdit(this);
        familyCombo_ = new QComboBox(this);
        familyCombo_->addItem(TR("form_none"), 0);
        genderCombo_ = new QComboBox(this);
        genderCombo_->addItems({"", "Male", "Female", "Other"});
        dodEdit_ = new QDateEdit(QDate::currentDate(), this);
        dodEdit_->setCalendarPopup(true); dodEdit_->setDisplayFormat("yyyy-MM-dd");
        burialEdit_ = new QDateEdit(QDate::currentDate(), this);
        burialEdit_->setCalendarPopup(true); burialEdit_->setDisplayFormat("yyyy-MM-dd");
        causeEdit_ = new QLineEdit(this);
        placeEdit_ = new QLineEdit(this);
        placeEdit_->setText("Mahallu Cemetery");
        ageSpin_ = new QSpinBox(this); ageSpin_->setRange(0, 150);
        remarksEdit_ = new QTextEdit(this); remarksEdit_->setMaximumHeight(50);

        f->addRow(TR("dth_number") + ":", numberEdit_);
        f->addRow(TR("dth_deceased") + " " + TR("member_name") + "*:", nameEdit_);
        f->addRow(TR("dth_father") + ":", fatherEdit_);
        f->addRow(TR("member_family") + ":", familyCombo_);
        f->addRow(TR("member_gender") + ":", genderCombo_);
        f->addRow(TR("dth_date_of_death") + "*:", dodEdit_);
        f->addRow(TR("dth_burial_date") + ":", burialEdit_);
        f->addRow(TR("dth_cause") + ":", causeEdit_);
        f->addRow(TR("dth_burial_place") + ":", placeEdit_);
        f->addRow(TR("member_age") + ":", ageSpin_);
        f->addRow(TR("family_notes") + ":", remarksEdit_);
        layout->addWidget(g);
        auto* btns = new QDialogButtonBox(QDialogButtonBox::Save | QDialogButtonBox::Cancel, this);
    btns->button(QDialogButtonBox::Save)->setText(TR("action_save"));
    btns->button(QDialogButtonBox::Cancel)->setText(TR("action_cancel"));
        connect(btns, &QDialogButtonBox::accepted, this, [this]{ onSave(); });
        connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
        layout->addWidget(btns);
    }
    void loadFamilies() {
        FamilyRepository repo;
        auto families = repo.listAll("Active");
        for (const auto& fm : families) {
            familyCombo_->addItem(QString("%1 - %2").arg(fm.familyNumber).arg(fm.houseName), fm.id);
        }
    }
    void load() {
        DeathRepository repo;
        auto d = repo.findById(id_);
        if (!d) return;
        numberEdit_->setText(d->deathNumber);
        nameEdit_->setText(d->deceasedName);
        fatherEdit_->setText(d->fatherName);
        familyCombo_->setCurrentIndex(familyCombo_->findData(d->familyId));
        genderCombo_->setCurrentText(d->gender);
        dodEdit_->setDate(QDate::fromString(d->dateOfDeath, Qt::ISODate));
        if (!d->burialDate.isEmpty()) burialEdit_->setDate(QDate::fromString(d->burialDate, Qt::ISODate));
        causeEdit_->setText(d->causeOfDeath);
        placeEdit_->setText(d->burialPlace);
        ageSpin_->setValue(d->age);
        remarksEdit_->setPlainText(d->remarks);
    }
    void onSave() {
        Death d;
        d.id = id_;
        d.deathNumber = numberEdit_->text().trimmed();
        d.deceasedName = nameEdit_->text().trimmed();
        d.fatherName = fatherEdit_->text().trimmed();
        d.familyId = familyCombo_->currentData().toLongLong();
        d.gender = genderCombo_->currentText();
        d.dateOfDeath = dodEdit_->date().toString(Qt::ISODate);
        d.burialDate = burialEdit_->date().toString(Qt::ISODate);
        d.causeOfDeath = causeEdit_->text().trimmed();
        d.burialPlace = placeEdit_->text().trimmed();
        d.age = ageSpin_->value();
        d.remarks = remarksEdit_->toPlainText().trimmed();
        DeathService svc;
        QString err;
        bool ok = (id_ > 0) ? svc.updateDeath(d, &err) : (svc.createDeath(d, &err) > 0);
        if (ok) accept();
        else QMessageBox::warning(this, "Save Failed", err);
    }
    qint64 id_ = 0;
    QLineEdit* numberEdit_, *nameEdit_, *fatherEdit_, *causeEdit_, *placeEdit_;
    QComboBox* familyCombo_, *genderCombo_;
    QDateEdit* dodEdit_, *burialEdit_;
    QSpinBox* ageSpin_;
    QTextEdit* remarksEdit_;
};

// =========================================================================
// DeathView
// =========================================================================
DeathView::DeathView(QWidget* parent) : QWidget(parent) {
    setupUi(); refresh();
}
void DeathView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(new QLabel(TR("dth_title"), this));

    auto* fb = new QHBoxLayout();
    searchEdit_ = new QLineEdit(this);
    searchEdit_->setPlaceholderText(" Search by name, number...");
    searchEdit_->setMinimumHeight(32);
    connect(searchEdit_, &QLineEdit::textChanged, this, [this]{ page_=1; refresh(); });
    fromDate_ = new QDateEdit(QDate::currentDate().addYears(-1), this);
    fromDate_->setCalendarPopup(true); fromDate_->setDisplayFormat("yyyy-MM-dd");
    toDate_ = new QDateEdit(QDate::currentDate(), this);
    toDate_->setCalendarPopup(true); toDate_->setDisplayFormat("yyyy-MM-dd");
    connect(fromDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    connect(toDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    fb->addWidget(searchEdit_, 2);
    fb->addWidget(new QLabel("From:", this));
    fb->addWidget(fromDate_);
    fb->addWidget(new QLabel("To:", this));
    fb->addWidget(toDate_);
    layout->addLayout(fb);

    auto* bb = new QHBoxLayout();
    addBtn_ = new QPushButton(TR("mrg_register"), this);
    editBtn_ = new QPushButton(TR("action_edit"), this);
    deleteBtn_ = new QPushButton(TR("action_delete"), this);
    certBtn_ = new QPushButton(TR("cert_title"), this);
    printBtn_ = new QPushButton(TR("action_print"), this);
    exportBtn_ = new QPushButton(TR("action_export"), this);
    for (auto* b : {addBtn_, editBtn_, deleteBtn_, certBtn_, printBtn_, exportBtn_}) {
        b->setMinimumHeight(32); bb->addWidget(b);
    }
    bb->addStretch();
    layout->addLayout(bb);

    table_ = new QTableWidget(this);
    table_->setColumnCount(7);
    table_->setHorizontalHeaderLabels({"ID","No","Name","Father","Date of Death","Burial","Cause"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    layout->addWidget(table_, 1);

    auto* pb = new QHBoxLayout();
    prevBtn_ = new QPushButton(TR("action_previous"), this);
    nextBtn_ = new QPushButton(TR("action_next") + " ", this);
    pageLabel_ = new QLabel(this); pageLabel_->setAlignment(Qt::AlignCenter);
    connect(prevBtn_, &QPushButton::clicked, this, &DeathView::onPrevPage);
    connect(nextBtn_, &QPushButton::clicked, this, &DeathView::onNextPage);
    pb->addWidget(prevBtn_); pb->addStretch(); pb->addWidget(pageLabel_); pb->addStretch(); pb->addWidget(nextBtn_);
    layout->addLayout(pb);

    connect(addBtn_, &QPushButton::clicked, this, &DeathView::onAdd);
    connect(editBtn_, &QPushButton::clicked, this, &DeathView::onEdit);
    connect(deleteBtn_, &QPushButton::clicked, this, &DeathView::onDelete);
    connect(certBtn_, &QPushButton::clicked, this, &DeathView::onCertificate);
    connect(printBtn_, &QPushButton::clicked, this, &DeathView::onPrint);
    connect(exportBtn_, &QPushButton::clicked, this, &DeathView::onExport);
}

void DeathView::refresh() { loadTable(); }
void DeathView::loadTable() {
    DeathService svc;
    int total = 0;
    auto items = svc.list(page_, pageSize_, searchEdit_->text().trimmed(),
                          fromDate_->date().toString(Qt::ISODate),
                          toDate_->date().toString(Qt::ISODate), &total);
    total_ = total;
    table_->setRowCount(0);
    for (const auto& d : items) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(QString::number(d.id)));
        table_->setItem(r, 1, new QTableWidgetItem(d.deathNumber));
        table_->setItem(r, 2, new QTableWidgetItem(d.deceasedName));
        table_->setItem(r, 3, new QTableWidgetItem(d.fatherName));
        table_->setItem(r, 4, new QTableWidgetItem(d.dateOfDeath));
        table_->setItem(r, 5, new QTableWidgetItem(d.burialDate));
        table_->setItem(r, 6, new QTableWidgetItem(d.causeOfDeath));
    }
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    pageLabel_->setText(QString("Page %1 of %2  (%3 records)").arg(page_).arg(tp).arg(total_));
    prevBtn_->setEnabled(page_ > 1);
    nextBtn_->setEnabled(page_ < tp);
}

void DeathView::onAdd() { DeathEditDialog dlg(this); if (dlg.exec() == QDialog::Accepted) refresh(); }
void DeathView::onEdit() {
    int r = table_->currentRow(); if (r < 0) return;
    DeathEditDialog dlg(this, table_->item(r, 0)->text().toLongLong());
    if (dlg.exec() == QDialog::Accepted) refresh();
}
void DeathView::onDelete() {
    int r = table_->currentRow(); if (r < 0) return;
    if (QMessageBox::question(this, "Delete", "Delete this death record?") == QMessageBox::Yes) {
        DeathService().deleteDeath(table_->item(r, 0)->text().toLongLong()); refresh();
    }
}
void DeathView::onCertificate() {
    int r = table_->currentRow(); if (r < 0) return;
    qint64 id = table_->item(r, 0)->text().toLongLong();
    CertificateService svc;
    QString err;
    QString path = svc.generateDeathCertificatePdf(id, &err);
    if (!path.isEmpty()) QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    else QMessageBox::warning(this, "Failed", err);
}
void DeathView::onPrint() {
    ReportService svc;
    auto row = svc.deathRegisterReport(fromDate_->date().toString(Qt::ISODate),
                                       toDate_->date().toString(Qt::ISODate));
    QString path = svc.ensureExportPath("death_register.pdf");
    if (!svc.exportToPdf(row, "Death Register", path,
                         fromDate_->date().toString(Qt::ISODate),
                         toDate_->date().toString(Qt::ISODate)).isEmpty())
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}
void DeathView::onExport() {
    QString path = QFileDialog::getSaveFileName(this, "Export", "deaths.csv", "CSV (*.csv)");
    if (path.isEmpty()) return;
    ReportService svc;
    auto row = svc.deathRegisterReport(fromDate_->date().toString(Qt::ISODate),
                                       toDate_->date().toString(Qt::ISODate));
    svc.exportToCsv(row, path);
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}
void DeathView::onPrevPage() { if (page_ > 1) { --page_; refresh(); } }
void DeathView::onNextPage() {
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    if (page_ < tp) { ++page_; refresh(); }
}

// =========================================================================
// Welfare Edit Dialog
// =========================================================================
class WelfareEditDialog : public QDialog {
public:
    WelfareEditDialog(QWidget* parent, qint64 id = 0) : QDialog(parent), id_(id) {
        setWindowTitle(id > 0 ? "Edit Welfare Request" : "New Welfare Request");
        setMinimumWidth(540);
        setupUi();
        loadFamilies();
        if (id > 0) load();
        else {
            numberEdit_->setText(WelfareService().nextRequestNumber());
        }
    }
private:
    void setupUi() {
        auto* layout = new QVBoxLayout(this);
        auto* g = new QGroupBox(TR("wel_title"), this);
        auto* f = new QFormLayout(g);
        numberEdit_ = new QLineEdit(this);
        applicantEdit_ = new QLineEdit(this);
        familyCombo_ = new QComboBox(this);
        familyCombo_->addItem(TR("form_none"), 0);
        categoryCombo_ = new QComboBox(this);
        categoryCombo_->addItems({"Medical Aid", "Education Aid", "Marriage Assistance", "Financial Assistance"});
        amountEdit_ = new QDoubleSpinBox(this);
        amountEdit_->setRange(1, 10000000);
        amountEdit_->setDecimals(2);
        amountEdit_->setSingleStep(1000);
        reasonEdit_ = new QTextEdit(this); reasonEdit_->setMaximumHeight(80);
        statusCombo_ = new QComboBox(this);
        statusCombo_->addItems({"Pending", "Approved", "Rejected", "Disbursed", "Closed"});
        remarksEdit_ = new QTextEdit(this); remarksEdit_->setMaximumHeight(50);

        f->addRow(TR("wel_request_no") + ":", numberEdit_);
        f->addRow(TR("wel_applicant") + "*:", applicantEdit_);
        f->addRow(TR("member_family") + ":", familyCombo_);
        f->addRow(TR("don_category") + "*:", categoryCombo_);
        f->addRow(TR("wel_amount_requested") + "*:", amountEdit_);
        f->addRow(TR("wel_reason") + "*:", reasonEdit_);
        f->addRow(TR("member_active") + ":", statusCombo_);
        f->addRow(TR("family_notes") + ":", remarksEdit_);
        layout->addWidget(g);
        auto* btns = new QDialogButtonBox(QDialogButtonBox::Save | QDialogButtonBox::Cancel, this);
    btns->button(QDialogButtonBox::Save)->setText(TR("action_save"));
    btns->button(QDialogButtonBox::Cancel)->setText(TR("action_cancel"));
        connect(btns, &QDialogButtonBox::accepted, this, [this]{ onSave(); });
        connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
        layout->addWidget(btns);
    }
    void loadFamilies() {
        FamilyRepository repo;
        auto families = repo.listAll("Active");
        for (const auto& fm : families) {
            familyCombo_->addItem(QString("%1 - %2").arg(fm.familyNumber).arg(fm.houseName), fm.id);
        }
    }
    void load() {
        WelfareRepository repo;
        auto w = repo.findById(id_);
        if (!w) return;
        numberEdit_->setText(w->requestNumber);
        applicantEdit_->setText(w->applicantName);
        familyCombo_->setCurrentIndex(familyCombo_->findData(w->familyId));
        categoryCombo_->setCurrentText(w->category);
        amountEdit_->setValue(w->amountRequested);
        reasonEdit_->setPlainText(w->reason);
        statusCombo_->setCurrentText(w->status);
        remarksEdit_->setPlainText(w->remarks);
    }
    void onSave() {
        WelfareRequest w;
        w.id = id_;
        w.requestNumber = numberEdit_->text().trimmed();
        w.applicantName = applicantEdit_->text().trimmed();
        w.familyId = familyCombo_->currentData().toLongLong();
        w.category = categoryCombo_->currentText();
        w.amountRequested = amountEdit_->value();
        w.reason = reasonEdit_->toPlainText().trimmed();
        w.status = statusCombo_->currentText();
        w.remarks = remarksEdit_->toPlainText().trimmed();
        WelfareService svc;
        QString err;
        bool ok = (id_ > 0) ? svc.updateRequest(w, &err) : (svc.createRequest(w, &err) > 0);
        if (ok) accept();
        else QMessageBox::warning(this, "Save Failed", err);
    }
    qint64 id_ = 0;
    QLineEdit* numberEdit_, *applicantEdit_;
    QComboBox* familyCombo_, *categoryCombo_, *statusCombo_;
    QDoubleSpinBox* amountEdit_;
    QTextEdit* reasonEdit_, *remarksEdit_;
};

// =========================================================================
// WelfareView
// =========================================================================
WelfareView::WelfareView(QWidget* parent) : QWidget(parent) {
    setupUi(); refresh();
}
void WelfareView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(new QLabel(TR("wel_title"), this));

    auto* fb = new QHBoxLayout();
    searchEdit_ = new QLineEdit(this);
    searchEdit_->setPlaceholderText(" Search by applicant, request no...");
    searchEdit_->setMinimumHeight(32);
    connect(searchEdit_, &QLineEdit::textChanged, this, [this]{ page_=1; refresh(); });
    statusFilter_ = new QComboBox(this);
    statusFilter_->addItems({"", "Pending", "Approved", "Rejected", "Disbursed", "Closed"});
    connect(statusFilter_, &QComboBox::currentTextChanged, this, [this]{ page_=1; refresh(); });
    categoryFilter_ = new QComboBox(this);
    categoryFilter_->addItems({"", "Medical Aid", "Education Aid", "Marriage Assistance", "Financial Assistance"});
    connect(categoryFilter_, &QComboBox::currentTextChanged, this, [this]{ page_=1; refresh(); });
    fb->addWidget(searchEdit_, 2);
    fb->addWidget(new QLabel(TR("member_active") + ":", this));
    fb->addWidget(statusFilter_);
    fb->addWidget(new QLabel("Category:", this));
    fb->addWidget(categoryFilter_);
    layout->addLayout(fb);

    auto* bb = new QHBoxLayout();
    addBtn_ = new QPushButton(TR("wel_new_request"), this);
    editBtn_ = new QPushButton(TR("action_edit"), this);
    deleteBtn_ = new QPushButton(TR("action_delete"), this);
    approveBtn_ = new QPushButton(TR("action_approve"), this);
    StyleProps::set(approveBtn_, "primary");
    rejectBtn_ = new QPushButton(TR("action_reject"), this);
    StyleProps::set(rejectBtn_, "ghostDanger");
    disburseBtn_ = new QPushButton(TR("action_disburse"), this);
    StyleProps::set(disburseBtn_, "primary");
    printBtn_ = new QPushButton(TR("action_print"), this);
    exportBtn_ = new QPushButton(TR("action_export"), this);
    for (auto* b : {addBtn_, editBtn_, deleteBtn_, approveBtn_, rejectBtn_, disburseBtn_, printBtn_, exportBtn_}) {
        b->setMinimumHeight(32); bb->addWidget(b);
    }
    bb->addStretch();
    layout->addLayout(bb);

    table_ = new QTableWidget(this);
    table_->setColumnCount(7);
    table_->setHorizontalHeaderLabels({"ID","Request No","Applicant","Category","Requested","Approved","Status"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    layout->addWidget(table_, 1);

    auto* pb = new QHBoxLayout();
    prevBtn_ = new QPushButton(TR("action_previous"), this);
    nextBtn_ = new QPushButton(TR("action_next") + " ", this);
    pageLabel_ = new QLabel(this); pageLabel_->setAlignment(Qt::AlignCenter);
    connect(prevBtn_, &QPushButton::clicked, this, &WelfareView::onPrevPage);
    connect(nextBtn_, &QPushButton::clicked, this, &WelfareView::onNextPage);
    pb->addWidget(prevBtn_); pb->addStretch(); pb->addWidget(pageLabel_); pb->addStretch(); pb->addWidget(nextBtn_);
    layout->addLayout(pb);

    connect(addBtn_, &QPushButton::clicked, this, &WelfareView::onAdd);
    connect(editBtn_, &QPushButton::clicked, this, &WelfareView::onEdit);
    connect(deleteBtn_, &QPushButton::clicked, this, &WelfareView::onDelete);
    connect(approveBtn_, &QPushButton::clicked, this, &WelfareView::onApprove);
    connect(rejectBtn_, &QPushButton::clicked, this, &WelfareView::onReject);
    connect(disburseBtn_, &QPushButton::clicked, this, &WelfareView::onDisburse);
    connect(printBtn_, &QPushButton::clicked, this, &WelfareView::onPrint);
    connect(exportBtn_, &QPushButton::clicked, this, &WelfareView::onExport);
}

void WelfareView::refresh() { loadTable(); }
void WelfareView::loadTable() {
    WelfareService svc;
    int total = 0;
    auto items = svc.list(page_, pageSize_, statusFilter_->currentText(),
                          categoryFilter_->currentText(),
                          searchEdit_->text().trimmed(), &total);
    total_ = total;
    table_->setRowCount(0);
    for (const auto& w : items) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(QString::number(w.id)));
        table_->setItem(r, 1, new QTableWidgetItem(w.requestNumber));
        table_->setItem(r, 2, new QTableWidgetItem(w.applicantName));
        table_->setItem(r, 3, new QTableWidgetItem(w.category));
        table_->setItem(r, 4, new QTableWidgetItem(QString::number(w.amountRequested, 'f', 2)));
        table_->setItem(r, 5, new QTableWidgetItem(QString::number(w.amountApproved, 'f', 2)));
        auto* s = new QTableWidgetItem(w.status);
        if (w.status == "Approved") s->setForeground(colors::cellPositive);
        else if (w.status == "Rejected") s->setForeground(colors::cellNegative);
        else if (w.status == "Disbursed") s->setForeground(colors::cellInfo);
        else if (w.status == "Pending") s->setForeground(colors::cellWarning);
        table_->setItem(r, 6, s);
    }
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    pageLabel_->setText(QString("Page %1 of %2  (%3 records)").arg(page_).arg(tp).arg(total_));
    prevBtn_->setEnabled(page_ > 1);
    nextBtn_->setEnabled(page_ < tp);
}

void WelfareView::onAdd() { WelfareEditDialog dlg(this); if (dlg.exec() == QDialog::Accepted) refresh(); }
void WelfareView::onEdit() {
    int r = table_->currentRow(); if (r < 0) return;
    WelfareEditDialog dlg(this, table_->item(r, 0)->text().toLongLong());
    if (dlg.exec() == QDialog::Accepted) refresh();
}
void WelfareView::onDelete() {
    int r = table_->currentRow(); if (r < 0) return;
    if (QMessageBox::question(this, "Delete", "Delete this welfare request?") == QMessageBox::Yes) {
        WelfareService().deleteRequest(table_->item(r, 0)->text().toLongLong()); refresh();
    }
}
void WelfareView::onApprove() {
    int r = table_->currentRow(); if (r < 0) return;
    qint64 id = table_->item(r, 0)->text().toLongLong();
    bool ok = false;
    double amt = QInputDialog::getDouble(this, "Approve Welfare Request",
        "Enter approved amount:", 0, 0, 10000000, 2, &ok);
    if (!ok) return;
    QString remarks = QInputDialog::getText(this, "Remarks", "Approval remarks:");
    WelfareService().approveRequest(id, amt, remarks);
    refresh();
}
void WelfareView::onReject() {
    int r = table_->currentRow(); if (r < 0) return;
    QString remarks = QInputDialog::getText(this, "Rejection Reason", "Reason for rejection:");
    WelfareService().rejectRequest(table_->item(r, 0)->text().toLongLong(), remarks);
    refresh();
}
void WelfareView::onDisburse() {
    int r = table_->currentRow(); if (r < 0) return;
    if (QMessageBox::question(this, "Disburse", "Confirm disbursement of this welfare request?") == QMessageBox::Yes) {
        WelfareService().disburseRequest(table_->item(r, 0)->text().toLongLong(), QDate::currentDate().toString(Qt::ISODate));
        refresh();
    }
}
void WelfareView::onPrint() {
    ReportService svc;
    auto row = svc.welfareReport(QString(), QDate::currentDate().toString(Qt::ISODate));
    QString path = svc.ensureExportPath("welfare_report.pdf");
    if (!svc.exportToPdf(row, "Welfare Report", path).isEmpty())
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}
void WelfareView::onExport() {
    QString path = QFileDialog::getSaveFileName(this, "Export", "welfare.csv", "CSV (*.csv)");
    if (path.isEmpty()) return;
    ReportService svc;
    auto row = svc.welfareReport(QString(), QDate::currentDate().toString(Qt::ISODate));
    svc.exportToCsv(row, path);
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}
void WelfareView::onPrevPage() { if (page_ > 1) { --page_; refresh(); } }
void WelfareView::onNextPage() {
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    if (page_ < tp) { ++page_; refresh(); }
}

} // namespace mms
