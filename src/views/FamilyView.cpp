/*
 * FamilyView.cpp
 */
#include "FamilyView.h"
#include "../services/FamilyService.h"
#include "../services/ReportService.h"
#include "../core/Database.h"
#include "FamilyEditDialog.h"

#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QFormLayout>
#include <QGroupBox>
#include <QTableWidget>
#include <QHeaderView>
#include <QLineEdit>
#include <QComboBox>
#include <QPushButton>
#include <QLabel>
#include <QMessageBox>
#include <QFileDialog>
#include <QFile>
#include <QTextStream>
#include <QPrintDialog>
#include <QPrinter>
#include <QTextDocument>
#include <QDesktopServices>
#include <QUrl>
#include "../core/I18N.h"

namespace mms {

FamilyView::FamilyView(QWidget* parent) : QWidget(parent) {
    setupUi();
    loadWardFilter();
    refresh();
}

void FamilyView::setupUi() {
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(20, 20, 20, 20);
    layout->setSpacing(12);

    // Title
    auto* title = new QLabel(TR("family_title"), this);
    layout->addWidget(title);

    // Filters bar
    auto* filterBar = new QHBoxLayout();
    searchEdit_ = new QLineEdit(this);
    searchEdit_->setPlaceholderText(" Search by family no, house name, phone, area...");
    searchEdit_->setClearButtonEnabled(true);
    searchEdit_->setMinimumHeight(32);
    connect(searchEdit_, &QLineEdit::textChanged, this, [this]{ page_=1; refresh(); });
    filterBar->addWidget(searchEdit_, 3);

    statusFilter_ = new QComboBox(this);
    statusFilter_->addItems({"", TR("member_active"), TR("member_inactive"), TR("family_archived")});
    statusFilter_->setMinimumHeight(32);
    connect(statusFilter_, &QComboBox::currentTextChanged, this, [this]{ page_=1; refresh(); });
    filterBar->addWidget(new QLabel(TR("family_status") + ":", this));
    filterBar->addWidget(statusFilter_);

    wardFilter_ = new QComboBox(this);
    wardFilter_->setMinimumHeight(32);
    connect(wardFilter_, &QComboBox::currentTextChanged, this, [this]{ page_=1; refresh(); });
    filterBar->addWidget(new QLabel(TR("family_ward") + ":", this));
    filterBar->addWidget(wardFilter_);

    layout->addLayout(filterBar);

    // Action buttons
    auto* btnBar = new QHBoxLayout();
    addBtn_     = new QPushButton("Add Family", this);
    addBtn_->setObjectName("action_add");
    editBtn_    = new QPushButton(TR("action_edit"), this);
    editBtn_->setObjectName("action_edit");
    archiveBtn_ = new QPushButton(TR("action_archive"), this);
    archiveBtn_->setObjectName("action_archive");
    deleteBtn_  = new QPushButton(TR("action_delete"), this);
    deleteBtn_->setObjectName("action_delete");
    printBtn_   = new QPushButton(TR("action_print"), this);
    printBtn_->setObjectName("action_print");
    exportBtn_  = new QPushButton(TR("action_export"), this);
    exportBtn_->setObjectName("action_export");

    for (auto* b : {addBtn_, editBtn_, archiveBtn_, deleteBtn_, printBtn_, exportBtn_}) {
        b->setMinimumHeight(32);
        btnBar->addWidget(b);
    }
    btnBar->addStretch();
    layout->addLayout(btnBar);

    // Table
    table_ = new QTableWidget(this);
    table_->setColumnCount(8);
    table_->setHorizontalHeaderLabels({"ID", TR("family_number"), TR("family_house_name"), TR("family_ward"), TR("family_area"), TR("family_phone"), TR("family_members_count"), TR("family_status")});
    table_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table_->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(1, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(5, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(6, QHeaderView::ResizeToContents);
    table_->horizontalHeader()->setSectionResizeMode(7, QHeaderView::ResizeToContents);
    table_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table_->setSelectionBehavior(QAbstractItemView::SelectRows);
    table_->setAlternatingRowColors(true);
    table_->setSortingEnabled(true);
    connect(table_, &QTableWidget::cellDoubleClicked, this, &FamilyView::onRowDoubleClicked);
    layout->addWidget(table_, 1);

    // Pagination
    auto* pageBar = new QHBoxLayout();
    prevBtn_ = new QPushButton(TR("action_previous"), this);
    prevBtn_->setObjectName("action_prev");
    nextBtn_ = new QPushButton(TR("action_next") + " ", this);
    nextBtn_->setObjectName("action_next");
    pageLabel_ = new QLabel(TR("action_page") + " 1", this);
    pageLabel_->setAlignment(Qt::AlignCenter);
    connect(prevBtn_, &QPushButton::clicked, this, &FamilyView::onPrevPage);
    connect(nextBtn_, &QPushButton::clicked, this, &FamilyView::onNextPage);
    pageBar->addWidget(prevBtn_);
    pageBar->addStretch();
    pageBar->addWidget(pageLabel_);
    pageBar->addStretch();
    pageBar->addWidget(nextBtn_);
    layout->addLayout(pageBar);

    // Connect buttons
    connect(addBtn_,     &QPushButton::clicked, this, &FamilyView::onAdd);
    connect(editBtn_,    &QPushButton::clicked, this, &FamilyView::onEdit);
    connect(archiveBtn_, &QPushButton::clicked, this, &FamilyView::onArchive);
    connect(deleteBtn_,  &QPushButton::clicked, this, &FamilyView::onDelete);
    connect(printBtn_,   &QPushButton::clicked, this, &FamilyView::onPrint);
    connect(exportBtn_,  &QPushButton::clicked, this, &FamilyView::onExport);
}

void FamilyView::loadWardFilter() {
    FamilyService svc;
    QStringList wards = svc.wards();
    wardFilter_->blockSignals(true);
    wardFilter_->clear();
    wardFilter_->addItem("");
    wardFilter_->addItems(wards);
    wardFilter_->blockSignals(false);
}

void FamilyView::refresh() {
    loadTable();
}

void FamilyView::loadTable() {
    FamilyService svc;
    int total = 0;
    auto families = svc.searchFamilies(searchEdit_->text().trimmed(), page_, pageSize_,
                                       statusFilter_->currentText(),
                                       wardFilter_->currentText(), &total);
    total_ = total;

    table_->setRowCount(0);
    table_->setSortingEnabled(false);
    for (const auto& f : families) {
        int r = table_->rowCount();
        table_->insertRow(r);
        table_->setItem(r, 0, new QTableWidgetItem(QString::number(f.id)));
        table_->setItem(r, 1, new QTableWidgetItem(f.familyNumber));
        table_->setItem(r, 2, new QTableWidgetItem(f.houseName));
        table_->setItem(r, 3, new QTableWidgetItem(f.ward));
        table_->setItem(r, 4, new QTableWidgetItem(f.area));
        table_->setItem(r, 5, new QTableWidgetItem(f.phone));
        table_->setItem(r, 6, new QTableWidgetItem(QString::number(f.memberCount)));
        table_->setItem(r, 7, new QTableWidgetItem(f.status));

        // Color status
        if (f.status == "Archived") {
            for (int c = 0; c < 8; ++c) {
                table_->item(r, c)->setForeground(QColor("#999999"));
            }
        } else if (f.status == "Inactive") {
            table_->item(r, 7)->setForeground(QColor("#c0392b"));
        } else {
            table_->item(r, 7)->setForeground(QColor("#2a7a3a"));
        }
    }
    table_->setSortingEnabled(true);

    int totalPages = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    pageLabel_->setText(QString(TR("action_page") + " %1 / %2  (%3 " + TR("ui_records") + ")")
                            .arg(page_).arg(totalPages).arg(total_));
    prevBtn_->setEnabled(page_ > 1);
    nextBtn_->setEnabled(page_ < totalPages);
}

qint64 selectedFamilyId(QTableWidget* table) {
    int r = table->currentRow();
    if (r < 0) return 0;
    return table->item(r, 0)->text().toLongLong();
}

void FamilyView::onAdd() {
    FamilyEditDialog dlg(this);
    if (dlg.exec() == QDialog::Accepted) {
        refresh();
    }
}

void FamilyView::onEdit() {
    qint64 id = selectedFamilyId(table_);
    if (id <= 0) {
        QMessageBox::warning(this, TR("action_edit"), TR("ui_no_data"));
        return;
    }
    FamilyEditDialog dlg(this, id);
    if (dlg.exec() == QDialog::Accepted) {
        refresh();
    }
}

void FamilyView::onArchive() {
    qint64 id = selectedFamilyId(table_);
    if (id <= 0) {
        QMessageBox::warning(this, TR("action_archive"), TR("ui_no_data"));
        return;
    }
    auto reply = QMessageBox::question(this, TR("action_archive"),
        "Are you sure you want to archive this family? It can be restored later.",
        QMessageBox::Yes | QMessageBox::No);
    if (reply == QMessageBox::Yes) {
        FamilyService svc;
        if (svc.archiveFamily(id)) {
            QMessageBox::information(this, TR("ui_success"), TR("action_archive"));
            refresh();
        }
    }
}

void FamilyView::onDelete() {
    qint64 id = selectedFamilyId(table_);
    if (id <= 0) {
        QMessageBox::warning(this, TR("action_delete"), TR("ui_no_data"));
        return;
    }
    auto reply = QMessageBox::warning(this, TR("action_delete"),
        "This will permanently delete the family record.\n"
        "You can only delete a family with no members.\n\nContinue?",
        QMessageBox::Yes | QMessageBox::No, QMessageBox::No);
    if (reply == QMessageBox::Yes) {
        FamilyService svc;
        QString err;
        if (svc.deleteFamily(id, &err)) {
            QMessageBox::information(this, TR("ui_success"), TR("action_delete"));
            refresh();
        } else {
            QMessageBox::warning(this, "Cannot Delete", err);
        }
    }
}

void FamilyView::onPrint() {
    ReportService svc;
    auto row = svc.familyRegister(statusFilter_->currentText());
    QString path = svc.ensureExportPath("family_register.pdf");
    if (!svc.exportToPdf(row, "Family Register", path).isEmpty()) {
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    }
}

void FamilyView::onExport() {
    QString path = QFileDialog::getSaveFileName(this, TR("action_export"),
        "family_register.csv", "CSV Files (*.csv)");
    if (path.isEmpty()) return;
    ReportService svc;
    auto row = svc.familyRegister(statusFilter_->currentText());
    if (!svc.exportToCsv(row, path).isEmpty()) {
        QMessageBox::information(this, TR("ui_success"), path);
    }
}

void FamilyView::onRowDoubleClicked(int, int) {
    onEdit();
}

void FamilyView::onPrevPage() {
    if (page_ > 1) { --page_; refresh(); }
}

void FamilyView::onNextPage() {
    int totalPages = std::max(1, (total_ + pageSize_ - 1) / pageSize_);
    if (page_ < totalPages) { ++page_; refresh(); }
}

void FamilyView::onSearch() { page_ = 1; refresh(); }
void FamilyView::onPageChanged() { refresh(); }

} // namespace mms
