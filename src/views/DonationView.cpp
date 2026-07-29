/*
 * DonationView.cpp + embedded DonationEditDialog
 */
#include "DonationView.h"
#include "../services/DonationService.h"
#include "../services/FamilyService.h"
#include "../services/MemberService.h"
#include "../services/ReportService.h"
#include "../repositories/DonationRepository.h"
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
#include <QMessageBox>
#include <QFileDialog>
#include <QGroupBox>
#include <QFormLayout>
#include <QDoubleSpinBox>
#include <QTextEdit>
#include <QDialogButtonBox>
#include <QDesktopServices>
#include <QUrl>
#include "../core/I18N.h"

namespace mms {

// ===== DonationEditDialog (inline) =====
class DonationEditDialog : public QDialog {
public:
    DonationEditDialog(QWidget* parent, qint64 id = 0) : QDialog(parent), id_(id) {
        setWindowTitle(id > 0 ? "Edit Donation" : "Record Donation");
        setMinimumWidth(520);
        setupUi();
        loadCategories();
        if (id > 0) load();
        else {
            receiptEdit_->setText(DonationService().nextReceiptNumber());
            donationDateEdit_->setDate(QDate::currentDate());
        }
    }

private:
    void setupUi() {
        auto* layout = new QVBoxLayout(this);
        auto* g = new QGroupBox(TR("don_title"), this);
        auto* f = new QFormLayout(g);
        donorNameEdit_ = new QLineEdit(this);
        donorPhoneEdit_ = new QLineEdit(this);
        donorAddressEdit_ = new QTextEdit(this); donorAddressEdit_->setMaximumHeight(50);
        categoryCombo_ = new QComboBox(this);
        amountEdit_ = new QDoubleSpinBox(this);
        amountEdit_->setRange(1, 10000000);
        amountEdit_->setDecimals(2);
        amountEdit_->setSingleStep(100);
        donationDateEdit_ = new QDateEdit(QDate::currentDate(), this);
        donationDateEdit_->setCalendarPopup(true);
        donationDateEdit_->setDisplayFormat("yyyy-MM-dd");
        receiptEdit_ = new QLineEdit(this);
        purposeEdit_ = new QLineEdit(this);
        remarksEdit_ = new QTextEdit(this); remarksEdit_->setMaximumHeight(50);
        methodCombo_ = new QComboBox(this);
        methodCombo_->addItems({"Cash", "Cheque", "UPI", "Bank Transfer", "Card", "Other"});

        f->addRow(TR("don_donor_name") + "*:", donorNameEdit_);
        f->addRow(TR("family_phone") + ":", donorPhoneEdit_);
        f->addRow(TR("family_address") + ":", donorAddressEdit_);
        f->addRow(TR("don_category") + "*:", categoryCombo_);
        f->addRow(TR("sub_amount") + "*:", amountEdit_);
        f->addRow(TR("don_date") + ":", donationDateEdit_);
        f->addRow(TR("sub_receipt") + ":", receiptEdit_);
        f->addRow(TR("don_purpose") + ":", purposeEdit_);
        f->addRow(TR("sub_method") + ":", methodCombo_);
        f->addRow(TR("family_notes") + ":", remarksEdit_);
        layout->addWidget(g);
        auto* btns = new QDialogButtonBox(QDialogButtonBox::Save | QDialogButtonBox::Cancel, this);
    btns->button(QDialogButtonBox::Save)->setText(TR("action_save"));
    btns->button(QDialogButtonBox::Cancel)->setText(TR("action_cancel"));
        connect(btns, &QDialogButtonBox::accepted, this, [this]{ onSave(); });
        connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
        layout->addWidget(btns);
    }
    void loadCategories() {
        DonationService svc;
        auto cats = svc.categories();
        for (const auto& c : cats) categoryCombo_->addItem(c.name, c.id);
    }
    void load() {
        DonationRepository repo;
        auto d = repo.findById(id_);
        if (!d) return;
        donorNameEdit_->setText(d->donorName);
        donorPhoneEdit_->setText(d->donorPhone);
        donorAddressEdit_->setPlainText(d->donorAddress);
        categoryCombo_->setCurrentIndex(categoryCombo_->findData(d->categoryId));
        amountEdit_->setValue(d->amount);
        donationDateEdit_->setDate(QDate::fromString(d->donationDate, Qt::ISODate));
        receiptEdit_->setText(d->receiptNumber);
        purposeEdit_->setText(d->purpose);
        remarksEdit_->setPlainText(d->remarks);
        methodCombo_->setCurrentText(d->paymentMethod);
    }
    void onSave() {
        Donation d;
        d.id = id_;
        d.donorName = donorNameEdit_->text().trimmed();
        d.donorPhone = donorPhoneEdit_->text().trimmed();
        d.donorAddress = donorAddressEdit_->toPlainText().trimmed();
        d.categoryId = categoryCombo_->currentData().toLongLong();
        d.amount = amountEdit_->value();
        d.donationDate = donationDateEdit_->date().toString(Qt::ISODate);
        d.receiptNumber = receiptEdit_->text().trimmed();
        d.purpose = purposeEdit_->text().trimmed();
        d.remarks = remarksEdit_->toPlainText().trimmed();
        d.paymentMethod = methodCombo_->currentText();
        DonationService svc;
        QString err;
        bool ok = (id_ > 0) ? svc.updateDonation(d, &err) : (svc.createDonation(d, &err) > 0);
        if (ok) accept();
        else QMessageBox::warning(this, "Save Failed", err);
    }

