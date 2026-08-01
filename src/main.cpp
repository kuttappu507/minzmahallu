#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <cstdio>
#include <QFile>
#include <QDir>
#include <iostream>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

int main(int argc, char* argv[]) {
#ifdef Q_OS_WIN
    // Create a console window so we can see output
    AllocConsole();
    freopen("CONOUT$", "w", stdout);
    freopen("CONOUT$", "w", stderr);
    SetProcessDPIAware();
#endif

    qputenv("QT_ENABLE_HIGHDPI_SCALING", "1");

    std::cout << "[MMS] Step 1: Creating QApplication..." << std::endl;
    fflush(stdout);

    QApplication app(argc, argv);
    app.setApplicationName("MMS");

    std::cout << "[MMS] Step 2: Setting QuickStyle..." << std::endl;
    fflush(stdout);

    QQuickStyle::setStyle("Basic");

    std::cout << "[MMS] Step 3: Creating QML engine..." << std::endl;
    fflush(stdout);

    QQmlApplicationEngine engine;

    // Capture errors
    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        &engine, [](const QList<QQmlError> &warnings) {
            for (const auto &w : warnings) {
                std::cerr << "[QML ERROR] " << w.url().toString().toStdString()
                          << ":" << w.line() << ": " << w.description().toStdString() << std::endl;
                fflush(stderr);
            }
        });

    std::cout << "[MMS] Step 4: Loading qrc:/qml/main.qml..." << std::endl;
    fflush(stdout);

    engine.load(QUrl("qrc:/qml/main.qml"));

    if (engine.rootObjects().isEmpty()) {
        std::cerr << "[MMS] FAILED: QML did not load!" << std::endl;
        fflush(stderr);

        // Try filesystem fallback
        QString exeDir = QCoreApplication::applicationDirPath();
        QString fsPath = exeDir + "/qml/main.qml";
        std::cout << "[MMS] Trying filesystem: " << fsPath.toStdString() << std::endl;
        fflush(stdout);

        if (QFile::exists(fsPath)) {
            engine.load(QUrl::fromLocalFile(fsPath));
        }
    }

    if (engine.rootObjects().isEmpty()) {
        std::cerr << "[MMS] FATAL: All QML loading failed. Press Enter to exit." << std::endl;
        fflush(stderr);
        getchar(); // Wait for user to press Enter
        return -1;
    }

    std::cout << "[MMS] SUCCESS: QML loaded! Running event loop." << std::endl;
    fflush(stdout);

    return app.exec();
}
