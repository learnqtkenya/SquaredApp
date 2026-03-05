#include "SecureStorageReply.h"

#include <QJSEngine>

SecureStorageReply::SecureStorageReply(QJSEngine *engine, QObject *parent)
    : QObject(parent)
    , m_engine(engine)
{
}

SecureStorageReply *SecureStorageReply::then(QJSValue callback)
{
    m_thenCallback = std::move(callback);
    return this;
}

SecureStorageReply *SecureStorageReply::error(QJSValue callback)
{
    m_errorCallback = std::move(callback);
    return this;
}

bool SecureStorageReply::loading() const
{
    return m_loading;
}

void SecureStorageReply::resolve(const QString &value)
{
    if (m_engine && m_thenCallback.isCallable()) {
        if (value.isNull())
            m_thenCallback.call();
        else
            m_thenCallback.call({QJSValue(value)});
    }

    emit succeeded(value);

    m_loading = false;
    emit loadingChanged();
    deleteLater();
}

void SecureStorageReply::reject(const QString &errorMessage)
{
    if (m_engine && m_errorCallback.isCallable())
        m_errorCallback.call({QJSValue(errorMessage)});

    emit failed(errorMessage);

    m_loading = false;
    emit loadingChanged();
    deleteLater();
}
