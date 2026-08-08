/*
 * I18NController.h — QML-facing controller for internationalization.
 *
 * Wraps existing I18N singleton. Exposes tr() and setLanguage() to QML.
 * Emits languageChanged so QML bindings re-evaluate.
 *
 * The key mechanism: QML bindings that call I18NController.tr("key") also
 * reference I18NController.currentLanguage (a Q_PROPERTY). When
 * setLanguage() is called, currentLanguage changes → QML re-evaluates
 * the binding → tr() is called again with the new language.
 *
 * Usage in QML:
 *   Text { text: I18NController.tr("nav_dashboard") }
 *
 * The binding implicitly depends on currentLanguage because tr() is a
 * Q_INVOKABLE method on the same QObject. However, to GUARANTEE
 * re-evaluation, QML code should use the pattern:
 *   Text { text: { var _l = I18NController.currentLanguage; return I18NController.tr("nav_dashboard") } }
 *
 * Or simply reference I18NController.currentLanguage anywhere in the
 * binding expression. This ensures the binding re-evaluates.
 */
#pragma once

#include <QObject>
#include <QString>
#include "../core/I18N.h"
#include "../core/FontManager.h"

class I18NController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)
    Q_PROPERTY(bool isMalayalam READ isMalayalam NOTIFY languageChanged)
    Q_PROPERTY(int revision READ revision NOTIFY languageChanged)

public:
    explicit I18NController(QObject* parent = nullptr) : QObject(parent) {
        mms::I18N::instance().loadFromSettings();
    }

    QString currentLanguage() const { return mms::I18N::instance().currentLanguage(); }
    bool isMalayalam() const { return currentLanguage() == "ml"; }
    int revision() const { return revision_; }

    Q_INVOKABLE QString tr(const QString& key) const {
        return mms::I18N::instance().tr(key);
    }

    Q_INVOKABLE void setLanguage(const QString& code) {
        if (code != "en" && code != "ml") return;
        if (mms::I18N::instance().currentLanguage() == code) return;
        mms::I18N::instance().setLanguage(code);
        // Apply the correct font for the language
        FontManager::instance().applyFont(code);
        ++revision_;
        emit languageChanged();
    }

    Q_INVOKABLE void toggleLanguage() {
        setLanguage(isMalayalam() ? "en" : "ml");
    }

signals:
    void languageChanged();

private:
    int revision_ = 0;
};
