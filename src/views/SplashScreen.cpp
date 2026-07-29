#include "SplashScreen.h"
#include "../core/I18N.h"
#include "../core/ThemeColors.h"
#include <QPainter>
#include <QPainterPath>
#include <QScreen>
#include <QGuiApplication>
#include <QLinearGradient>
#include <QTimer>
#include <QFile>
#include <QPixmap>

namespace mms {

SplashScreen::SplashScreen(const QPixmap&)
    : QSplashScreen(QPixmap(640, 420)) {
    setFixedSize(640, 420);
    setWindowFlags(Qt::FramelessWindowHint | Qt::SplashScreen | Qt::WindowStaysOnTopHint);
    if (QScreen* screen = QGuiApplication::primaryScreen()) {
        QRect sg = screen->availableGeometry();
        move((sg.width() - width()) / 2, (sg.height() - height()) / 2);
    }
    timer_ = new QTimer(this);
    timer_->setInterval(40);
    connect(timer_, &QTimer::timeout, this, &SplashScreen::advanceProgress);
}

SplashScreen::~SplashScreen() { if (timer_) timer_->stop(); }

void SplashScreen::showLoading() {
    progress_ = 0;
    currentStatus_ = "Loading Minz Mahallu Management...";
    show();
    timer_->start();
}

void SplashScreen::advanceProgress() {
    if (progress_ < progressTarget_)
        progress_ = std::min(progress_ + 2, progressTarget_);
    if (progress_ < 20) currentStatus_ = "Initializing core systems...";
    else if (progress_ < 40) currentStatus_ = "Loading fonts and resources...";
    else if (progress_ < 60) currentStatus_ = "Connecting to database...";
    else if (progress_ < 80) currentStatus_ = "Loading translations...";
    else if (progress_ < 100) currentStatus_ = "Preparing user interface...";
    else currentStatus_ = "Ready!";
    repaint();
    if (progress_ >= 100) {
        timer_->stop();
        QTimer::singleShot(400, this, [this]() { emit loadingComplete(); });
    }
}

void SplashScreen::finish() { if (timer_) timer_->stop(); close(); }

void SplashScreen::drawContents(QPainter* painter) {
    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->setRenderHint(QPainter::TextAntialiasing, true);
    int w = width(), h = height();

    QLinearGradient bgGrad(0, 0, w, h);
    bgGrad.setColorAt(0, colors::splashStart);
    bgGrad.setColorAt(0.5, colors::splashMid);
    bgGrad.setColorAt(1, colors::splashStart);
    painter->fillRect(0, 0, w, h, bgGrad);

    painter->setPen(QPen(QColor(255, 255, 255, 12), 1));
    for (int i = -h; i < w + h; i += 24)
        painter->drawLine(i, 0, i + h, h);

    // Logo - load from PNG resource
    int logoSize = 140, logoX = (w - logoSize) / 2, logoY = 40;
    painter->setPen(QPen(QColor(255, 255, 255, 60), 2));
    painter->setBrush(QColor(255, 255, 255, 30));
    painter->drawEllipse(logoX - 10, logoY - 10, logoSize + 20, logoSize + 20);
    QPixmap logoPix;
    if (QFile::exists(":/icons/mms_white.png")) logoPix.load(":/icons/mms_white.png");
    else if (QFile::exists(":/icons/mms.png")) logoPix.load(":/icons/mms.png");
    if (!logoPix.isNull()) {
        painter->drawPixmap(logoX, logoY, logoPix.scaled(logoSize, logoSize, Qt::KeepAspectRatio, Qt::SmoothTransformation));
    }

    // App name
    painter->setPen(QColor(255, 255, 255));
    QFont nameFont("Space Grotesk", 22, QFont::Bold);
    painter->setFont(nameFont);
    painter->drawText(QRect(0, logoY + logoSize + 15, w, 36), Qt::AlignCenter, "Minz Mahallu Management");

    // Subtitle
    painter->setPen(QColor(255, 215, 0, 220));
    QFont subFont("Manrope", 11);
    painter->setFont(subFont);
    QString subtitle = "Mosque Community Administration";
    if (I18N::instance().currentLanguage() == "ml") subtitle = "മസ്ജിദ് കമ്മ്യൂണിറ്റി ഭരണം";
    painter->drawText(QRect(0, logoY + logoSize + 50, w, 22), Qt::AlignCenter, subtitle);

    // Progress bar
    int barX = 80, barY = h - 70, barW = w - 160, barH = 8;
    painter->setPen(Qt::NoPen);
    painter->setBrush(QColor(255, 255, 255, 50));
    painter->drawRoundedRect(barX, barY, barW, barH, 4, 4);
    int fillW = (barW * progress_) / 100;
    if (fillW > 0) {
        QLinearGradient fillGrad(barX, 0, barX + barW, 0);
        fillGrad.setColorAt(0, colors::goldLight);
        fillGrad.setColorAt(1, colors::gold);
        painter->setBrush(fillGrad);
        painter->drawRoundedRect(barX, barY, fillW, barH, 4, 4);
    }
    painter->setPen(QColor(255, 255, 255, 200));
    QFont pctFont("Space Grotesk", 10, QFont::Bold);
    painter->setFont(pctFont);
    painter->drawText(QRect(barX, barY - 25, barW, 18), Qt::AlignRight, QString::number(progress_) + "%");
    painter->setPen(QColor(255, 255, 255, 230));
    QFont statusFont("Manrope", 10);
    painter->setFont(statusFont);
    painter->drawText(QRect(barX, barY + 14, barW, 20), Qt::AlignLeft, currentStatus_);
    painter->setPen(QColor(255, 255, 255, 100));
    QFont verFont("Manrope", 9);
    painter->setFont(verFont);
    painter->drawText(QRect(20, h - 26, w - 40, 16), Qt::AlignLeft, "v1.0.0");
}

} // namespace mms
