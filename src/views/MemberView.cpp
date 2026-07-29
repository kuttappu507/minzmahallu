/*
 * MemberView.cpp
 */
#include "MemberView.h"
#include "../services/MemberService.h"
#include "../services/ReportService.h"
#include "MemberEditDialog.h"

#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QComboBox>
#include <QPushButton>
#include <QTableWidget>
#include <QHeaderView>
#include <QMessageBox>
#include <QFileDialog>
#include <QDesktopServices>
#include <QUrl>
#include "../core/I18N.h"
#include "../core/StyleProps.h"

namespace mms {

MemberView::MemberView(QWidget* parent) : QWidget(parent) {
    setupUi();
    refresh();
}

void MemberView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);

    layout->addWidget(new QLabel(TR("member_title"), this));

    auto* filterBar = new QHBoxLayout();
    searchEdit_ = new QLineEdit(this);
    searchEdit_->setPlaceholderText(TR("member_search_placeholder"));
    searchEdit_->setClearButtonEnabled(true);
    searchEdit_->setMinimumHeight(32);
    connect(searchEdit_, &QLineEdit::textChanged, this, [this]{ page_=1; refresh(); });
    filterBar->addWidget(searchEdit_, 3);

    genderFilter_ = new QComboBox(this);
    genderFilter_->addItems({"", "Male", "Female", "Other"});
    genderFilter_->setMinimumHeight(32);
    connect(genderFilter_, &QComboBox::currentTextChanged, this, [this]{ page_=1; refresh(); });
    filterBar->addWidget(new QLabel("Gender:", this));
    filterBar->addWidget(genderFilter_);

    statusFilter_ = new QComboBox(this);
    statusFilter_->addItems({"", "Active", "Inactive", "Deceased"});
    statusFilter_->setMinimumHeight(32);
    connect(statusFilter_, &QComboBox::currentTextChanged, this, [this]{ page_=1; refresh(); });
    filterBar->addWidget(new QLabel("Status:", this));
    filterBar->addWidget(statusFilter_);

    layout->addLayout(filterBar);

    auto* btnBar = new QHBoxLayout();
    addBtn_ = new QPushButton(TR("member_add"), this);
    StyleProps::set(addBtn_, "primary");
    editBtn_ = new QPushButton(TR("action_edit"), this);
    StyleProps::set(editBtn_, "chip");
    deleteBtn_ = new QPushButton(TR("action_delete"), this);
    StyleProps::set(deleteBtn_, "ghostDanger");
    printBtn_ = new QPushButton(TR("action_print"), this);
    StyleProps::set(printBtn_, "chip");
    exportBtn_ = new QPushButton(TR("action_export"), this);
    StyleProps::set(exportBtn_, "chip");
    for (auto* b : {addBtn_, editBtn_, deleteBtn_, printBtn_, exportBtn_}) {
        b->setMinimumHeight(32);
        btnBar->addWidget(b);
    }
    btnBar->addStretch();
    layout->addLayout(btnBar);

    table_ = new QTableWidget(this);
    table_->setColumnCount(8);
    table_->setHorizontalHeaderLabels({"ID","Code","Name","Gender","Age","Mobile","Family","Status"});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(1, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(3, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(4, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(7, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    connect(table_, &QTableWidget::cellDoubleClicked, this, &MemberView::onRowDoubleClicked);
    layout->addWidget(table_, 1);

    auto* pageBar = new QHBoxLayout();
    prevBtn_ = new QPushButton(TR("action_previous"), this);
    StyleProps::set(prevBtn_, "chip");
    nextBtn_ = new QPushButton(TR("action_next") + " ", this);
    StyleProps::set(nextBtn_, "chip");
    pageLabel_ = new QLabel(this);
    pageLabel_->setAlignment(Qt::AlignCenter);
    connect(prevBtn_, &QPushButton::clicked, this, &MemberView::onPrevPage);
    connect(nextBtn_, &QPushButton::clicked, this, &MemberView::onNextPage);
    pageBar->addWidget(prevBtn_);
    pageBar->addStretch();
    pageBar->addWidget(pageLabel_);
    pageBar->addStretch();
    pageBar->addWidget(nextBtn_);
    layout->addLayout(pageBar);

    connect(addBtn_, &QPushButton::clicked, this, &MemberView::onAdd);
    connect(editBtn_, &QPushButton::clicked, this, &MemberView::onEdit);
    connect(deleteBtn_, &QPushButton::clicked, this, &MemberView::onDelete);
    connect(printBtn_, &QPushButton::clicked, this, &MemberView::onPrint);
    connect(exportBtn_, &QPushButton::clicked, this, &MemberView::onExport);
}

void MemberView::refresh() { loadTable(); }

void MemberView::loadTable() {
    MemberService svc;
    int total = 0;
    auto members = svc.searchMembers(searchEdit_->text().trimmed(), page_, pageSize_,
                                     genderFilter_->currentText(),
                                     statusFilter_->currentText(), 0, &total);
    total_ = total;
    table_->setRowCount(0);
    for (const auto& m : members) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(QString::number(m.id)));
        table_->setItem(r, 1, new QTableWidgetItem(m.memberCode));
        table_->setItem(r, 2, new QTableWidgetItem(m.name));
        table_->setItem(r, 3, new QTableWidgetItem(m.gender));
        table_->setItem(r, 4, new QTableWidgetItem(QString::number(m.age)));
        table_->setItem(r, 5, new QTableWidgetItem(m.mobile));
        table_->setItem(r, 6, new QTableWidgetItem(m.familyNumber + " / " + m.houseName));
        table_->setItem(r, 7, new QTableWidgetItem(m.status));
    }
    int totalPages = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    pageLabel_->setText(QString("Page %1 of %2  (%3 members)")
                            .arg(page_).arg(totalPages).arg(total_));
    prevBtn_->setEnabled(page_ > 1);
    nextBtn_->setEnabled(page_ < totalPages);
}

qint64 selectedId(QTableWidget* table) {
    int r = table->currentRow();
    if (r < 0) return 0;
    return table->item(r, 0)->text().toLongLong();
}

void MemberView::onAdd() {
    MemberEditDialog dlg(this);
    if (dlg.exec() == QDialog::Accepted) refresh();
}

void MemberView::onEdit() {
    qint64 id = selectedId(table_);
    if (id <= 0) { QMessageBox::warning(this, "Edit", "Select a member first."); return; }
    MemberEditDialog dlg(this, id);
    if (dlg.exec() == QDialog::Accepted) refresh();
}

void MemberView::onDelete() {
    qint64 id = selectedId(table_);
    if (id <= 0) { QMessageBox::warning(this, "Delete", "Select a member first."); return; }
    auto reply = QMessageBox::warning(this, "Delete Member",
        "Permanently delete this member record?", QMessageBox::Yes|QMessageBox::No);
    if (reply == QMessageBox::Yes) {
        MemberService svc;
        QString err;
        if (svc.deleteMember(id, &err)) {
            QMessageBox::information(this, "Deleted", "Member deleted.");
            refresh();
        } else {
            QMessageBox::warning(this, "Cannot Delete", err);
        }
    }
}

void MemberView::onPrint() {
    ReportService svc;
    auto row = svc.memberRegister(statusFilter_->currentText());
    QString path = svc.ensureExportPath("member_register.pdf");
    if (!svc.exportToPdf(row, "Member Register", path).isEmpty())
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}

void MemberView::onExport() {
    QString path = QFileDialog::getSaveFileName(this, "Export Member Register",
        "member_register.csv", "CSV Files (*.csv)");
    if (path.isEmpty()) return;
    ReportService svc;
    auto row = svc.memberRegister(statusFilter_->currentText());
    svc.exportToCsv(row, path);
    QMessageBox::information(this, "Exported", "Saved to:\n" + path);
}

void MemberView::onRowDoubleClicked() { onEdit(); }
void MemberView::onPrevPage() { if (page_ > 1) { --page_; refresh(); } }
void MemberView::onNextPage() {
    int totalPages = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    if (page_ < totalPages) { ++page_; refresh(); }
}

} // namespace mms
