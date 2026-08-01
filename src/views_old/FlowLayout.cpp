#include "FlowLayout.h"
#include <QWidget>
FlowLayout::FlowLayout(QWidget* parent, int margin, int hSpacing, int vSpacing)
    : QLayout(parent), m_hSpace(hSpacing < 0 ? smartSpacing(QStyle::PM_LayoutHorizontalSpacing) : hSpacing),
      m_vSpace(vSpacing < 0 ? smartSpacing(QStyle::PM_LayoutVerticalSpacing) : vSpacing) {
    setContentsMargins(margin < 0 ? 0 : margin, margin < 0 ? 0 : margin, margin < 0 ? 0 : margin, margin < 0 ? 0 : margin);
}
FlowLayout::FlowLayout(int margin, int hSpacing, int vSpacing)
    : m_hSpace(hSpacing < 0 ? smartSpacing(QStyle::PM_LayoutHorizontalSpacing) : hSpacing),
      m_vSpace(vSpacing < 0 ? smartSpacing(QStyle::PM_LayoutVerticalSpacing) : vSpacing) {
    setContentsMargins(margin < 0 ? 0 : margin, margin < 0 ? 0 : margin, margin < 0 ? 0 : margin, margin < 0 ? 0 : margin);
}
FlowLayout::~FlowLayout() { while (QLayoutItem* item = takeAt(0)) delete item; }
void FlowLayout::addItem(QLayoutItem* item) { itemList.append(item); }
int FlowLayout::horizontalSpacing() const { return m_hSpace >= 0 ? m_hSpace : smartSpacing(QStyle::PM_LayoutHorizontalSpacing); }
int FlowLayout::verticalSpacing() const { return m_vSpace >= 0 ? m_vSpace : smartSpacing(QStyle::PM_LayoutVerticalSpacing); }
int FlowLayout::count() const { return itemList.size(); }
QLayoutItem* FlowLayout::itemAt(int index) const { return itemList.value(index); }
QLayoutItem* FlowLayout::takeAt(int index) { return index >= 0 && index < itemList.size() ? itemList.takeAt(index) : nullptr; }
Qt::Orientations FlowLayout::expandingDirections() const { return Qt::Horizontal | Qt::Vertical; }
bool FlowLayout::hasHeightForWidth() const { return true; }
int FlowLayout::heightForWidth(int width) const { return doLayout(QRect(0, 0, width, 0), true); }
QSize FlowLayout::sizeHint() const { return minimumSize(); }
QSize FlowLayout::minimumSize() const {
    QSize size;
    for (QLayoutItem* item : itemList) size = size.expandedTo(item->minimumSize());
    const auto margins = contentsMargins();
    size += QSize(margins.left() + margins.right(), margins.top() + margins.bottom());
    return size;
}
void FlowLayout::setGeometry(const QRect& rect) { QLayout::setGeometry(rect); doLayout(rect, false); }
int FlowLayout::doLayout(const QRect& rect, bool testOnly) const {
    const auto margins = contentsMargins();
    QRect effectiveRect = rect.adjusted(margins.left(), margins.top(), -margins.right(), -margins.bottom());
    int x = effectiveRect.x(); int y = effectiveRect.y(); int lineHeight = 0;
    for (QLayoutItem* item : itemList) {
        const int spaceX = horizontalSpacing() >= 0 ? horizontalSpacing() : item->widget()->style()->layoutSpacing(QSizePolicy::PushButton, QSizePolicy::PushButton, Qt::Horizontal);
        const int spaceY = verticalSpacing() >= 0 ? verticalSpacing() : item->widget()->style()->layoutSpacing(QSizePolicy::PushButton, QSizePolicy::PushButton, Qt::Vertical);
        int nextX = x + item->sizeHint().width() + spaceX;
        if (nextX - spaceX > effectiveRect.right() && lineHeight > 0) {
            x = effectiveRect.x(); y = y + lineHeight + spaceY;
            nextX = x + item->sizeHint().width() + spaceX; lineHeight = 0;
        }
        if (!testOnly) item->setGeometry(QRect(QPoint(x, y), item->sizeHint()));
        x = nextX; lineHeight = qMax(lineHeight, item->sizeHint().height());
    }
    return y + lineHeight - rect.y() + margins.bottom();
}
int FlowLayout::smartSpacing(QStyle::PixelMetric pm) const {
    QObject* p = parent();
    if (!p || !p->isWidgetType()) return -1;
    if (QWidget* pw = qobject_cast<QWidget*>(p)) return pw->style()->pixelMetric(pm, nullptr, pw);
    return -1;
}
