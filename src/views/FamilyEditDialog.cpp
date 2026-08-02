/*
 * FamilyEditDialog.cpp - With full i18n support
 */
#include "FamilyEditDialog.h"
#include "../services/FamilyService.h"
#include "../repositories/FamilyRepository.h"
#include "../core/I18N.h"
#include "../core/StyleProps.h"
#include <QFormLayout>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLineEdit>
#include <QComboBox>
#include <QTextEdit>
#include <QPushButton>
#include <QDialogButtonBox>
#include <QGroupBox>
#include <QMessageBox>
#include <QIntValidator>

namespace mms {

FamilyEditDialog::FamilyEditDialog(QWidget* parent, qint64 familyId)
    : QDialog(parent), familyId_(familyId) {
    setWindowTitle(familyId > 0 ? TR("family_edit") : TR("family_add"));
    setMinimumWidth(620);
    setupUi();
    if (familyId > 0) loadFamily();
    else {
        FamilyRepository repo;
        familyNumberEdit_->setText(repo.generateNextFamilyNumber());
    }
}

void FamilyEditDialog::setupUi() {
    auto* layout = new QVBoxLayout(this);
    auto* formGroup = new QGroupBox(TR("family_title"), this);
    auto* form = new QFormLayout(formGroup);
    form->setLabelAlignment(Qt::AlignRight);

    familyNumberEdit_ = new QLineEdit(this);
    houseNameEdit_    = new QLineEdit(this);
    houseNumberEdit_  = new QLineEdit(this);
    wardEdit_         = new QLineEdit(this);
    areaEdit_         = new QLineEdit(this);
    addressEdit_      = new QTextEdit(this);
    addressEdit_->setMaximumHeight(70);
    pincodeEdit_      = new QLineEdit(this);
    pincodeEdit_->setValidator(new QIntValidator(100000, 999999, this));
    phoneEdit_        = new QLineEdit(this);
    phoneEdit_->setPlaceholderText("10-digit mobile number");
    altPhoneEdit_     = new QLineEdit(this);
    statusCombo_      = new QComboBox(this);
    statusCombo_->addItem(TR("member_active"));
    statusCombo_->addItem(TR("member_inactive"));
    statusCombo_->addItem(TR("family_archived"));
    notesEdit_        = new QTextEdit(this);
    notesEdit_->setMaximumHeight(70);

    form->addRow(TR("family_number") + ":",    familyNumberEdit_);
    form->addRow(TR("family_house_name") + ":",   houseNameEdit_);
    form->addRow(TR("family_house_number") + ":", houseNumberEdit_);
    form->addRow(TR("family_ward") + ":",         wardEdit_);
    form->addRow(TR("family_area") + ":",         areaEdit_);
    form->addRow(TR("family_address") + ":",      addressEdit_);
    form->addRow(TR("family_pincode") + ":",      pincodeEdit_);
    form->addRow(TR("family_phone") + ":",        phoneEdit_);
    form->addRow(TR("family_alt_phone") + ":",   altPhoneEdit_);
    form->addRow(TR("family_status") + ":",       statusCombo_);
    form->addRow(TR("family_notes") + ":",        notesEdit_);

    layout->addWidget(formGroup);

    auto* btns = new QDialogButtonBox(QDialogButtonBox::Save | QDialogButtonBox::Cancel, this);
    btns->button(QDialogButtonBox::Save)->setText(TR("action_save"));
    btns->button(QDialogButtonBox::Cancel)->setText(TR("action_cancel"));
    connect(btns, &QDialogButtonBox::accepted, this, &FamilyEditDialog::onSave);
    connect(btns, &QDialogButtonBox::rejected, this, &FamilyEditDialog::onCancel);
    layout->addWidget(btns);
}

void FamilyEditDialog::loadFamily() {
    FamilyRepository repo;
    auto f = repo.findById(familyId_);
    if (!f) return;
    family_ = *f;
    familyNumberEdit_->setText(f->familyNumber);
    houseNameEdit_->setText(f->houseName);
    houseNumberEdit_->setText(f->houseNumber);
    wardEdit_->setText(f->ward);
    areaEdit_->setText(f->area);
    addressEdit_->setPlainText(f->address);
    pincodeEdit_->setText(f->pincode);
    phoneEdit_->setText(f->phone);
    altPhoneEdit_->setText(f->alternativePhone);
    int idx = 0;
    if (f->status == "Active") idx = 0;
    else if (f->status == "Inactive") idx = 1;
    else if (f->status == "Archived") idx = 2;
    statusCombo_->setCurrentIndex(idx);
    notesEdit_->setPlainText(f->notes);
}

void FamilyEditDialog::onSave() {
    family_.id = familyId_;
    family_.familyNumber     = familyNumberEdit_->text().trimmed();
    family_.houseName        = houseNameEdit_->text().trimmed();
    family_.houseNumber      = houseNumberEdit_->text().trimmed();
    family_.ward             = wardEdit_->text().trimmed();
    family_.area             = areaEdit_->text().trimmed();
    family_.address          = addressEdit_->toPlainText().trimmed();
    family_.pincode          = pincodeEdit_->text().trimmed();
    family_.phone            = phoneEdit_->text().trimmed();
    family_.alternativePhone = altPhoneEdit_->text().trimmed();
    QString statusText = statusCombo_->currentText();
    if (statusText == TR("member_active")) family_.status = "Active";
    else if (statusText == TR("member_inactive")) family_.status = "Inactive";
    else if (statusText == TR("family_archived")) family_.status = "Archived";
    else family_.status = "Active";
    family_.notes            = notesEdit_->toPlainText().trimmed();

    FamilyService svc;
    QString err;
    bool ok;
    if (familyId_ > 0) ok = svc.updateFamily(family_, &err);
    else { qint64 id = svc.createFamily(family_, &err); ok = id > 0; if (ok) familyId_ = id; }
    if (ok) accept();
    else QMessageBox::warning(this, TR("val_save_failed"), err);
}

void FamilyEditDialog::onCancel() { reject(); }

} // namespace mms
