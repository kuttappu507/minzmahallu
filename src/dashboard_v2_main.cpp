/*
 * dashboard_v2_main.cpp — DashboardV2 preview launcher
 *
 * Opens directly to DashboardV2.qml — the production-quality dashboard screen.
 * No backend, no other screens.
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QFontDatabase>
#include <cstdio>

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("MMS-DashboardV2");
    app.setOrganizationName("MMS");

    QQuickStyle::setStyle("Basic");

    // Load fonts
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-SemiBold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Bold.ttf");

    // Register Theme singleton
    qmlRegisterSingletonType(
        QUrl("qrc:/qml/theme/Theme.qml"),
        "MMS.Theme", 1, 0, "Theme"
    );

    QQmlApplicationEngine engine;

    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        &engine, [](const QList<QQmlError>& warnings) {
            for (const auto& w : warnings) {
                std::fprintf(stderr, "QML WARNING: %s:%d: %s\n",
                    w.url().toString().toUtf8().constData(),
                    w.line(),
                    w.description().toUtf8().constData());
            }
        });

    std::fprintf(stderr, "[dashboard-v2] Loading DashboardV2.qml...\n");
    engine.load(QUrl("qrc:/qml/design/DashboardV2.qml"));

    if (engine.rootObjects().isEmpty()) {
        std::fprintf(stderr, "[dashboard-v2] FAILED: QML did not load.\n");
        return 1;
    }

    std::fprintf(stderr, "[dashboard-v2] DashboardV2 loaded. Running event loop.\n");
    return app.exec();
}
