#pragma once
#include "StyledComboBox.h"
#include "../core/I18N.h"
#include <QSizePolicy>

namespace mms {

// Centralized combo box factory — ensures consistent TR() + UserRole pattern
// across all views. Canonical English values stored in UserRole.
class ComboFactory {
public:
    static StyledComboBox* makeStatusCombo(QWidget* parent, bool includeAll = true) {
        auto* cb = new StyledComboBox(parent);
        if (includeAll) cb->addItem("", "");
        cb->addItem(TR("member_active"), "Active");
        cb->addItem(TR("member_inactive"), "Inactive");
        cb->addItem(TR("family_archived"), "Archived");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }

    static StyledComboBox* makeGenderCombo(QWidget* parent, bool includeAll = true) {
        auto* cb = new StyledComboBox(parent);
        if (includeAll) cb->addItem("", "");
        cb->addItem(TR("member_male"), "Male");
        cb->addItem(TR("member_female"), "Female");
        cb->addItem(TR("member_other"), "Other");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }

    static StyledComboBox* makeMemberStatusCombo(QWidget* parent, bool includeAll = true) {
        auto* cb = new StyledComboBox(parent);
        if (includeAll) cb->addItem("", "");
        cb->addItem(TR("member_active"), "Active");
        cb->addItem(TR("member_inactive"), "Inactive");
        cb->addItem(TR("member_deceased"), "Deceased");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }

    static StyledComboBox* makeSubscriptionStatusCombo(QWidget* parent, bool includeAll = true) {
        auto* cb = new StyledComboBox(parent);
        if (includeAll) cb->addItem("", "");
        cb->addItem(TR("sub_paid"), "Paid");
        cb->addItem(TR("sub_pending"), "Pending");
        cb->addItem(TR("sub_overdue"), "Overdue");
        cb->addItem(TR("sub_partial"), "Partial");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }

    static StyledComboBox* makePaymentMethodCombo(QWidget* parent) {
        auto* cb = new StyledComboBox(parent);
        cb->addItem(TR("acc_method_cash"), "Cash");
        cb->addItem(TR("acc_method_cheque"), "Cheque");
        cb->addItem(TR("acc_method_upi"), "UPI");
        cb->addItem(TR("acc_method_bank"), "Bank Transfer");
        cb->addItem(TR("acc_method_card"), "Card");
        cb->addItem(TR("acc_method_other"), "Other");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }

    static StyledComboBox* makeRelationshipCombo(QWidget* parent) {
        auto* cb = new StyledComboBox(parent);
        cb->addItem(TR("member_head"), "Head");
        cb->addItem(TR("member_spouse"), "Spouse");
        cb->addItem(TR("member_son"), "Son");
        cb->addItem(TR("member_daughter"), "Daughter");
        cb->addItem(TR("member_parent"), "Parent");
        cb->addItem(TR("member_sibling"), "Sibling");
        cb->addItem(TR("member_other_rel"), "Other");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }

    static StyledComboBox* makeWelfareStatusCombo(QWidget* parent, bool includeAll = true) {
        auto* cb = new StyledComboBox(parent);
        if (includeAll) cb->addItem("", "");
        cb->addItem(TR("wel_status_pending"), "Pending");
        cb->addItem(TR("wel_status_approved"), "Approved");
        cb->addItem(TR("wel_status_rejected"), "Rejected");
        cb->addItem(TR("wel_status_disbursed"), "Disbursed");
        cb->addItem(TR("wel_status_closed"), "Closed");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }

    static StyledComboBox* makeWelfareCategoryCombo(QWidget* parent, bool includeAll = true) {
        auto* cb = new StyledComboBox(parent);
        if (includeAll) cb->addItem("", "");
        cb->addItem(TR("wel_cat_medical"), "Medical Aid");
        cb->addItem(TR("wel_cat_education"), "Education Aid");
        cb->addItem(TR("wel_cat_marriage"), "Marriage Assistance");
        cb->addItem(TR("wel_cat_financial"), "Financial Assistance");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }

    static StyledComboBox* makeTransactionTypeCombo(QWidget* parent, bool includeAll = true) {
        auto* cb = new StyledComboBox(parent);
        if (includeAll) cb->addItem("", "");
        cb->addItem(TR("acc_type_income"), "Income");
        cb->addItem(TR("acc_type_expense"), "Expense");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }

    static StyledComboBox* makeUserRoleCombo(QWidget* parent) {
        auto* cb = new StyledComboBox(parent);
        cb->addItem(TR("usr_role_admin"), "Administrator");
        cb->addItem(TR("usr_role_president"), "President");
        cb->addItem(TR("usr_role_secretary"), "Secretary");
        cb->addItem(TR("usr_role_treasurer"), "Treasurer");
        cb->addItem(TR("usr_role_imam"), "Imam");
        cb->addItem(TR("usr_role_staff"), "Staff");
        cb->addItem(TR("usr_role_auditor"), "Auditor");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }

    static StyledComboBox* makeCertificateTypeCombo(QWidget* parent) {
        auto* cb = new StyledComboBox(parent);
        cb->addItem(TR("cert_type_membership"), "Membership");
        cb->addItem(TR("cert_type_residence"), "Residence");
        cb->addItem(TR("cert_type_marriage"), "Marriage");
        cb->addItem(TR("cert_type_death"), "Death");
        cb->addItem(TR("cert_type_character"), "Character");
        cb->addItem(TR("cert_type_income"), "Income");
        cb->setMinimumHeight(38);
        cb->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
        return cb;
    }
};

} // namespace mms
