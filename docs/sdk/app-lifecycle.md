# App Lifecycle

The `App` object provides metadata about the running app and its lifecycle state. Always available — no permissions required.

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `appId` | `string` | The app's reverse-domain identifier (constant) |
| `appVersion` | `string` | The app's version from `manifest.json` (constant) |
| `hostVersion` | `string` | The Squared host app version (constant) |
| `lifecycle` | `Lifecycle` | Current lifecycle state |

## Lifecycle States

| State | Description |
|-------|-------------|
| `App.Active` | App is visible and in the foreground |
| `App.Inactive` | App is loaded but not currently visible |
| `App.Suspended` | App is suspended and may be resumed later |

## Signals

| Signal | Description |
|--------|-------------|
| `lifecycleChanged()` | Emitted when the lifecycle state changes |

## Usage

### Display app info

```qml
SPage {
    title: App.appId

    SCard {
        Layout.fillWidth: true

        SText { text: "App: " + App.appId }
        SText { text: "Version: " + App.appVersion }
        SText { text: "Host: " + App.hostVersion }
    }
}
```

### React to lifecycle changes

```qml
Connections {
    target: App
    function onLifecycleChanged() {
        if (App.lifecycle === App.Active) {
            refreshData()
        } else if (App.lifecycle === App.Suspended) {
            saveState()
        }
    }
}
```

### Conditional behavior based on lifecycle

```qml
Timer {
    interval: 5000
    repeat: true
    running: App.lifecycle === App.Active
    onTriggered: fetchUpdates()
}
```

## Implementation Details

- **`appId` and `appVersion`** are set from the app's `manifest.json` at launch time
- **`hostVersion`** is the compile-time version of the Squared host app (`CMake PROJECT_VERSION`)
- **Lifecycle transitions** are managed by the `AppRunner`:
    - `launch()` sets `Active`
    - `suspend()` sets `Suspended`
    - `resume()` sets `Active`
    - `close()` destroys the `App` object
