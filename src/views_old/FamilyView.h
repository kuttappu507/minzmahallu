/*
 * FamilyView.h - Family management screen with full CRUD
 */
#pragma once

#include <QWidget>

class QTableWidget;
class QLineEdit;
class QComboBox;
class QPushButton;
class QLabel;

namespace mms {

class FamilyView : public QWidget {
    Q_OBJECT
public:
    explicit FamilyView(QWidget* parent = nullptr);

public slots:
    void refresh();

private slots:
    void onSearch();
    void onAdd();
    void onEdit();
    void onDelete();
    void onArchive();
    void onPrint();
    void onExport();
    void onRowDoubleClicked(int row, int col);
    void onPageChanged();
    void onNextPage();
    void onPrevPage();

private:
    void setupUi();
    void loadTable();
    void loadWardFilter();

    QTableWidget* table_ = nullptr;
    QLineEdit* searchEdit_ = nullptr;
    QComboBox* statusFilter_ = nullptr;
    QComboBox* wardFilter_ = nullptr;
    QPushButton* addBtn_   = nullptr;
    QPushButton* editBtn_  = nullptr;
    QPushButton* archiveBtn_ = nullptr;
    QPushButton* deleteBtn_ = nullptr;
    QPushButton* printBtn_ = nullptr;
    QPushButton* exportBtn_ = nullptr;
    QPushButton* prevBtn_  = nullptr;
    QPushButton* nextBtn_  = nullptr;
    QLabel* pageLabel_ = nullptr;

    int page_ = 1;
    int pageSize_ = 25;
    int total_ = 0;
};

} // namespace mms
