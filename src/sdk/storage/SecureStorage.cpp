#include "SecureStorage.h"
#include "SecureStorageReply.h"

#include <QDir>
#include <QEventLoop>
#include <QFile>
#include <QSaveFile>
#include <QTimer>

#include <qtkeychain/keychain.h>

static const QString kServiceName = QStringLiteral("squared");

SecureStorage::SecureStorage(const QString &appId, const QString &storageRoot,
                             bool insecureFallback, QJSEngine *engine,
                             QObject *parent)
    : QObject(parent)
    , m_appId(appId)
    , m_storageRoot(storageRoot)
    , m_insecureFallback(insecureFallback)
    , m_engine(engine)
{
    loadTrackedKeys();
}

QString SecureStorage::fullKey(const QString &key) const
{
    return m_appId + u'/' + key;
}

QString SecureStorage::insecureValuePath(const QString &key) const
{
    return m_storageRoot + u'/' + m_appId + QStringLiteral("/secrets/") + key;
}

SecureStorageReply *SecureStorage::set(const QString &key, const QString &value)
{
    auto *reply = new SecureStorageReply(m_engine, this);

    if (m_insecureFallback) {
        auto path = insecureValuePath(key);
        QDir().mkpath(QFileInfo(path).absolutePath());
        QSaveFile file(path);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(value.toUtf8());
            file.commit();
            trackKey(key);
            QTimer::singleShot(0, this, [reply]() { reply->resolve(); });
        } else {
            auto err = file.errorString();
            QTimer::singleShot(0, this, [reply, err]() { reply->reject(err); });
        }
        return reply;
    }

    auto *job = new QKeychain::WritePasswordJob(kServiceName, this);
    job->setAutoDelete(true);
    job->setInsecureFallback(false);
    job->setKey(fullKey(key));
    job->setTextData(value);

    connect(job, &QKeychain::Job::finished, this, [this, key, reply](QKeychain::Job *j) {
        if (j->error() == QKeychain::NoError) {
            trackKey(key);
            reply->resolve();
        } else {
            reply->reject(j->errorString());
        }
    });

    job->start();
    return reply;
}

SecureStorageReply *SecureStorage::get(const QString &key)
{
    auto *reply = new SecureStorageReply(m_engine, this);

    if (m_insecureFallback) {
        QFile file(insecureValuePath(key));
        if (file.open(QIODevice::ReadOnly)) {
            auto data = QString::fromUtf8(file.readAll());
            QTimer::singleShot(0, this, [reply, data]() { reply->resolve(data); });
        } else {
            // Key not found — resolve with empty (non-null) string
            QTimer::singleShot(0, this, [reply]() {
                reply->resolve(QString(QLatin1StringView("")));
            });
        }
        return reply;
    }

    auto *job = new QKeychain::ReadPasswordJob(kServiceName, this);
    job->setAutoDelete(true);
    job->setInsecureFallback(false);
    job->setKey(fullKey(key));

    connect(job, &QKeychain::Job::finished, this, [reply](QKeychain::Job *j) {
        if (j->error() == QKeychain::NoError) {
            auto *readJob = qobject_cast<QKeychain::ReadPasswordJob *>(j);
            reply->resolve(readJob->textData());
        } else if (j->error() == QKeychain::EntryNotFound) {
            reply->resolve(QString(QLatin1StringView("")));
        } else {
            reply->reject(j->errorString());
        }
    });

    job->start();
    return reply;
}

SecureStorageReply *SecureStorage::remove(const QString &key)
{
    auto *reply = new SecureStorageReply(m_engine, this);

    if (m_insecureFallback) {
        QFile::remove(insecureValuePath(key));
        untrackKey(key);
        QTimer::singleShot(0, this, [reply]() { reply->resolve(); });
        return reply;
    }

    auto *job = new QKeychain::DeletePasswordJob(kServiceName, this);
    job->setAutoDelete(true);
    job->setInsecureFallback(false);
    job->setKey(fullKey(key));

    connect(job, &QKeychain::Job::finished, this, [this, key, reply](QKeychain::Job *j) {
        if (j->error() == QKeychain::NoError
            || j->error() == QKeychain::EntryNotFound) {
            untrackKey(key);
            reply->resolve();
        } else {
            reply->reject(j->errorString());
        }
    });

    job->start();
    return reply;
}

void SecureStorage::removeAllForApp(const QString &appId, const QString &storageRoot,
                                    bool insecureFallback)
{
    auto path = storageRoot + u'/' + appId + QStringLiteral("/keychain_keys");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return;

    auto keys = QString::fromUtf8(file.readAll()).split(u'\n', Qt::SkipEmptyParts);
    file.close();

    if (insecureFallback) {
        // Direct file removal for insecure mode
        auto secretsDir = storageRoot + u'/' + appId + QStringLiteral("/secrets");
        for (const auto &key : keys)
            QFile::remove(secretsDir + u'/' + key);
        QDir(secretsDir).removeRecursively();
        return;
    }

    if (keys.isEmpty())
        return;

    int pending = keys.size();
    QEventLoop loop;

    for (const auto &key : keys) {
        auto *job = new QKeychain::DeletePasswordJob(kServiceName);
        job->setAutoDelete(true);
        job->setInsecureFallback(false);
        job->setKey(appId + u'/' + key);
        QObject::connect(job, &QKeychain::Job::finished, [&pending, &loop](QKeychain::Job *) {
            if (--pending == 0)
                loop.quit();
        });
        job->start();
    }

    QTimer::singleShot(10000, &loop, &QEventLoop::quit);
    loop.exec();
}

void SecureStorage::trackKey(const QString &key)
{
    if (!m_trackedKeys.contains(key)) {
        m_trackedKeys.append(key);
        saveTrackedKeys();
    }
}

void SecureStorage::untrackKey(const QString &key)
{
    if (m_trackedKeys.removeAll(key) > 0)
        saveTrackedKeys();
}

void SecureStorage::loadTrackedKeys()
{
    QFile file(trackedKeysPath());
    if (!file.open(QIODevice::ReadOnly))
        return;

    m_trackedKeys = QString::fromUtf8(file.readAll()).split(u'\n', Qt::SkipEmptyParts);
}

void SecureStorage::saveTrackedKeys()
{
    auto path = trackedKeysPath();
    QDir().mkpath(QFileInfo(path).absolutePath());

    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly))
        return;

    file.write(m_trackedKeys.join(u'\n').toUtf8());
    file.commit();
}

QString SecureStorage::trackedKeysPath() const
{
    return m_storageRoot + u'/' + m_appId + QStringLiteral("/keychain_keys");
}
