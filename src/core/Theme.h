/*
 * Theme.h - QML-exposed theme singleton via context property
 *
 * Exposes the emerald palette, fonts, tints, and status pills
 * to QML without needing qt_add_qml_module or qmldir.
 *
 * Usage in main.cpp:
 *   qmlRegisterType<Theme>("MMS", 1, 0, "ThemeImpl"); // optional
 *   engine.rootContext()->setContextProperty("Theme", new Theme());
 *
 * Usage in QML (no imports needed):
 *   color: Theme.bg
 *   font.family: Theme.fontPrimary
 *   var t: Theme.tint("em")  // returns {sb, sc, st}
 *   var p: Theme.pillFor("Active")  // returns {sb, sc, st, label}
 */
#pragma once

#include <QObject>
#include <QColor>
#include <QString>
#include <QVariantMap>
#include <QVariantList>

class Theme : public QObject {
    Q_OBJECT

    // ===== Fonts =====
    Q_PROPERTY(QString fontDisplay READ fontDisplay CONSTANT)
    Q_PROPERTY(QString fontPrimary READ fontPrimary CONSTANT)

    // ===== Base palette =====
    Q_PROPERTY(QColor bg          READ bg          CONSTANT)
    Q_PROPERTY(QColor panel       READ panel       CONSTANT)
    Q_PROPERTY(QColor panelMuted  READ panelMuted  CONSTANT)
    Q_PROPERTY(QColor border      READ border      CONSTANT)
    Q_PROPERTY(QColor text        READ text        CONSTANT)
    Q_PROPERTY(QColor muted       READ muted       CONSTANT)
    Q_PROPERTY(QColor sidebar     READ sidebar     CONSTANT)
    Q_PROPERTY(QColor accent      READ accent      CONSTANT)
    Q_PROPERTY(QColor accentDeep  READ accentDeep  CONSTANT)
    Q_PROPERTY(QColor danger      READ danger      CONSTANT)
    Q_PROPERTY(QColor success     READ success     CONSTANT)
    Q_PROPERTY(QColor warning     READ warning     CONSTANT)
    Q_PROPERTY(QColor info        READ info        CONSTANT)

    // ===== Sidebar gradient =====
    Q_PROPERTY(QColor sidebarTop  READ sidebarTop  CONSTANT)
    Q_PROPERTY(QColor sidebarMid  READ sidebarMid  CONSTANT)
    Q_PROPERTY(QColor sidebarBot  READ sidebarBot  CONSTANT)

    // ===== Tints (10 named sets) =====
    Q_PROPERTY(QVariantMap tints  READ tints       CONSTANT)

public:
    explicit Theme(QObject* parent = nullptr) : QObject(parent) {}

    // Fonts
    QString fontDisplay() const { return QStringLiteral("Space Grotesk"); }
    QString fontPrimary() const { return QStringLiteral("Poppins"); }

    // Base palette
    QColor bg()         const { return QColor("#e7f4ea"); }
    QColor panel()      const { return QColor("#ffffff"); }
    QColor panelMuted() const { return QColor("#f2faf4"); }
    QColor border()     const { return QColor("#d2e5d8"); }
    QColor text()       const { return QColor("#12241b"); }
    QColor muted()      const { return QColor("#7e968a"); }
    QColor sidebar()    const { return QColor("#065f46"); }
    QColor accent()     const { return QColor("#f2c14e"); }
    QColor accentDeep() const { return QColor("#b98317"); }
    QColor danger()     const { return QColor("#e11d48"); }
    QColor success()    const { return QColor("#059669"); }
    QColor warning()    const { return QColor("#f59e0b"); }
    QColor info()       const { return QColor("#0891b2"); }

    // Sidebar gradient
    QColor sidebarTop() const { return QColor("#0a7f5d"); }
    QColor sidebarMid() const { return QColor("#065f46"); }
    QColor sidebarBot() const { return QColor("#044633"); }

    // Tints
    QVariantMap tints() const {
        QVariantMap m;
        QVariantMap em; em["sb"] = "#d3f5e6"; em["sc"] = "#059669"; em["st"] = "#04543c"; m["em"] = em;
        QVariantMap cy; cy["sb"] = "#c8f6f1"; cy["sc"] = "#0d9488"; cy["st"] = "#0f5e54"; m["cy"] = cy;
        QVariantMap bl; bl["sb"] = "#d7edfb"; bl["sc"] = "#0284c7"; bl["st"] = "#0a5480"; m["bl"] = bl;
        QVariantMap am; am["sb"] = "#fcebc8"; am["sc"] = "#d97706"; am["st"] = "#7c4403"; m["am"] = am;
        QVariantMap rd; rd["sb"] = "#fddfe5"; rd["sc"] = "#e11d48"; rd["st"] = "#95102e"; m["rd"] = rd;
        QVariantMap pk; pk["sb"] = "#fadfeb"; pk["sc"] = "#db2777"; pk["st"] = "#93184f"; m["pk"] = pk;
        QVariantMap vi; vi["sb"] = "#e7defc"; vi["sc"] = "#7c3aed"; vi["st"] = "#5423b7"; m["vi"] = vi;
        QVariantMap or_; or_["sb"] = "#ffe4cf"; or_["sc"] = "#ea580c"; or_["st"] = "#8f3708"; m["or"] = or_;
        QVariantMap sl; sl["sb"] = "#e6ebf2"; sl["sc"] = "#64748b"; sl["st"] = "#33415c"; m["sl"] = sl;
        QVariantMap ib; ib["sb"] = "#dbe7fd"; ib["sc"] = "#2563eb"; ib["st"] = "#1e3fae"; m["ib"] = ib;
        return m;
    }

    // ===== Helper functions callable from QML =====
    Q_INVOKABLE QVariantMap tint(const QString& name) const {
        static const QVariantMap all = tints();
        return all.value(name).toMap();
    }

    Q_INVOKABLE QVariantMap pillFor(const QString& status) const {
        static const QVariantMap pills = []() {
            QVariantMap p;
            auto make = [](const QString& sb, const QString& sc, const QString& st, const QString& label) {
                QVariantMap m;
                m["sb"] = sb; m["sc"] = sc; m["st"] = st; m["label"] = label;
                return m;
            };
            p["Active"]   = make("#d3f5e6", "#059669", "#04543c", "Active");
            p["Inactive"] = make("#e6ebf2", "#64748b", "#33415c", "Inactive");
            p["Archived"] = make("#fddfe5", "#e11d48", "#95102e", "Archived");
            p["Overdue"]  = make("#fddfe5", "#e11d48", "#95102e", "Overdue");
            p["Paid"]     = make("#d3f5e6", "#059669", "#04543c", "Paid");
            p["Pending"]  = make("#fcebc8", "#d97706", "#7c4403", "Pending");
            p["Approved"] = make("#d3f5e6", "#059669", "#04543c", "Approved");
            p["Rejected"] = make("#fddfe5", "#e11d48", "#95102e", "Rejected");
            p["Issued"]   = make("#d7edfb", "#0284c7", "#0a5480", "Issued");
            return p;
        }();
        QVariantMap fallback;
        fallback["sb"] = "#e6ebf2"; fallback["sc"] = "#64748b"; fallback["st"] = "#33415c";
        fallback["label"] = status.isEmpty() ? QStringLiteral("—") : status;
        return pills.value(status, fallback).toMap();
    }
};
