#include "TokenView.h"
#include "../core/I18N.h"
#include "../core/IconUtils.h"
#include "../core/StyledComboBox.h"
#include "../services/AuthSession.h"
#include "../repositories/AuditLogRepository.h"
#include "../core/StyleProps.h"
#include "../core/ThemeColors.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QMessageBox>
#include <QDialog>
#include <QFormLayout>
#include <QLineEdit>
#include <QDateEdit>
#include <QTimeEdit>
#include <QTextEdit>
#include <QDialogButtonBox>
#include <QFileDialog>
#include <QDesktopServices>
#include <QUrl>
#include <QListWidget>
#include <QCheckBox>
#include <QProgressDialog>

// TR helper for token keys
#ifndef TTR
#define TTR(key) mms::I18N::instance().tr(key)
#endif

namespace mms {

// --- NewEventDialog ---
class TokenEventDialog : public QDialog {
public:
    TokenEventDialog(QWidget* parent = nullptr) : QDialog(parent) {
        setWindowTitle(TTR("token_new_event"));
        setMinimumWidth(450);
        auto* layout = new QVBoxLayout(this);
        auto* form = new QFormLayout();
        form->setLabelAlignment(Qt::AlignRight);
        form->setSpacing(8);

        nameEdit_ = new QLineEdit(this);
        nameEdit_->setPlaceholderText("e.g. Eid Meat Distribution");
        typeCombo_ = new StyledComboBox(this);
        typeCombo_->addItem(TTR("token_type_meat"), "Meat Distribution");
        typeCombo_->addItem(TTR("token_type_food"), "Food Distribution");
        typeCombo_->addItem(TTR("token_type_aid"), "Aid Distribution");
        typeCombo_->addItem(TTR("token_type_ration"), "Ration Distribution");
        typeCombo_->addItem(TTR("token_type_gift"), "Gift Distribution");
        typeCombo_->addItem(TTR("token_type_other"), "Other");
        dateEdit_ = new QDateEdit(QDate::currentDate(), this);
        dateEdit_->setCalendarPopup(true);
        dateEdit_->setDisplayFormat("yyyy-MM-dd");
        timeEdit_ = new QTimeEdit(QTime(10, 0), this);
        timeEdit_->setDisplayFormat("hh:mm AP");
        venueEdit_ = new QLineEdit(this);
        descEdit_ = new QTextEdit(this);
        descEdit_->setMaximumHeight(60);
        notesEdit_ = new QLineEdit(this);

        form->addRow(TTR("token_event_name") + "*:", nameEdit_);
        form->addRow(TTR("token_event_type") + "*:", typeCombo_);
        form->addRow(TTR("token_event_date") + "*:", dateEdit_);
        form->addRow(TTR("token_event_time") + ":", timeEdit_);
        form->addRow(TTR("token_venue") + ":", venueEdit_);
        form->addRow(TTR("token_description") + ":", descEdit_);
        form->addRow(TTR("token_notes") + ":", notesEdit_);
        layout->addLayout(form);

        auto* btns = new QDialogButtonBox(QDialogButtonBox::Save | QDialogButtonBox::Cancel, this);
        btns->button(QDialogButtonBox::Save)->setText(TTR("action_save"));
        btns->button(QDialogButtonBox::Cancel)->setText(TTR("action_cancel"));
        connect(btns, &QDialogButtonBox::accepted, this, &QDialog::accept);
        connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
        layout->addWidget(btns);
    }

