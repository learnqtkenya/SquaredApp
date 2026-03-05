#include "AppManifest.h"

#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>

std::optional<AppManifest> AppManifest::fromDirectory(const QString &dirPath)
{
    QFile file(dirPath + QStringLiteral("/manifest.json"));
    if (!file.open(QIODevice::ReadOnly))
        return std::nullopt;

    QJsonParseError parseError;
    auto doc = QJsonDocument::fromJson(file.readAll(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject())
        return std::nullopt;

    return fromJson(doc.object(), dirPath);
}

std::optional<AppManifest> AppManifest::fromJson(const QJsonObject &json, const QString &basePath)
{
    auto id = json[u"id"].toString();
    auto name = json[u"name"].toString();
    auto version = json[u"version"].toString();

    if (id.isEmpty() || name.isEmpty() || version.isEmpty())
        return std::nullopt;

    if (!id.contains(u'.'))
        return std::nullopt;

    AppManifest m;
    m.id = id;
    m.name = name;
    m.version = version;
    m.entry = json[u"entry"].toString(QStringLiteral("Main.qml"));
    m.icon = json[u"icon"].toString();
    m.author = json[u"author"].toString();
    m.description = json[u"description"].toString();
    m.basePath = basePath;

    auto permsArray = json[u"permissions"].toArray();
    for (const auto &p : permsArray)
        m.permissions.append(p.toString());

    return m;
}

bool AppManifest::hasPermission(const QString &perm) const
{
    return permissions.contains(perm);
}
