/*
 * I18NController.h — QML-facing controller for internationalization.
 * Keeps the existing translation catalog as the single source of truth
 * and makes QML translation bindings react immediately to language changes.
 */
#pragma once

#include <QObject>
#include <QString>
#include <QQmlEngine>
#include "core/I18N.h"
#include "SettingsService.h"

class I18NController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLanguage READ currentLanguage NOTIFY languageChanged)
    Q_PROPERTY(bool isMalayalam READ isMalayalam NOTIFY languageChanged)

public:
    explicit I18NController(QObject* parent = nullptr) : QObject(parent) {
        mms::I18N::instance().loadFromSettings();
    }

    QString currentLanguage() const { return mms::I18N::instance().currentLanguage(); }
    bool isMalayalam() const { return currentLanguage() == "ml"; }

    Q_INVOKABLE QString tr(const QString& key) const {
        // In Qt 6.8 this is an instance method, not a static method.
        // Mark the current QML function as a translation binding so Qt can
        // reevaluate bindings when uiLanguage changes.
        if (QQmlEngine* engine = qmlEngine(const_cast<I18NController*>(this))) {
            engine->markCurrentFunctionAsTranslationBinding();
        }
        return mms::I18N::instance().tr(key);
    }

    Q_INVOKABLE void setLanguage(const QString& code) {
        if (code != "en" && code != "ml") return;
        if (mms::I18N::instance().currentLanguage() == code) return;

        mms::SettingsService::instance().setLanguage(code);

        // Keep Qt Quick's translation binding system in sync with the
        // application's existing catalog.
        if (QQmlEngine* engine = qmlEngine(this)) {
            engine->setUiLanguage(code);
        }

        emit languageChanged();
    }

    Q_INVOKABLE void toggleLanguage() {
        setLanguage(isMalayalam() ? "en" : "ml");
    }

signals:
    void languageChanged();
};
