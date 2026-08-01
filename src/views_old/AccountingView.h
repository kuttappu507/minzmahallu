/*
 * AccountingView.h
 */
#pragma once

#include <QWidget>
#include <QTabWidget>

class QTableWidget;
class QLineEdit;
class QComboBox;
class QDateEdit;
class QPushButton;
class QLabel;

namespace mms {

class AccountingView : public QWidget {
    Q_OBJECT
public:
    explicit AccountingView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onAddIncome();
    void onAddExpense();
    void onDelete();
    void onPrint();
    void onExport();
    void onNextPage();
    void onPrevPage();
    void onTabChanged(int);
private:
    void setupUi();
    void loadTable();
    void loadSummary();
    void loadSummaryLabel();
    QTabWidget* tabs_ = nullptr;
    QTableWidget* table_ = nullptr;
    QTableWidget* summaryTable_ = nullptr;
    QDateEdit* fromDate_ = nullptr;
    QDateEdit* toDate_ = nullptr;
    QComboBox* typeFilter_ = nullptr;
    QPushButton* addIncomeBtn_, *addExpenseBtn_, *deleteBtn_, *printBtn_, *exportBtn_;
    QPushButton* prevBtn_, *nextBtn_;
    QLabel* pageLabel_, *summaryLabel_;
    int page_ = 1, pageSize_ = 25, total_ = 0;
};

} // namespace mms
