#include "SquaredApp.h"

#ifndef SQUARED_VERSION
#define SQUARED_VERSION "0.1.0"
#endif

SquaredApp::SquaredApp(const QString &appId, const QString &appVersion,
                       QObject *parent)
    : QObject(parent), m_appId(appId), m_appVersion(appVersion)
{
}

QString SquaredApp::appId() const { return m_appId; }
QString SquaredApp::appVersion() const { return m_appVersion; }
QString SquaredApp::hostVersion() const { return QStringLiteral(SQUARED_VERSION); }
SquaredApp::Lifecycle SquaredApp::lifecycle() const { return m_lifecycle; }

void SquaredApp::setLifecycle(Lifecycle state)
{
    if (m_lifecycle != state) {
        m_lifecycle = state;
        emit lifecycleChanged();
    }
}
