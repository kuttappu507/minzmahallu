#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QFile>
#include <QDir>
#include <QDateTime>
#include <QStandardPaths>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <csignal>
#include <cstdlib>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

// Global log file path
static QString g_logPath;
static std::ofstream g_logFile;

void logMsg(const QString& msg) {
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz");
    QString line = QString("[%1] %2").arg(timestamp, msg);
    
    // Write to log file
    if (g_logFile.is_open()) {
        g_logFile << line.toStdString() << std::endl;
        g_logFile.flush();
    }
    
    // Write to console
    std::cout << line.toStdString() << std::endl;
    fflush(stdout);
    
    // Write to stderr too
    fprintf(stderr, "%s\n", line.toUtf8().constData());
    fflush(stderr);
}

// Crash handler
void crashHandler(int signal) {
    QString msg = QString("CRASH! Signal %1").arg(signal);
    logMsg(msg);
    
    if (g_logFile.is_open()) {
        g_logFile << "=== APPLICATION CRASHED ===" << std::endl;
        g_logFile.close();
    }
    
#ifdef Q_OS_WIN
    MessageBoxA(nullptr, msg.toUtf8().constData(), "MMS Crash", MB_ICONERROR | MB_OK);
#endif
    exit(1);
}

// Unhandled exception handler
void terminateHandler() {
    QString msg = "UNHANDLED EXCEPTION! std::terminate() called.";
    logMsg(msg);
    
    if (g_logFile.is_open()) {
        g_logFile << "=== UNHANDLED EXCEPTION ===" << std::endl;
        g_logFile.close();
    }
    
#ifdef Q_OS_WIN
    MessageBoxA(nullptr, "Unhandled exception! Check mms_error.log for details.", "MMS Error", MB_ICONERROR | MB_OK);
#endif
    abort();
}

int main(int argc, char* argv[]) {
    // Set up crash handlers FIRST — before anything else
    std::signal(SIGSEGV, crashHandler);
    std::signal(SIGABRT, crashHandler);
    std::signal(SIGFPE, crashHandler);
    std::signal(SIGILL, crashHandler);
    std::set_terminate(terminateHandler);

#ifdef Q_OS_WIN
    // Create console window
    AllocConsole();
    freopen("CONOUT$", "w", stdout);
    freopen("CONOUT$", "w", stderr);
    SetProcessDPIAware();
#endif

    // Open log file next to the exe
    QString exeDir = QCoreApplication::applicationDirPath();
    g_logPath = exeDir + "/mms_error.log";
    g_logFile.open(g_logPath.toStdString(), std::ios::out | std::ios::trunc);
    
    logMsg("========================================");
    logMsg("MMS Application Starting");
    logMsg("========================================");
    logMsg(QString("Exe dir: %1").arg(exeDir));
    logMsg(QString("Log file: %1").arg(g_logPath));

    qputenv("QT_ENABLE_HIGHDPI_SCALING", "1");

    logMsg("Step 1: Creating QApplication...");
    QApplication app(argc, argv);
    app.setApplicationName("MMS");

    logMsg("Step 2: Setting QuickStyle to Basic...");
    QQuickStyle::setStyle("Basic");

    logMsg("Step 3: Creating QML engine...");
    QQmlApplicationEngine engine;

    // Capture QML warnings
    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
        &engine, [](const QList<QQmlError> &warnings) {
            for (const auto &w : warnings) {
                logMsg(QString("QML WARNING: %1:%2:%3: %4")
                    .arg(w.url().toString())
                    .arg(w.line())
                    .arg(w.column())
                    .arg(w.description()));
            }
        });

    // Capture object creation failure
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() {
            logMsg("QML objectCreationFailed signal fired!");
        }, Qt::QueuedConnection);

    logMsg("Step 4: Loading qrc:/qml/main.qml...");
    engine.load(QUrl("qrc:/qml/main.qml"));

    if (engine.rootObjects().isEmpty()) {
        logMsg("FAILED: qrc:/qml/main.qml did not load!");
        
        // Try filesystem fallback
        QString fsPath = exeDir + "/qml/main.qml";
        logMsg(QString("Trying filesystem: %1").arg(fsPath));
        
        if (QFile::exists(fsPath)) {
            logMsg("File exists! Loading from disk...");
            engine.load(QUrl::fromLocalFile(fsPath));
        } else {
            logMsg("File does NOT exist on disk!");
        }
    }

    if (engine.rootObjects().isEmpty()) {
        logMsg("FATAL: All QML loading failed!");
        logMsg("========================================");
        logMsg("Check mms_error.log for details.");
        logMsg("========================================");
        
        if (g_logFile.is_open()) g_logFile.close();
        
#ifdef Q_OS_WIN
        MessageBoxA(nullptr, 
            "Failed to load QML UI.\n\nCheck mms_error.log in the same folder for details.",
            "MMS Error", MB_ICONERROR | MB_OK);
#endif
        return -1;
    }

    logMsg("SUCCESS: QML loaded! Entering event loop.");
    
    int ret = app.exec();
    
    logMsg(QString("Application exited with code %1").arg(ret));
    if (g_logFile.is_open()) g_logFile.close();
    
    return ret;
}
