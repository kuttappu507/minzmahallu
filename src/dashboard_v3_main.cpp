#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QFontDatabase>
#include <cstdio>

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("MMS-DashboardV3");
    app.setOrganizationName("MMS");
    QQuickStyle::setStyle("Basic");

    QFontDatabase::addApplicationFont(":/fonts/Poppins-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-SemiBold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Poppins-Bold.ttf");

    qmlRegisterSingletonType(QUrl("qrc:/qml/theme/Theme.qml"), "MMS.Theme", 1, 0, "Theme");

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        &engine, [](const QList<QQmlError>& warnings) {
            for (const auto& w : warnings)
                std::fprintf(stderr, "QML WARNING: %s:%d: %s\n",
                    w.url().toString().toUtf8().constData(), w.line(),
                    w.description().toUtf8().constData());
        });

    std::fprintf(stderr, "[dashboard-v3] Loading DashboardV3.qml...\n");
    engine.load(QUrl("qrc:/qml/design/DashboardV3.qml"));
    if (engine.rootObjects().isEmpty()) {
        std::fprintf(stderr, "[dashboard-v3] FAILED\n");
        return 1;
    }
    std::fprintf(stderr, "[dashboard-v3] Loaded. Running.\n");
    return app.exec();
}
