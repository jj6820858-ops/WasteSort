#include <QGuiApplication>
#include <QFont>
#include <QFileInfo>
#include <QImage>
#include <QIcon>
#include <QScreen>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QTemporaryDir>
#include <QDir>
#include "controller.h"

int main(int argc, char *argv[]) {
    // Deterministic 1:1 image captures; normal desktop sessions retain native DPI.
    for (int i = 1; i < argc; ++i) {
        if (QByteArray(argv[i]) == "--capture") {
            qputenv("QT_ENABLE_HIGHDPI_SCALING", "0");
            qputenv("QT_FONT_DPI", "96");
        }
    }
    QGuiApplication app(argc, argv);
    app.setOrganizationName("JGH");
    app.setApplicationName("WasteSort");
    app.setApplicationDisplayName(QStringLiteral("归序 · 垃圾分类工作台"));
    app.setWindowIcon(QIcon(":/assets/guixu.png"));
    QQuickStyle::setStyle("Basic");
    QFont font("Microsoft YaHei UI"); font.setPointSize(11); app.setFont(font);
    const auto args = app.arguments();
    const bool preview = args.contains("--preview");
    const bool capture = args.contains("--capture");
    QTemporaryDir temporary;
    Controller controller((preview || capture) ? temporary.path() : QString());
    if (preview) controller.seedPreview();
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("backend", &controller);
    engine.rootContext()->setContextProperty("initialPage", args.contains("--logs") ? 1 : args.contains("--settings") ? 2 : 0);
    engine.loadFromModule("WasteSort", "Main");
    if (engine.rootObjects().isEmpty()) return 1;
    auto *mainWindow = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    // Apply logical desktop geometry after Windows has established the window DPI.
    QTimer::singleShot(0, mainWindow, [mainWindow, args]() {
        const QRect available = mainWindow->screen()->availableGeometry();
        const QSize desired = args.contains("--compact") ? QSize(1120, 760) : QSize(1440, 920);
        mainWindow->resize(qMin(desired.width(), available.width() - 32), qMin(desired.height(), available.height() - 50));
        mainWindow->setPosition(available.center() - QPoint(mainWindow->width() / 2, mainWindow->height() / 2));
    });
    if (capture) {
        const int index = args.indexOf("--capture");
        const QString path = index + 1 < args.size() ? args[index + 1] : "capture.png";
        QTimer::singleShot(1300, &app, [&app, &engine, path]() {
            auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
            QDir().mkpath(QFileInfo(path).absolutePath());
            if (!window) { app.exit(2); return; }
            app.exit(window->grabWindow().save(path) ? 0 : 2);
        });
    }
    return app.exec();
}
