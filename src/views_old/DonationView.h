/*
 * DonationView.h
 */
#pragma once

#include <QWidget>

class QTableWidget;
class QLineEdit;
class QComboBox;
class QDateEdit;
class QPushButton;
class QLabel;

namespace mms {

class DonationView : public QWidget {
    Q_OBJECT
public:
    explicit DonationView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onAdd();
    void onEdit();
    void onDelete();
    void onPrint();
    void onExport();
    void onNextPage();
    void onPrevPage();
private:
    void setupUi();
    void loadTable();
    void loadCategories();
    QTableWidget* table_ = nullptr;
    QLineEdit* searchEdit_ = nullptr;
    QComboBox* categoryCombo_ = nullptr;
    QDateEdit* fromDate_ = nullptr;
    QDateEdit* toDate_ = nullptr;
    QPushButton* addBtn_, *editBtn_, *deleteBtn_, *printBtn_, *exportBtn_, *prevBtn_, *nextBtn_;
    QLabel* pageLabel_, *summaryLabel_;
    int page_ = 1, pageSize_ = 25, total_ = 0;
};

} // namespace mms
