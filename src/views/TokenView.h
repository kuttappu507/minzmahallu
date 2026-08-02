#pragma once
#include <QWidget>
#include <QStackedWidget>
#include <QTableWidget>
#include <QPushButton>
#include <QLabel>
#include <QProgressBar>
#include <QLineEdit>
#include "../services/TokenService.h"
#include "../services/TokenPdfEngine.h"

namespace mms {

class TokenView : public QWidget {
    Q_OBJECT
public:
    explicit TokenView(QWidget* parent = nullptr);
    void refresh();

signals:
    void navigateToView(int index);

private slots:
    void onNewEvent();
    void onDeleteEvent();
    void onEventDoubleClicked(int row, int col);
    void onBackToList();
    void onSelectFamilies();
    void onGenerateTokens();
    void onPrintTokens();
    void onPrintCollection();
    void onMarkCollected();
    void onMarkUncollected();
    void onToggleCollected(int row, int col);

private:
    void setupEventListPage();
    void setupEventDetailPage();
    void loadEventList();
    void loadEventDetail(int eventId);
    void showEventDetail(int eventId);

    TokenService* tokenService_ = nullptr;
    TokenPdfEngine* pdfEngine_ = nullptr;

    QStackedWidget* stack_ = nullptr;

    // Event list page
    QWidget* listPage_ = nullptr;
    QTableWidget* eventTable_ = nullptr;
    QPushButton* newEventBtn_ = nullptr;
    QPushButton* deleteEventBtn_ = nullptr;

    // Event detail page
    QWidget* detailPage_ = nullptr;
    QLabel* detailTitle_ = nullptr;
    QLabel* detailInfo_ = nullptr;
    QProgressBar* progressBar_ = nullptr;
    QLabel* statsLabel_ = nullptr;
    QTableWidget* assignmentTable_ = nullptr;
    QPushButton* selectFamiliesBtn_ = nullptr;
    QPushButton* generateBtn_ = nullptr;
    QPushButton* printTokensBtn_ = nullptr;
    QPushButton* printCollectionBtn_ = nullptr;
    QPushButton* backBtn_ = nullptr;
    QPushButton* markCollectedBtn_ = nullptr;
    QPushButton* markUncollectedBtn_ = nullptr;

    int currentEventId_ = 0;
};

} // namespace mms
