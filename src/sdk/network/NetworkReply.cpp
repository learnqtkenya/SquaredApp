#include "NetworkReply.h"

#include <QJSEngine>
#include <QJsonDocument>
#include <QNetworkReply>
#include <QRestReply>

NetworkReply::NetworkReply(QNetworkReply *reply, QJSEngine *engine,
                           QObject *parent)
    : QObject(parent)
    , m_reply(reply)
    , m_engine(engine)
{
}

NetworkReply *NetworkReply::then(QJSValue callback)
{
    m_thenCallback = std::move(callback);
    return this;
}

NetworkReply *NetworkReply::error(QJSValue callback)
{
    m_errorCallback = std::move(callback);
    return this;
}

void NetworkReply::abort()
{
    if (m_reply)
        m_reply->abort();
}

bool NetworkReply::loading() const
{
    return m_loading;
}

void NetworkReply::handleFinished(QRestReply &restReply)
{
    if (restReply.isSuccess()) {
        if (m_thenCallback.isCallable()) {
            auto json = restReply.readJson();
            QJSValue data;
            if (json)
                data = m_engine->toScriptValue(json->toVariant());
            else
                data = m_engine->toScriptValue(QVariant());
            m_thenCallback.call({QJSValue(restReply.httpStatus()), data});
        }
    } else {
        if (m_errorCallback.isCallable()) {
            m_errorCallback.call({QJSValue(restReply.httpStatus()),
                                  QJSValue(restReply.errorString())});
        }
    }

    m_loading = false;
    emit loadingChanged();
    deleteLater();
}
