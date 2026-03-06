#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QObject>

#include <optional>

struct AppEntry {
    QString id;
    QString name;
    QString version;
    QString icon;
    QString color;
    QString author;
    QString description;
    QString dirName;
    QDateTime installDate;
    QDateTime lastLaunched;
    int launchCount = 0;
};

QDataStream &operator<<(QDataStream &out, const AppEntry &e);
QDataStream &operator>>(QDataStream &in, AppEntry &e);

class InstalledAppsModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum Roles {
        AppIdRole = Qt::UserRole + 1,
        AppNameRole,
        AppVersionRole,
        AppIconRole,
        AppColorRole,
        AppDirNameRole,
        AppAuthorRole,
        AppDescriptionRole,
    };

    explicit InstalledAppsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    friend class AppRegistry;
    QList<AppEntry> *m_entries = nullptr;
};

class AppRegistry : public QObject {
    Q_OBJECT

public:
    explicit AppRegistry(const QString &registryPath, QObject *parent = nullptr);

    void addApp(const AppEntry &entry);
    Q_INVOKABLE void removeApp(const QString &appId);
    std::optional<AppEntry> findApp(const QString &appId) const;
    QList<AppEntry> allApps() const;
    void updateLaunchStats(const QString &appId);

    Q_INVOKABLE bool isInstalled(const QString &appId) const;
    Q_INVOKABLE QString appName(const QString &dirName) const;

    InstalledAppsModel *model();

signals:
    void appAdded(const QString &appId);
    void appRemoved(const QString &appId);

private:
    void save();
    void load();
    void ensureDirectory();

    int indexOf(const QString &appId) const;

    static constexpr quint32 MAGIC = 0x53515245;   // "SQRE"
    static constexpr quint32 VERSION = 1;

    QString m_path;
    QList<AppEntry> m_entries;
    InstalledAppsModel *m_model = nullptr;
};
