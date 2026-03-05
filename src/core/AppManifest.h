#pragma once

#include <QString>
#include <QStringList>
#include <QJsonObject>
#include <optional>

struct AppManifest {
    QString id;
    QString name;
    QString version;
    QString entry;
    QString icon;
    QString author;
    QString description;
    QString basePath;
    QStringList permissions;

    bool hasPermission(const QString &perm) const;

    static std::optional<AppManifest> fromDirectory(const QString &dirPath);
    static std::optional<AppManifest> fromJson(const QJsonObject &json, const QString &basePath);
};
