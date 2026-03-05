#pragma once

#include <QJSValue>
#include <QObject>
#include <QtQml/qqmlregistration.h>

QT_FORWARD_DECLARE_CLASS(QJSEngine)

class SecureStorageReply : public QObject {
    Q_OBJECT
    QML_UNCREATABLE("Created by SecureStorage")
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit SecureStorageReply(QJSEngine *engine, QObject *parent = nullptr);

    Q_INVOKABLE SecureStorageReply *then(QJSValue callback);
    Q_INVOKABLE SecureStorageReply *error(QJSValue callback);

    bool loading() const;

signals:
    void loadingChanged();
    void succeeded(const QString &value);
    void failed(const QString &errorMessage);

private:
    friend class SecureStorage;

    void resolve(const QString &value = {});
    void reject(const QString &errorMessage);

    QJSEngine *m_engine = nullptr;
    QJSValue m_thenCallback;
    QJSValue m_errorCallback;
    bool m_loading = true;
};
