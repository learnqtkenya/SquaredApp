#include "AppCatalog.h"

#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QStandardPaths>

AppCatalog::AppCatalog(const QUrl &catalogUrl, QObject *parent)
    : QObject(parent), m_catalogUrl(catalogUrl)
{
    auto cacheDir = QStandardPaths::writableLocation(
        QStandardPaths::CacheLocation) + QStringLiteral("/squared");
    QDir().mkpath(cacheDir);
    m_cachePath = cacheDir + QStringLiteral("/catalog.json");

    // Load cached ETag if cache file exists
    QFile etagFile(m_cachePath + QStringLiteral(".etag"));
    if (etagFile.open(QIODevice::ReadOnly))
        m_cachedETag = QString::fromUtf8(etagFile.readAll()).trimmed();
}

QVariantList AppCatalog::entries() const
{
    QVariantList list;
    for (const auto &e : m_entries) {
        QVariantMap map;
        map[QStringLiteral("id")] = e.id;
        map[QStringLiteral("name")] = e.name;
        map[QStringLiteral("version")] = e.version;
        map[QStringLiteral("author")] = e.author;
        map[QStringLiteral("description")] = e.description;
        map[QStringLiteral("iconUrl")] = e.iconUrl;
        map[QStringLiteral("packageUrl")] = e.packageUrl;
        map[QStringLiteral("sizeBytes")] = e.sizeBytes;
        map[QStringLiteral("category")] = e.category;
        map[QStringLiteral("icon")] = e.icon;
        map[QStringLiteral("color")] = e.color;
        map[QStringLiteral("permissions")] = QVariant::fromValue(e.permissions);
        list.append(map);
    }
    return list;
}

bool AppCatalog::loading() const
{
    return m_loading;
}

QString AppCatalog::errorMessage() const
{
    return m_errorMessage;
}

void AppCatalog::setEntries(const QList<CatalogEntry> &entries)
{
    m_entries = entries;
    emit entriesChanged();
    emit catalogReady(entries);
}

void AppCatalog::fetch()
{
    m_loading = true;
    m_errorMessage.clear();
    emit loadingChanged();
    emit errorMessageChanged();

    QNetworkRequest request(m_catalogUrl);
    if (!m_cachedETag.isEmpty())
        request.setRawHeader("If-None-Match", m_cachedETag.toUtf8());

    auto *reply = m_nam.get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();

        if (reply->error() != QNetworkReply::NoError) {
            // Try to use cached data on network error
            QFile cache(m_cachePath);
            if (cache.open(QIODevice::ReadOnly)) {
                setEntries(parseJson(cache.readAll()));
            } else {
                m_errorMessage = reply->errorString();
                emit errorMessageChanged();
                emit fetchError(m_errorMessage);
            }
            m_loading = false;
            emit loadingChanged();
            return;
        }

        auto statusCode = reply->attribute(
            QNetworkRequest::HttpStatusCodeAttribute).toInt();

        if (statusCode == 304) {
            // Not Modified — use cached data
            QFile cache(m_cachePath);
            if (cache.open(QIODevice::ReadOnly)) {
                setEntries(parseJson(cache.readAll()));
            } else {
                m_errorMessage = QStringLiteral("Cache read failed after 304");
                emit errorMessageChanged();
                emit fetchError(m_errorMessage);
            }
            m_loading = false;
            emit loadingChanged();
            return;
        }

        auto data = reply->readAll();

        // Save to cache
        QFile cache(m_cachePath);
        if (cache.open(QIODevice::WriteOnly))
            cache.write(data);

        // Save ETag
        auto etag = reply->rawHeader("ETag");
        if (!etag.isEmpty()) {
            m_cachedETag = QString::fromUtf8(etag);
            QFile etagFile(m_cachePath + QStringLiteral(".etag"));
            if (etagFile.open(QIODevice::WriteOnly))
                etagFile.write(etag);
        }

        setEntries(parseJson(data));
        m_loading = false;
        emit loadingChanged();
    });
}

QList<CatalogEntry> AppCatalog::parseJson(const QByteArray &data)
{
    QList<CatalogEntry> result;

    auto doc = QJsonDocument::fromJson(data);
    if (!doc.isObject())
        return result;

    auto apps = doc.object().value(QStringLiteral("apps")).toArray();
    for (const auto &val : apps) {
        auto obj = val.toObject();
        CatalogEntry entry;
        entry.id = obj.value(QStringLiteral("id")).toString();
        entry.name = obj.value(QStringLiteral("name")).toString();
        entry.version = obj.value(QStringLiteral("version")).toString();
        entry.author = obj.value(QStringLiteral("author")).toString();
        entry.description = obj.value(QStringLiteral("description")).toString();
        entry.iconUrl = QUrl(obj.value(QStringLiteral("iconUrl")).toString());
        entry.packageUrl = QUrl(obj.value(QStringLiteral("packageUrl")).toString());
        entry.sizeBytes = obj.value(QStringLiteral("sizeBytes")).toInteger();
        entry.category = obj.value(QStringLiteral("category")).toString();
        entry.icon = obj.value(QStringLiteral("icon")).toString();
        entry.color = obj.value(QStringLiteral("color")).toString();

        auto permsArr = obj.value(QStringLiteral("permissions")).toArray();
        for (const auto &p : permsArr)
            entry.permissions.append(p.toString());

        if (!entry.id.isEmpty() && !entry.name.isEmpty())
            result.append(entry);
    }
    return result;
}
