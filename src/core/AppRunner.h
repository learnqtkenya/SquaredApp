#pragma once

#include <QObject>

QT_FORWARD_DECLARE_CLASS(QQmlEngine)
QT_FORWARD_DECLARE_CLASS(QQmlContext)
QT_FORWARD_DECLARE_CLASS(QQuickItem)

struct AppManifest;
class AppStorage;
class SecureStorage;
class NetworkClient;
class SquaredApp;

class AppRunner : public QObject {
    Q_OBJECT
    Q_PROPERTY(State state READ state NOTIFY stateChanged)

public:
    enum class State { Idle, Loading, Running, Suspended, Error };
    Q_ENUM(State)

    explicit AppRunner(QQmlEngine *engine, const QString &storageRoot,
                       QObject *parent = nullptr);
    ~AppRunner() override;

    Q_INVOKABLE void launchFromPath(const QString &appDirPath, QQuickItem *container);
    Q_INVOKABLE void close();
    Q_INVOKABLE void suspend();
    Q_INVOKABLE void resume(QQuickItem *container);
    void launch(const AppManifest &manifest, QQuickItem *container);

    State state() const;

signals:
    void stateChanged();
    void launched(const QString &appId, qint64 loadTimeMs);
    void suspended();
    void resumed();
    void closed();
    void error(const QString &appId, const QString &message);
    void reloadRequested();

private:
    void setState(State newState);
    void cleanup();

    QQmlEngine *m_engine = nullptr;
    QString m_storageRoot;
    State m_state = State::Idle;

    QQmlContext *m_appContext = nullptr;
    QQuickItem *m_rootItem = nullptr;
    AppStorage *m_storage = nullptr;
    SecureStorage *m_secureStorage = nullptr;
    SquaredApp *m_app = nullptr;
    NetworkClient *m_network = nullptr;
    QString m_currentAppId;
    QString m_addedImportPath;
};
