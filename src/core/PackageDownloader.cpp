#include "PackageDownloader.h"
#include "AppInstaller.h"
#include "AppManifest.h"
#include "../sdk/storage/SecureStorage.h"
#include "../sdk/storage/SecureStorageReply.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QTemporaryFile>

PackageDownloader::PackageDownloader(AppInstaller *installer,
                                     const QUrl &storeBaseUrl,
                                     const QString &storageRoot,
                                     QObject *parent)
    : QObject(parent), m_installer(installer),
      m_storeBaseUrl(storeBaseUrl), m_storageRoot(storageRoot)
{
    m_nam.setRedirectPolicy(QNetworkRequest::NoLessSafeRedirectPolicy);
}

void PackageDownloader::download(const QString &appId, const QUrl &packageUrl,
                                 const QString &installDir)
{
    QNetworkRequest request(packageUrl);
    auto *reply = m_nam.get(request);

    connect(reply, &QNetworkReply::downloadProgress, this,
            [this, appId](qint64 received, qint64 total) {
                emit progress(appId, received, total);
            });

    connect(reply, &QNetworkReply::finished, this,
            [this, reply, appId, installDir]() {
                reply->deleteLater();

                if (reply->error() != QNetworkReply::NoError) {
                    emit error(appId, reply->errorString());
                    return;
                }

                // Write to temp file
                QTemporaryFile tempFile;
                tempFile.setAutoRemove(false);
                if (!tempFile.open()) {
                    emit error(appId, QStringLiteral("Failed to create temp file"));
                    return;
                }

                tempFile.write(reply->readAll());
                tempFile.close();

                auto result = m_installer->install(tempFile.fileName(), installDir);
                QFile::remove(tempFile.fileName());

                if (result)
                    provisionSecrets(appId);
                else
                    emit error(appId, result.error());
            });
}

void PackageDownloader::provisionSecrets(const QString &appId)
{
    auto baseStr = m_storeBaseUrl.toString();
    if (!baseStr.endsWith(QLatin1Char('/')))
        baseStr.append(QLatin1Char('/'));
    auto url = QUrl(baseStr + QStringLiteral("api/apps/%1/secrets").arg(appId));

    auto *reply = m_nam.get(QNetworkRequest(url));

    connect(reply, &QNetworkReply::finished, this,
            [this, reply, appId]() {
                reply->deleteLater();

                if (reply->error() != QNetworkReply::NoError) {
                    // Secrets are best-effort — still emit installed
                    emit installed(appId);
                    return;
                }

                auto doc = QJsonDocument::fromJson(reply->readAll());
                auto secrets = doc.object().value(QStringLiteral("secrets")).toArray();

                if (secrets.isEmpty()) {
                    emit installed(appId);
                    return;
                }

                auto *storage = new SecureStorage(appId, m_storageRoot, false, nullptr, this);
                int *remaining = new int(secrets.size());

                auto finish = [this, appId, storage, remaining]() {
                    if (--(*remaining) <= 0) {
                        delete remaining;
                        storage->deleteLater();
                        emit installed(appId);
                    }
                };

                for (const auto &s : secrets) {
                    auto obj = s.toObject();
                    auto *setReply = storage->set(
                        obj.value(QStringLiteral("key")).toString(),
                        obj.value(QStringLiteral("value")).toString());
                    connect(setReply, &SecureStorageReply::succeeded, this,
                            [finish](const QString &) { finish(); });
                    connect(setReply, &SecureStorageReply::failed, this,
                            [finish](const QString &) { finish(); });
                }
            });
}
