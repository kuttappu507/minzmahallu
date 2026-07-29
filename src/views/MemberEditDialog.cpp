/*
 * MemberEditDialog.cpp
 */
#include "MemberEditDialog.h"
#include "../services/MemberService.h"
#include "../services/FamilyService.h"
#include "../repositories/MemberRepository.h"
#include "../repositories/FamilyRepository.h"
#include "../core/Security.h"

#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QFormLayout>
#include <QScrollArea>
#include <QGroupBox>
#include <QLineEdit>
#include <QComboBox>
#include <QTextEdit>
#include <QDateEdit>
#include <QSpinBox>
#include <QLabel>
#include <QPushButton>
#include <QDialogButtonBox>
#include <QFileDialog>
#include <QMessageBox>
#include <QPixmap>
#include <QIntValidator>
#include "../core/I18N.h"

namespace mms {

MemberEditDialog::MemberEditDialog(QWidget* parent, qint64 memberId, qint64 familyId)
    : QDialog(parent), memberId_(memberId) {
    setWindowTitle(memberId > 0 ? "Edit Member" : "Add Member");
    setMinimumWidth(720);
    setupUi();
    loadFamilyCombo();
    if (familyId > 0) familyCombo_->setCurrentIndex(familyCombo_->findData(familyId));
    if (memberId > 0) loadMember();
    else {
        MemberRepository repo;
        codeEdit_->setText(repo.generateNextMemberCode());
    }
}

void MemberEditDialog::setupUi() {
    auto* scroll = new QScrollArea(this);
    scroll->setWidgetResizable(true);
    auto* content = new QWidget(scroll);
    auto* layout = new QVBoxLayout(content);

    // Photo + identity
    auto* topRow = new QHBoxLayout();

    auto* photoBox = new QGroupBox(TR("member_photo"), this);
    auto* photoLayout = new QVBoxLayout(photoBox);
    photoLabel_ = new QLabel(this);
    photoLabel_->setFixedSize(120, 150);
    photoLabel_->setAlignment(Qt::AlignCenter);
    photoLabel_->setText("No Photo");
    photoLayout->addWidget(photoLabel_, 0, Qt::AlignCenter);
    photoBtn_ = new QPushButton(TR("member_upload_photo"), this);
    connect(photoBtn_, &QPushButton::clicked, this, &MemberEditDialog::onUploadPhoto);
    photoLayout->addWidget(photoBtn_);
    topRow->addWidget(photoBox);

    auto* formGroup = new QGroupBox(TR("member_title"), this);
    auto* form = new QFormLayout(formGroup);
    form->setLabelAlignment(Qt::AlignRight);

    familyCombo_ = new QComboBox(this);
    familyCombo_->setMinimumWidth(300);
    connect(familyCombo_, &QComboBox::currentIndexChanged, this, &MemberEditDialog::onFamilyChanged);

    familyNumberLabel_ = new QLabel(this);

    codeEdit_         = new QLineEdit(this);
    nameEdit_         = new QLineEdit(this);
    genderCombo_      = new QComboBox(this);
    genderCombo_->addItems({"Male", "Female", "Other"});
    dobEdit_          = new QDateEdit(QDate::currentDate(), this);
    dobEdit_->setCalendarPopup(true);
    dobEdit_->setDisplayFormat("yyyy-MM-dd");
    ageEdit_          = new QSpinBox(this);
    ageEdit_->setRange(0, 150);
    bloodCombo_       = new QComboBox(this);
    bloodCombo_->addItems({"", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"});
    occupationEdit_   = new QLineEdit(this);
    educationEdit_    = new QLineEdit(this);
    maritalCombo_     = new QComboBox(this);
    maritalCombo_->addItems({"Single", "Married", "Divorced", "Widowed"});
    mobileEdit_       = new QLineEdit(this);
    emailEdit_        = new QLineEdit(this);
    nationalityEdit_  = new QLineEdit(this);
    nationalityEdit_->setText("Indian");
    addressEdit_      = new QTextEdit(this);
    addressEdit_->setMaximumHeight(60);
    emergencyEdit_    = new QLineEdit(this);
    relationshipCombo_ = new QComboBox(this);
    relationshipCombo_->addItems({"Head", "Spouse", "Son", "Daughter", "Parent", "Sibling", "Other"});
    statusCombo_      = new QComboBox(this);
    statusCombo_->addItems({"Active", "Inactive", "Deceased"});

    form->addRow(TR("member_family") + "*:",       familyCombo_);
    form->addRow("",               familyNumberLabel_);
    form->addRow(TR("member_code") + ":",   codeEdit_);
    form->addRow(TR("member_name") + "*:",         nameEdit_);
    form->addRow(TR("member_gender") + "*:",       genderCombo_);
    form->addRow(TR("member_dob") + ":", dobEdit_);
    form->addRow(TR("member_age") + ":",           ageEdit_);
    form->addRow(TR("member_blood_group") + ":",   bloodCombo_);
    form->addRow(TR("member_occupation") + ":",    occupationEdit_);
    form->addRow(TR("member_education") + ":",     educationEdit_);
    form->addRow(TR("member_marital_status") + ":",maritalCombo_);
    form->addRow(TR("member_mobile") + ":",        mobileEdit_);
    form->addRow(TR("member_email") + ":",         emailEdit_);
    form->addRow(TR("member_nationality") + ":",   nationalityEdit_);
    form->addRow(TR("family_address") + ":",       addressEdit_);
    form->addRow(TR("member_emergency_contact") + ":",     emergencyEdit_);
    form->addRow(TR("member_relationship") + ":",  relationshipCombo_);
    form->addRow(TR("member_active") + ":",        statusCombo_);

    topRow->addWidget(formGroup, 1);
    layout->addLayout(topRow);

    auto* btns = new QDialogButtonBox(
        QDialogButtonBox::Save | QDialogButtonBox::Cancel, this);
    connect(btns, &QDialogButtonBox::accepted, this, &MemberEditDialog::onSave);
    connect(btns, &QDialogButtonBox::rejected, this, &QDialog::reject);
    layout->addWidget(btns);
}

void MemberEditDialog::loadFamilyCombo() {
    FamilyRepository repo;
    auto families = repo.listAll("Active");
    familyCombo_->blockSignals(true);
    familyCombo_->clear();
    for (const auto& f : families) {
        familyCombo_->addItem(QString("%1 - %2").arg(f.familyNumber).arg(f.houseName), f.id);
    }
    familyCombo_->blockSignals(false);
}

void MemberEditDialog::loadMember() {
    MemberRepository repo;
    auto m = repo.findById(memberId_);
    if (!m) return;
    member_ = *m;
    familyCombo_->setCurrentIndex(familyCombo_->findData(m->familyId));
    codeEdit_->setText(m->memberCode);
    nameEdit_->setText(m->name);
    genderCombo_->setCurrentText(m->gender);
    if (!m->dateOfBirth.isEmpty()) {
        QDate d = QDate::fromString(m->dateOfBirth, Qt::ISODate);
        if (d.isValid()) dobEdit_->setDate(d);
    }
    ageEdit_->setValue(m->age);
    bloodCombo_->setCurrentText(m->bloodGroup);
    occupationEdit_->setText(m->occupation);
    educationEdit_->setText(m->education);
    maritalCombo_->setCurrentText(m->maritalStatus);
    mobileEdit_->setText(m->mobile);
    emailEdit_->setText(m->email);
    nationalityEdit_->setText(m->nationality);
    addressEdit_->setPlainText(m->address);
    emergencyEdit_->setText(m->emergencyContact);
    relationshipCombo_->setCurrentText(m->relationship);
    statusCombo_->setCurrentText(m->status);
    photoPath_ = m->photoPath;
    if (!photoPath_.isEmpty() && QFile::exists(photoPath_)) {
        QPixmap pix(photoPath_);
        photoLabel_->setPixmap(pix.scaled(120, 150, Qt::KeepAspectRatio, Qt::SmoothTransformation));
    }
}

void MemberEditDialog::onUploadPhoto() {
    QString path = QFileDialog::getOpenFileName(this, "Select Photo",
        QString(), "Images (*.jpg *.jpeg *.png *.bmp)");
    if (path.isEmpty()) return;
    QPixmap pix(path);
    if (pix.isNull()) {
        QMessageBox::warning(this, "Invalid", "Cannot load image file.");
        return;
    }
    photoPath_ = path;
    photoLabel_->setPixmap(pix.scaled(120, 150, Qt::KeepAspectRatio, Qt::SmoothTransformation));
}

void MemberEditDialog::onFamilyChanged() {
    qint64 fid = familyCombo_->currentData().toLongLong();
    if (fid <= 0) return;
    FamilyRepository repo;
    auto f = repo.findById(fid);
    if (f) {
        familyNumberLabel_->setText(QString(" %1 |  %2, %3").arg(f->familyNumber).arg(f->address).arg(f->area));
    }
}

void MemberEditDialog::onSave() {
    if (familyCombo_->currentData().toLongLong() <= 0) {
        QMessageBox::warning(this, "Validation", "Please select a family.");
        return;
    }
    if (nameEdit_->text().trimmed().isEmpty()) {
        QMessageBox::warning(this, "Validation", "Name is required.");
        return;
    }
    if (!mobileEdit_->text().isEmpty() && !Security::isValidPhone(mobileEdit_->text())) {
        QMessageBox::warning(this, "Validation", "Mobile number format is invalid.");
        return;
    }
    if (!emailEdit_->text().isEmpty() && !Security::isValidEmail(emailEdit_->text())) {
        QMessageBox::warning(this, "Validation", "Email format is invalid.");
        return;
    }

    member_.id = memberId_;
    member_.familyId = familyCombo_->currentData().toLongLong();
    member_.memberCode = codeEdit_->text().trimmed();
    member_.name = nameEdit_->text().trimmed();
    member_.gender = genderCombo_->currentText();
    member_.dateOfBirth = dobEdit_->date().toString(Qt::ISODate);
    member_.age = ageEdit_->value();
    member_.bloodGroup = bloodCombo_->currentText();
    member_.occupation = occupationEdit_->text().trimmed();
    member_.education = educationEdit_->text().trimmed();
    member_.maritalStatus = maritalCombo_->currentText();
    member_.mobile = mobileEdit_->text().trimmed();
    member_.email = emailEdit_->text().trimmed();
    member_.nationality = nationalityEdit_->text().trimmed();
    member_.address = addressEdit_->toPlainText().trimmed();
    member_.emergencyContact = emergencyEdit_->text().trimmed();
    member_.relationship = relationshipCombo_->currentText();
    member_.status = statusCombo_->currentText();
    member_.isHead = (relationshipCombo_->currentText() == "Head");

    // Save photo
    if (!photoPath_.isEmpty()) {
        QString savedPath = MemberService().savePhoto(photoPath_, memberId_);
        if (!savedPath.isEmpty()) member_.photoPath = savedPath;
    }

    MemberService svc;
    QString err;
    bool ok;
    if (memberId_ > 0) {
        ok = svc.updateMember(member_, &err);
    } else {
        qint64 id = svc.createMember(member_, &err);
        ok = id > 0;
        if (ok) {
            memberId_ = id;
            // If this is a head, set as family head
            if (member_.isHead) svc.setFamilyHead(member_.familyId, id);
        }
    }
    if (ok) accept();
    else QMessageBox::warning(this, "Save Failed", err);
}

} // namespace mms
