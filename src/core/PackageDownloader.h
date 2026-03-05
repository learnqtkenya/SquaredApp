#pragma once

#include <QNetworkAccessManager>
#include <QObject>
#include <QUrl>

struct AppManifest;
class AppInstaller;

class PackageDownloader : public QObject {
    Q_OBJECT

public:
    explicit PackageDownloader(AppInstaller *installer,
                               const QUrl &storeBaseUrl,
                               const QString &storageRoot,
                               QObject *parent = nullptr);

    Q_INVOKABLE void download(const QString &appId, const QUrl &packageUrl,
                              const QString &installDir);

signals:
    void progress(const QString &appId, qint64 bytesReceived, qint64 bytesTotal);
    void installed(const QString &appId);
    void error(const QString &appId, const QString &message);

private:
    void provisionSecrets(const QString &appId);

    QNetworkAccessManager m_nam;
    AppInstaller *m_installer;
    QUrl m_storeBaseUrl;
    QString m_storageRoot;
};
