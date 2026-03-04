#pragma once

#include <QString>
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

    static std::optional<AppManifest> fromDirectory(const QString &dirPath);
    static std::optional<AppManifest> fromJson(const QJsonObject &json, const QString &basePath);
};
