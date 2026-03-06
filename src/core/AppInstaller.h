#pragma once

#include <QObject>
#include <expected>

struct AppManifest;

class AppInstaller : public QObject {
    Q_OBJECT

public:
    explicit AppInstaller(QObject *parent = nullptr);

    std::expected<AppManifest, QString> install(const QString &sqappPath,
                                                const QString &installDir);
    Q_INVOKABLE bool uninstall(const QString &appId, const QString &installDir,
                               const QString &storageRoot);
    bool isInstalled(const QString &appId, const QString &installDir) const;
    QList<AppManifest> installedApps(const QString &installDir) const;

private:
    static bool extractZip(const QString &zipPath, const QString &destDir);
    static bool copyDirectory(const QString &src, const QString &dst);
};