    TokenEvent getEvent() const {
        TokenEvent e;
        e.eventName = nameEdit_->text().trimmed();
        e.eventType = typeCombo_->currentData().toString();
        e.eventDate = dateEdit_->date().toString(Qt::ISODate);
        e.eventTime = timeEdit_->time().toString("hh:mm AP");
        e.venue = venueEdit_->text().trimmed();
        e.description = descEdit_->toPlainText().trimmed();
        e.notes = notesEdit_->text().trimmed();
        return e;
    }

private:
    QLineEdit* nameEdit_;
    StyledComboBox* typeCombo_;
    QDateEdit* dateEdit_;
    QTimeEdit* timeEdit_;
    QLineEdit* venueEdit_;
    QTextEdit* descEdit_;
    QLineEdit* notesEdit_;
};

// --- FamilySelectionDialog ---
class FamilySelectionDialog : public QDialog {
public:
    FamilySelectionDialog(int eventId, QWidget* parent = nullptr) : QDialog(parent), eventId_(eventId) {
        setWindowTitle(TTR("token_select_families"));
        setMinimumSize(700, 500);
        auto* layout = new QVBoxLayout(this);

        auto* mainLayout = new QHBoxLayout();
        // Left: available families
        auto* leftCol = new QVBoxLayout();
        leftCol->addWidget(new QLabel(TTR("token_available_families"), this));
        wardCombo_ = new StyledComboBox(this);
        wardCombo_->addItem(TTR("ui_all_categories"), "");
        for (const auto& w : TokenService().getWards()) wardCombo_->addItem(w, w);
        leftCol->addWidget(wardCombo_);
        searchEdit_ = new QLineEdit(this);
        searchEdit_->setPlaceholderText(TTR("action_search"));
        leftCol->addWidget(searchEdit_);
        availList_ = new QListWidget(this);
        availList_->setSelectionMode(QAbstractItemView::MultiSelection);
        leftCol->addWidget(availList_);

        auto* btnBar = new QHBoxLayout();
        auto* addSelectedBtn = new QPushButton(TTR("token_add_selected"), this);
        auto* addAllWardBtn = new QPushButton(TTR("token_add_all_ward"), this);
        auto* addAllActiveBtn = new QPushButton(TTR("token_add_all_active"), this);
        btnBar->addWidget(addSelectedBtn);
        btnBar->addWidget(addAllWardBtn);
        btnBar->addWidget(addAllActiveBtn);
        leftCol->addLayout(btnBar);
        mainLayout->addLayout(leftCol);

        // Right: selected families
        auto* rightCol = new QVBoxLayout();
        rightCol->addWidget(new QLabel(TTR("token_selected_families"), this));
        selectedList_ = new QListWidget(this);
        selectedList_->setSelectionMode(QAbstractItemView::MultiSelection);
        rightCol->addWidget(selectedList_);
        auto* rightBtnBar = new QHBoxLayout();
        auto* removeBtn = new QPushButton(TTR("action_delete"), this);
        auto* clearBtn = new QPushButton(TTR("token_clear_all"), this);
        rightBtnBar->addWidget(removeBtn);
        rightBtnBar->addWidget(clearBtn);
        rightCol->addLayout(rightBtnBar);
        countLabel_ = new QLabel(TTR("ui_total") + " 0", this);
        rightCol->addWidget(countLabel_);
        mainLayout->addLayout(rightCol);
        layout->addLayout(mainLayout);

        auto* btns = new QDialogButtonBox(QDialogButtonBox::Ok | QDialogButtonBox::Cancel, this);
        btns->button(QDialogButtonBox::Ok)->setText(TTR("token_generate"));
        btns->button(QDialogButtonBox::Cancel)->setText(TTR("action_cancel"));
        connect(btns, &QDialogButtonBox::accepted, this, &QDialog::accept);
        connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
        layout->addWidget(btns);

        // Connections
        connect(addSelectedBtn, &QPushButton::clicked, this, [this]() {
            for (auto* item : availList_->selectedItems()) {
                int fid = item->data(Qt::UserRole).toInt();
                if (selectedIds_.contains(fid)) continue;
                selectedIds_.append(fid);
                selectedList_->addItem(item->text());
                selectedList_->item(selectedList_->count()-1)->setData(Qt::UserRole, fid);
            }
            updateCount();
        });
        connect(addAllActiveBtn, &QPushButton::clicked, this, [this]() {
            for (int i = 0; i < availList_->count(); i++) {
                auto* item = availList_->item(i);
                int fid = item->data(Qt::UserRole).toInt();
                if (!selectedIds_.contains(fid)) {
                    selectedIds_.append(fid);
                    selectedList_->addItem(item->text());
                    selectedList_->item(selectedList_->count()-1)->setData(Qt::UserRole, fid);
                }
            }
            updateCount();
        });
        connect(removeBtn, &QPushButton::clicked, this, [this]() {
            for (auto* item : selectedList_->selectedItems()) {
                int fid = item->data(Qt::UserRole).toInt();
                selectedIds_.removeAll(fid);
                delete item;
            }
            updateCount();
        });
        connect(clearBtn, &QPushButton::clicked, this, [this]() {
            selectedIds_.clear();
            selectedList_->clear();
            updateCount();
        });

        loadAvailableFamilies();
    }

