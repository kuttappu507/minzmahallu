/*
 * design_preview_main.cpp — Phase 3 Design Preview launcher
 *
 * Loads the DesignPreview.qml which shows all design system components.
 * No backend integration — purely visual.
 *
 * This is a SEPARATE executable (mms_design_preview) that does NOT affect
 * the existing MMS widgets application.
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QFontDatabase>
#include <cstdio>

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("MMS-Design-Preview");
    app.setOrganizationName("MMS");

    QQuickStyle::setStyle("Basic");

    // Load Poppins fonts from qrc
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-SemiBold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Bold.ttf");

    // Register Theme as a QML singleton
    // This is the most reliable way to expose a QML-based singleton
    qmlRegisterSingletonType(
        QUrl("qrc:/qml/theme/Theme.qml"),
        "MMS.Theme", 1, 0, "Theme"
    );

    QQmlApplicationEngine engine;

    // Capture QML warnings to stderr
    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        &engine, [](const QList<QQmlError>& warnings) {
            for (const auto& w : warnings) {
                std::fprintf(stderr, "QML WARNING: %s:%d: %s\n",
                    w.url().toString().toUtf8().constData(),
                    w.line(),
                    w.description().toUtf8().constData());
            }
        });

    std::fprintf(stderr, "[design-preview] Loading DesignPreview.qml...\n");
    engine.load(QUrl("qrc:/qml/design/DesignPreview.qml"));

    if (engine.rootObjects().isEmpty()) {
        std::fprintf(stderr, "[design-preview] FAILED: QML did not load.\n");
        return 1;
    }

    std::fprintf(stderr, "[design-preview] DesignPreview loaded. Running event loop.\n");
    return app.exec();
}
