# src/core/ — Phase 2-3: App Runtime and Store Infrastructure

## Overview

Core host app logic: loading app manifests, running mini apps in sandboxed contexts, installing/uninstalling packages, fetching the store catalog, and tracking installed apps.

---

## Phase 2: App Manifest + App Runner

### AppManifest (`AppManifest.h`)

Data struct representing a parsed `manifest.json`.

```cpp
struct AppManifest {
    QString id;          // Reverse domain: "com.author.appname"
    QString name;
    QString version;
    QString entry;       // Default: "Main.qml"
    QString icon;        // Relative path to icon within app dir
    QString author;
    QString description;
    QString basePath;    // Absolute path to directory containing manifest.json

    static std::optional<AppManifest> fromDirectory(const QString &dirPath);
    static std::optional<AppManifest> fromJson(const QJsonObject &json, const QString &basePath);
};
```

**Validation:**
- Required fields: `id`, `name`, `version`
- `id` must be reverse domain format (at least two dot-separated segments)
- `entry` defaults to `"Main.qml"` if omitted
- `basePath` is set to the directory path passed to `fromDirectory()`
- Return `std::nullopt` on any validation failure

**Tests (tst_appmanifest.cpp):**
- Valid manifest parses correctly
- Missing required field → nullopt
- Empty JSON → nullopt
- Malformed JSON → nullopt
- Default entry is "Main.qml" when omitted
- basePath set to directory containing manifest.json

### AppRunner (`AppRunner.h` / `AppRunner.cpp`)

Manages the lifecycle of a running mini app.

```cpp
class AppRunner : public QObject {
    Q_OBJECT
    Q_PROPERTY(State state READ state NOTIFY stateChanged)

public:
    enum class State { Idle, Loading, Running, Suspended, Error };
    Q_ENUM(State)

    explicit AppRunner(QQmlEngine *engine, const QString &storageRoot, QObject *parent = nullptr);

    void launch(const AppManifest &manifest, QQuickItem *container);
    void suspend();
    void resume(QQuickItem *container);
    void close();

    State state() const;

signals:
    void stateChanged();
    void launched(const QString &appId, qint64 loadTimeMs);
    void suspended();
    void resumed();
    void closed();
    void error(const QString &appId, const QString &message);
};
```

**Key implementation details:**
- Takes a **shared** `QQmlEngine*` (not owned — one engine for whole host app)
- `launch()` creates a child `QQmlContext`, registers `Storage` (AppStorage) and `App` (SquaredApp) as context properties
- Adds the app's `basePath` to the engine's import path list (remove on close)
- Loads the entry QML file via `QQmlComponent`, parents the root item to the container
- `suspend()` hides the root item, detaches from container
- `resume()` re-parents to container, shows root item
- `close()` destroys root item, destroys QQmlContext, removes import path, destroys AppStorage and SquaredApp
- Import path must never leak outside the app's basePath (security)

**Tests (tst_apprunner.cpp):**
- Launch valid app → state Running, `launched` signal emits
- Launch invalid path → state Error, `error` signal emits
- Launch → close → state Idle
- Launch → suspend → state Suspended, root item not visible
- Suspend → resume → state Running, root item visible
- Close cleans up QQmlContext
- Second launch closes first app cleanly

---

## Phase 3: App Installer + Store Catalog

### AppInstaller (`AppInstaller.h` / `AppInstaller.cpp`)

```cpp
class AppInstaller : public QObject {
    Q_OBJECT
public:
    explicit AppInstaller(QObject *parent = nullptr);

    std::expected<AppManifest, QString> install(const QString &sqappPath, const QString &installDir);
    bool uninstall(const QString &appId, const QString &installDir, const QString &storageRoot);
    bool isInstalled(const QString &appId, const QString &installDir) const;
    QList<AppManifest> installedApps(const QString &installDir) const;
};
```

**Install flow:**
1. Validate ZIP integrity
2. Extract to temp directory
3. Parse and validate manifest.json
4. Copy to `<installDir>/<appId>/`
5. Return manifest on success, error string on failure

**Uninstall:** removes `<installDir>/<appId>/` and `<storageRoot>/<appId>/`

**.sqapp format:**
```
myapp.sqapp (ZIP):
├── manifest.json
├── qml/
│   ├── Main.qml
│   └── *.qml
└── assets/
    ├── icon.png
    └── *
```

**Tests (tst_appinstaller.cpp):**
- Install valid .sqapp → extracts, manifest parses, returns manifest
- Corrupt ZIP → error
- ZIP missing manifest → error
- ZIP with invalid manifest → error
- Uninstall removes directory
- Uninstall removes associated storage data
- isInstalled returns correct state
- installedApps returns all installed manifests
- Re-install overwrites cleanly

### AppCatalog (`AppCatalog.h` / `AppCatalog.cpp`)

```cpp
struct CatalogEntry {
    QString id, name, version, author, description;
    QUrl iconUrl, packageUrl;
    qint64 sizeBytes;
    QString category;
};

class AppCatalog : public QObject {
    Q_OBJECT
public:
    explicit AppCatalog(const QUrl &catalogUrl, QObject *parent = nullptr);
    void fetch();

signals:
    void catalogReady(const QList<CatalogEntry> &entries);
    void fetchError(const QString &message);
};
```

- Fetches `catalog.json` via `QNetworkAccessManager`
- Caches locally, uses `ETag` / `If-None-Match` headers
- Emits `catalogReady` with parsed entries or `fetchError`

**Tests (tst_appcatalog.cpp):**
- Parse valid catalog.json → correct entries
- Empty apps array → empty list
- Malformed JSON → fetchError

### PackageDownloader (`PackageDownloader.h` / `PackageDownloader.cpp`)

- Downloads `.sqapp` from URL to temp directory
- Emits `progress(appId, bytesReceived, bytesTotal)`
- On completion, hands off to AppInstaller
- Emits `installed(appId)` or `error(appId, message)`

### AppRegistry (`AppRegistry.h` / `AppRegistry.cpp`)

- SQLite database tracking installed apps
- Fields: id, name, version, install date, last launched, launch count
- Methods: `addApp()`, `removeApp()`, `allApps()`, `updateLaunchStats()`
- Provides `InstalledAppsModel` (QAbstractListModel) for QML binding

**Tests (tst_appregistry.cpp):**
- Add app, query it back
- Remove app, query returns empty
- Launch stats update correctly
- allApps returns correct list
