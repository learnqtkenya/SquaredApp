#pragma once

#include <QJSValue>
#include <QObject>
#include <QtQml/qqmlregistration.h>

class NetworkReplySingleton : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(NetworkReply)
    QML_UNCREATABLE("Created by Network")

    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit NetworkReplySingleton(QObject *parent = nullptr)
        : QObject(parent) {}

    bool loading() const { return false; }

    Q_INVOKABLE NetworkReplySingleton *then(QJSValue callback) {
        Q_UNUSED(callback); return this;
    }
    Q_INVOKABLE NetworkReplySingleton *error(QJSValue callback) {
        Q_UNUSED(callback); return this;
    }
    Q_INVOKABLE void abort() {}

signals:
    void loadingChanged();
};
