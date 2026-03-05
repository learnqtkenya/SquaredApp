#include <QtTest>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include "AppCatalog.h"

class tst_AppCatalog : public QObject {
    Q_OBJECT

private:
    static QByteArray validCatalogJson()
    {
        QJsonObject app1;
        app1["id"] = "com.test.app1";
        app1["name"] = "App One";
        app1["version"] = "1.0.0";
        app1["author"] = "Author";
        app1["description"] = "A test app";
        app1["iconUrl"] = "https://example.com/icon.png";
        app1["packageUrl"] = "https://example.com/app1.sqapp";
        app1["sizeBytes"] = 12345;
        app1["category"] = "tools";
        app1["permissions"] = QJsonArray{"network", "secure-storage"};

        QJsonObject app2;
        app2["id"] = "com.test.app2";
        app2["name"] = "App Two";
        app2["version"] = "2.0.0";
        app2["author"] = "Author 2";
        app2["description"] = "Another app";
        app2["iconUrl"] = "https://example.com/icon2.png";
        app2["packageUrl"] = "https://example.com/app2.sqapp";
        app2["sizeBytes"] = 67890;
        app2["category"] = "games";

        QJsonObject root;
        root["apps"] = QJsonArray{app1, app2};
        return QJsonDocument(root).toJson();
    }

private slots:
    void parseValidCatalog()
    {
        auto entries = AppCatalog::parseJson(validCatalogJson());
        QCOMPARE(entries.size(), 2);

        QCOMPARE(entries[0].id, "com.test.app1");
        QCOMPARE(entries[0].name, "App One");
        QCOMPARE(entries[0].version, "1.0.0");
        QCOMPARE(entries[0].author, "Author");
        QCOMPARE(entries[0].sizeBytes, 12345);
        QCOMPARE(entries[0].category, "tools");
        QCOMPARE(entries[0].packageUrl.toString(), "https://example.com/app1.sqapp");

        QCOMPARE(entries[0].permissions.size(), 2);
        QVERIFY(entries[0].permissions.contains("network"));
        QVERIFY(entries[0].permissions.contains("secure-storage"));

        QCOMPARE(entries[1].id, "com.test.app2");
        QCOMPARE(entries[1].name, "App Two");
        QVERIFY(entries[1].permissions.isEmpty());
    }

    void parseEmptyAppsArray()
    {
        auto entries = AppCatalog::parseJson(R"json({"apps": []})json");
        QCOMPARE(entries.size(), 0);
    }

    void parseMalformedJson()
    {
        auto entries = AppCatalog::parseJson("not json at all {{{");
        QCOMPARE(entries.size(), 0);
    }

    void parseSkipsEntriesWithoutId()
    {
        QJsonObject noId;
        noId["name"] = "No ID";

        QJsonObject valid;
        valid["id"] = "com.test.valid";
        valid["name"] = "Valid";

        QJsonObject root;
        root["apps"] = QJsonArray{noId, valid};

        auto entries = AppCatalog::parseJson(QJsonDocument(root).toJson());
        QCOMPARE(entries.size(), 1);
        QCOMPARE(entries[0].id, "com.test.valid");
    }

    void parseSkipsEntriesWithoutName()
    {
        QJsonObject noName;
        noName["id"] = "com.test.noname";

        QJsonObject valid;
        valid["id"] = "com.test.valid";
        valid["name"] = "Valid";

        QJsonObject root;
        root["apps"] = QJsonArray{noName, valid};

        auto entries = AppCatalog::parseJson(QJsonDocument(root).toJson());
        QCOMPARE(entries.size(), 1);
    }

    void parseMissingAppsKey()
    {
        auto entries = AppCatalog::parseJson(R"json({"other": "data"})json");
        QCOMPARE(entries.size(), 0);
    }
};

QTEST_GUILESS_MAIN(tst_AppCatalog)
#include "tst_appcatalog.moc"
