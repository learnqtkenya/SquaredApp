# Manifest Format

Every Squared app has a `manifest.json` at its root. This file defines the app's identity, entry point, and permissions.

## Structure

```json
{
    "id": "com.example.myapp",
    "name": "My App",
    "version": "1.0.0",
    "entry": "Main.qml",
    "icon": "assets/icon.png",
    "author": "Your Name",
    "description": "A short description of the app",
    "permissions": ["network"]
}
```

## Fields

### Required

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique reverse-domain identifier (e.g., `com.author.appname`) |
| `name` | string | Human-readable display name |
| `version` | string | Semantic version (e.g., `1.0.0`) |

### Optional

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `entry` | string | `"Main.qml"` | Entry QML file relative to `qml/` |
| `icon` | string | (empty) | Icon path relative to app root |
| `author` | string | (empty) | Developer name |
| `description` | string | (empty) | Short app description |
| `permissions` | array | `[]` | List of [permissions](permissions.md) |

## Validation Rules

### ID format

The `id` must be a reverse-domain identifier with at least two segments:

```
com.squared.myapp       # valid
org.example.tool        # valid
myapp                   # invalid — needs at least one dot
com                     # invalid — needs at least two segments
```

Pattern: `^[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)+$`

### Entry file

The entry QML file must exist at `qml/<entry>`. If omitted, defaults to `qml/Main.qml`.

### CLI validation

Running `squared validate` checks:

- **Errors** (exit code 1): missing/invalid JSON, missing required fields, invalid ID format, missing entry file
- **Warnings** (exit code 2): missing `author` or `description`, total size > 5 MB

## Examples

### Minimal

```json
{
    "id": "com.squared.hello",
    "name": "Hello World",
    "version": "1.0.0"
}
```

### Full

```json
{
    "id": "com.squared.weather",
    "name": "Weather",
    "version": "1.0.0",
    "entry": "Main.qml",
    "icon": "assets/icon.png",
    "author": "Squared Computing",
    "description": "Live weather using SecureStorage + Network",
    "permissions": ["network", "secure-storage"]
}
```
