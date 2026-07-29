/*
 * RegisterViews.h - Combined Marriage, Death, Welfare views (shared header)
 *
 * These three register views share similar structure (CRUD table).
 * Kept in one header for compactness; implementations in RegisterViews.cpp.
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

class MarriageView : public QWidget {
    Q_OBJECT
public:
    explicit MarriageView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onAdd();
    void onEdit();
    void onDelete();
    void onCertificate();
    void onPrint();
    void onExport();
    void onNextPage();
    void onPrevPage();
private:
    void setupUi();
    void loadTable();
    QTableWidget* table_;
    QLineEdit* searchEdit_;
    QDateEdit* fromDate_, *toDate_;
    QPushButton* addBtn_, *editBtn_, *deleteBtn_, *certBtn_, *printBtn_, *exportBtn_, *prevBtn_, *nextBtn_;
    QLabel* pageLabel_;
    int page_ = 1, pageSize_ = 25, total_ = 0;
};

class DeathView : public QWidget {
    Q_OBJECT
public:
    explicit DeathView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onAdd();
    void onEdit();
    void onDelete();
    void onCertificate();
    void onPrint();
    void onExport();
    void onNextPage();
    void onPrevPage();
private:
    void setupUi();
    void loadTable();
    QTableWidget* table_;
    QLineEdit* searchEdit_;
    QDateEdit* fromDate_, *toDate_;
    QPushButton* addBtn_, *editBtn_, *deleteBtn_, *certBtn_, *printBtn_, *exportBtn_, *prevBtn_, *nextBtn_;
    QLabel* pageLabel_;
    int page_ = 1, pageSize_ = 25, total_ = 0;
};

class WelfareView : public QWidget {
    Q_OBJECT
public:
    explicit WelfareView(QWidget* parent = nullptr);
public slots:
    void refresh();
private slots:
    void onAdd();
    void onEdit();
    void onDelete();
    void onApprove();
    void onReject();
    void onDisburse();
    void onPrint();
    void onExport();
    void onNextPage();
    void onPrevPage();
private:
    void setupUi();
    void loadTable();
    QTableWidget* table_;
    QLineEdit* searchEdit_;
    QComboBox* statusFilter_, *categoryFilter_;
    QPushButton* addBtn_, *editBtn_, *deleteBtn_, *approveBtn_, *rejectBtn_, *disburseBtn_, *printBtn_, *exportBtn_, *prevBtn_, *nextBtn_;
    QLabel* pageLabel_;
    int page_ = 1, pageSize_ = 25, total_ = 0;
};

} // namespace mms
