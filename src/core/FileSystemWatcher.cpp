#include "FileSystemWatcher.h"

#include <QDir>
#include <QDirIterator>
#include <QFileInfo>

FileSystemWatcher::FileSystemWatcher(QObject *parent)
    : QObject(parent)
{
    connect(&m_watcher, &QFileSystemWatcher::fileChanged,
            this, &FileSystemWatcher::onFileChanged);
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged,
            this, &FileSystemWatcher::onDirectoryChanged);
}

void FileSystemWatcher::addDirectory(const QString &path)
{
    QFileInfo info(path);
    if (!info.isDir())
        return;
    scanDirectory(info.absoluteFilePath());
}

void FileSystemWatcher::scanDirectory(const QString &dirPath)
{
    if (m_watchedDirs.contains(dirPath))
        return;

    m_watchedDirs.insert(dirPath);
    m_watcher.addPath(dirPath);

    QDirIterator it(dirPath, QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot,
                    QDirIterator::Subdirectories);
    while (it.hasNext()) {
        it.next();
        const QFileInfo fi = it.fileInfo();
        if (fi.isDir()) {
            if (!m_watchedDirs.contains(fi.absoluteFilePath())) {
                m_watchedDirs.insert(fi.absoluteFilePath());
                m_watcher.addPath(fi.absoluteFilePath());
            }
        } else {
            addFileIfWatchable(fi.absoluteFilePath());
        }
    }
}

void FileSystemWatcher::addFileIfWatchable(const QString &filePath)
{
    if (!isWatchable(filePath) || m_watchedFiles.contains(filePath))
        return;
    m_watchedFiles.insert(filePath);
    m_watcher.addPath(filePath);
}

bool FileSystemWatcher::isWatchable(const QString &path)
{
    return path.endsWith(QLatin1String(".qml"), Qt::CaseInsensitive)
        || path.endsWith(QLatin1String(".js"), Qt::CaseInsensitive);
}

void FileSystemWatcher::onFileChanged(const QString &path)
{
    // Qt removes the watch after notifying on some platforms — re-add it
    if (QFileInfo::exists(path))
        m_watcher.addPath(path);
    else
        m_watchedFiles.remove(path);

    if (isWatchable(path))
        emit fileChanged(path);
}

void FileSystemWatcher::onDirectoryChanged(const QString &dirPath)
{
    // Pick up new QML/JS files
    QDirIterator it(dirPath, QDir::Files | QDir::NoDotAndDotDot);
    while (it.hasNext()) {
        it.next();
        addFileIfWatchable(it.fileInfo().absoluteFilePath());
    }

    // Pick up new subdirectories
    QDirIterator dirIt(dirPath, QDir::Dirs | QDir::NoDotAndDotDot);
    while (dirIt.hasNext()) {
        dirIt.next();
        const QString subDir = dirIt.fileInfo().absoluteFilePath();
        if (!m_watchedDirs.contains(subDir))
            scanDirectory(subDir);
    }

    // Emit a change signal so the debounce timer picks it up (new file = likely needs reload)
    emit fileChanged(dirPath);
}
