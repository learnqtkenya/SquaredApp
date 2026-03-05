#pragma once

#include <QJsonValue>
#include <QObject>
#include <QUrl>
#include <QtQml/qqmlregistration.h>

class NetworkReplySingleton;

class NetworkSingleton : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(Network)
    QML_SINGLETON

    Q_PROPERTY(QUrl baseUrl READ baseUrl WRITE setBaseUrl NOTIFY baseUrlChanged)
    Q_PROPERTY(QString bearerToken READ bearerToken WRITE setBearerToken NOTIFY bearerTokenChanged)
    Q_PROPERTY(int timeout READ timeout WRITE setTimeout NOTIFY timeoutChanged)

public:
    explicit NetworkSingleton(QObject *parent = nullptr) : QObject(parent) {}

    QUrl baseUrl() const { return {}; }
    void setBaseUrl(const QUrl &url) { Q_UNUSED(url); }

    QString bearerToken() const { return {}; }
    void setBearerToken(const QString &token) { Q_UNUSED(token); }

    int timeout() const { return 30000; }
    void setTimeout(int ms) { Q_UNUSED(ms); }

    Q_INVOKABLE NetworkReplySingleton *get(const QString &path) {
        Q_UNUSED(path); return nullptr;
    }
    Q_INVOKABLE NetworkReplySingleton *post(const QString &path,
                                             const QJsonValue &body) {
        Q_UNUSED(path); Q_UNUSED(body); return nullptr;
    }
    Q_INVOKABLE NetworkReplySingleton *put(const QString &path,
                                            const QJsonValue &body) {
        Q_UNUSED(path); Q_UNUSED(body); return nullptr;
    }
    Q_INVOKABLE NetworkReplySingleton *patch(const QString &path,
                                              const QJsonValue &body) {
        Q_UNUSED(path); Q_UNUSED(body); return nullptr;
    }
    Q_INVOKABLE NetworkReplySingleton *del(const QString &path) {
        Q_UNUSED(path); return nullptr;
    }

    Q_INVOKABLE void setHeader(const QString &name, const QString &value) {
        Q_UNUSED(name); Q_UNUSED(value);
    }
    Q_INVOKABLE void clearHeaders() {}

signals:
    void baseUrlChanged();
    void bearerTokenChanged();
    void timeoutChanged();
};
