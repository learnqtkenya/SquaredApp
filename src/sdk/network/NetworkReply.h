#pragma once

#include <QJSValue>
#include <QObject>
#include <QtQml/qqmlregistration.h>

QT_FORWARD_DECLARE_CLASS(QJSEngine)
QT_FORWARD_DECLARE_CLASS(QNetworkReply)
class QRestReply;

class NetworkReply : public QObject {
    Q_OBJECT
    QML_UNCREATABLE("Created by NetworkClient")
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit NetworkReply(QNetworkReply *reply, QJSEngine *engine,
                          QObject *parent = nullptr);

    Q_INVOKABLE NetworkReply *then(QJSValue callback);
    Q_INVOKABLE NetworkReply *error(QJSValue callback);
    Q_INVOKABLE void abort();

    bool loading() const;

signals:
    void loadingChanged();

private:
    friend class NetworkClient;
    void handleFinished(QRestReply &restReply);

    QNetworkReply *m_reply;
    QJSEngine *m_engine;
    QJSValue m_thenCallback;
    QJSValue m_errorCallback;
    bool m_loading = true;
};
