#include <QJSEngine>
#include <QJsonObject>
#include <QJsonValue>
#include <QSignalSpy>
#include <QTest>
#include <QUrl>

#include "NetworkClient.h"
#include "NetworkReply.h"

class tst_NetworkClient : public QObject {
    Q_OBJECT

private slots:
    void defaultProperties();
    void setBaseUrl();
    void setBearerToken();
    void setTimeout();
    void setAndClearHeaders();
    void getReturnsReply();
    void postReturnsReply();
    void putReturnsReply();
    void patchReturnsReply();
    void delReturnsReply();
    void thenReturnsThis();
    void errorReturnsThis();
    void chainingWorks();
    void abortSetsLoadingFalse();
};

void tst_NetworkClient::defaultProperties()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);

    QVERIFY(client.baseUrl().isEmpty());
    QCOMPARE(client.bearerToken(), QString());
    QCOMPARE(client.timeout(), 30000);
}

void tst_NetworkClient::setBaseUrl()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);

    QSignalSpy spy(&client, &NetworkClient::baseUrlChanged);
    client.setBaseUrl(QUrl(QStringLiteral("https://api.example.com")));

    QCOMPARE(spy.count(), 1);
    QCOMPARE(client.baseUrl(), QUrl(QStringLiteral("https://api.example.com")));

    // Setting same value should not emit
    client.setBaseUrl(QUrl(QStringLiteral("https://api.example.com")));
    QCOMPARE(spy.count(), 1);
}

void tst_NetworkClient::setBearerToken()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);

    QSignalSpy spy(&client, &NetworkClient::bearerTokenChanged);
    client.setBearerToken(QStringLiteral("my-token"));

    QCOMPARE(spy.count(), 1);
    QCOMPARE(client.bearerToken(), QStringLiteral("my-token"));

    // Setting same value should not emit
    client.setBearerToken(QStringLiteral("my-token"));
    QCOMPARE(spy.count(), 1);

    // Clearing token
    client.setBearerToken(QString());
    QCOMPARE(spy.count(), 2);
    QCOMPARE(client.bearerToken(), QString());
}

void tst_NetworkClient::setTimeout()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);

    QSignalSpy spy(&client, &NetworkClient::timeoutChanged);
    client.setTimeout(5000);

    QCOMPARE(spy.count(), 1);
    QCOMPARE(client.timeout(), 5000);

    // Setting same value should not emit
    client.setTimeout(5000);
    QCOMPARE(spy.count(), 1);
}

void tst_NetworkClient::setAndClearHeaders()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);

    // Should not crash
    client.setHeader(QStringLiteral("X-Custom"), QStringLiteral("value"));
    client.setHeader(QStringLiteral("X-Another"), QStringLiteral("value2"));
    client.clearHeaders();
}

void tst_NetworkClient::getReturnsReply()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);
    client.setBaseUrl(QUrl(QStringLiteral("https://httpbin.org")));

    auto *reply = client.get(QStringLiteral("/get"));
    QVERIFY(reply != nullptr);
    QVERIFY(reply->loading());
}

void tst_NetworkClient::postReturnsReply()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);
    client.setBaseUrl(QUrl(QStringLiteral("https://httpbin.org")));

    QJsonValue body(QJsonObject{{QStringLiteral("key"), QStringLiteral("value")}});
    auto *reply = client.post(QStringLiteral("/post"), body);
    QVERIFY(reply != nullptr);
    QVERIFY(reply->loading());
}

void tst_NetworkClient::putReturnsReply()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);
    client.setBaseUrl(QUrl(QStringLiteral("https://httpbin.org")));

    QJsonValue body(QJsonObject{{QStringLiteral("key"), QStringLiteral("value")}});
    auto *reply = client.put(QStringLiteral("/put"), body);
    QVERIFY(reply != nullptr);
    QVERIFY(reply->loading());
}

void tst_NetworkClient::patchReturnsReply()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);
    client.setBaseUrl(QUrl(QStringLiteral("https://httpbin.org")));

    QJsonValue body(QJsonObject{{QStringLiteral("key"), QStringLiteral("value")}});
    auto *reply = client.patch(QStringLiteral("/patch"), body);
    QVERIFY(reply != nullptr);
    QVERIFY(reply->loading());
}

void tst_NetworkClient::delReturnsReply()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);
    client.setBaseUrl(QUrl(QStringLiteral("https://httpbin.org")));

    auto *reply = client.del(QStringLiteral("/delete"));
    QVERIFY(reply != nullptr);
    QVERIFY(reply->loading());
}

void tst_NetworkClient::thenReturnsThis()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);
    client.setBaseUrl(QUrl(QStringLiteral("https://httpbin.org")));

    auto *reply = client.get(QStringLiteral("/get"));
    auto *chained = reply->then(engine.evaluate(QStringLiteral("(function(s,d){})")));
    QCOMPARE(chained, reply);
}

void tst_NetworkClient::errorReturnsThis()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);
    client.setBaseUrl(QUrl(QStringLiteral("https://httpbin.org")));

    auto *reply = client.get(QStringLiteral("/get"));
    auto *chained = reply->error(engine.evaluate(QStringLiteral("(function(s,m){})")));
    QCOMPARE(chained, reply);
}

void tst_NetworkClient::chainingWorks()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);
    client.setBaseUrl(QUrl(QStringLiteral("https://httpbin.org")));

    auto *reply = client.get(QStringLiteral("/get"));
    auto *result = reply->then(engine.evaluate(QStringLiteral("(function(s,d){})")))
                        ->error(engine.evaluate(QStringLiteral("(function(s,m){})")));
    QCOMPARE(result, reply);
}

void tst_NetworkClient::abortSetsLoadingFalse()
{
    QJSEngine engine;
    NetworkClient client(QStringLiteral("com.test.app"), &engine);
    client.setBaseUrl(QUrl(QStringLiteral("https://httpbin.org")));

    auto *reply = client.get(QStringLiteral("/delay/10"));
    QVERIFY(reply->loading());

    QSignalSpy spy(reply, &NetworkReply::loadingChanged);
    reply->abort();

    // Process events to let abort propagate
    QTRY_VERIFY_WITH_TIMEOUT(!reply->loading(), 2000);
    QVERIFY(spy.count() >= 1);
}

QTEST_MAIN(tst_NetworkClient)
#include "tst_networkclient.moc"