    QList<int> getSelectedFamilyIds() const { return selectedIds_; }

private:
    void loadAvailableFamilies() {
        availList_->clear();
        auto families = TokenService().getAllActiveFamilies();
        // Get already assigned family IDs for this event
        auto assigned = TokenService().getAssignments(eventId_);
        QSet<int> assignedIds;
        for (const auto& a : assigned) assignedIds.insert(a.familyId);

        for (const auto& f : families) {
            if (assignedIds.contains(f.familyId)) continue;
            QString text = QString("%1 / %2 / %3").arg(f.headName).arg(f.houseName).arg(f.ward);
            auto* item = new QListWidgetItem(text, availList_);
            item->setData(Qt::UserRole, f.familyId);
        }
    }

    void updateCount() {
        countLabel_->setText(QString("Total: %1").arg(selectedIds_.size()));
    }

    int eventId_;
    StyledComboBox* wardCombo_;
    QLineEdit* searchEdit_;
    QListWidget* availList_;
    QListWidget* selectedList_;
    QLabel* countLabel_;
    QList<int> selectedIds_;
};

// --- TokenView ---
TokenView::TokenView(QWidget* parent) : QWidget(parent) {
    tokenService_ = new TokenService(this);
    pdfEngine_ = new TokenPdfEngine(this);
    stack_ = new QStackedWidget(this);
    auto* layout = new QVBoxLayout(this);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->addWidget(stack_);

    setupEventListPage();
    setupEventDetailPage();
    stack_->addWidget(listPage_);
    stack_->addWidget(detailPage_);
    stack_->setCurrentWidget(listPage_);
}

void TokenView::setupEventListPage() {
    listPage_ = new QWidget(this);
    auto* layout = new QVBoxLayout(listPage_);
    layout->setContentsMargins(22, 20, 22, 26);
    layout->setSpacing(12);

    auto* header = new QHBoxLayout();
    auto* title = new QLabel(TTR("token_events"), listPage_);
    StyleProps::set(title, "h1");
    header->addWidget(title);
    header->addStretch();
    newEventBtn_ = new QPushButton(TTR("token_new_event"), listPage_);
    StyleProps::set(newEventBtn_, "primary");
    deleteEventBtn_ = new QPushButton(TTR("action_delete"), listPage_);
    StyleProps::set(deleteEventBtn_, "ghostDanger");
    header->addWidget(newEventBtn_);
    header->addWidget(deleteEventBtn_);
    layout->addLayout(header);

    eventTable_ = new QTableWidget(listPage_);
    eventTable_->setColumnCount(6);
    eventTable_->setHorizontalHeaderLabels({
        TTR("ui_id"), TTR("token_event_name"), TTR("token_event_type"),
        TTR("token_event_date"), TTR("token_total_families"), TTR("ui_status_label").replace(":","")
    });
    eventTable_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    eventTable_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    eventTable_->setSelectionBehavior(QAbstractItemView::SelectRows);
    eventTable_->setAlternatingRowColors(true);
    connect(eventTable_, &QTableWidget::cellDoubleClicked, this, &TokenView::onEventDoubleClicked);
    layout->addWidget(eventTable_, 1);

    connect(newEventBtn_, &QPushButton::clicked, this, &TokenView::onNewEvent);
    connect(deleteEventBtn_, &QPushButton::clicked, this, &TokenView::onDeleteEvent);
}

void TokenView::setupEventDetailPage() {
    detailPage_ = new QWidget(this);
    auto* layout = new QVBoxLayout(detailPage_);
    layout->setContentsMargins(22, 20, 22, 26);
    layout->setSpacing(12);

    auto* header = new QHBoxLayout();
    backBtn_ = new QPushButton(TTR("action_previous"), detailPage_);
    StyleProps::set(backBtn_, "chip");
    header->addWidget(backBtn_);
    detailTitle_ = new QLabel(detailPage_);
    StyleProps::set(detailTitle_, "h1");
    header->addWidget(detailTitle_, 1);
    header->addStretch();
    layout->addLayout(header);

    detailInfo_ = new QLabel(detailPage_);
    StyleProps::set(detailInfo_, "h2");
    layout->addWidget(detailInfo_);

    progressBar_ = new QProgressBar(detailPage_);
    /* progressBar_ styled via default QSS */;
    layout->addWidget(progressBar_);

    statsLabel_ = new QLabel(detailPage_);
    layout->addWidget(statsLabel_);

    auto* btnBar = new QHBoxLayout();
    selectFamiliesBtn_ = new QPushButton(TTR("token_select_families"), detailPage_);
    StyleProps::set(selectFamiliesBtn_, "chip");
    generateBtn_ = new QPushButton(TTR("token_generate"), detailPage_);
    StyleProps::set(generateBtn_, "primary");
    printTokensBtn_ = new QPushButton(TTR("token_print_tokens"), detailPage_);
    StyleProps::set(printTokensBtn_, "chip");
    printCollectionBtn_ = new QPushButton(TTR("token_print_collection"), detailPage_);
    StyleProps::set(printCollectionBtn_, "chip");
    markCollectedBtn_ = new QPushButton(TTR("token_mark_collected"), detailPage_);
    StyleProps::set(markCollectedBtn_, "primary");
    markUncollectedBtn_ = new QPushButton(TTR("token_mark_uncollected"), detailPage_);
    StyleProps::set(markUncollectedBtn_, "ghostDanger");
    for (auto* b : {selectFamiliesBtn_, generateBtn_, printTokensBtn_, printCollectionBtn_, markCollectedBtn_, markUncollectedBtn_}) {
        b->setMinimumHeight(32);
        btnBar->addWidget(b);
    }
    btnBar->addStretch();
    layout->addLayout(btnBar);

    assignmentTable_ = new QTableWidget(detailPage_);
    assignmentTable_->setColumnCount(6);
    assignmentTable_->setHorizontalHeaderLabels({
        TTR("token_serial_no"), TTR("token_head_name"), TTR("token_house_name"),
        TTR("token_unique_code"), TTR("token_ward"), TTR("token_collected")
    });
    assignmentTable_->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    assignmentTable_->setEditTriggers(QAbstractItemView::NoEditTriggers);
    assignmentTable_->setSelectionBehavior(QAbstractItemView::SelectRows);
    assignmentTable_->setAlternatingRowColors(true);
    layout->addWidget(assignmentTable_, 1);

    connect(backBtn_, &QPushButton::clicked, this, &TokenView::onBackToList);
    connect(selectFamiliesBtn_, &QPushButton::clicked, this, &TokenView::onSelectFamilies);
    connect(generateBtn_, &QPushButton::clicked, this, &TokenView::onGenerateTokens);
    connect(printTokensBtn_, &QPushButton::clicked, this, &TokenView::onPrintTokens);
    connect(printCollectionBtn_, &QPushButton::clicked, this, &TokenView::onPrintCollection);
    connect(markCollectedBtn_, &QPushButton::clicked, this, &TokenView::onMarkCollected);
    connect(markUncollectedBtn_, &QPushButton::clicked, this, &TokenView::onMarkUncollected);
}

void TokenView::refresh() {
    loadEventList();
}

void TokenView::loadEventList() {
    auto events = tokenService_->listEvents();
    eventTable_->setRowCount(0);
    for (const auto& e : events) {
        int r = eventTable_->rowCount();
        eventTable_->insertRow(r);
        eventTable_->setItem(r, 0, new QTableWidgetItem(QString::number(e.id)));
        eventTable_->setItem(r, 1, new QTableWidgetItem(e.eventName));
        eventTable_->setItem(r, 2, new QTableWidgetItem(e.eventType));
        eventTable_->setItem(r, 3, new QTableWidgetItem(e.eventDate));
        eventTable_->setItem(r, 4, new QTableWidgetItem(QString::number(e.totalFamilies)));
        eventTable_->setItem(r, 5, new QTableWidgetItem(e.status));
    }
}

void TokenView::showEventDetail(int eventId) {
    currentEventId_ = eventId;
    loadEventDetail(eventId);
    stack_->setCurrentWidget(detailPage_);
}

void TokenView::loadEventDetail(int eventId) {
    auto event = tokenService_->getEvent(eventId);
    detailTitle_->setText(event.eventName);
    QString info = QString("Date: %1").arg(event.eventDate);
    if (!event.eventTime.isEmpty()) info += "  Time: " + event.eventTime;
    if (!event.venue.isEmpty()) info += "  Venue: " + event.venue;
    info += "  Status: " + event.status;
    detailInfo_->setText(info);

    auto stats = tokenService_->getStats(eventId);
    progressBar_->setValue((int)stats.percentage);
    statsLabel_->setText(QString("%1: %2  |  %3: %4  |  %5: %6")
        .arg(TTR("token_total_families")).arg(stats.totalFamilies)
        .arg(TTR("token_collected")).arg(stats.collected)
        .arg(TTR("token_pending")).arg(stats.pending));

    // Load assignments
    auto assignments = tokenService_->getAssignments(eventId);
    assignmentTable_->setRowCount(0);
    for (const auto& a : assignments) {
        int r = assignmentTable_->rowCount();
        assignmentTable_->insertRow(r);
        assignmentTable_->setItem(r, 0, new QTableWidgetItem(QString::number(a.serialNumber)));
        assignmentTable_->setItem(r, 1, new QTableWidgetItem(a.headName));
        assignmentTable_->setItem(r, 2, new QTableWidgetItem(a.houseName));
        auto* codeItem = new QTableWidgetItem(a.uniqueCode);
        codeItem->setTextAlignment(Qt::AlignCenter);
        QFont monoFont("Courier New");
        monoFont.setBold(true);
        codeItem->setFont(monoFont);
        assignmentTable_->setItem(r, 3, codeItem);
        assignmentTable_->setItem(r, 4, new QTableWidgetItem(a.ward));
        auto* colItem = new QTableWidgetItem(a.isCollected ? TTR("token_collected") : TTR("token_pending"));
        colItem->setForeground(a.isCollected ? colors::cellPositive : colors::cellNegative);
        assignmentTable_->setItem(r, 5, colItem);
    }
}

void TokenView::onNewEvent() {
    TokenEventDialog dlg(this);
    if (dlg.exec() == QDialog::Accepted) {
        TokenEvent e = dlg.getEvent();
        if (e.eventName.isEmpty()) {
            QMessageBox::warning(this, TTR("ui_error"), TTR("token_event_name") + " required");
            return;
        }
        QString err;
        auto created = tokenService_->createEvent(e, &err);
        if (created.id > 0) {
            refresh();
            showEventDetail(created.id);
        } else {
            QMessageBox::warning(this, TTR("ui_error"), err);
        }
    }
}

void TokenView::onDeleteEvent() {
    int r = eventTable_->currentRow();
    if (r < 0) return;
    int id = eventTable_->item(r, 0)->text().toInt();
    if (QMessageBox::question(this, TTR("action_delete"), "Delete this token event?") == QMessageBox::Yes) {
        QString err;
        if (tokenService_->deleteEvent(id, &err)) {
            refresh();
        } else {
            QMessageBox::warning(this, TTR("ui_error"), err);
        }
    }
}

void TokenView::onEventDoubleClicked(int row, int) {
    int id = eventTable_->item(row, 0)->text().toInt();
    showEventDetail(id);
}

void TokenView::onBackToList() {
    stack_->setCurrentWidget(listPage_);
    loadEventList();
}

void TokenView::onSelectFamilies() {
    FamilySelectionDialog dlg(currentEventId_, this);
    if (dlg.exec() == QDialog::Accepted) {
        auto familyIds = dlg.getSelectedFamilyIds();
        if (familyIds.isEmpty()) return;
        if (QMessageBox::question(this, TTR("token_confirm_generate"),
            QString("Generate tokens for %1 families?").arg(familyIds.size())) == QMessageBox::Yes) {
            QString err;
            if (tokenService_->generateTokens(currentEventId_, familyIds, &err)) {
                QMessageBox::information(this, TTR("ui_success"), TTR("token_generate_success"));
                loadEventDetail(currentEventId_);
            } else {
                QMessageBox::warning(this, TTR("ui_error"), err);
            }
        }
    }
}

void TokenView::onGenerateTokens() {
    onSelectFamilies();
}

void TokenView::onPrintTokens() {
    auto event = tokenService_->getEvent(currentEventId_);
    auto assignments = tokenService_->getAssignments(currentEventId_);
    if (assignments.isEmpty()) {
        QMessageBox::warning(this, TTR("ui_error"), "No tokens to print");
        return;
    }

    QMessageBox msgBox(this);
    msgBox.setWindowTitle(TTR("token_print_as"));
    msgBox.setText(TTR("token_print_as"));
    QPushButton* printBtn = msgBox.addButton(TTR("token_print_printer"), QMessageBox::ActionRole);
    QPushButton* pdfBtn = msgBox.addButton(TTR("token_save_pdf"), QMessageBox::ActionRole);
    msgBox.addButton(QMessageBox::Cancel);
    msgBox.exec();

    QString err;
    if (msgBox.clickedButton() == pdfBtn) {
        QString path = QFileDialog::getSaveFileName(this, TTR("token_save_pdf"),
            "tokens.pdf", "PDF (*.pdf)");
        if (path.isEmpty()) return;
        if (pdfEngine_->generateTokenSheet(event, assignments, path, &err)) {
            QDesktopServices::openUrl(QUrl::fromLocalFile(path));
        } else {
            QMessageBox::warning(this, TTR("ui_error"), err);
        }
    } else if (msgBox.clickedButton() == printBtn) {
        pdfEngine_->printTokenSheet(event, assignments, &err);
    }
}

void TokenView::onPrintCollection() {
    auto event = tokenService_->getEvent(currentEventId_);
    auto assignments = tokenService_->getAssignments(currentEventId_);
    if (assignments.isEmpty()) {
        QMessageBox::warning(this, TTR("ui_error"), "No tokens to print");
        return;
    }

    QMessageBox msgBox(this);
    msgBox.setWindowTitle(TTR("token_print_as"));
    msgBox.setText(TTR("token_print_as"));
    QPushButton* printBtn = msgBox.addButton(TTR("token_print_printer"), QMessageBox::ActionRole);
    QPushButton* pdfBtn = msgBox.addButton(TTR("token_save_pdf"), QMessageBox::ActionRole);
    msgBox.addButton(QMessageBox::Cancel);
    msgBox.exec();

    QString err;
    if (msgBox.clickedButton() == pdfBtn) {
        QString path = QFileDialog::getSaveFileName(this, TTR("token_save_pdf"),
            "collection_sheet.pdf", "PDF (*.pdf)");
        if (path.isEmpty()) return;
        if (pdfEngine_->generateCollectionSheet(event, assignments, path, &err)) {
            QDesktopServices::openUrl(QUrl::fromLocalFile(path));
        } else {
            QMessageBox::warning(this, TTR("ui_error"), err);
        }
    } else if (msgBox.clickedButton() == printBtn) {
        pdfEngine_->printCollectionSheet(event, assignments, &err);
    }
}

void TokenView::onMarkCollected() {
    int r = assignmentTable_->currentRow();
    if (r < 0) return;
    // Find assignment ID from serial number
    int serial = assignmentTable_->item(r, 0)->text().toInt();
    auto assignments = tokenService_->getAssignments(currentEventId_);
    for (const auto& a : assignments) {
        if (a.serialNumber == serial) {
            QString err;
            if (tokenService_->markCollected(a.id, &err)) {
                loadEventDetail(currentEventId_);
            } else {
                QMessageBox::warning(this, TTR("ui_error"), err);
            }
            break;
        }
    }
}

void TokenView::onMarkUncollected() {
    int r = assignmentTable_->currentRow();
    if (r < 0) return;
    int serial = assignmentTable_->item(r, 0)->text().toInt();
    auto assignments = tokenService_->getAssignments(currentEventId_);
    for (const auto& a : assignments) {
        if (a.serialNumber == serial) {
            QString err;
            if (tokenService_->markUncollected(a.id, &err)) {
                loadEventDetail(currentEventId_);
            } else {
                QMessageBox::warning(this, TTR("ui_error"), err);
            }
            break;
        }
    }
}

void TokenView::onToggleCollected(int row, int) {
    auto assignments = tokenService_->getAssignments(currentEventId_);
    if (row < 0 || row >= assignments.size()) return;
    const auto& a = assignments[row];
    if (a.isCollected) {
        markUncollectedBtn_->click();
    } else {
        markCollectedBtn_->click();
    }
}

} // namespace mms
