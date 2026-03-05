#pragma once

#include <QObject>
#include <QSettings>

class ThemeManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool dark READ dark WRITE setDark NOTIFY darkChanged)

public:
    explicit ThemeManager(QObject *parent = nullptr);

    bool dark() const;
    void setDark(bool dark);

signals:
    void darkChanged();

private:
    QSettings m_settings;
    bool m_dark;
};
