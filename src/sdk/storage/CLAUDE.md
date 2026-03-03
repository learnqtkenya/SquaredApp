# src/sdk/storage/ — Phase 2: Squared.Storage

## Overview

Sandboxed key-value persistence for mini apps. Each app gets isolated storage keyed by app ID. Exposed to QML as a context property `Storage` within each app's `QQmlContext`.

## AppStorage Class

**File:** `AppStorage.h` / `AppStorage.cpp`

```cpp
class AppStorage : public QObject {
    Q_OBJECT
    QML_ELEMENT
public:
    explicit AppStorage(const QString &appId, const QString &storageRoot, QObject *parent = nullptr);

    Q_INVOKABLE void set(const QString &key, const QVariant &value);
    Q_INVOKABLE QVariant get(const QString &key, const QVariant &fallback = QVariant()) const;
    Q_INVOKABLE void remove(const QString &key);
    Q_INVOKABLE bool has(const QString &key) const;
    Q_INVOKABLE void clear();

signals:
    void changed(const QString &key);
};
```

## Storage Details

- **Path:** `<storageRoot>/<appId>/data.json`
- **Format:** JSON object — keys are strings, values are JSON-compatible types
- **Supported types:** string, int, double, bool, QVariantList, QVariantMap
- **Sandboxing:** Each AppStorage instance only accesses its own `<appId>/` directory. No path traversal possible.

## Batched Writes

Avoid disk thrashing by batching writes:
1. On `set()` / `remove()` / `clear()` — set a dirty flag
2. Start a `QTimer::singleShot(500ms)` if not already running
3. On timer fire — flush `QJsonDocument` to disk
4. Also flush on destruction (in destructor)

This means `get()` always reads from the in-memory map (fast), and writes coalesce.

## Error Handling

- If storage directory doesn't exist, create it on first write
- If `data.json` is corrupt/unreadable, start fresh (log warning, don't crash)
- Filesystem errors during flush: log warning, retry on next timer

## Test Requirements (tst_appstorage.cpp)

- set/get roundtrip for string, int, bool, list, map
- get with fallback returns fallback for missing key
- has returns true for existing, false for missing
- remove deletes key, has returns false after
- clear empties all data
- Data persists after destroy + recreate (verifies disk flush)
- Two AppStorage instances with different appIds are isolated
- changed signal emits on set/remove/clear
