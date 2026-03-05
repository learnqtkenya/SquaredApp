#pragma once

#include <QJSValue>
#include <QObject>
#include <QtQml/qqmlregistration.h>

class SecureStorageReplySingleton : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(SecureStorageReply)
    QML_UNCREATABLE("Created by SecureStorage")

    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit SecureStorageReplySingleton(QObject *parent = nullptr)
        : QObject(parent) {}

    bool loading() const { return false; }

    Q_INVOKABLE SecureStorageReplySingleton *then(QJSValue callback) {
        Q_UNUSED(callback); return this;
    }
    Q_INVOKABLE SecureStorageReplySingleton *error(QJSValue callback) {
        Q_UNUSED(callback); return this;
    }

signals:
    void loadingChanged();
    void succeeded(const QString &value);
    void failed(const QString &errorMessage);
};
