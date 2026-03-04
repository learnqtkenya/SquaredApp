#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class SquaredApp : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString appId READ appId CONSTANT)
    Q_PROPERTY(QString appVersion READ appVersion CONSTANT)
    Q_PROPERTY(QString hostVersion READ hostVersion CONSTANT)
    Q_PROPERTY(Lifecycle lifecycle READ lifecycle NOTIFY lifecycleChanged)

public:
    enum class Lifecycle { Active, Inactive, Suspended };
    Q_ENUM(Lifecycle)

    explicit SquaredApp(const QString &appId, const QString &appVersion,
                        QObject *parent = nullptr);

    QString appId() const;
    QString appVersion() const;
    QString hostVersion() const;
    Lifecycle lifecycle() const;
    void setLifecycle(Lifecycle state);

signals:
    void lifecycleChanged();

private:
    QString m_appId;
    QString m_appVersion;
    Lifecycle m_lifecycle = Lifecycle::Active;
};
