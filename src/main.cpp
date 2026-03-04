#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>
#include <QStandardPaths>
#include "AppRunner.h"

#ifndef EXAMPLES_PATH
#define EXAMPLES_PATH ""
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QFontDatabase::addApplicationFont(
        QStringLiteral(":/qt/qml/Squared/UI/fonts/Inter-Variable.ttf"));
    QFontDatabase::addApplicationFont(
        QStringLiteral(":/qt/qml/Squared/UI/fonts/MaterialSymbolsOutlined-Variable.ttf"));

    QQmlApplicationEngine engine;

    auto storageRoot = QStandardPaths::writableLocation(
        QStandardPaths::AppDataLocation) + QStringLiteral("/storage");

    AppRunner runner(&engine, storageRoot);
    engine.rootContext()->setContextProperty(QStringLiteral("appRunner"), &runner);
    engine.rootContext()->setContextProperty(QStringLiteral("examplesPath"),
                                            QStringLiteral(EXAMPLES_PATH));

    engine.loadFromModule("Squared.Host", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
