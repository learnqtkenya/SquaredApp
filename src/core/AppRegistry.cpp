#include "AppRegistry.h"

#include <QDataStream>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSaveFile>

// --- AppEntry serialization ---

QDataStream &operator<<(QDataStream &out, const AppEntry &e)
{
    out << e.id << e.name << e.version << e.icon << e.color
        << e.author << e.description << e.dirName
        << e.installDate << e.lastLaunched << e.launchCount;
    return out;
}

QDataStream &operator>>(QDataStream &in, AppEntry &e)
{
    in >> e.id >> e.name >> e.version >> e.icon >> e.color
       >> e.author >> e.description >> e.dirName
       >> e.installDate >> e.lastLaunched >> e.launchCount;
    return in;
}

// --- InstalledAppsModel ---

InstalledAppsModel::InstalledAppsModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int InstalledAppsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !m_entries)
        return 0;
    return m_entries->size();
}

QVariant InstalledAppsModel::data(const QModelIndex &index, int role) const
{
    if (!m_entries || !index.isValid() || index.row() >= m_entries->size())
        return {};

    const auto &e = m_entries->at(index.row());
    switch (role) {
    case AppIdRole:          return e.id;
    case AppNameRole:        return e.name;
    case AppVersionRole:     return e.version;
    case AppIconRole:        return e.icon;
    case AppColorRole:       return e.color;
    case AppDirNameRole:     return e.dirName;
    case AppAuthorRole:      return e.author;
    case AppDescriptionRole: return e.description;
    default:                 return {};
    }
}

QHash<int, QByteArray> InstalledAppsModel::roleNames() const
{
    return {
        { AppIdRole,          "appId" },
        { AppNameRole,        "appName" },
        { AppVersionRole,     "appVersion" },
        { AppIconRole,        "appIcon" },
        { AppColorRole,       "appColor" },
        { AppDirNameRole,     "appDirName" },
        { AppAuthorRole,      "appAuthor" },
        { AppDescriptionRole, "appDescription" },
    };
}

// --- AppRegistry ---

AppRegistry::AppRegistry(const QString &registryPath, QObject *parent)
    : QObject(parent), m_path(registryPath)
{
    load();
}

void AppRegistry::addApp(const AppEntry &entry)
{
    auto idx = indexOf(entry.id);
    if (idx >= 0) {
        m_entries[idx] = entry;
        if (m_model) {
            auto mi = m_model->index(idx);
            emit m_model->dataChanged(mi, mi);
        }
    } else {
        if (m_model)
            m_model->beginInsertRows({}, m_entries.size(), m_entries.size());
        m_entries.append(entry);
        if (m_model)
            m_model->endInsertRows();
    }
    save();
    emit appAdded(entry.id);
}

void AppRegistry::removeApp(const QString &appId)
{
    auto idx = indexOf(appId);
    if (idx < 0)
        return;

    if (m_model)
        m_model->beginRemoveRows({}, idx, idx);
    m_entries.removeAt(idx);
    if (m_model)
        m_model->endRemoveRows();

    save();
    emit appRemoved(appId);
}

std::optional<AppEntry> AppRegistry::findApp(const QString &appId) const
{
    auto idx = indexOf(appId);
    if (idx < 0)
        return std::nullopt;
    return m_entries.at(idx);
}

QList<AppEntry> AppRegistry::allApps() const
{
    return m_entries;
}

void AppRegistry::updateLaunchStats(const QString &appId)
{
    auto idx = indexOf(appId);
    if (idx < 0)
        return;

    m_entries[idx].lastLaunched = QDateTime::currentDateTime();
    m_entries[idx].launchCount++;
    save();

    if (m_model) {
        auto mi = m_model->index(idx);
        emit m_model->dataChanged(mi, mi);
    }
}

InstalledAppsModel *AppRegistry::model()
{
    if (!m_model) {
        m_model = new InstalledAppsModel(this);
        m_model->m_entries = &m_entries;
    }
    return m_model;
}

bool AppRegistry::isInstalled(const QString &appId) const
{
    return indexOf(appId) >= 0;
}

int AppRegistry::indexOf(const QString &appId) const
{
    for (int i = 0; i < m_entries.size(); ++i) {
        if (m_entries[i].id == appId)
            return i;
    }
    return -1;
}

void AppRegistry::save()
{
    ensureDirectory();

    QSaveFile file(m_path);
    if (!file.open(QIODevice::WriteOnly))
        return;

    QDataStream out(&file);
    out.setVersion(QDataStream::Qt_6_0);
    out << MAGIC << VERSION << m_entries;

    if (out.status() != QDataStream::Ok) {
        file.cancelWriting();
        return;
    }

    file.commit();
}

void AppRegistry::load()
{
    QFile file(m_path);
    if (!file.open(QIODevice::ReadOnly))
        return;

    QDataStream in(&file);
    in.setVersion(QDataStream::Qt_6_0);

    quint32 magic = 0, version = 0;
    in >> magic >> version;

    if (magic != MAGIC || version != VERSION) {
        qWarning("AppRegistry: invalid file format, starting fresh");
        return;
    }

    QList<AppEntry> entries;
    in >> entries;

    if (in.status() == QDataStream::Ok)
        m_entries = entries;
}

void AppRegistry::ensureDirectory()
{
    auto dir = QFileInfo(m_path).absolutePath();
    QDir().mkpath(dir);
}
