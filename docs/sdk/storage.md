# Storage

Synchronous key-value persistence, sandboxed per app. Available as the `Storage` context property in every app — no permissions required.

## API

| Method | Description |
|--------|-------------|
| `set(key, value)` | Store a value |
| `get(key, fallback?)` | Retrieve a value (returns `fallback` if missing) |
| `remove(key)` | Delete a key |
| `has(key)` | Check if key exists |
| `clear()` | Remove all keys |

### Signals

| Signal | Description |
|--------|-------------|
| `changed(key)` | Emitted after `set()`, `remove()`, or `clear()` |

## Supported Types

Storage accepts any QML-compatible value:

- `string`
- `int` / `double`
- `bool`
- `list` (arrays)
- `object` (JS objects / maps)

## Usage

### Basic read/write

```qml
// Save a value
Storage.set("username", "alice")

// Read with fallback
var name = Storage.get("username", "anonymous")

// Check existence
if (Storage.has("username")) {
    console.log("Found:", Storage.get("username"))
}
```

### Persisting component state

```qml
SPage {
    title: "Settings"

    property bool darkMode: Storage.get("darkMode", false)

    SSwitch {
        text: "Dark mode"
        checked: darkMode
        onToggled: {
            darkMode = checked
            Storage.set("darkMode", darkMode)
        }
    }
}
```

### Storing complex data

```qml
// Arrays
Storage.set("recentSearches", ["qt", "qml", "squared"])
var searches = Storage.get("recentSearches", [])

// Objects
Storage.set("profile", { name: "Alice", level: 5 })
var profile = Storage.get("profile", {})
```

### Reacting to changes

```qml
Connections {
    target: Storage
    function onChanged(key) {
        if (key === "theme")
            reloadTheme()
    }
}
```

## Implementation Details

- **Format:** QDataStream binary (magic: `0x53515344`)
- **Writes:** Atomic via `QSaveFile` (crash-safe)
- **Reads:** Served from in-memory cache (fast)
- **Location:** `<storageRoot>/<appId>/storage.dat`
- **Sandboxed:** Each app has its own isolated storage directory
