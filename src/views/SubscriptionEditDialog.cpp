/*
 * SubscriptionEditDialog.cpp
 */
#include "SubscriptionEditDialog.h"
#include "../services/SubscriptionService.h"
#include "../services/FamilyService.h"
#include "../services/MemberService.h"
#include "../repositories/SubscriptionRepository.h"
#include "../repositories/FamilyRepository.h"
#include "../repositories/MemberRepository.h"

#include <QVBoxLayout>
#include <QFormLayout>
#include <QGroupBox>
#include <QComboBox>
#include <QLineEdit>
#include <QDateEdit>
#include <QDoubleSpinBox>
#include <QTextEdit>
#include <QDialogButtonBox>
#include <QPushButton>
#include <QMessageBox>
#include <QHBoxLayout>
#include <QLabel>
#include "../core/I18N.h"

namespace mms {

SubscriptionEditDialog::SubscriptionEditDialog(QWidget* parent, qint64 id)
    : QDialog(parent), id_(id) {
    setWindowTitle(id > 0 ? "Edit Subscription" : "Record Subscription Payment");
    setMinimumWidth(560);
    setupUi();
    loadFamilies();
    loadPlans();
    if (id > 0) loadSubscription();
    else {
        receiptEdit_->setText(SubscriptionService().nextReceiptNumber());
        periodStartEdit_->setDate(QDate::currentDate());
        periodEndEdit_->setDate(QDate::currentDate().addMonths(1));
        paymentDateEdit_->setDate(QDate::currentDate());
        amountPaidEdit_->setValue(0);
    }
}

void SubscriptionEditDialog::setupUi() {
    auto* layout = new QVBoxLayout(this);
    auto* formGroup = new QGroupBox("Subscription Details", this);
    auto* form = new QFormLayout(formGroup);

    familyCombo_ = new QComboBox(this);
    connect(familyCombo_, &QComboBox::currentIndexChanged, this, &SubscriptionEditDialog::onFamilyChanged);
    memberCombo_ = new QComboBox(this);
    planCombo_ = new QComboBox(this);
    periodStartEdit_ = new QDateEdit(QDate::currentDate(), this);
    periodStartEdit_->setCalendarPopup(true);
    periodStartEdit_->setDisplayFormat("yyyy-MM-dd");
    periodEndEdit_ = new QDateEdit(QDate::currentDate().addMonths(1), this);
    periodEndEdit_->setCalendarPopup(true);
    periodEndEdit_->setDisplayFormat("yyyy-MM-dd");
    amountEdit_ = new QDoubleSpinBox(this);
    amountEdit_->setRange(0, 10000000);
    amountEdit_->setDecimals(2);
    amountEdit_->setSingleStep(10);
    amountPaidEdit_ = new QDoubleSpinBox(this);
    amountPaidEdit_->setRange(0, 10000000);
    amountPaidEdit_->setDecimals(2);
    amountPaidEdit_->setSingleStep(10);
    paymentDateEdit_ = new QDateEdit(QDate::currentDate(), this);
    paymentDateEdit_->setCalendarPopup(true);
    paymentDateEdit_->setDisplayFormat("yyyy-MM-dd");
    receiptEdit_ = new QLineEdit(this);
    methodCombo_ = new QComboBox(this);
    methodCombo_->addItems({"Cash", "Cheque", "UPI", "Bank Transfer", "Card", "Other"});
    refEdit_ = new QLineEdit(this);
    statusCombo_ = new QComboBox(this);
    statusCombo_->addItems({"Paid", "Pending", "Overdue", "Partial"});
    connect(statusCombo_, &QComboBox::currentTextChanged, this, &SubscriptionEditDialog::onStatusChanged);
    remarksEdit_ = new QTextEdit(this);
    remarksEdit_->setMaximumHeight(60);

    form->addRow(TR("member_family") + "*:",      familyCombo_);
    form->addRow("Member:",       memberCombo_);
    form->addRow("Plan*:",        planCombo_);
    form->addRow("Period Start:", periodStartEdit_);
    form->addRow("Period End:",   periodEndEdit_);
    form->addRow(TR("sub_amount") + "*:",      amountEdit_);
    form->addRow("Amount Paid:",  amountPaidEdit_);
    form->addRow("Payment Date:", paymentDateEdit_);
    form->addRow(TR("sub_receipt") + ":",   receiptEdit_);
    form->addRow(TR("sub_method") + ":",       methodCombo_);
    form->addRow(TR("acc_reference") + ":",    refEdit_);
    form->addRow(TR("member_active") + ":",       statusCombo_);
    form->addRow(TR("family_notes") + ":",      remarksEdit_);

    layout->addWidget(formGroup);
    auto* btns = new QDialogButtonBox(QDialogButtonBox::Save | QDialogButtonBox::Cancel, this);
    btns->button(QDialogButtonBox::Save)->setText(TR("action_save"));
    btns->button(QDialogButtonBox::Cancel)->setText(TR("action_cancel"));
    connect(btns, &QDialogButtonBox::accepted, this, &SubscriptionEditDialog::onSave);
    connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
    layout->addWidget(btns);
}

void SubscriptionEditDialog::loadFamilies() {
    FamilyRepository repo;
    auto families = repo.listAll("Active");
    familyCombo_->clear();
    familyCombo_->addItem(TR("form_select"), 0);
    for (const auto& f : families) {
        familyCombo_->addItem(QString("%1 - %2").arg(f.familyNumber).arg(f.houseName), f.id);
    }
}

void SubscriptionEditDialog::loadPlans() {
    SubscriptionRepository repo;
    auto plans = repo.listPlans();
    planCombo_->clear();
    for (const auto& p : plans) {
        planCombo_->addItem(QString("%1 (₹%2)").arg(p.name).arg(p.defaultAmount), p.id);
    }
    if (!plans.empty()) amountEdit_->setValue(plans.front().defaultAmount);
}

void SubscriptionEditDialog::loadMembers(qint64 familyId) {
    memberCombo_->clear();
    memberCombo_->addItem(TR("form_none"), 0);
    if (familyId <= 0) return;
    MemberRepository repo;
    auto members = repo.listByFamily(familyId);
    for (const auto& m : members) {
        memberCombo_->addItem(QString("%1 (%2)").arg(m.name).arg(m.relationship), m.id);
    }
}

void SubscriptionEditDialog::loadSubscription() {
    SubscriptionRepository repo;
    auto s = repo.findById(id_);
    if (!s) return;
    sub_ = *s;
    familyCombo_->setCurrentIndex(familyCombo_->findData(s->familyId));
    loadMembers(s->familyId);
    memberCombo_->setCurrentIndex(memberCombo_->findData(s->memberId));
    planCombo_->setCurrentIndex(planCombo_->findData(s->planId));
    if (!s->periodStart.isEmpty()) periodStartEdit_->setDate(QDate::fromString(s->periodStart, Qt::ISODate));
    if (!s->periodEnd.isEmpty()) periodEndEdit_->setDate(QDate::fromString(s->periodEnd, Qt::ISODate));
    amountEdit_->setValue(s->amount);
    amountPaidEdit_->setValue(s->amountPaid);
    if (!s->paymentDate.isEmpty()) paymentDateEdit_->setDate(QDate::fromString(s->paymentDate, Qt::ISODate));
    receiptEdit_->setText(s->receiptNumber);
    methodCombo_->setCurrentText(s->paymentMethod);
    refEdit_->setText(s->transactionRef);
    statusCombo_->setCurrentText(s->status);
    remarksEdit_->setPlainText(s->remarks);
}

void SubscriptionEditDialog::onFamilyChanged() {
    qint64 fid = familyCombo_->currentData().toLongLong();
    loadMembers(fid);
}

void SubscriptionEditDialog::onStatusChanged() {
    QString s = statusCombo_->currentText();
    if (s == "Paid") amountPaidEdit_->setValue(amountEdit_->value());
    else if (s == "Pending") amountPaidEdit_->setValue(0);
}

void SubscriptionEditDialog::onSave() {
    sub_.id = id_;
    sub_.familyId = familyCombo_->currentData().toLongLong();
    sub_.memberId = memberCombo_->currentData().toLongLong();
    sub_.planId = planCombo_->currentData().toLongLong();
    sub_.periodStart = periodStartEdit_->date().toString(Qt::ISODate);
    sub_.periodEnd = periodEndEdit_->date().toString(Qt::ISODate);
    sub_.amount = amountEdit_->value();
    sub_.amountPaid = amountPaidEdit_->value();
    sub_.paymentDate = paymentDateEdit_->date().toString(Qt::ISODate);
    sub_.receiptNumber = receiptEdit_->text().trimmed();
    sub_.paymentMethod = methodCombo_->currentText();
    sub_.transactionRef = refEdit_->text().trimmed();
    sub_.status = statusCombo_->currentText();
    sub_.remarks = remarksEdit_->toPlainText().trimmed();

    SubscriptionService svc;
    QString err;
    bool ok;
    if (id_ > 0) ok = svc.updateSubscription(sub_, &err);
    else { qint64 newId = svc.createSubscription(sub_, &err); ok = newId > 0; if (ok) id_ = newId; }
    if (ok) accept();
    else QMessageBox::warning(this, "Save Failed", err);
}

} // namespace mms
