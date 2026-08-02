/*
 * MemberEditDialog.h
 */
#pragma once

#include <QDialog>
#include "../models/Member.h"

class QLineEdit;
class QComboBox;
class QTextEdit;
class QDateEdit;
class QLabel;
class QSpinBox;

namespace mms {

class MemberEditDialog : public QDialog {
    Q_OBJECT
public:
    MemberEditDialog(QWidget* parent, qint64 memberId = 0, qint64 familyId = 0);

private slots:
    void onSave();
    void onUploadPhoto();
    void onFamilyChanged();

private:
    void setupUi();
    void loadFamilyCombo();
    void loadMember();

    qint64 memberId_ = 0;
    Member member_;
    QString photoPath_;

    QComboBox* familyCombo_ = nullptr;
    QLabel* familyNumberLabel_ = nullptr;
    QLineEdit* codeEdit_ = nullptr;
    QLineEdit* nameEdit_ = nullptr;
    QLineEdit* arabicNameEdit_ = nullptr;
    QComboBox* genderCombo_ = nullptr;
    QDateEdit* dobEdit_ = nullptr;
    QSpinBox* ageEdit_ = nullptr;
    QComboBox* bloodCombo_ = nullptr;
    QLineEdit* occupationEdit_ = nullptr;
    QLineEdit* educationEdit_ = nullptr;
    QComboBox* maritalCombo_ = nullptr;
    QLineEdit* mobileEdit_ = nullptr;
    QLineEdit* emailEdit_ = nullptr;
    QLineEdit* nationalityEdit_ = nullptr;
    QTextEdit* addressEdit_ = nullptr;
    QLineEdit* emergencyEdit_ = nullptr;
    QComboBox* relationshipCombo_ = nullptr;
    QComboBox* statusCombo_ = nullptr;
    QLabel* photoLabel_ = nullptr;
    QPushButton* photoBtn_ = nullptr;
};

} // namespace mms
