#include <QtTest>
#include <QTemporaryDir>
#include <private/qzipwriter_p.h>
#include "AppInstaller.h"
#include "AppManifest.h"

class tst_AppInstaller : public QObject {
    Q_OBJECT

private:
    QByteArray validManifestJson()
    {
        return R"json({
            "id": "com.test.myapp",
            "name": "My App",
            "version": "1.0.0",
            "entry": "Main.qml",
            "author": "Test Author"
        })json";
    }

    QString createSqapp(const QString &dir, const QByteArray &manifest,
                        bool includeQml = true)
    {
        auto path = dir + QStringLiteral("/test.sqapp");
        QZipWriter writer(path);
        writer.addFile(QStringLiteral("manifest.json"), manifest);
        if (includeQml) {
            writer.addFile(QStringLiteral("qml/Main.qml"),
                           "import QtQuick\nItem { width: 100; height: 100 }");
        }
        writer.close();
        return path;
    }

    QString createCorruptZip(const QString &dir)
    {
        auto path = dir + QStringLiteral("/corrupt.sqapp");
        QFile f(path);
        f.open(QIODevice::WriteOnly);
        f.write("this is not a zip file");
        f.close();
        return path;
    }

private slots:
    void installValidPackage()
    {
        QTemporaryDir tmp;
        QTemporaryDir installDir;
        AppInstaller installer;

        auto sqapp = createSqapp(tmp.path(), validManifestJson());
        auto result = installer.install(sqapp, installDir.path());

        QVERIFY(result.has_value());
        QCOMPARE(result->id, "com.test.myapp");
        QCOMPARE(result->name, "My App");
        QVERIFY(QFile::exists(installDir.path() + "/com.test.myapp/manifest.json"));
        QVERIFY(QFile::exists(installDir.path() + "/com.test.myapp/qml/Main.qml"));
    }

    void installCorruptZip()
    {
        QTemporaryDir tmp;
        QTemporaryDir installDir;
        AppInstaller installer;

        auto sqapp = createCorruptZip(tmp.path());
        auto result = installer.install(sqapp, installDir.path());

        QVERIFY(!result.has_value());
        QVERIFY(!result.error().isEmpty());
    }

    void installMissingManifest()
    {
        QTemporaryDir tmp;
        QTemporaryDir installDir;
        AppInstaller installer;

        // ZIP with no manifest.json
        auto path = tmp.path() + "/nomanifest.sqapp";
        QZipWriter writer(path);
        writer.addFile(QStringLiteral("qml/Main.qml"), "import QtQuick\nItem {}");
        writer.close();

        auto result = installer.install(path, installDir.path());
        QVERIFY(!result.has_value());
        QVERIFY(result.error().contains("manifest"));
    }

    void installInvalidManifest()
    {
        QTemporaryDir tmp;
        QTemporaryDir installDir;
        AppInstaller installer;

        auto sqapp = createSqapp(tmp.path(), R"({"name": "No ID"})");
        auto result = installer.install(sqapp, installDir.path());

        QVERIFY(!result.has_value());
    }

    void uninstallRemovesDirectory()
    {
        QTemporaryDir tmp;
        QTemporaryDir installDir;
        QTemporaryDir storageDir;
        AppInstaller installer;

        auto sqapp = createSqapp(tmp.path(), validManifestJson());
        installer.install(sqapp, installDir.path());

        // Create fake storage data
        QDir().mkpath(storageDir.path() + "/com.test.myapp");
        QFile f(storageDir.path() + "/com.test.myapp/storage.dat");
        f.open(QIODevice::WriteOnly);
        f.write("data");
        f.close();

        bool ok = installer.uninstall("com.test.myapp", installDir.path(),
                                      storageDir.path());
        QVERIFY(ok);
        QVERIFY(!QDir(installDir.path() + "/com.test.myapp").exists());
        QVERIFY(!QDir(storageDir.path() + "/com.test.myapp").exists());
    }

    void isInstalledCorrectState()
    {
        QTemporaryDir tmp;
        QTemporaryDir installDir;
        AppInstaller installer;

        QVERIFY(!installer.isInstalled("com.test.myapp", installDir.path()));

        auto sqapp = createSqapp(tmp.path(), validManifestJson());
        installer.install(sqapp, installDir.path());

        QVERIFY(installer.isInstalled("com.test.myapp", installDir.path()));
    }

    void installedAppsReturnsList()
    {
        QTemporaryDir tmp;
        QTemporaryDir installDir;
        AppInstaller installer;

        auto json1 = R"({"id":"com.test.a","name":"A","version":"1.0"})";
        auto json2 = R"({"id":"com.test.b","name":"B","version":"1.0"})";

        auto sqapp1 = createSqapp(tmp.path() + "/d1", QByteArray(json1));
        QDir().mkpath(tmp.path() + "/d1");
        sqapp1 = createSqapp(tmp.path(), QByteArray(json1));
        installer.install(sqapp1, installDir.path());

        // Need second sqapp with different id
        auto path2 = tmp.path() + "/test2.sqapp";
        QZipWriter writer(path2);
        writer.addFile(QStringLiteral("manifest.json"), QByteArray(json2));
        writer.addFile(QStringLiteral("qml/Main.qml"), "import QtQuick\nItem {}");
        writer.close();
        installer.install(path2, installDir.path());

        auto apps = installer.installedApps(installDir.path());
        QCOMPARE(apps.size(), 2);
    }

    void reinstallOverwrites()
    {
        QTemporaryDir tmp;
        QTemporaryDir installDir;
        AppInstaller installer;

        auto sqapp = createSqapp(tmp.path(), validManifestJson());
        auto r1 = installer.install(sqapp, installDir.path());
        QVERIFY(r1.has_value());

        // Reinstall with updated manifest
        auto updated = R"json({
            "id": "com.test.myapp",
            "name": "Updated App",
            "version": "2.0.0"
        })json";
        auto sqapp2 = createSqapp(tmp.path(), QByteArray(updated));
        auto r2 = installer.install(sqapp2, installDir.path());
        QVERIFY(r2.has_value());
        QCOMPARE(r2->name, "Updated App");
        QCOMPARE(r2->version, "2.0.0");
    }

    void installNonexistentFile()
    {
        QTemporaryDir installDir;
        AppInstaller installer;
        auto result = installer.install("/nonexistent.sqapp", installDir.path());
        QVERIFY(!result.has_value());
    }
};

QTEST_GUILESS_MAIN(tst_AppInstaller)
#include "tst_appinstaller.moc"
