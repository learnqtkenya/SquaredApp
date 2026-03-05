#include "NetworkClient.h"
#include "NetworkReply.h"

#include <QHttpHeaders>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QRestAccessManager>
#include <QRestReply>

NetworkClient::NetworkClient(const QString &appId, QJSEngine *engine,
                             QObject *parent)
    : QObject(parent)
    , m_appId(appId)
    , m_engine(engine)
    , m_rest(new QRestAccessManager(&m_nam, this))
{
}

QUrl NetworkClient::baseUrl() const
{
    return m_factory.baseUrl();
}

void NetworkClient::setBaseUrl(const QUrl &url)
{
    if (m_factory.baseUrl() == url)
        return;
    m_factory.setBaseUrl(url);
    emit baseUrlChanged();
}

QString NetworkClient::bearerToken() const
{
    return QString::fromUtf8(m_factory.bearerToken());
}

void NetworkClient::setBearerToken(const QString &token)
{
    auto bytes = token.toUtf8();
    if (m_factory.bearerToken() == bytes)
        return;
    if (token.isEmpty())
        m_factory.clearBearerToken();
    else
        m_factory.setBearerToken(bytes);
    emit bearerTokenChanged();
}

int NetworkClient::timeout() const
{
    return m_timeout;
}

void NetworkClient::setTimeout(int ms)
{
    if (m_timeout == ms)
        return;
    m_timeout = ms;
    m_factory.setTransferTimeout(std::chrono::milliseconds(ms));
    emit timeoutChanged();
}

NetworkReply *NetworkClient::get(const QString &path)
{
    auto *reply = sendRequest(path);
    reply->m_reply = m_rest->get(m_factory.createRequest(path), reply,
                                 [reply](QRestReply &restReply) {
                                     reply->handleFinished(restReply);
                                 });
    return reply;
}

NetworkReply *NetworkClient::post(const QString &path, const QJsonValue &body)
{
    auto *reply = sendRequest(path);
    auto doc = body.isArray() ? QJsonDocument(body.toArray())
                              : QJsonDocument(body.toObject());
    reply->m_reply = m_rest->post(m_factory.createRequest(path), doc, reply,
                                   [reply](QRestReply &restReply) {
                                       reply->handleFinished(restReply);
                                   });
    return reply;
}

NetworkReply *NetworkClient::put(const QString &path, const QJsonValue &body)
{
    auto *reply = sendRequest(path);
    auto doc = body.isArray() ? QJsonDocument(body.toArray())
                              : QJsonDocument(body.toObject());
    reply->m_reply = m_rest->put(m_factory.createRequest(path), doc, reply,
                                  [reply](QRestReply &restReply) {
                                      reply->handleFinished(restReply);
                                  });
    return reply;
}

NetworkReply *NetworkClient::patch(const QString &path, const QJsonValue &body)
{
    auto *reply = sendRequest(path);
    auto doc = body.isArray() ? QJsonDocument(body.toArray())
                              : QJsonDocument(body.toObject());
    reply->m_reply = m_rest->patch(m_factory.createRequest(path), doc, reply,
                                    [reply](QRestReply &restReply) {
                                        reply->handleFinished(restReply);
                                    });
    return reply;
}

NetworkReply *NetworkClient::del(const QString &path)
{
    auto *reply = sendRequest(path);
    reply->m_reply = m_rest->deleteResource(
        m_factory.createRequest(path), reply,
        [reply](QRestReply &restReply) {
            reply->handleFinished(restReply);
        });
    return reply;
}

void NetworkClient::setHeader(const QString &name, const QString &value)
{
    m_customHeaders.insert(name.toUtf8(), value.toUtf8());
    applyHeaders();
}

void NetworkClient::clearHeaders()
{
    m_customHeaders.clear();
    m_factory.clearCommonHeaders();
}

NetworkReply *NetworkClient::sendRequest(const QString &path)
{
    Q_UNUSED(path)
    return new NetworkReply(nullptr, m_engine, this);
}

void NetworkClient::applyHeaders()
{
    QHttpHeaders headers;
    for (auto it = m_customHeaders.constBegin(); it != m_customHeaders.constEnd(); ++it)
        headers.append(it.key(), it.value());
    m_factory.setCommonHeaders(headers);
}
