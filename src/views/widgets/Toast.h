#pragma once
#include <QWidget>
#include <QLabel>
#include <QHBoxLayout>
#include <QTimer>
#include <QPropertyAnimation>
#include <QGraphicsOpacityEffect>
#include <QPainter>
#include <QSvgRenderer>

// Toast — transient notification widget.
//
// All visual styling (background, border, accent stripe, label color) is
// driven by QSS via object name `toast` and the `kind` dynamic property
// (one of "ok", "err", "warn", "info"). This class does NOT call
// setStyleSheet anywhere; the QSS rules live in resources/styles/light.qss
// and dark.qss.
class Toast : public QWidget {
    Q_OBJECT
public:
    enum Type { Success, Error, Warning, Info };

    static void showToast(QWidget* parent, const QString& message,
                     Type type = Success, int durationMs = 3000) {
        QWidget* root = parent;
        while (root->parentWidget()) root = root->parentWidget();
        auto* toast = new Toast(root, message, type);
        toast->animateIn();
        QTimer::singleShot(durationMs, toast, [toast]() { toast->animateOut(); });
    }

protected:
    void paintEvent(QPaintEvent*) override {
        // The QSS handles the visual styling of the underlying QFrame#toast,
        // but Toast itself is a frameless translucent QWidget. We paint a
        // soft drop shadow here only — the body comes from QSS via the
        // QFrame#toast child that fills the widget.
        QPainter p(this);
        p.setRenderHint(QPainter::Antialiasing);
        for (int i = 4; i >= 0; i--) {
            p.setBrush(QColor(0, 0, 0, 8 * (5 - i)));
            p.setPen(Qt::NoPen);
            p.drawRoundedRect(rect().adjusted(i, i, -i, -i + 4), 10, 10);
        }
    }

private:
    explicit Toast(QWidget* parent, const QString& msg, Type type)
        : QWidget(parent, Qt::FramelessWindowHint | Qt::Tool) {
        setAttribute(Qt::WA_TranslucentBackground);
        setAttribute(Qt::WA_ShowWithoutActivating);
        setFixedSize(320, 52);

        // Map Type -> kind property string used by QSS.
        const char* kinds[] = {"ok", "err", "warn", "info"};
        const char* icons[] = {
            ":/icons/check.svg",
            ":/icons/trash.svg",
            ":/icons/alert.svg",
            ":/icons/bell.svg"
        };

        // The visible card is a QFrame styled entirely by QSS.
        auto* card = new QFrame(this);
        card->setObjectName("toast");
        card->setProperty("kind", kinds[type]);
        card->setGeometry(rect());

        auto* layout = new QHBoxLayout(card);
        layout->setContentsMargins(16, 0, 16, 0);
        layout->setSpacing(10);

        auto* iconLbl = new QLabel(card);
        QPixmap iconPix(18, 18);
        iconPix.fill(Qt::transparent);
        QSvgRenderer svg(QString(icons[type]));
        if (svg.isValid()) {
            QPainter ip(&iconPix);
            ip.setRenderHint(QPainter::Antialiasing);
            svg.render(&ip, QRectF(0, 0, 18, 18));
        }
        iconLbl->setPixmap(iconPix);

        auto* label = new QLabel(msg, card);
        label->setObjectName("toastMsg");
        layout->addWidget(iconLbl);
        layout->addWidget(label, 1);

        move(parent->width() - 340, parent->height() - 72);
    }

    void animateIn() {
        show();
        auto* anim = new QPropertyAnimation(this, "pos", this);
        anim->setDuration(200);
        anim->setStartValue(pos() + QPoint(0, 20));
        anim->setEndValue(pos());
        anim->setEasingCurve(QEasingCurve::OutCubic);
        anim->start(QAbstractAnimation::DeleteWhenStopped);
    }

    void animateOut() {
        auto* fade = new QGraphicsOpacityEffect(this);
        setGraphicsEffect(fade);
        auto* fadeAnim = new QPropertyAnimation(fade, "opacity", this);
        fadeAnim->setDuration(120);
        fadeAnim->setStartValue(1.0);
        fadeAnim->setEndValue(0.0);
        connect(fadeAnim, &QPropertyAnimation::finished, this, &QObject::deleteLater);
        fadeAnim->start(QAbstractAnimation::DeleteWhenStopped);
    }
};
