#pragma once
#include <QFrame>
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>
#include "../core/I18N.h"

namespace mms {

// Reusable empty state widget for tables with no data.
// Shows an icon, title, subtitle, and optional action button.
//
// Styling is driven entirely by QSS (resources/styles/light.qss and
// dark.qss). This class does NOT call setStyleSheet — all visual properties
// are expressed via object names and dynamic properties so the theme system
// has a single source of truth.
class EmptyStateWidget : public QFrame {
    Q_OBJECT
public:
    explicit EmptyStateWidget(QWidget* parent = nullptr) : QFrame(parent) {
        setObjectName("emptyState");
        // Frame is transparent; the surrounding table/card provides the
        // background. The QSS rule `QFrame#emptyState { background: transparent; }`
        // lives in light.qss / dark.qss.
        auto* layout = new QVBoxLayout(this);
        layout->setAlignment(Qt::AlignCenter);
        layout->setSpacing(8);

        iconLabel_ = new QLabel(this);
        iconLabel_->setAlignment(Qt::AlignCenter);
        iconLabel_->setProperty("cssClass", "emptyIcon");
        layout->addWidget(iconLabel_);

        titleLabel_ = new QLabel(this);
        titleLabel_->setAlignment(Qt::AlignCenter);
        titleLabel_->setProperty("cssClass", "emptyTitle");
        layout->addWidget(titleLabel_);

        subtitleLabel_ = new QLabel(this);
        subtitleLabel_->setAlignment(Qt::AlignCenter);
        subtitleLabel_->setProperty("cssClass", "emptySubtitle");
        layout->addWidget(subtitleLabel_);

        actionBtn_ = new QPushButton(this);
        actionBtn_->setProperty("cssClass", "primary");
        actionBtn_->setCursor(Qt::PointingHandCursor);
        actionBtn_->hide();
        layout->addWidget(actionBtn_, 0, Qt::AlignCenter);
    }

    void setIcon(const QString& emoji) { iconLabel_->setText(emoji); }
    void setTitle(const QString& t) { titleLabel_->setText(t); }
    void setSubtitle(const QString& s) { subtitleLabel_->setText(s); }
    void setAction(const QString& label, std::function<void()> callback) {
        actionBtn_->setText(label);
        actionBtn_->show();
        connect(actionBtn_, &QPushButton::clicked, this, [callback]() { callback(); });
    }

private:
    QLabel* iconLabel_ = nullptr;
    QLabel* titleLabel_ = nullptr;
    QLabel* subtitleLabel_ = nullptr;
    QPushButton* actionBtn_ = nullptr;
};

} // namespace mms
