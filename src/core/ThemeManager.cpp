#include "ThemeManager.h"

ThemeManager::ThemeManager(QObject *parent)
    : QObject(parent)
    , m_dark(m_settings.value(QStringLiteral("theme/dark"), false).toBool())
{
}

bool ThemeManager::dark() const
{
    return m_dark;
}

void ThemeManager::setDark(bool dark)
{
    if (m_dark == dark)
        return;
    m_dark = dark;
    m_settings.setValue(QStringLiteral("theme/dark"), dark);
    emit darkChanged();
}
