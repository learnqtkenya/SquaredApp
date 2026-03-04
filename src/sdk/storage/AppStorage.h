#pragma once

#include <QObject>
#include <QVariant>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

class AppStorage : public QObject {
    Q_OBJECT
    QML_ELEMENT

public:
    explicit AppStorage(const QString &appId, const QString &storageRoot,
                        QObject *parent = nullptr);

    Q_INVOKABLE void set(const QString &key, const QVariant &value);
    Q_INVOKABLE QVariant get(const QString &key,
                             const QVariant &fallback = QVariant()) const;
    Q_INVOKABLE void remove(const QString &key);
    Q_INVOKABLE bool has(const QString &key) const;
    Q_INVOKABLE void clear();

signals:
    void changed(const QString &key);

private:
    void save();
    void load();
    QString storagePath() const;
    void ensureDirectory();

    static QVariant normalize(const QVariant &v);

    static constexpr quint32 MAGIC = 0x53515344;   // "SQSD"
    static constexpr quint32 VERSION = 1;

    QString m_appId;
    QString m_storageRoot;
    QVariantMap m_data;
};
