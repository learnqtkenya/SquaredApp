#pragma once

#include <QFileSystemWatcher>
#include <QObject>
#include <QSet>
#include <QString>

class FileSystemWatcher : public QObject
{
    Q_OBJECT

public:
    explicit FileSystemWatcher(QObject *parent = nullptr);

    void addDirectory(const QString &path);

signals:
    void fileChanged(const QString &path);

private slots:
    void onFileChanged(const QString &path);
    void onDirectoryChanged(const QString &path);

private:
    void scanDirectory(const QString &dirPath);
    void addFileIfWatchable(const QString &filePath);
    static bool isWatchable(const QString &path);

    QFileSystemWatcher m_watcher;
    QSet<QString> m_watchedFiles;
    QSet<QString> m_watchedDirs;
};
