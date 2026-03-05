#include <QtTest>
#include <QTemporaryDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include "AppManifest.h"

class tst_AppManifest : public QObject {
    Q_OBJECT

private:
    void writeManifest(const QString &dir, const QByteArray &data)
    {
        QFile f(dir + QStringLiteral("/manifest.json"));
        QVERIFY(f.open(QIODevice::WriteOnly));
        f.write(data);
    }

    void writeManifest(const QString &dir, const QJsonObject &json)
    {
        writeManifest(dir, QJsonDocument(json).toJson());
    }

    QJsonObject validJson()
    {
        QJsonObject json;
        json[QStringLiteral("id")] = QStringLiteral("com.squared.test");
        json[QStringLiteral("name")] = QStringLiteral("Test App");
        json[QStringLiteral("version")] = QStringLiteral("1.0.0");
        json[QStringLiteral("author")] = QStringLiteral("Test Author");
        json[QStringLiteral("description")] = QStringLiteral("A test app");
        json[QStringLiteral("icon")] = QStringLiteral("assets/icon.png");
        return json;
    }

private slots:
    void validManifestParses()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());
        writeManifest(dir.path(), validJson());

        auto result = AppManifest::fromDirectory(dir.path());
        QVERIFY(result.has_value());
        QCOMPARE(result->id, u"com.squared.test");
        QCOMPARE(result->name, u"Test App");
        QCOMPARE(result->version, u"1.0.0");
        QCOMPARE(result->author, u"Test Author");
        QCOMPARE(result->description, u"A test app");
        QCOMPARE(result->icon, u"assets/icon.png");
        QCOMPARE(result->entry, u"Main.qml");
    }

    void missingRequiredFieldReturnsNullopt()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());

        // Missing id
        auto json = validJson();
        json.remove(u"id");
        writeManifest(dir.path(), json);
        QVERIFY(!AppManifest::fromDirectory(dir.path()).has_value());

        // Missing name
        json = validJson();
        json.remove(u"name");
        writeManifest(dir.path(), json);
        QVERIFY(!AppManifest::fromDirectory(dir.path()).has_value());

        // Missing version
        json = validJson();
        json.remove(u"version");
        writeManifest(dir.path(), json);
        QVERIFY(!AppManifest::fromDirectory(dir.path()).has_value());
    }

    void emptyJsonReturnsNullopt()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());
        writeManifest(dir.path(), QJsonObject{});
        QVERIFY(!AppManifest::fromDirectory(dir.path()).has_value());
    }

    void malformedJsonReturnsNullopt()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());
        writeManifest(dir.path(), QByteArray("not json {{{"));
        QVERIFY(!AppManifest::fromDirectory(dir.path()).has_value());
    }

    void defaultEntryIsMainQml()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());
        auto json = validJson();
        json.remove(u"entry");
        writeManifest(dir.path(), json);

        auto result = AppManifest::fromDirectory(dir.path());
        QVERIFY(result.has_value());
        QCOMPARE(result->entry, u"Main.qml");
    }

    void basePathIsSetToDirectory()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());
        writeManifest(dir.path(), validJson());

        auto result = AppManifest::fromDirectory(dir.path());
        QVERIFY(result.has_value());
        QCOMPARE(result->basePath, dir.path());
    }

    void permissionsParsed()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());
        auto json = validJson();
        json[QStringLiteral("permissions")] = QJsonArray{
            QStringLiteral("network"),
            QStringLiteral("secure-storage")
        };
        writeManifest(dir.path(), json);

        auto result = AppManifest::fromDirectory(dir.path());
        QVERIFY(result.has_value());
        QCOMPARE(result->permissions.size(), 2);
        QVERIFY(result->permissions.contains(u"network"));
        QVERIFY(result->permissions.contains(u"secure-storage"));
        QVERIFY(result->hasPermission(QStringLiteral("network")));
        QVERIFY(!result->hasPermission(QStringLiteral("storage")));
    }

    void missingPermissionsDefaultsToEmpty()
    {
        QTemporaryDir dir;
        QVERIFY(dir.isValid());
        writeManifest(dir.path(), validJson());

        auto result = AppManifest::fromDirectory(dir.path());
        QVERIFY(result.has_value());
        QVERIFY(result->permissions.isEmpty());
        QVERIFY(!result->hasPermission(QStringLiteral("network")));
    }
};

QTEST_GUILESS_MAIN(tst_AppManifest)
#include "tst_appmanifest.moc"
