#pragma once
#include <QComboBox>
#include <QListView>
#include <QGuiApplication>
#include <QScreen>
#include <QPoint>
#include <QRect>
#include <QFrame>
#include <QApplication>

namespace mms {

// StyledComboBox ensures the dropdown popup appears directly below the
// combo box, properly aligned, and clamped to screen boundaries.
// This fixes the issue where QSS margin/padding properties conflict
// with Qt's internal popup geometry calculation.
class StyledComboBox : public QComboBox {
    Q_OBJECT
public:
    explicit StyledComboBox(QWidget* parent = nullptr) : QComboBox(parent) {
        setView(new QListView(this));
        setObjectName("styledCombo");
        setMaxVisibleItems(30);
    }

protected:
    void showPopup() override {
        // Let Qt do default positioning first
        QComboBox::showPopup();

        // Find the popup widget
        QFrame* popup = nullptr;
        // Try finding a child QFrame (the popup container)
        QList<QFrame*> frames = findChildren<QFrame*>();
        for (auto* f : frames) {
            if (f->isVisible() && qobject_cast<StyledComboBox*>(f) == nullptr) {
                popup = f;
                break;
            }
        }

        // Fallback: use active popup widget
        if (!popup) {
            popup = qobject_cast<QFrame*>(QApplication::activePopupWidget());
        }

        if (!popup) return;

        // Calculate correct position: directly below the combo box
        QPoint correctPos = mapToGlobal(QPoint(0, height()));

        // Get screen geometry for clamping
        QScreen* screen = QGuiApplication::screenAt(
            mapToGlobal(QPoint(width() / 2, height() / 2)));
        if (!screen) screen = QGuiApplication::primaryScreen();
        if (!screen) return;
        QRect screenRect = screen->availableGeometry();

        // Clamp X so popup does not go off right edge of screen
        if (correctPos.x() + popup->width() > screenRect.right()) {
            correctPos.setX(screenRect.right() - popup->width());
        }
        // Clamp X so popup does not go off left edge
        if (correctPos.x() < screenRect.left()) {
            correctPos.setX(screenRect.left());
        }

        // Flip above if not enough room below
        if (correctPos.y() + popup->height() > screenRect.bottom()) {
            correctPos.setY(mapToGlobal(QPoint(0, 0)).y() - popup->height());
        }

        // Force popup width to match combo width
        popup->setFixedWidth(width());

        // Move popup to correct position
        popup->move(correctPos);
    }
};

} // namespace mms
