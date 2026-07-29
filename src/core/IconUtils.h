#pragma once
#include <QPixmap>
#include <QString>
#include <QColor>
class QPushButton;
class QComboBox;
namespace mms { namespace icons {
QPixmap renderSvgIcon(const QString& svgPath, const QColor& color, int size);
QPixmap renderSvgIcon(const QString& svgPath, const QString& colorHex, int size);
void setButtonIcon(QPushButton* btn, const QString& svgPath, const QString& colorHex, int iconSize = 18, bool stripTextPrefix = true);
void applyComboShadow(QComboBox* combo);
}}
