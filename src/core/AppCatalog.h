#pragma once

#include <QNetworkAccessManager>
#include <QObject>
#include <QUrl>
#include <QVariantList>

struct CatalogEntry {
    QString id;
    QString name;
    QString version;
    QString author;
    QString description;
    QUrl iconUrl;
    QUrl packageUrl;
    qint64 sizeBytes = 0;
    QString category;
    QStringList permissions;
};

class AppCatalog : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantList entries READ entries NOTIFY entriesChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    explicit AppCatalog(const QUrl &catalogUrl, QObject *parent = nullptr);

    Q_INVOKABLE void fetch();

    QVariantList entries() const;
    bool loading() const;
    QString errorMessage() const;

    static QList<CatalogEntry> parseJson(const QByteArray &data);

signals:
    void catalogReady(const QList<CatalogEntry> &entries);
    void fetchError(const QString &message);
    void entriesChanged();
    void loadingChanged();
    void errorMessageChanged();

private:
    void setEntries(const QList<CatalogEntry> &entries);

    QUrl m_catalogUrl;
    QNetworkAccessManager m_nam;
    QString m_cachedETag;
    QString m_cachePath;
    QList<CatalogEntry> m_entries;
    bool m_loading = false;
    QString m_errorMessage;
};
