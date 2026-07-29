/*
 * FamilyEditDialog.h - Add/Edit family dialog
 */
#pragma once

#include <QDialog>
#include "../models/Family.h"

class QLineEdit;
class QComboBox;
class QTextEdit;

namespace mms {

class FamilyEditDialog : public QDialog {
    Q_OBJECT
public:
    FamilyEditDialog(QWidget* parent, qint64 familyId = 0);

private slots:
    void onSave();
    void onCancel();

private:
    void setupUi();
    void loadFamily();

    qint64 familyId_ = 0;
    Family family_;

    QLineEdit* familyNumberEdit_ = nullptr;
    QLineEdit* houseNameEdit_    = nullptr;
    QLineEdit* houseNumberEdit_  = nullptr;
    QLineEdit* wardEdit_         = nullptr;
    QLineEdit* areaEdit_         = nullptr;
    QTextEdit* addressEdit_      = nullptr;
    QLineEdit* pincodeEdit_      = nullptr;
    QLineEdit* phoneEdit_        = nullptr;
    QLineEdit* altPhoneEdit_     = nullptr;
    QComboBox* statusCombo_      = nullptr;
    QTextEdit* notesEdit_        = nullptr;
};

} // namespace mms
