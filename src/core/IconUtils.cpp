#include "IconUtils.h"
#include <QPushButton>
#include <QComboBox>
#include <QAbstractItemView>
#include <QFrame>
#include <QSvgRenderer>
#include <QPainter>
#include <QImage>
namespace mms { namespace icons {
QPixmap renderSvgIcon(const QString& svgPath, const QColor& color, int size) {
    QPixmap pix(size, size); pix.fill(Qt::transparent);
    QSvgRenderer svg(svgPath); if (!svg.isValid()) return pix;
    QImage img(size, size, QImage::Format_ARGB32); img.fill(Qt::transparent);
    QPainter p(&img); p.setRenderHint(QPainter::Antialiasing); p.setRenderHint(QPainter::SmoothPixmapTransform);
    svg.render(&p, QRectF(0, 0, size, size)); p.end();
    for (int y = 0; y < img.height(); ++y) for (int x = 0; x < img.width(); ++x) {
        QRgb px = img.pixel(x, y); int a = qAlpha(px);
        if (a > 0) img.setPixel(x, y, qRgba(color.red(), color.green(), color.blue(), a));
    }
    return QPixmap::fromImage(img);
}
QPixmap renderSvgIcon(const QString& svgPath, const QString& colorHex, int size) { return renderSvgIcon(svgPath, QColor(colorHex), size); }
void setButtonIcon(QPushButton* btn, const QString& svgPath, const QString& colorHex, int iconSize, bool stripTextPrefix) {
    if (!btn) return;
    if (stripTextPrefix) {
        QString text = btn->text(); int i = 0;
        while (i < text.size()) { QChar ch = text.at(i); if (ch.isSpace()) { ++i; break; }
            if (ch.unicode() >= 0x2000 && ch.unicode() <= 0x2BFF) { ++i; continue; }
            if (ch.unicode() >= 0x1F000) { ++i; continue; }
            if (ch.unicode() >= 0x2600 && ch.unicode() <= 0x27BF) { ++i; continue; } break; }
        while (i < text.size() && text.at(i).isSpace()) ++i; btn->setText(text.mid(i));
    }
    btn->setIcon(QIcon(renderSvgIcon(svgPath, colorHex, iconSize))); btn->setIconSize(QSize(iconSize, iconSize));
}
void applyComboShadow(QComboBox* combo) {
    if (!combo) return; QAbstractItemView* v = combo->view(); if (!v) return;
    v->setFrameShape(QFrame::NoFrame);
}
}}
