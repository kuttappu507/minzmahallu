/*
 * SplashScreen.h
 */
#pragma once
#include <QSplashScreen>
#include <QTimer>
#include <QString>

namespace mms {
class SplashScreen : public QSplashScreen {
    Q_OBJECT
public:
    explicit SplashScreen(const QPixmap& pixmap = QPixmap());
    ~SplashScreen() override;
    void showLoading();
    void finish();
signals:
    void loadingComplete();
private slots:
    void advanceProgress();
private:
    void drawContents(QPainter* painter) override;
    QTimer* timer_ = nullptr;
    int progress_ = 0;
    QString currentStatus_ = "Initializing...";
    int progressTarget_ = 100;
};
} // namespace mms
