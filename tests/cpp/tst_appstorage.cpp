#include <QtTest>
#include <QTemporaryDir>
#include <QSignalSpy>
#include "AppStorage.h"

using namespace Qt::StringLiterals;

class tst_AppStorage : public QObject {
    Q_OBJECT

private:
    QTemporaryDir *m_tempDir = nullptr;

private slots:
    void init()
    {
        m_tempDir = new QTemporaryDir;
        QVERIFY(m_tempDir->isValid());
    }

    void cleanup()
    {
        delete m_tempDir;
        m_tempDir = nullptr;
    }

    void setGetRoundtripString()
    {
        AppStorage storage(u"test.app"_s, m_tempDir->path());
        storage.set(u"key"_s, u"hello"_s);
        QCOMPARE(storage.get(u"key"_s).toString(), u"hello");
    }

    void setGetRoundtripInt()
    {
        AppStorage storage(u"test.app"_s, m_tempDir->path());
        storage.set(u"count"_s, 42);
        QCOMPARE(storage.get(u"count"_s).toInt(), 42);
    }

    void setGetRoundtripBool()
    {
        AppStorage storage(u"test.app"_s, m_tempDir->path());
        storage.set(u"flag"_s, true);
        QCOMPARE(storage.get(u"flag"_s).toBool(), true);
    }

    void setGetRoundtripList()
    {
        AppStorage storage(u"test.app"_s, m_tempDir->path());
        QVariantList list{1, u"two"_s, true};
        storage.set(u"list"_s, list);
        QCOMPARE(storage.get(u"list"_s).toList().size(), 3);
    }

    void setGetRoundtripMap()
    {
        AppStorage storage(u"test.app"_s, m_tempDir->path());
        QVariantMap map{{u"a"_s, 1}, {u"b"_s, u"two"_s}};
        storage.set(u"map"_s, QVariant::fromValue(map));
        auto result = storage.get(u"map"_s).toMap();
        QCOMPARE(result.size(), 2);
        QCOMPARE(result[u"a"_s].toInt(), 1);
    }

    void getWithFallback()
    {
        AppStorage storage(u"test.app"_s, m_tempDir->path());
        QCOMPARE(storage.get(u"missing"_s, u"default"_s).toString(), u"default");
    }

    void hasExistingAndMissing()
    {
        AppStorage storage(u"test.app"_s, m_tempDir->path());
        storage.set(u"key"_s, u"val"_s);
        QVERIFY(storage.has(u"key"_s));
        QVERIFY(!storage.has(u"other"_s));
    }

    void removeKey()
    {
        AppStorage storage(u"test.app"_s, m_tempDir->path());
        storage.set(u"key"_s, u"val"_s);
        storage.remove(u"key"_s);
        QVERIFY(!storage.has(u"key"_s));
        QCOMPARE(storage.get(u"key"_s, u"gone"_s).toString(), u"gone");
    }

    void clearAll()
    {
        AppStorage storage(u"test.app"_s, m_tempDir->path());
        storage.set(u"a"_s, 1);
        storage.set(u"b"_s, 2);
        storage.clear();
        QVERIFY(!storage.has(u"a"_s));
        QVERIFY(!storage.has(u"b"_s));
    }

    void persistsAfterDestroyRecreate()
    {
        {
            AppStorage storage(u"test.app"_s, m_tempDir->path());
            storage.set(u"key"_s, u"persisted"_s);
        } // destructor flushes

        AppStorage storage2(u"test.app"_s, m_tempDir->path());
        QCOMPARE(storage2.get(u"key"_s).toString(), u"persisted");
    }

    void twoInstancesIsolated()
    {
        AppStorage a(u"app.one"_s, m_tempDir->path());
        AppStorage b(u"app.two"_s, m_tempDir->path());

        a.set(u"key"_s, u"from-a"_s);
        b.set(u"key"_s, u"from-b"_s);

        QCOMPARE(a.get(u"key"_s).toString(), u"from-a");
        QCOMPARE(b.get(u"key"_s).toString(), u"from-b");
    }

    void changedSignalEmits()
    {
        AppStorage storage(u"test.app"_s, m_tempDir->path());
        QSignalSpy spy(&storage, &AppStorage::changed);
        storage.set(u"key"_s, u"val"_s);
        QCOMPARE(spy.count(), 1);
        QCOMPARE(spy.first().first().toString(), u"key");
    }

    void nestedComplexTypeRoundtrip()
    {
        auto path = m_tempDir->path();
        {
            AppStorage storage(u"test.app"_s, path);
            QVariantList transactions;
            QVariantMap tx1{{u"id"_s, u"abc"_s},
                           {u"amount"_s, 100},
                           {u"tags"_s, QVariantList{u"food"_s, u"lunch"_s}}};
            QVariantMap tx2{{u"id"_s, u"def"_s},
                           {u"amount"_s, 250},
                           {u"tags"_s, QVariantList{u"rent"_s}}};
            transactions.append(QVariant::fromValue(tx1));
            transactions.append(QVariant::fromValue(tx2));
            storage.set(u"transactions"_s, transactions);
        }

        AppStorage storage2(u"test.app"_s, path);
        auto result = storage2.get(u"transactions"_s).toList();
        QCOMPARE(result.size(), 2);
        auto first = result[0].toMap();
        QCOMPARE(first[u"id"_s].toString(), u"abc");
        QCOMPARE(first[u"amount"_s].toInt(), 100);
        QCOMPARE(first[u"tags"_s].toList().size(), 2);
    }

    void corruptFileHandledGracefully()
    {
        auto path = m_tempDir->path();
        {
            AppStorage storage(u"test.app"_s, path);
            storage.set(u"key"_s, u"value"_s);
        }

        // Corrupt the storage file
        auto filePath = path + u"/test.app/storage.dat"_s;
        QFile f(filePath);
        QVERIFY(f.open(QIODevice::WriteOnly));
        f.write("not a valid binary file");
        f.close();

        // Should not crash — starts fresh
        AppStorage storage(u"test.app"_s, path);
        QVERIFY(!storage.has(u"key"_s));
        // Should still be able to write new data
        storage.set(u"key"_s, u"new"_s);
        QCOMPARE(storage.get(u"key"_s).toString(), u"new");
    }

    void clearPersistsAcrossInstances()
    {
        auto path = m_tempDir->path();
        {
            AppStorage storage(u"test.app"_s, path);
            storage.set(u"a"_s, 1);
            storage.set(u"b"_s, 2);
            storage.clear();
        }

        AppStorage storage2(u"test.app"_s, path);
        QVERIFY(!storage2.has(u"a"_s));
        QVERIFY(!storage2.has(u"b"_s));
    }
};

QTEST_GUILESS_MAIN(tst_AppStorage)
#include "tst_appstorage.moc"
