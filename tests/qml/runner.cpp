#include <QtQuickTest>
#include <QQmlEngine>
#include <QFontDatabase>
#include <QDir>

class Setup : public QObject {
    Q_OBJECT

public slots:
    void applicationAvailable() {
        // Load bundled fonts so STheme and SIcon work in tests
    }

    void qmlEngineAvailable(QQmlEngine *engine) {
        Q_UNUSED(engine)
    }
};

QUICK_TEST_MAIN_WITH_SETUP(SquaredUITests, Setup)

#include "runner.moc"
