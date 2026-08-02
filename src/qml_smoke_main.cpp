/*
 * qml_smoke_main.cpp — Phase 2 QML smoke test launcher
 *
 * Minimal: creates a QGuiApplication + QQmlApplicationEngine,
 * loads qml/Main.qml, runs the event loop for 2 seconds, then quits.
 *
 * This is NOT the real application UI. It only verifies that:
 *   1. Qt Quick / QML modules are correctly linked
 *   2. The QML file loads without errors
 *   3. An ApplicationWindow can be created
 *
 * No backend integration, no theme, no custom components.
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QTimer>
#include <QFile>
#include <cstdio>

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("MMS-QML-Smoke");

    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;

    // Capture QML warnings
    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        &engine, [](const QList<QQmlError>& warnings) {
            for (const auto& w : warnings) {
                std::fprintf(stderr, "QML WARNING: %s:%d: %s\n",
                    w.url().toString().toUtf8().constData(),
                    w.line(),
                    w.description().toUtf8().constData());
            }
        });

    // Load the smoke test QML from qrc
    QUrl source = QUrl("qrc:/qml/Main.qml");

    std::fprintf(stderr, "[smoke] Loading QML from: %s\n", source.toString().toUtf8().constData());
    engine.load(source);

    if (engine.rootObjects().isEmpty()) {
        std::fprintf(stderr, "[smoke] FAILED: QML did not load. Root objects empty.\n");

        // Try filesystem fallback
        QString fsPath = app.applicationDirPath() + "/qml/Main.qml";
        if (QFile::exists(fsPath)) {
            std::fprintf(stderr, "[smoke] Retrying with filesystem: %s\n", fsPath.toUtf8().constData());
            engine.load(QUrl::fromLocalFile(fsPath));
        }

        if (engine.rootObjects().isEmpty()) {
            std::fprintf(stderr, "[smoke] FATAL: All QML load attempts failed.\n");
            return 1;
        }
    }

    std::fprintf(stderr, "[smoke] QML loaded successfully. Running event loop for 2s...\n");

    // Auto-quit after 2 seconds — just verifying it launches
    QTimer::singleShot(2000, &app, &QGuiApplication::quit);

    int ret = app.exec();
    std::fprintf(stderr, "[smoke] Event loop exited (code %d). Smoke test PASSED.\n", ret);
    return ret;
}
