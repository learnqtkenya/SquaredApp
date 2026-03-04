#include "AppStorage.h"

#include <QDataStream>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSaveFile>

AppStorage::AppStorage(const QString &appId, const QString &storageRoot,
                       QObject *parent)
    : QObject(parent), m_appId(appId), m_storageRoot(storageRoot)
{
    load();
}

void AppStorage::set(const QString &key, const QVariant &value)
{
    m_data[key] = normalize(value);
    save();
    emit changed(key);
}

QVariant AppStorage::get(const QString &key, const QVariant &fallback) const
{
    return m_data.value(key, fallback);
}

void AppStorage::remove(const QString &key)
{
    m_data.remove(key);
    save();
    emit changed(key);
}

bool AppStorage::has(const QString &key) const
{
    return m_data.contains(key);
}

void AppStorage::clear()
{
    m_data.clear();
    save();
    emit changed(QString());
}

QVariant AppStorage::normalize(const QVariant &v)
{
    if (!v.isValid() || v.isNull())
        return QVariant();

    switch (v.typeId()) {
    case QMetaType::Bool:
    case QMetaType::Int:
    case QMetaType::LongLong:
    case QMetaType::Double:
    case QMetaType::Float:
    case QMetaType::QString:
        return v;

    case QMetaType::QVariantList: {
        QVariantList result;
        const auto list = v.toList();
        result.reserve(list.size());
        for (const auto &item : list)
            result.append(normalize(item));
        return result;
    }

    case QMetaType::QVariantMap: {
        QVariantMap result;
        const auto map = v.toMap();
        for (auto it = map.cbegin(); it != map.cend(); ++it)
            result.insert(it.key(), normalize(it.value()));
        return result;
    }

    default:
        // QML JS types (QJSValue): convert to list or map
        if (v.canConvert<QVariantList>()) {
            QVariantList result;
            const auto list = v.value<QVariantList>();
            result.reserve(list.size());
            for (const auto &item : list)
                result.append(normalize(item));
            return result;
        }
        if (v.canConvert<QVariantMap>()) {
            QVariantMap result;
            const auto map = v.value<QVariantMap>();
            for (auto it = map.cbegin(); it != map.cend(); ++it)
                result.insert(it.key(), normalize(it.value()));
            return result;
        }
        return v.toString();
    }
}

void AppStorage::save()
{
    ensureDirectory();

    QSaveFile file(storagePath());
    if (!file.open(QIODevice::WriteOnly))
        return;

    QDataStream out(&file);
    out.setVersion(QDataStream::Qt_6_0);
    out << MAGIC << VERSION << m_data;

    if (out.status() != QDataStream::Ok) {
        file.cancelWriting();
        return;
    }

    file.commit();
}

void AppStorage::load()
{
    QFile file(storagePath());
    if (!file.open(QIODevice::ReadOnly))
        return;

    QDataStream in(&file);
    in.setVersion(QDataStream::Qt_6_0);

    quint32 magic = 0, version = 0;
    in >> magic >> version;

    if (magic != MAGIC || version != VERSION) {
        qWarning("AppStorage: invalid file format for %s, starting fresh",
                 qPrintable(m_appId));
        return;
    }

    QVariantMap data;
    in >> data;

    if (in.status() == QDataStream::Ok)
        m_data = data;
}

QString AppStorage::storagePath() const
{
    return m_storageRoot + u'/' + m_appId + QStringLiteral("/storage.dat");
}

void AppStorage::ensureDirectory()
{
    auto dir = QFileInfo(storagePath()).absolutePath();
    QDir().mkpath(dir);
}
