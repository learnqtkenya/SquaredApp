#pragma once

#include <QObject>
#include <QVariant>
#include <QtQml/qqmlregistration.h>

class StorageSingleton : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(Storage)
    QML_SINGLETON

public:
    explicit StorageSingleton(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE void set(const QString &key, const QVariant &value) {
        Q_UNUSED(key); Q_UNUSED(value);
    }
    Q_INVOKABLE QVariant get(const QString &key,
                             const QVariant &fallback = QVariant()) const {
        Q_UNUSED(key); return fallback;
    }
    Q_INVOKABLE void remove(const QString &key) { Q_UNUSED(key); }
    Q_INVOKABLE bool has(const QString &key) const { Q_UNUSED(key); return false; }
    Q_INVOKABLE void clear() {}

signals:
    void changed(const QString &key);
};
