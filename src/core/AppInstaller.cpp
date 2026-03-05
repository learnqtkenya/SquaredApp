#include "AppInstaller.h"
#include "AppManifest.h"
#include "SecureStorage.h"

#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QTemporaryDir>

#include <private/qzipreader_p.h>

AppInstaller::AppInstaller(QObject *parent)
    : QObject(parent)
{
}

std::expected<AppManifest, QString> AppInstaller::install(
    const QString &sqappPath, const QString &installDir)
{
    if (!QFile::exists(sqappPath))
        return std::unexpected(QStringLiteral("Package file not found: ") + sqappPath);

    // Extract ZIP to temp directory
    QTemporaryDir tempDir;
    if (!tempDir.isValid())
        return std::unexpected(QStringLiteral("Failed to create temp directory"));

    if (!extractZip(sqappPath, tempDir.path()))
        return std::unexpected(QStringLiteral("Failed to extract package (corrupt or invalid ZIP)"));

    // Parse and validate manifest
    auto manifest = AppManifest::fromDirectory(tempDir.path());
    if (!manifest)
        return std::unexpected(QStringLiteral("Invalid or missing manifest.json in package"));

    // Prepare install destination
    auto destPath = installDir + u'/' + manifest->id;

    // Remove old installation if exists
    QDir destDir(destPath);
    if (destDir.exists())
        destDir.removeRecursively();

    // Copy extracted contents to install directory
    QDir().mkpath(installDir);
    if (!copyDirectory(tempDir.path(), destPath))
        return std::unexpected(QStringLiteral("Failed to copy files to install directory"));

    // Update basePath to final location
    manifest->basePath = destPath;
    return *manifest;
}

bool AppInstaller::uninstall(const QString &appId, const QString &installDir,
                             const QString &storageRoot)
{
    SecureStorage::removeAllForApp(appId, storageRoot);

    bool result = true;

    QDir appDir(installDir + u'/' + appId);
    if (appDir.exists())
        result = appDir.removeRecursively();

    QDir dataDir(storageRoot + u'/' + appId);
    if (dataDir.exists())
        result = dataDir.removeRecursively() && result;

    return result;
}

bool AppInstaller::isInstalled(const QString &appId, const QString &installDir) const
{
    auto dirPath = installDir + u'/' + appId;
    return AppManifest::fromDirectory(dirPath).has_value();
}

QList<AppManifest> AppInstaller::installedApps(const QString &installDir) const
{
    QList<AppManifest> result;
    QDir dir(installDir);
    if (!dir.exists())
        return result;

    const auto entries = dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const auto &entry : entries) {
        auto manifest = AppManifest::fromDirectory(dir.absoluteFilePath(entry));
        if (manifest)
            result.append(*manifest);
    }
    return result;
}

bool AppInstaller::extractZip(const QString &zipPath, const QString &destDir)
{
    QZipReader reader(zipPath);
    if (reader.status() != QZipReader::NoError)
        return false;

    return reader.extractAll(destDir);
}

bool AppInstaller::copyDirectory(const QString &src, const QString &dst)
{
    QDir srcDir(src);
    if (!srcDir.exists())
        return false;

    QDir().mkpath(dst);

    QDirIterator it(src, QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot,
                    QDirIterator::Subdirectories);

    while (it.hasNext()) {
        it.next();
        auto relativePath = srcDir.relativeFilePath(it.filePath());
        auto destPath = dst + u'/' + relativePath;

        if (it.fileInfo().isDir()) {
            QDir().mkpath(destPath);
        } else {
            QDir().mkpath(QFileInfo(destPath).absolutePath());
            if (!QFile::copy(it.filePath(), destPath))
                return false;
        }
    }
    return true;
}
