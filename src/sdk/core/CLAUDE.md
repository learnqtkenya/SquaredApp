# src/sdk/core/ — Phase 2: Squared.Core

## Overview

Provides app metadata and lifecycle state to mini apps. Exposed to QML as context property `App` within each app's `QQmlContext`.

## SquaredApp Class

**File:** `SquaredApp.h` / `SquaredApp.cpp`

```cpp
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
    QString hostVersion() const;    // Returns compiled-in host version
    Lifecycle lifecycle() const;
    void setLifecycle(Lifecycle state);

signals:
    void lifecycleChanged();
};
```

## Lifecycle States

| State | Meaning |
|-------|---------|
| `Active` | App is visible and in the foreground |
| `Inactive` | App is loaded but not visible (e.g., dialog overlay) |
| `Suspended` | App is suspended (not visible, may be resumed) |

## Integration with AppRunner

- AppRunner creates a `SquaredApp` instance per launched app
- Sets lifecycle to `Active` on launch/resume
- Sets lifecycle to `Suspended` on suspend
- Destroys the instance on close

## Host Version

`hostVersion` returns a compile-time constant (e.g., from CMake `PROJECT_VERSION`). Mini apps can use this to check compatibility.

## Usage in Mini Apps

```qml
import Squared.Core 1.0

Text {
    text: "Running " + App.appId + " v" + App.appVersion
    text: "Host: " + App.hostVersion
}

Connections {
    target: App
    onLifecycleChanged: {
        if (App.lifecycle === SquaredApp.Suspended) {
            // Save state
        }
    }
}
```
