/*
 * I18NController.h — QML-facing controller for internationalization.
 * Wraps existing I18N singleton. Exposes tr() and setLanguage() to QML.
 * Emits languageChanged so QML bindings re-evaluate.
 */
#pragma once

#include <QObject>
#include <QString>
#include "core/I18N.h"

class I18NController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)
    Q_PROPERTY(bool isMalayalam READ isMalayalam NOTIFY languageChanged)

public:
    explicit I18NController(QObject* parent = nullptr) : QObject(parent) {
        // Load language from settings on startup
        mms::I18N::instance().loadFromSettings();
    }

    QString currentLanguage() const { return mms::I18N::instance().currentLanguage(); }
    bool isMalayalam() const { return currentLanguage() == "ml"; }

    Q_INVOKABLE QString tr(const QString& key) const {
        return mms::I18N::instance().tr(key);
    }

    Q_INVOKABLE void setLanguage(const QString& code) {
        if (code != "en" && code != "ml") return;
        if (mms::I18N::instance().currentLanguage() == code) return;
        mms::I18N::instance().setLanguage(code);
        emit languageChanged();
    }

    Q_INVOKABLE void toggleLanguage() {
        setLanguage(isMalayalam() ? "en" : "ml");
    }

signals:
    void languageChanged();
};
