#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class SecureStorageReplySingleton;

class SecureStorageSingleton : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(SecureStorage)
    QML_SINGLETON

public:
    explicit SecureStorageSingleton(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE SecureStorageReplySingleton *set(const QString &key,
                                                  const QString &value) {
        Q_UNUSED(key); Q_UNUSED(value); return nullptr;
    }
    Q_INVOKABLE SecureStorageReplySingleton *get(const QString &key) {
        Q_UNUSED(key); return nullptr;
    }
    Q_INVOKABLE SecureStorageReplySingleton *remove(const QString &key) {
        Q_UNUSED(key); return nullptr;
    }
};
