/*
 * SubscriptionView.h
 */
#pragma once

#include <QWidget>

class QTableWidget;
class QLineEdit;
class QComboBox;
class QDateEdit;
class QPushButton;
class QLabel;
class QTabWidget;

namespace mms {

class SubscriptionView : public QWidget {
    Q_OBJECT
public:
    explicit SubscriptionView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onAdd();
    void onEdit();
    void onDelete();
    void onPrint();
    void onExport();
    void onMarkOverdue();
    void onShowDefaulters();
    void onNextPage();
    void onPrevPage();
    void onTabChanged(int);
private:
    void setupUi();
    void loadTable();
    void loadDefaulters();
    QTabWidget* tabs_ = nullptr;
    QTableWidget* table_ = nullptr;
    QTableWidget* defaultersTable_ = nullptr;
    QLineEdit* searchEdit_ = nullptr;
    QComboBox* statusFilter_ = nullptr;
    QDateEdit* fromDate_ = nullptr;
    QDateEdit* toDate_ = nullptr;
    QPushButton* addBtn_, *editBtn_, *deleteBtn_, *printBtn_, *exportBtn_, *markOverdueBtn_;
    QPushButton* prevBtn_, *nextBtn_;
    QLabel* pageLabel_, *summaryLabel_;
    int page_ = 1, pageSize_ = 25, total_ = 0;
};

} // namespace mms
