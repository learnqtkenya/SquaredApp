#pragma once

#include <QObject>
#include <QStringList>

QT_FORWARD_DECLARE_CLASS(QJSEngine)
class SecureStorageReply;

class SecureStorage : public QObject {
    Q_OBJECT

public:
    explicit SecureStorage(const QString &appId, const QString &storageRoot,
                           bool insecureFallback = false,
                           QJSEngine *engine = nullptr,
                           QObject *parent = nullptr);

    Q_INVOKABLE SecureStorageReply *set(const QString &key, const QString &value);
    Q_INVOKABLE SecureStorageReply *get(const QString &key);
    Q_INVOKABLE SecureStorageReply *remove(const QString &key);

    static void removeAllForApp(const QString &appId, const QString &storageRoot,
                                bool insecureFallback = false);

private:
    QString fullKey(const QString &key) const;
    void trackKey(const QString &key);
    void untrackKey(const QString &key);
    void loadTrackedKeys();
    void saveTrackedKeys();
    QString trackedKeysPath() const;
    QString insecureValuePath(const QString &key) const;

    QString m_appId;
    QString m_storageRoot;
    bool m_insecureFallback;
    QStringList m_trackedKeys;
    QJSEngine *m_engine = nullptr;
};
