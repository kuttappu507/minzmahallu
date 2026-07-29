/*
 * AccountingView.cpp + TransactionEditDialog inline
 */
#include "AccountingView.h"
#include "../services/AccountingService.h"
#include "../services/ReportService.h"
#include "../repositories/AccountingRepository.h"

#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QComboBox>
#include <QDateEdit>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QTabWidget>
#include <QGroupBox>
#include <QFormLayout>
#include <QLineEdit>
#include <QDoubleSpinBox>
#include <QDialogButtonBox>
#include <QMessageBox>
#include <QFileDialog>
#include <QDesktopServices>
#include <QUrl>
#include "../core/I18N.h"

namespace mms {

class TransactionEditDialog : public QDialog {
public:
    TransactionEditDialog(QWidget* parent, const QString& presetType = QString(), qint64 id = 0)
        : QDialog(parent), id_(id), presetType_(presetType) {
        setWindowTitle((id > 0 ? "Edit " : "Add ") + (presetType.isEmpty() ? "Transaction" : presetType));
        setMinimumWidth(480);
        setupUi();
        loadAccounts();
        if (id > 0) load();
        else {
            dateEdit_->setDate(QDate::currentDate());
            if (!presetType.isEmpty()) {
                typeCombo_->setCurrentText(presetType);
                typeCombo_->setEnabled(false);
            }
        }
    }
private:
    void setupUi() {
        auto* layout = new QVBoxLayout(this);
        auto* g = new QGroupBox(TR("acc_title"), this);
        auto* f = new QFormLayout(g);
        dateEdit_ = new QDateEdit(QDate::currentDate(), this);
        dateEdit_->setCalendarPopup(true);
        dateEdit_->setDisplayFormat("yyyy-MM-dd");
        typeCombo_ = new QComboBox(this);
        typeCombo_->addItems({"Income", "Expense"});
        accountCombo_ = new QComboBox(this);
        amountEdit_ = new QDoubleSpinBox(this);
        amountEdit_->setRange(1, 100000000);
        amountEdit_->setDecimals(2);
        amountEdit_->setSingleStep(100);
        methodCombo_ = new QComboBox(this);
        methodCombo_->addItems({"Cash", "Cheque", "UPI", "Bank Transfer", "Card", "Other"});
        refEdit_ = new QLineEdit(this);
        receiptEdit_ = new QLineEdit(this);
        descEdit_ = new QLineEdit(this);
        descEdit_->setPlaceholderText("e.g., Imam salary April 2024");

        f->addRow(TR("don_date") + "*:", dateEdit_);
        f->addRow(TR("acc_type") + "*:", typeCombo_);
        f->addRow(TR("acc_account") + "*:", accountCombo_);
        f->addRow(TR("sub_amount") + "*:", amountEdit_);
        f->addRow(TR("sub_method") + ":", methodCombo_);
        f->addRow(TR("acc_reference") + ":", refEdit_);
        f->addRow(TR("sub_receipt") + ":", receiptEdit_);
        f->addRow(TR("acc_description") + "*:", descEdit_);
        layout->addWidget(g);

        connect(typeCombo_, &QComboBox::currentTextChanged, this, [this]{ reloadAccounts(); });

        auto* btns = new QDialogButtonBox(QDialogButtonBox::Save | QDialogButtonBox::Cancel, this);
    btns->button(QDialogButtonBox::Save)->setText(TR("action_save"));
    btns->button(QDialogButtonBox::Cancel)->setText(TR("action_cancel"));
        connect(btns, &QDialogButtonBox::accepted, this, [this]{ onSave(); });
        connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
        layout->addWidget(btns);
    }
    void loadAccounts() {
        QString t = typeCombo_->currentText();
        AccountingService svc;
        auto accs = svc.accounts(t);
        accountCombo_->clear();
        for (const auto& a : accs) {
            accountCombo_->addItem(QString("%1 - %2").arg(a.code).arg(a.name), a.id);
        }
    }
    void reloadAccounts() { loadAccounts(); }
    void load() {
        AccountingRepository repo;
        auto t = repo.findTransaction(id_);
        if (!t) return;
        dateEdit_->setDate(QDate::fromString(t->txnDate, Qt::ISODate));
        typeCombo_->setCurrentText(t->type);
        reloadAccounts();
        accountCombo_->setCurrentIndex(accountCombo_->findData(t->accountId));
        amountEdit_->setValue(t->amount);
        methodCombo_->setCurrentText(t->paymentMethod);
        refEdit_->setText(t->reference);
        receiptEdit_->setText(t->receiptNumber);
        descEdit_->setText(t->description);
    }
    void onSave() {
        if (descEdit_->text().trimmed().isEmpty()) {
            QMessageBox::warning(this, "Validation", "Description is required.");
            return;
        }
        Transaction t;
        t.id = id_;
        t.txnDate = dateEdit_->date().toString(Qt::ISODate);
        t.type = typeCombo_->currentText();
        t.accountId = accountCombo_->currentData().toLongLong();
        t.amount = amountEdit_->value();
        t.paymentMethod = methodCombo_->currentText();
        t.reference = refEdit_->text().trimmed();
        t.receiptNumber = receiptEdit_->text().trimmed();
        t.description = descEdit_->text().trimmed();
        AccountingService svc;
        QString err;
        bool ok = (id_ > 0) ? svc.updateTransaction(t, &err) : (svc.createTransaction(t, &err) > 0);
        if (ok) accept();
        else QMessageBox::warning(this, "Save Failed", err);
    }
    qint64 id_ = 0;
    QString presetType_;
    QDateEdit* dateEdit_ = nullptr;
    QComboBox* typeCombo_ = nullptr;
    QComboBox* accountCombo_ = nullptr;
    QDoubleSpinBox* amountEdit_ = nullptr;
    QComboBox* methodCombo_ = nullptr;
    QLineEdit* refEdit_ = nullptr;
    QLineEdit* receiptEdit_ = nullptr;
    QLineEdit* descEdit_ = nullptr;
};

// ===== AccountingView =====

AccountingView::AccountingView(QWidget* parent) : QWidget(parent) {
    setupUi();
    refresh();
}

void AccountingView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);
    layout->addWidget(new QLabel(TR("acc_title"), this));

    summaryLabel_ = new QLabel(this);
    layout->addWidget(summaryLabel_);

    tabs_ = new QTabWidget(this);
    auto* txnTab = new QWidget(this);
    auto* tLayout = new QVBoxLayout(txnTab);

    auto* fb = new QHBoxLayout();
    typeFilter_ = new QComboBox(this);
    typeFilter_->addItems({"", "Income", "Expense"});
    typeFilter_->setMinimumHeight(32);
    connect(typeFilter_, &QComboBox::currentTextChanged, this, [this]{ page_=1; refresh(); });
    fromDate_ = new QDateEdit(QDate::currentDate().addMonths(-1), this);
    fromDate_->setCalendarPopup(true); fromDate_->setDisplayFormat("yyyy-MM-dd");
    toDate_ = new QDateEdit(QDate::currentDate(), this);
    toDate_->setCalendarPopup(true); toDate_->setDisplayFormat("yyyy-MM-dd");
    connect(fromDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    connect(toDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    fb->addWidget(new QLabel("Type:", this));
    fb->addWidget(typeFilter_);
    fb->addWidget(new QLabel("From:", this));
    fb->addWidget(fromDate_);
    fb->addWidget(new QLabel("To:", this));
    fb->addWidget(toDate_);
    fb->addStretch();
    tLayout->addLayout(fb);

    auto* bb = new QHBoxLayout();
    addIncomeBtn_ = new QPushButton(TR("acc_add_income"), this);
    addIncomeBtn_->setObjectName("action_add");
    addExpenseBtn_ = new QPushButton(TR("acc_add_expense"), this);
    addExpenseBtn_->setObjectName("action_add");
    deleteBtn_ = new QPushButton(TR("action_delete"), this);
    deleteBtn_->setObjectName("action_delete");
    printBtn_ = new QPushButton(TR("action_print"), this);
    printBtn_->setObjectName("action_print");
    exportBtn_ = new QPushButton(TR("action_export"), this);
    exportBtn_->setObjectName("action_export");
    for (auto* b : {addIncomeBtn_, addExpenseBtn_, deleteBtn_, printBtn_, exportBtn_}) {
        b->setMinimumHeight(32); bb->addWidget(b);
    }
    bb->addStretch();
    tLayout->addLayout(bb);

    table_ = new QTableWidget(this);
    table_->setColumnCount(7);
    table_->setHorizontalHeaderLabels({"ID","Date","Type","Account","Description","Amount","Receipt"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    tLayout->addWidget(table_, 1);

    auto* pb = new QHBoxLayout();
    prevBtn_ = new QPushButton(TR("action_previous"), this);
    prevBtn_->setObjectName("action_prev");
    nextBtn_ = new QPushButton(TR("action_next") + " ", this);
    nextBtn_->setObjectName("action_next");
    pageLabel_ = new QLabel(this);
    pageLabel_->setAlignment(Qt::AlignCenter);
    connect(prevBtn_, &QPushButton::clicked, this, &AccountingView::onPrevPage);
    connect(nextBtn_, &QPushButton::clicked, this, &AccountingView::onNextPage);
    pb->addWidget(prevBtn_); pb->addStretch(); pb->addWidget(pageLabel_); pb->addStretch(); pb->addWidget(nextBtn_);
    tLayout->addLayout(pb);

    tabs_->addTab(txnTab, " Transactions");

    // Summary tab
    auto* smTab = new QWidget(this);
    auto* smLayout = new QVBoxLayout(smTab);
    summaryTable_ = new QTableWidget(this);
    summaryTable_->setColumnCount(4);
    summaryTable_->setHorizontalHeaderLabels({"Code","Name","Type","Total"});
    summaryTable_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    summaryTable_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    summaryTable_->setAlternatingRowColors(true);
    smLayout->addWidget(summaryTable_, 1);
    tabs_->addTab(smTab, " Summary");

    layout->addWidget(tabs_, 1);

    connect(addIncomeBtn_, &QPushButton::clicked, this, &AccountingView::onAddIncome);
    connect(addExpenseBtn_, &QPushButton::clicked, this, &AccountingView::onAddExpense);
    connect(deleteBtn_, &QPushButton::clicked, this, &AccountingView::onDelete);
    connect(printBtn_, &QPushButton::clicked, this, &AccountingView::onPrint);
    connect(exportBtn_, &QPushButton::clicked, this, &AccountingView::onExport);
    connect(tabs_, &QTabWidget::currentChanged, this, &AccountingView::onTabChanged);
}

void AccountingView::refresh() {
    if (tabs_->currentIndex() == 0) loadTable();
    else loadSummary();
    loadSummaryLabel();
}

void AccountingView::loadSummaryLabel() {
    AccountingService svc;
    double inc = svc.totalIncome(fromDate_->date().toString(Qt::ISODate),
                                 toDate_->date().toString(Qt::ISODate));
    double exp = svc.totalExpense(fromDate_->date().toString(Qt::ISODate),
                                  toDate_->date().toString(Qt::ISODate));
    double bal = inc - exp;
    summaryLabel_->setText(QString(" Income: ₹%1   |   Expense: ₹%2   |   Balance: ₹%3  (Period: %4 to %5)")
        .arg(inc, 0, 'f', 2).arg(exp, 0, 'f', 2)
        .arg(bal, 0, 'f', 2)
        .arg(fromDate_->date().toString(Qt::ISODate))
        .arg(toDate_->date().toString(Qt::ISODate)));
}

void AccountingView::loadTable() {
    AccountingService svc;
    int total = 0;
    auto items = svc.listTransactions(page_, pageSize_,
                                      fromDate_->date().toString(Qt::ISODate),
                                      toDate_->date().toString(Qt::ISODate),
                                      typeFilter_->currentText(), 0, &total);
    total_ = total;
    table_->setRowCount(0);
    for (const auto& t : items) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(QString::number(t.id)));
        table_->setItem(r, 1, new QTableWidgetItem(t.txnDate));
        auto* typeItem = new QTableWidgetItem(t.type);
        typeItem->setForeground(t.type == "Income" ? QColor("#2a7a3a") : QColor("#c0392b"));
        table_->setItem(r, 2, typeItem);
        table_->setItem(r, 3, new QTableWidgetItem(t.accountName));
        table_->setItem(r, 4, new QTableWidgetItem(t.description));
        table_->setItem(r, 5, new QTableWidgetItem(QString::number(t.amount, 'f', 2)));
        table_->setItem(r, 6, new QTableWidgetItem(t.receiptNumber));
    }
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    pageLabel_->setText(QString("Page %1 of %2  (%3 records)").arg(page_).arg(tp).arg(total_));
    prevBtn_->setEnabled(page_ > 1);
    nextBtn_->setEnabled(page_ < tp);
}

void AccountingView::loadSummary() {
    AccountingService svc;
    auto totals = svc.accountTotals(fromDate_->date().toString(Qt::ISODate),
                                    toDate_->date().toString(Qt::ISODate));
    summaryTable_->setRowCount(0);
    for (const auto& a : totals) {
        int r = summaryTable_->rowCount();
        summaryTable_->insertRow(r);
        summaryTable_->setItem(r, 0, new QTableWidgetItem(a.code));
        summaryTable_->setItem(r, 1, new QTableWidgetItem(a.name));
        summaryTable_->setItem(r, 2, new QTableWidgetItem(a.type));
        auto* amtItem = new QTableWidgetItem(QString::number(a.total, 'f', 2));
        amtItem->setForeground(a.type == "Income" ? QColor("#2a7a3a") : QColor("#c0392b"));
        summaryTable_->setItem(r, 3, amtItem);
    }
}

void AccountingView::onAddIncome() {
    TransactionEditDialog dlg(this, "Income");
    if (dlg.exec() == QDialog::Accepted) refresh();
}

void AccountingView::onAddExpense() {
    TransactionEditDialog dlg(this, "Expense");
    if (dlg.exec() == QDialog::Accepted) refresh();
}

void AccountingView::onDelete() {
    int r = table_->currentRow();
    if (r < 0) return;
    qint64 id = table_->item(r, 0)->text().toLongLong();
    if (QMessageBox::question(this, "Delete", "Delete this transaction?") == QMessageBox::Yes) {
        AccountingService().deleteTransaction(id);
        refresh();
    }
}

void AccountingView::onPrint() {
    ReportService svc;
    auto row = svc.cashBookReport(fromDate_->date().toString(Qt::ISODate),
                                  toDate_->date().toString(Qt::ISODate));
    QString path = svc.ensureExportPath("cash_book.pdf");
    if (!svc.exportToPdf(row, "Cash Book Report", path,
                         fromDate_->date().toString(Qt::ISODate),
                         toDate_->date().toString(Qt::ISODate)).isEmpty())
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}

void AccountingView::onExport() {
    QString path = QFileDialog::getSaveFileName(this, "Export Cash Book",
        "cash_book.csv", "CSV (*.csv)");
    if (path.isEmpty()) return;
    ReportService svc;
    auto row = svc.cashBookReport(fromDate_->date().toString(Qt::ISODate),
                                  toDate_->date().toString(Qt::ISODate));
    svc.exportToCsv(row, path);
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}

void AccountingView::onTabChanged(int) { refresh(); }
void AccountingView::onPrevPage() { if (page_ > 1) { --page_; refresh(); } }
void AccountingView::onNextPage() {
    int tp = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    if (page_ < tp) { ++page_; refresh(); }
}

} // namespace mms
