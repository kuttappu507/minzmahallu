/*
 * SubscriptionView.cpp
 */
#include "SubscriptionView.h"
#include "../services/SubscriptionService.h"
#include "../services/ReportService.h"
#include "SubscriptionEditDialog.h"

#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QComboBox>
#include <QDateEdit>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QTabWidget>
#include <QGroupBox>
#include <QMessageBox>
#include <QFileDialog>
#include <QDesktopServices>
#include <QUrl>
#include "../core/I18N.h"
#include "../core/StyleProps.h"
#include "../core/ThemeColors.h"

namespace mms {

SubscriptionView::SubscriptionView(QWidget* parent) : QWidget(parent) {
    setupUi();
    refresh();
}

void SubscriptionView::setupUi() {
    setObjectName("contentArea");
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(22, 20, 22, 26);
    layout->setSpacing(12);

    layout->addWidget(new QLabel(TR("sub_title"), this));

    summaryLabel_ = new QLabel(this);
    layout->addWidget(summaryLabel_);

    tabs_ = new QTabWidget(this);

    // Collections tab
    auto* collectionsTab = new QWidget(this);
    auto* ctLayout = new QVBoxLayout(collectionsTab);

    auto* filterBar = new QHBoxLayout();
    searchEdit_ = new QLineEdit(this);
    searchEdit_->setPlaceholderText(" Search by receipt, family...");
    searchEdit_->setMinimumHeight(32);
    connect(searchEdit_, &QLineEdit::textChanged, this, [this]{ page_=1; refresh(); });
    filterBar->addWidget(searchEdit_, 2);

    statusFilter_ = new QComboBox(this);
    statusFilter_->addItems({"", "Paid", "Pending", "Overdue", "Partial"});
    statusFilter_->setMinimumHeight(32);
    connect(statusFilter_, &QComboBox::currentTextChanged, this, [this]{ page_=1; refresh(); });
    filterBar->addWidget(new QLabel("Status:", this));
    filterBar->addWidget(statusFilter_);

    fromDate_ = new QDateEdit(this);
    fromDate_->setCalendarPopup(true);
    fromDate_->setDisplayFormat("yyyy-MM-dd");
    fromDate_->setDate(QDate::currentDate().addMonths(-1));
    toDate_ = new QDateEdit(this);
    toDate_->setCalendarPopup(true);
    toDate_->setDisplayFormat("yyyy-MM-dd");
    toDate_->setDate(QDate::currentDate());
    connect(fromDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    connect(toDate_, &QDateEdit::dateChanged, this, [this]{ page_=1; refresh(); });
    filterBar->addWidget(new QLabel("From:", this));
    filterBar->addWidget(fromDate_);
    filterBar->addWidget(new QLabel("To:", this));
    filterBar->addWidget(toDate_);

    ctLayout->addLayout(filterBar);

    auto* btnBar = new QHBoxLayout();
    addBtn_ = new QPushButton(TR("sub_record_payment"), this);
    StyleProps::set(addBtn_, "primary");
    editBtn_ = new QPushButton(TR("action_edit"), this);
    StyleProps::set(editBtn_, "chip");
    deleteBtn_ = new QPushButton(TR("action_delete"), this);
    StyleProps::set(deleteBtn_, "ghostDanger");
    markOverdueBtn_ = new QPushButton(TR("sub_mark_overdue"), this);
    StyleProps::set(markOverdueBtn_, "ghostDanger");
    printBtn_ = new QPushButton(TR("action_print"), this);
    StyleProps::set(printBtn_, "chip");
    exportBtn_ = new QPushButton(TR("action_export"), this);
    StyleProps::set(exportBtn_, "chip");
    for (auto* b : {addBtn_, editBtn_, deleteBtn_, markOverdueBtn_, printBtn_, exportBtn_}) {
        b->setMinimumHeight(32);
        btnBar->addWidget(b);
    }
    btnBar->addStretch();
    ctLayout->addLayout(btnBar);

    table_ = new QTableWidget(this);
    table_->setColumnCount(8);
    table_->setHorizontalHeaderLabels({"ID","Receipt","Family","Member","Plan","Amount","Paid","Status"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    ctLayout->addWidget(table_, 1);

    auto* pageBar = new QHBoxLayout();
    prevBtn_ = new QPushButton(TR("action_previous"), this);
    StyleProps::set(prevBtn_, "chip");
    nextBtn_ = new QPushButton(TR("action_next") + " ", this);
    StyleProps::set(nextBtn_, "chip");
    pageLabel_ = new QLabel(this);
    pageLabel_->setAlignment(Qt::AlignCenter);
    connect(prevBtn_, &QPushButton::clicked, this, &SubscriptionView::onPrevPage);
    connect(nextBtn_, &QPushButton::clicked, this, &SubscriptionView::onNextPage);
    pageBar->addWidget(prevBtn_);
    pageBar->addStretch();
    pageBar->addWidget(pageLabel_);
    pageBar->addStretch();
    pageBar->addWidget(nextBtn_);
    ctLayout->addLayout(pageBar);

    tabs_->addTab(collectionsTab, " Collections");

    // Defaulters tab
    auto* defTab = new QWidget(this);
    auto* dtLayout = new QVBoxLayout(defTab);
    defaultersTable_ = new QTableWidget(this);
    defaultersTable_->setColumnCount(5);
    defaultersTable_->setHorizontalHeaderLabels({"Family No","House Name","Phone","Pending Count","Due Amount"});
    defaultersTable_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    defaultersTable_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    defaultersTable_->setAlternatingRowColors(true);
    dtLayout->addWidget(defaultersTable_, 1);
    tabs_->addTab(defTab, " Defaulters");

    layout->addWidget(tabs_, 1);

    connect(addBtn_, &QPushButton::clicked, this, &SubscriptionView::onAdd);
    connect(editBtn_, &QPushButton::clicked, this, &SubscriptionView::onEdit);
    connect(deleteBtn_, &QPushButton::clicked, this, &SubscriptionView::onDelete);
    connect(markOverdueBtn_, &QPushButton::clicked, this, &SubscriptionView::onMarkOverdue);
    connect(printBtn_, &QPushButton::clicked, this, &SubscriptionView::onPrint);
    connect(exportBtn_, &QPushButton::clicked, this, &SubscriptionView::onExport);
    connect(tabs_, &QTabWidget::currentChanged, this, &SubscriptionView::onTabChanged);
}

void SubscriptionView::refresh() {
    if (tabs_->currentIndex() == 0) loadTable();
    else loadDefaulters();

    SubscriptionService svc;
    double collected = svc.totalCollected(fromDate_->date().toString(Qt::ISODate),
                                          toDate_->date().toString(Qt::ISODate));
    double pending = svc.totalPending();
    summaryLabel_->setText(QString(" Collected (%1 to %2): ₹%3   |   Total Pending Dues: ₹%4")
                               .arg(fromDate_->date().toString(Qt::ISODate))
                               .arg(toDate_->date().toString(Qt::ISODate))
                               .arg(collected, 0, 'f', 2)
                               .arg(pending, 0, 'f', 2));
}

void SubscriptionView::loadTable() {
    SubscriptionService svc;
    int total = 0;
    auto items = svc.list(page_, pageSize_, statusFilter_->currentText(),
                          fromDate_->date().toString(Qt::ISODate),
                          toDate_->date().toString(Qt::ISODate), 0, &total);
    total_ = total;
    table_->setRowCount(0);
    for (const auto& s : items) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(QString::number(s.id)));
        table_->setItem(r, 1, new QTableWidgetItem(s.receiptNumber));
        table_->setItem(r, 2, new QTableWidgetItem(s.familyNumber));
        table_->setItem(r, 3, new QTableWidgetItem(s.memberName));
        table_->setItem(r, 4, new QTableWidgetItem(s.planName));
        table_->setItem(r, 5, new QTableWidgetItem(QString::number(s.amount, 'f', 2)));
        table_->setItem(r, 6, new QTableWidgetItem(QString::number(s.amountPaid, 'f', 2)));
        auto* statusItem = new QTableWidgetItem(s.status);
        if (s.status == "Paid") statusItem->setForeground(colors::cellPositive);
        else if (s.status == "Overdue") statusItem->setForeground(colors::cellNegative);
        else if (s.status == "Pending") statusItem->setForeground(colors::cellWarning);
        else statusItem->setForeground(colors::cellAccent);
        table_->setItem(r, 7, statusItem);
    }
    int totalPages = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    pageLabel_->setText(QString("Page %1 of %2  (%3 records)").arg(page_).arg(totalPages).arg(total_));
    prevBtn_->setEnabled(page_ > 1);
    nextBtn_->setEnabled(page_ < totalPages);
}

void SubscriptionView::loadDefaulters() {
    SubscriptionService svc;
    auto defs = svc.defaulters();
    defaultersTable_->setRowCount(0);
    double totalDue = 0;
    for (const auto& d : defs) {
        int r = defaultersTable_->rowCount();
        defaultersTable_->insertRow(r);
        defaultersTable_->setItem(r, 0, new QTableWidgetItem(d.familyNumber));
        defaultersTable_->setItem(r, 1, new QTableWidgetItem(d.houseName));
        defaultersTable_->setItem(r, 2, new QTableWidgetItem(d.phone));
        defaultersTable_->setItem(r, 3, new QTableWidgetItem(QString::number(d.pendingCount)));
        auto* amtItem = new QTableWidgetItem(QString::number(d.dueAmount, 'f', 2));
        amtItem->setForeground(colors::cellNegative);
        defaultersTable_->setItem(r, 4, amtItem);
        totalDue += d.dueAmount;
    }
    defaultersTable_->setToolTip(QString("Total due: ₹%1").arg(totalDue, 0, 'f', 2));
}

void SubscriptionView::onAdd() {
    SubscriptionEditDialog dlg(this);
    if (dlg.exec() == QDialog::Accepted) refresh();
}

void SubscriptionView::onEdit() {
    int r = table_->currentRow();
    if (r < 0) { QMessageBox::warning(this, "Edit", "Select a record first."); return; }
    qint64 id = table_->item(r, 0)->text().toLongLong();
    SubscriptionEditDialog dlg(this, id);
    if (dlg.exec() == QDialog::Accepted) refresh();
}

void SubscriptionView::onDelete() {
    int r = table_->currentRow();
    if (r < 0) return;
    qint64 id = table_->item(r, 0)->text().toLongLong();
    if (QMessageBox::question(this, "Delete", "Delete this subscription record?") == QMessageBox::Yes) {
        SubscriptionService().deleteSubscription(id);
        refresh();
    }
}

void SubscriptionView::onMarkOverdue() {
    int n = SubscriptionService().markOverdue();
    QMessageBox::information(this, "Marked Overdue", QString("%1 subscription(s) marked as overdue.").arg(n));
    refresh();
}

void SubscriptionView::onPrint() {
    ReportService svc;
    auto row = svc.subscriptionReport(fromDate_->date().toString(Qt::ISODate),
                                      toDate_->date().toString(Qt::ISODate));
    QString path = svc.ensureExportPath("subscription_report.pdf");
    if (!svc.exportToPdf(row, "Subscription Report", path,
                         fromDate_->date().toString(Qt::ISODate),
                         toDate_->date().toString(Qt::ISODate)).isEmpty())
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}

void SubscriptionView::onExport() {
    QString path = QFileDialog::getSaveFileName(this, "Export Subscriptions",
        "subscriptions.csv", "CSV (*.csv)");
    if (path.isEmpty()) return;
    ReportService svc;
    auto row = svc.subscriptionReport(fromDate_->date().toString(Qt::ISODate),
                                      toDate_->date().toString(Qt::ISODate));
    svc.exportToCsv(row, path);
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}

void SubscriptionView::onShowDefaulters() { tabs_->setCurrentIndex(1); }
void SubscriptionView::onTabChanged(int) { refresh(); }
void SubscriptionView::onPrevPage() { if (page_ > 1) { --page_; refresh(); } }
void SubscriptionView::onNextPage() {
    int totalPages = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    if (page_ < totalPages) { ++page_; refresh(); }
}

} // namespace mms
