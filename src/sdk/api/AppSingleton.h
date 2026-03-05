#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>

class AppSingleton : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(App)
    QML_SINGLETON

    Q_PROPERTY(QString appId READ appId CONSTANT)
    Q_PROPERTY(QString appVersion READ appVersion CONSTANT)
    Q_PROPERTY(QString hostVersion READ hostVersion CONSTANT)
    Q_PROPERTY(Lifecycle lifecycle READ lifecycle NOTIFY lifecycleChanged)

public:
    enum class Lifecycle { Active, Inactive, Suspended };
    Q_ENUM(Lifecycle)

    explicit AppSingleton(QObject *parent = nullptr) : QObject(parent) {}

    QString appId() const { return {}; }
    QString appVersion() const { return {}; }
    QString hostVersion() const { return {}; }
    Lifecycle lifecycle() const { return Lifecycle::Active; }

signals:
    void lifecycleChanged();
};
