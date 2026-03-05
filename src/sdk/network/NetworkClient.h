#pragma once

#include <QJsonValue>
#include <QMap>
#include <QNetworkAccessManager>
#include <QNetworkRequestFactory>
#include <QObject>
#include <QUrl>
#include <QtQml/qqmlregistration.h>

#include "NetworkReply.h"

QT_FORWARD_DECLARE_CLASS(QJSEngine)
QT_FORWARD_DECLARE_CLASS(QRestAccessManager)

class NetworkClient : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QUrl baseUrl READ baseUrl WRITE setBaseUrl NOTIFY baseUrlChanged)
    Q_PROPERTY(QString bearerToken READ bearerToken WRITE setBearerToken NOTIFY bearerTokenChanged)
    Q_PROPERTY(int timeout READ timeout WRITE setTimeout NOTIFY timeoutChanged)

public:
    explicit NetworkClient(const QString &appId, QJSEngine *engine,
                           QObject *parent = nullptr);

    QUrl baseUrl() const;
    void setBaseUrl(const QUrl &url);

    QString bearerToken() const;
    void setBearerToken(const QString &token);

    int timeout() const;
    void setTimeout(int ms);

    Q_INVOKABLE NetworkReply *get(const QString &path);
    Q_INVOKABLE NetworkReply *post(const QString &path, const QJsonValue &body);
    Q_INVOKABLE NetworkReply *put(const QString &path, const QJsonValue &body);
    Q_INVOKABLE NetworkReply *patch(const QString &path, const QJsonValue &body);
    Q_INVOKABLE NetworkReply *del(const QString &path);

    Q_INVOKABLE void setHeader(const QString &name, const QString &value);
    Q_INVOKABLE void clearHeaders();

signals:
    void baseUrlChanged();
    void bearerTokenChanged();
    void timeoutChanged();

private:
    NetworkReply *sendRequest(const QString &path);
    void applyHeaders();

    QString m_appId;
    QJSEngine *m_engine;
    QNetworkAccessManager m_nam;
    QRestAccessManager *m_rest;
    QNetworkRequestFactory m_factory;
    QMap<QByteArray, QByteArray> m_customHeaders;
    int m_timeout = 30000;
};
