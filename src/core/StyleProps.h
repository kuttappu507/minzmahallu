#pragma once

// =============================================================================
// StyleProps.h — Helper for applying QSS `cssClass` dynamic properties.
//
// The application's QSS (resources/styles/light.qss and dark.qss) selects
// widgets by their dynamic `cssClass` property — e.g.:
//
//     QPushButton[cssClass="primary"] { background: #059669; ... }
//     QLabel[cssClass="statValue"]    { font-family: "Space Grotesk"; ... }
//
// Setting these properties inline via setProperty("cssClass", "primary")
// scattered throughout the views is verbose and error-prone. StyleProps
// provides short, intention-revealing helpers that:
//   1. Set the property on the widget
//   2. Force the widget's style to refresh so the QSS re-evaluates
//
// All visual styling lives in QSS; this file does NOT contain any colors,
// fonts, or layout values.
// =============================================================================

#include <QWidget>
#include <QStyle>

namespace mms {

struct StyleProps {
    // Apply a single cssClass value to a widget and refresh its style.
    static void set(QWidget* w, const char* cssClass) {
        if (!w || !cssClass) return;
        w->setProperty("cssClass", QString::fromLatin1(cssClass));
        w->style()->unpolish(w);
        w->style()->polish(w);
    }

    // Apply a cssClass value and an additional status/variant property.
    // Used for status pills:  setStatus(label, "Paid");
    static void setStatus(QWidget* w, const QString& status) {
        if (!w) return;
        w->setProperty("status", status);
        w->style()->unpolish(w);
        w->style()->polish(w);
    }
};

} // namespace mms
