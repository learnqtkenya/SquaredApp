#include "AppRunner.h"
#include "AppManifest.h"
#include "AppStorage.h"
#include "SecureStorage.h"
#include "NetworkClient.h"
#include "SquaredApp.h"

#include <QElapsedTimer>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QQuickItem>

AppRunner::AppRunner(QQmlEngine *engine, const QString &storageRoot,
                     QObject *parent)
    : QObject(parent), m_engine(engine), m_storageRoot(storageRoot)
{
}

AppRunner::~AppRunner()
{
    cleanup();
}

void AppRunner::launchFromPath(const QString &appDirPath, QQuickItem *container)
{
    auto manifest = AppManifest::fromDirectory(appDirPath);
    if (!manifest) {
        setState(State::Error);
        emit error(QString(), QStringLiteral("Failed to parse manifest at: ") + appDirPath);
        return;
    }
    launch(*manifest, container);
}

void AppRunner::launch(const AppManifest &manifest, QQuickItem *container)
{
    if (m_state != State::Idle)
        close();

    setState(State::Loading);

    QElapsedTimer timer;
    timer.start();

    m_currentAppId = manifest.id;
    m_addedImportPath = manifest.basePath + QStringLiteral("/qml");
    m_engine->addImportPath(m_addedImportPath);

    m_appContext = new QQmlContext(m_engine->rootContext());

    // Storage and App are always available
    m_storage = new AppStorage(manifest.id, m_storageRoot);
    m_app = new SquaredApp(manifest.id, manifest.version);
    m_appContext->setContextProperty(QStringLiteral("Storage"), m_storage);
    m_appContext->setContextProperty(QStringLiteral("App"), m_app);

    // Network requires "network" permission
    if (manifest.hasPermission(QStringLiteral("network"))) {
        m_network = new NetworkClient(manifest.id, m_engine);
        m_appContext->setContextProperty(QStringLiteral("Network"), m_network);
    }

    // SecureStorage requires "secure-storage" permission
    if (manifest.hasPermission(QStringLiteral("secure-storage"))) {
        m_secureStorage = new SecureStorage(manifest.id, m_storageRoot, false, m_engine);
        m_appContext->setContextProperty(QStringLiteral("SecureStorage"), m_secureStorage);
    }

    auto entryPath = manifest.basePath + QStringLiteral("/qml/") + manifest.entry;
    QQmlComponent component(m_engine, QUrl::fromLocalFile(entryPath));

    if (!component.isReady()) {
        setState(State::Error);
        emit error(manifest.id, component.errorString());
        cleanup();
        return;
    }

    auto *obj = component.create(m_appContext);
    m_rootItem = qobject_cast<QQuickItem *>(obj);
    if (!m_rootItem) {
        delete obj;
        setState(State::Error);
        emit error(manifest.id, QStringLiteral("Root component is not an Item"));
        cleanup();
        return;
    }

    m_rootItem->setParentItem(container);
    m_rootItem->setWidth(container->width());
    m_rootItem->setHeight(container->height());

    connect(container, &QQuickItem::widthChanged, m_rootItem, [this, container]() {
        if (m_rootItem)
            m_rootItem->setWidth(container->width());
    });
    connect(container, &QQuickItem::heightChanged, m_rootItem, [this, container]() {
        if (m_rootItem)
            m_rootItem->setHeight(container->height());
    });

    m_app->setLifecycle(SquaredApp::Lifecycle::Active);

    setState(State::Running);
    emit launched(manifest.id, timer.elapsed());
}

void AppRunner::suspend()
{
    if (m_state != State::Running)
        return;

    m_rootItem->setVisible(false);
    m_rootItem->setParentItem(nullptr);
    m_app->setLifecycle(SquaredApp::Lifecycle::Suspended);

    setState(State::Suspended);
    emit suspended();
}

void AppRunner::resume(QQuickItem *container)
{
    if (m_state != State::Suspended)
        return;

    m_rootItem->setParentItem(container);
    m_rootItem->setWidth(container->width());
    m_rootItem->setHeight(container->height());

    connect(container, &QQuickItem::widthChanged, m_rootItem, [this, container]() {
        if (m_rootItem)
            m_rootItem->setWidth(container->width());
    });
    connect(container, &QQuickItem::heightChanged, m_rootItem, [this, container]() {
        if (m_rootItem)
            m_rootItem->setHeight(container->height());
    });

    m_rootItem->setVisible(true);
    m_app->setLifecycle(SquaredApp::Lifecycle::Active);

    setState(State::Running);
    emit resumed();
}

void AppRunner::close()
{
    if (m_state == State::Idle)
        return;

    cleanup();
    setState(State::Idle);
    emit closed();
}

AppRunner::State AppRunner::state() const
{
    return m_state;
}

void AppRunner::setState(State newState)
{
    if (m_state != newState) {
        m_state = newState;
        emit stateChanged();
    }
}

void AppRunner::cleanup()
{
    if (!m_addedImportPath.isEmpty()) {
        auto paths = m_engine->importPathList();
        paths.removeAll(m_addedImportPath);
        m_engine->setImportPathList(paths);
        m_addedImportPath.clear();
    }

    delete m_rootItem;
    m_rootItem = nullptr;

    delete m_storage;
    m_storage = nullptr;

    delete m_secureStorage;
    m_secureStorage = nullptr;

    delete m_app;
    m_app = nullptr;

    delete m_network;
    m_network = nullptr;

    delete m_appContext;
    m_appContext = nullptr;

    m_currentAppId.clear();
}
