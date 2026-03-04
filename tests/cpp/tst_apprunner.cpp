#include <QtTest>
#include <QTemporaryDir>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSignalSpy>
#include "AppRunner.h"
#include "AppManifest.h"

using namespace Qt::StringLiterals;

class tst_AppRunner : public QObject {
    Q_OBJECT

private:
    void createTestApp(const QString &dir, const QString &qml)
    {
        QDir().mkpath(dir + QStringLiteral("/qml"));

        QFile manifest(dir + QStringLiteral("/manifest.json"));
        QVERIFY(manifest.open(QIODevice::WriteOnly));
        manifest.write(R"({"id":"com.test.app","name":"Test","version":"1.0.0"})");
        manifest.close();

        QFile entry(dir + QStringLiteral("/qml/Main.qml"));
        QVERIFY(entry.open(QIODevice::WriteOnly));
        entry.write(qml.toUtf8());
        entry.close();
    }

    QQmlEngine *m_engine = nullptr;
    QQuickWindow *m_window = nullptr;
    QQuickItem *m_container = nullptr;
    QTemporaryDir *m_appDir = nullptr;
    QTemporaryDir *m_storageDir = nullptr;

private slots:
    void init()
    {
        m_engine = new QQmlEngine;
        m_window = new QQuickWindow;
        m_container = new QQuickItem(m_window->contentItem());
        m_container->setWidth(400);
        m_container->setHeight(600);
        m_appDir = new QTemporaryDir;
        m_storageDir = new QTemporaryDir;
        QVERIFY(m_appDir->isValid());
        QVERIFY(m_storageDir->isValid());
    }

    void cleanup()
    {
        delete m_window;
        m_window = nullptr;
        m_container = nullptr;
        delete m_engine;
        m_engine = nullptr;
        delete m_appDir;
        m_appDir = nullptr;
        delete m_storageDir;
        m_storageDir = nullptr;
    }

    void launchValidApp()
    {
        createTestApp(m_appDir->path(),
                      "import QtQuick\nItem { width: 100; height: 100 }");

        AppRunner runner(m_engine, m_storageDir->path());
        QSignalSpy launchedSpy(&runner, &AppRunner::launched);

        runner.launchFromPath(m_appDir->path(), m_container);

        QCOMPARE(runner.state(), AppRunner::State::Running);
        QCOMPARE(launchedSpy.count(), 1);
        QCOMPARE(launchedSpy.first().first().toString(), u"com.test.app");
        QVERIFY(launchedSpy.first().at(1).toLongLong() >= 0);
    }

    void launchInvalidPath()
    {
        AppRunner runner(m_engine, m_storageDir->path());
        QSignalSpy errorSpy(&runner, &AppRunner::error);

        runner.launchFromPath(u"/nonexistent/path"_s, m_container);

        QCOMPARE(runner.state(), AppRunner::State::Error);
        QCOMPARE(errorSpy.count(), 1);
    }

    void launchThenClose()
    {
        createTestApp(m_appDir->path(),
                      "import QtQuick\nItem { width: 100; height: 100 }");

        AppRunner runner(m_engine, m_storageDir->path());
        QSignalSpy closedSpy(&runner, &AppRunner::closed);

        runner.launchFromPath(m_appDir->path(), m_container);
        QCOMPARE(runner.state(), AppRunner::State::Running);

        runner.close();
        QCOMPARE(runner.state(), AppRunner::State::Idle);
        QCOMPARE(closedSpy.count(), 1);
    }

    void launchThenSuspend()
    {
        createTestApp(m_appDir->path(),
                      "import QtQuick\nItem { width: 100; height: 100 }");

        AppRunner runner(m_engine, m_storageDir->path());
        QSignalSpy suspendedSpy(&runner, &AppRunner::suspended);

        runner.launchFromPath(m_appDir->path(), m_container);
        runner.suspend();

        QCOMPARE(runner.state(), AppRunner::State::Suspended);
        QCOMPARE(suspendedSpy.count(), 1);
    }

    void suspendThenResume()
    {
        createTestApp(m_appDir->path(),
                      "import QtQuick\nItem { width: 100; height: 100 }");

        AppRunner runner(m_engine, m_storageDir->path());
        QSignalSpy resumedSpy(&runner, &AppRunner::resumed);

        runner.launchFromPath(m_appDir->path(), m_container);
        runner.suspend();
        runner.resume(m_container);

        QCOMPARE(runner.state(), AppRunner::State::Running);
        QCOMPARE(resumedSpy.count(), 1);
    }

    void closeCleanup()
    {
        createTestApp(m_appDir->path(),
                      "import QtQuick\nItem { width: 100; height: 100 }");

        AppRunner runner(m_engine, m_storageDir->path());
        runner.launchFromPath(m_appDir->path(), m_container);
        runner.close();

        // Container should have no children from the app
        QCOMPARE(m_container->childItems().count(), 0);
    }

    void secondLaunchClosesFirst()
    {
        auto dir1 = m_appDir->path() + QStringLiteral("/app1");
        auto dir2 = m_appDir->path() + QStringLiteral("/app2");
        QDir().mkpath(dir1);
        QDir().mkpath(dir2);

        createTestApp(dir1, "import QtQuick\nItem { width: 100; height: 100 }");

        // Create second app with different id
        QDir().mkpath(dir2 + QStringLiteral("/qml"));
        {
            QFile manifest(dir2 + QStringLiteral("/manifest.json"));
            QVERIFY(manifest.open(QIODevice::WriteOnly));
            manifest.write(R"({"id":"com.test.app2","name":"Test2","version":"1.0.0"})");
        }
        {
            QFile entry(dir2 + QStringLiteral("/qml/Main.qml"));
            QVERIFY(entry.open(QIODevice::WriteOnly));
            entry.write("import QtQuick\nItem { width: 100; height: 100 }");
        }

        AppRunner runner(m_engine, m_storageDir->path());
        QSignalSpy closedSpy(&runner, &AppRunner::closed);

        runner.launchFromPath(dir1, m_container);
        QCOMPARE(runner.state(), AppRunner::State::Running);

        runner.launchFromPath(dir2, m_container);
        QCOMPARE(runner.state(), AppRunner::State::Running);
        QCOMPARE(closedSpy.count(), 1); // First app was closed
    }
};

QTEST_MAIN(tst_AppRunner)
#include "tst_apprunner.moc"
