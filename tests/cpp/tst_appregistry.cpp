#include <QtTest>
#include <QTemporaryDir>
#include "AppRegistry.h"

class tst_AppRegistry : public QObject {
    Q_OBJECT

private:
    AppEntry makeEntry(const QString &id, const QString &name)
    {
        AppEntry e;
        e.id = id;
        e.name = name;
        e.version = QStringLiteral("1.0.0");
        e.icon = QStringLiteral("\ue614");
        e.color = QStringLiteral("#FF9800");
        e.dirName = id;
        e.installDate = QDateTime::currentDateTime();
        return e;
    }

private slots:
    void addAndFindApp()
    {
        QTemporaryDir tmp;
        AppRegistry reg(tmp.filePath("registry.dat"));
        auto entry = makeEntry("com.test.app", "Test App");
        reg.addApp(entry);

        auto found = reg.findApp("com.test.app");
        QVERIFY(found.has_value());
        QCOMPARE(found->name, "Test App");
        QCOMPARE(found->version, "1.0.0");
    }

    void removeApp()
    {
        QTemporaryDir tmp;
        AppRegistry reg(tmp.filePath("registry.dat"));
        reg.addApp(makeEntry("com.test.app", "Test App"));
        reg.removeApp("com.test.app");

        QVERIFY(!reg.findApp("com.test.app").has_value());
    }

    void allAppsReturnsList()
    {
        QTemporaryDir tmp;
        AppRegistry reg(tmp.filePath("registry.dat"));
        reg.addApp(makeEntry("com.test.a", "App A"));
        reg.addApp(makeEntry("com.test.b", "App B"));

        auto all = reg.allApps();
        QCOMPARE(all.size(), 2);
    }

    void updateLaunchStats()
    {
        QTemporaryDir tmp;
        AppRegistry reg(tmp.filePath("registry.dat"));
        reg.addApp(makeEntry("com.test.app", "Test App"));

        reg.updateLaunchStats("com.test.app");
        reg.updateLaunchStats("com.test.app");

        auto found = reg.findApp("com.test.app");
        QVERIFY(found.has_value());
        QCOMPARE(found->launchCount, 2);
        QVERIFY(found->lastLaunched.isValid());
    }

    void persistenceAcrossInstances()
    {
        QTemporaryDir tmp;
        auto path = tmp.filePath("registry.dat");

        {
            AppRegistry reg(path);
            reg.addApp(makeEntry("com.test.app", "Persisted"));
        }

        AppRegistry reg2(path);
        auto found = reg2.findApp("com.test.app");
        QVERIFY(found.has_value());
        QCOMPARE(found->name, "Persisted");
    }

    void modelRowCount()
    {
        QTemporaryDir tmp;
        AppRegistry reg(tmp.filePath("registry.dat"));
        auto *model = reg.model();

        QCOMPARE(model->rowCount(), 0);

        reg.addApp(makeEntry("com.test.app", "Test App"));
        QCOMPARE(model->rowCount(), 1);

        reg.removeApp("com.test.app");
        QCOMPARE(model->rowCount(), 0);
    }

    void modelDataRoles()
    {
        QTemporaryDir tmp;
        AppRegistry reg(tmp.filePath("registry.dat"));
        auto *model = reg.model();

        auto entry = makeEntry("com.test.app", "Test App");
        entry.color = "#22C55E";
        entry.dirName = "testdir";
        reg.addApp(entry);

        auto idx = model->index(0);
        QCOMPARE(model->data(idx, InstalledAppsModel::AppIdRole).toString(), "com.test.app");
        QCOMPARE(model->data(idx, InstalledAppsModel::AppNameRole).toString(), "Test App");
        QCOMPARE(model->data(idx, InstalledAppsModel::AppColorRole).toString(), "#22C55E");
        QCOMPARE(model->data(idx, InstalledAppsModel::AppDirNameRole).toString(), "testdir");
    }

    void reAddUpdatesExisting()
    {
        QTemporaryDir tmp;
        AppRegistry reg(tmp.filePath("registry.dat"));
        reg.addApp(makeEntry("com.test.app", "Old Name"));

        auto updated = makeEntry("com.test.app", "New Name");
        reg.addApp(updated);

        QCOMPARE(reg.allApps().size(), 1);
        QCOMPARE(reg.findApp("com.test.app")->name, "New Name");
    }
};

QTEST_GUILESS_MAIN(tst_AppRegistry)
#include "tst_appregistry.moc"