    qint64 id_ = 0;
    QLineEdit* donorNameEdit_ = nullptr;
    QLineEdit* donorPhoneEdit_ = nullptr;
    QTextEdit* donorAddressEdit_ = nullptr;
    QComboBox* categoryCombo_ = nullptr;
    QDoubleSpinBox* amountEdit_ = nullptr;
    QDateEdit* donationDateEdit_ = nullptr;
    QLineEdit* receiptEdit_ = nullptr;
    QLineEdit* purposeEdit_ = nullptr;
    QTextEdit* remarksEdit_ = nullptr;
    QComboBox* methodCombo_ = nullptr;
};

// ===== DonationView =====

DonationView::DonationView(QWidget* parent) : QWidget(parent) {
    setupUi();
    refresh();
}

void DonationView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(new QLabel(TR("don_title"), this));

    summaryLabel_ = new QLabel(this);
    layout->addWidget(summaryLabel_);

    auto* fb = new QHBoxLayout();
    searchEdit_ = new QLineEdit(this);
    searchEdit_->setPlaceholderText(" Search by donor, receipt...");
    searchEdit_->setMinimumHeight(32);
    connect(searchEdit_, &QLineEdit::textChanged, this, [this]{ page_=1; refresh(); });
    fb->addWidget(searchEdit_, 2);
    categoryCombo_ = new QComboBox(this);
    categoryCombo_->addItem("All Categories", 0);
    DonationService svc;
    for (const auto& c : svc.categories()) categoryCombo_->addItem(c.name, c.id);
    connect(categoryCombo_, &QComboBox::currentIndexChanged, this, [this]{ page_=1; refresh(); });
    fb->addWidget(new QLabel("Category:", this));
    fb->addWidget(categoryCombo_);
    fromDate_ = new QDateEdit(QDate::currentDate().addMonths(-1), this);
    fromDate_->setCalendarPopup(true); fromDate_->setDisplayFormat("yyyy-MM-dd");
    toDate_ = new QDateEdit(QDate::currentDate(), this);
    toDate_->setCalendarPopup(true); toDate_->setDisplayFormat("yyyy-MM-dd");
    connect(fromDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    connect(toDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    fb->addWidget(new QLabel("From:", this));
    fb->addWidget(fromDate_);
    fb->addWidget(new QLabel("To:", this));
    fb->addWidget(toDate_);
    layout->addLayout(fb);

    auto* bb = new QHBoxLayout();
    addBtn_ = new QPushButton(TR("don_add"), this);
    addBtn_->setObjectName("action_add");
    editBtn_ = new QPushButton(TR("action_edit"), this);
    editBtn_->setObjectName("action_edit");
    deleteBtn_ = new QPushButton(TR("action_delete"), this);
    deleteBtn_->setObjectName("action_delete");
    printBtn_ = new QPushButton(TR("action_print"), this);
    printBtn_->setObjectName("action_print");
    exportBtn_ = new QPushButton(TR("action_export"), this);
    exportBtn_->setObjectName("action_export");
    for (auto* b : {addBtn_, editBtn_, deleteBtn_, printBtn_, exportBtn_}) {
        b->setMinimumHeight(32); bb->addWidget(b);
    }
    bb->addStretch();
    layout->addLayout(bb);

    table_ = new QTableWidget(this);
    table_->setColumnCount(7);
    table_->setHorizontalHeaderLabels({"ID","Receipt","Donor","Category","Amount","Date","Purpose"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    layout->addWidget(table_, 1);

    auto* pb = new QHBoxLayout();
    prevBtn_ = new QPushButton(TR("action_previous"), this);
    prevBtn_->setObjectName("action_prev");
    nextBtn_ = new QPushButton(TR("action_next") + " ", this);
    nextBtn_->setObjectName("action_next");
    pageLabel_ = new QLabel(this);
    pageLabel_->setAlignment(Qt::AlignCenter);
    connect(prevBtn_, &QPushButton::clicked, this, &DonationView::onPrevPage);
    connect(nextBtn_, &QPushButton::clicked, this, &DonationView::onNextPage);
    pb->addWidget(prevBtn_); pb->addStretch(); pb->addWidget(pageLabel_); pb->addStretch(); pb->addWidget(nextBtn_);
    layout->addLayout(pb);

    connect(addBtn_, &QPushButton::clicked, this, &DonationView::onAdd);
    connect(editBtn_, &QPushButton::clicked, this, &DonationView::onEdit);
    connect(deleteBtn_, &QPushButton::clicked, this, &DonationView::onDelete);
    connect(printBtn_, &QPushButton::clicked, this, &DonationView::onPrint);
    connect(exportBtn_, &QPushButton::clicked, this, &DonationView::onExport);
}

void DonationView::refresh() {
    loadTable();
    DonationService svc;
    double total = svc.totalDonations(fromDate_->date().toString(Qt::ISODate),
                                      toDate_->date().toString(Qt::ISODate));
    summaryLabel_->setText(QString(" Total Donations (%1 to %2): ₹%3")
                               .arg(fromDate_->date().toString(Qt::ISODate))
                               .arg(toDate_->date().toString(Qt::ISODate))
                               .arg(total, 0, 'f', 2));
}

void DonationView::loadTable() {
    DonationService svc;
    int total = 0;
    auto items = svc.list(page_, pageSize_,
                          fromDate_->date().toString(Qt::ISODate),
                          toDate_->date().toString(Qt::ISODate),
                          categoryCombo_->currentData().toLongLong(),
                          searchEdit_->text().trimmed(), &total);
    total_ = total;
    table_->setRowCount(0);
    for (const auto& d : items) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(QString::number(d.id)));
        table_->setItem(r, 1, new QTableWidgetItem(d.receiptNumber));
        table_->setItem(r, 2, new QTableWidgetItem(d.donorName));
        table_->setItem(r, 3, new QTableWidgetItem(d.categoryName));
        auto* amtItem = new QTableWidgetItem(QString::number(d.amount, 'f', 2));
        amtItem->setForeground(QColor("#2a7a3a"));
        table_->setItem(r, 4, new QTableWidgetItem(QString::number(d.amount, 'f', 2)));
        table_->setItem(r, 5, new QTableWidgetItem(d.donationDate));
        table_->setItem(r, 6, new QTableWidgetItem(d.purpose));
    }
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    pageLabel_->setText(QString("Page %1 of %2  (%3 records)").arg(page_).arg(tp).arg(total_));
    prevBtn_->setEnabled(page_ > 1);
    nextBtn_->setEnabled(page_ < tp);
}

void DonationView::onAdd() {
    DonationEditDialog dlg(this);
    if (dlg.exec() == QDialog::Accepted) refresh();
}

void DonationView::onEdit() {
    int r = table_->currentRow();
    if (r < 0) { QMessageBox::warning(this, "Edit", "Select a record first."); return; }
    DonationEditDialog dlg(this, table_->item(r, 0)->text().toLongLong());
    if (dlg.exec() == QDialog::Accepted) refresh();
}

void DonationView::onDelete() {
    int r = table_->currentRow();
    if (r < 0) return;
    qint64 id = table_->item(r, 0)->text().toLongLong();
    if (QMessageBox::question(this, "Delete", "Delete this donation?") == QMessageBox::Yes) {
        DonationService().deleteDonation(id);
        refresh();
    }
}

void DonationView::onPrint() {
    ReportService svc;
    auto row = svc.donationReport(fromDate_->date().toString(Qt::ISODate),
                                  toDate_->date().toString(Qt::ISODate));
    QString path = svc.ensureExportPath("donation_report.pdf");
    if (!svc.exportToPdf(row, "Donation Report", path,
                         fromDate_->date().toString(Qt::ISODate),
                         toDate_->date().toString(Qt::ISODate)).isEmpty())
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}

void DonationView::onExport() {
    QString path = QFileDialog::getSaveFileName(this, "Export Donations", "donations.csv", "CSV (*.csv)");
    if (path.isEmpty()) return;
    ReportService svc;
    auto row = svc.donationReport(fromDate_->date().toString(Qt::ISODate),
                                  toDate_->date().toString(Qt::ISODate));
    svc.exportToCsv(row, path);
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}

void DonationView::onPrevPage() { if (page_ > 1) { --page_; refresh(); } }
void DonationView::onNextPage() {
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    if (page_ < tp) { ++page_; refresh(); }
}

} // namespace mms
