/*
 * MemberView.h
 */
#pragma once

#include <QWidget>

class QTableWidget;
class QLineEdit;
class QComboBox;
class QPushButton;
class QLabel;

namespace mms {

class MemberView : public QWidget {
    Q_OBJECT
public:
    explicit MemberView(QWidget* parent = nullptr);

public slots:
    void refresh();

private slots:
    void onAdd();
    void onEdit();
    void onDelete();
    void onPrint();
    void onExport();
    void onRowDoubleClicked();
    void onNextPage();
    void onPrevPage();

private:
    void setupUi();
    void loadTable();

    QTableWidget* table_ = nullptr;
    QLineEdit* searchEdit_ = nullptr;
    QComboBox* genderFilter_ = nullptr;
    QComboBox* statusFilter_ = nullptr;
    QPushButton* addBtn_, *editBtn_, *deleteBtn_, *printBtn_, *exportBtn_;
    QPushButton* prevBtn_, *nextBtn_;
    QLabel* pageLabel_;
    int page_ = 1;
    int pageSize_ = 25;
    int total_ = 0;
};

} // namespace mms
