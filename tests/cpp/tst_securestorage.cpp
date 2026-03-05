#include <QtTest>
#include <QSignalSpy>
#include <QTemporaryDir>
#include "SecureStorage.h"
#include "SecureStorageReply.h"

class tst_SecureStorage : public QObject {
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

    void setAndGetRoundtrip()
    {
        SecureStorage storage(QStringLiteral("test.roundtrip"), m_tempDir->path(), true);

        auto *setReply = storage.set(QStringLiteral("token"), QStringLiteral("secret123"));
        QSignalSpy setSpy(setReply, &SecureStorageReply::succeeded);
        QVERIFY(setSpy.wait(5000));
        QCOMPARE(setSpy.count(), 1);

        auto *getReply = storage.get(QStringLiteral("token"));
        QSignalSpy getSpy(getReply, &SecureStorageReply::succeeded);
        QVERIFY(getSpy.wait(5000));
        QCOMPARE(getSpy.count(), 1);
        QCOMPARE(getSpy.first().first().toString(), QStringLiteral("secret123"));
    }

    void getMissingKeyReturnsEmpty()
    {
        SecureStorage storage(QStringLiteral("test.missing"), m_tempDir->path(), true);

        auto *reply = storage.get(QStringLiteral("nonexistent"));
        QSignalSpy spy(reply, &SecureStorageReply::succeeded);
        QVERIFY(spy.wait(5000));
        QCOMPARE(spy.first().first().toString(), QString());
    }

    void removeKey()
    {
        SecureStorage storage(QStringLiteral("test.remove"), m_tempDir->path(), true);

        auto *setReply = storage.set(QStringLiteral("token"), QStringLiteral("val"));
        QSignalSpy setSpy(setReply, &SecureStorageReply::succeeded);
        QVERIFY(setSpy.wait(5000));

        auto *removeReply = storage.remove(QStringLiteral("token"));
        QSignalSpy removeSpy(removeReply, &SecureStorageReply::succeeded);
        QVERIFY(removeSpy.wait(5000));
        QCOMPARE(removeSpy.count(), 1);

        auto *getReply = storage.get(QStringLiteral("token"));
        QSignalSpy getSpy(getReply, &SecureStorageReply::succeeded);
        QVERIFY(getSpy.wait(5000));
        QCOMPARE(getSpy.first().first().toString(), QString());
    }

    void removeNonexistentKeySucceeds()
    {
        SecureStorage storage(QStringLiteral("test.removeghost"), m_tempDir->path(), true);

        auto *reply = storage.remove(QStringLiteral("ghost"));
        QSignalSpy spy(reply, &SecureStorageReply::succeeded);
        QVERIFY(spy.wait(5000));
        QCOMPARE(spy.count(), 1);
    }

    void twoAppsIsolated()
    {
        SecureStorage a(QStringLiteral("app.one"), m_tempDir->path(), true);
        SecureStorage b(QStringLiteral("app.two"), m_tempDir->path(), true);

        auto *setReplyA = a.set(QStringLiteral("token"), QStringLiteral("alpha"));
        QSignalSpy setSpyA(setReplyA, &SecureStorageReply::succeeded);
        QVERIFY(setSpyA.wait(5000));

        auto *setReplyB = b.set(QStringLiteral("token"), QStringLiteral("beta"));
        QSignalSpy setSpyB(setReplyB, &SecureStorageReply::succeeded);
        QVERIFY(setSpyB.wait(5000));

        auto *getReplyA = a.get(QStringLiteral("token"));
        QSignalSpy getSpyA(getReplyA, &SecureStorageReply::succeeded);
        QVERIFY(getSpyA.wait(5000));
        QCOMPARE(getSpyA.first().first().toString(), QStringLiteral("alpha"));

        auto *getReplyB = b.get(QStringLiteral("token"));
        QSignalSpy getSpyB(getReplyB, &SecureStorageReply::succeeded);
        QVERIFY(getSpyB.wait(5000));
        QCOMPARE(getSpyB.first().first().toString(), QStringLiteral("beta"));
    }

    void overwriteExistingKey()
    {
        SecureStorage storage(QStringLiteral("test.overwrite"), m_tempDir->path(), true);

        auto *setReply1 = storage.set(QStringLiteral("token"), QStringLiteral("first"));
        QSignalSpy setSpy1(setReply1, &SecureStorageReply::succeeded);
        QVERIFY(setSpy1.wait(5000));

        auto *setReply2 = storage.set(QStringLiteral("token"), QStringLiteral("second"));
        QSignalSpy setSpy2(setReply2, &SecureStorageReply::succeeded);
        QVERIFY(setSpy2.wait(5000));

        auto *getReply = storage.get(QStringLiteral("token"));
        QSignalSpy getSpy(getReply, &SecureStorageReply::succeeded);
        QVERIFY(getSpy.wait(5000));
        QCOMPARE(getSpy.first().first().toString(), QStringLiteral("second"));
    }

    void trackedKeysFileUpdated()
    {
        {
            SecureStorage storage(QStringLiteral("test.tracked"), m_tempDir->path(), true);

            auto *reply1 = storage.set(QStringLiteral("a"), QStringLiteral("1"));
            QSignalSpy spy1(reply1, &SecureStorageReply::succeeded);
            QVERIFY(spy1.wait(5000));

            auto *reply2 = storage.set(QStringLiteral("b"), QStringLiteral("2"));
            QSignalSpy spy2(reply2, &SecureStorageReply::succeeded);
            QVERIFY(spy2.wait(5000));
        }

        QFile f(m_tempDir->path() + QStringLiteral("/test.tracked/keychain_keys"));
        QVERIFY(f.exists());
        QVERIFY(f.open(QIODevice::ReadOnly));
        auto content = QString::fromUtf8(f.readAll());
        QVERIFY(content.contains(QStringLiteral("a")));
        QVERIFY(content.contains(QStringLiteral("b")));
    }

    void removeAllForAppCleansUp()
    {
        {
            SecureStorage storage(QStringLiteral("test.cleanup"), m_tempDir->path(), true);

            auto *reply1 = storage.set(QStringLiteral("x"), QStringLiteral("1"));
            QSignalSpy spy1(reply1, &SecureStorageReply::succeeded);
            QVERIFY(spy1.wait(5000));

            auto *reply2 = storage.set(QStringLiteral("y"), QStringLiteral("2"));
            QSignalSpy spy2(reply2, &SecureStorageReply::succeeded);
            QVERIFY(spy2.wait(5000));
        }

        SecureStorage::removeAllForApp(QStringLiteral("test.cleanup"), m_tempDir->path(), true);

        SecureStorage storage2(QStringLiteral("test.cleanup"), m_tempDir->path(), true);

        auto *getReply = storage2.get(QStringLiteral("x"));
        QSignalSpy spy(getReply, &SecureStorageReply::succeeded);
        QVERIFY(spy.wait(5000));
        QCOMPARE(spy.first().first().toString(), QString());
    }
};

QTEST_GUILESS_MAIN(tst_SecureStorage)
#include "tst_securestorage.moc"
