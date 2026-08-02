/*
 * SubscriptionEditDialog.h
 */
#pragma once

#include <QDialog>
#include "../models/Subscription.h"

class QLineEdit;
class QComboBox;
class QDateEdit;
class QTextEdit;
class QDoubleSpinBox;

namespace mms {

class SubscriptionEditDialog : public QDialog {
    Q_OBJECT
public:
    SubscriptionEditDialog(QWidget* parent, qint64 subscriptionId = 0);
private slots:
    void onSave();
    void onFamilyChanged();
    void onStatusChanged();
private:
    void setupUi();
    void loadPlans();
    void loadFamilies();
    void loadMembers(qint64 familyId);
    void loadSubscription();

    qint64 id_ = 0;
    Subscription sub_;

    QComboBox* familyCombo_ = nullptr;
    QComboBox* memberCombo_ = nullptr;
    QComboBox* planCombo_ = nullptr;
    QDateEdit* periodStartEdit_ = nullptr;
    QDateEdit* periodEndEdit_ = nullptr;
    QDoubleSpinBox* amountEdit_ = nullptr;
    QDoubleSpinBox* amountPaidEdit_ = nullptr;
    QDateEdit* paymentDateEdit_ = nullptr;
    QLineEdit* receiptEdit_ = nullptr;
    QComboBox* methodCombo_ = nullptr;
    QLineEdit* refEdit_ = nullptr;
    QComboBox* statusCombo_ = nullptr;
    QTextEdit* remarksEdit_ = nullptr;
};

} // namespace mms
