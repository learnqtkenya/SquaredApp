#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QFontDatabase::addApplicationFont(":/qt/qml/Squared/UI/fonts/Inter-Variable.ttf");
    QFontDatabase::addApplicationFont(":/qt/qml/Squared/UI/fonts/MaterialSymbolsOutlined-Variable.ttf");

    QQmlApplicationEngine engine;
    engine.loadFromModule("Squared.UI", "ComponentGallery");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
