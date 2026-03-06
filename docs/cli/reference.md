# CLI Reference

The `squared` CLI scaffolds, validates, packages, and publishes Squared apps.

## Installation

=== "Linux / macOS"

    ```bash
    curl -fsSL https://squared.co.ke/install.sh | sh
    ```

=== "Windows (PowerShell)"

    ```powershell
    irm https://squared.co.ke/install.ps1 | iex
    ```

=== "From source"

    ```bash
    cd tools/squared-cli && go build -o squared .
    ```

---

## Commands

### `squared init <name>`

Scaffold a new app project.

```bash
squared init my-app
```

**Creates:**

```
my-app/
├── manifest.json       # Pre-filled with defaults
├── CMakeLists.txt      # For IDE autocomplete
├── qml/
│   └── Main.qml        # Starter template
└── assets/
```

**Manifest defaults:**

- `id`: `com.developer.<name>` (alphanumeric)
- `name`: Title-cased from project name
- `version`: `1.0.0`
- `entry`: `Main.qml`

**Validation:** Name must start with a letter and contain only letters, digits, dots, hyphens, or underscores. Fails if directory already exists.

---

### `squared setup [--force]`

Install SDK type stubs and host app binary.

```bash
squared setup
squared setup --force    # Reinstall even if present
```

**Installs to `~/.squared/`:**

- Pre-built host binary (downloaded from GitHub releases)
- SDK type stubs for IDE autocomplete

**Platform detection:** Automatically picks the right binary for your OS and architecture.

---

### `squared validate [path]`

Check an app directory for correctness.

```bash
squared validate              # Current directory
squared validate ./my-app     # Specific path
```

**Checks:**

| Check | Severity |
|-------|----------|
| `manifest.json` exists and is valid JSON | Error |
| `id`, `name`, `version` present | Error |
| `id` is reverse-domain format | Error |
| Entry file exists at `qml/<entry>` | Error |
| `author` and `description` present | Warning |
| Total size < 5 MB | Warning |

**Exit codes:** `0` = pass, `1` = errors, `2` = warnings only

---

### `squared package [path] [--output <file>]`

Create a `.sqapp` bundle.

```bash
squared package                           # Default: <id>-<version>.sqapp
squared package --output dist/app.sqapp   # Custom output path
squared package ./my-app                  # Specific directory
```

Runs validation first. Fails on errors.

**Excludes:** hidden files, `.git`, `build/`, `node_modules/`, `__pycache__/`, `.pyc`, `.sqapp`

---

### `squared run [path]`

Preview an app with hot reload.

```bash
squared run              # Current directory
squared run ./my-app     # Specific path
```

Launches the Squared host app in dev mode. File changes trigger automatic reload.

**Host binary resolution:**

1. `Squared` (or `Squared.exe`) in `PATH`
2. `~/.squared/bin/Squared`
3. macOS: unwraps `.app` bundle

If not found, suggests running `squared setup`.

---

### `squared publish <sqapp> [flags]`

Publish a `.sqapp` to the store server.

```bash
squared publish my-app.sqapp
squared publish my-app.sqapp --server https://store.example.com --token sk-123
squared publish my-app.sqapp --package-url https://cdn.example.com/my-app.sqapp
```

| Flag | Default | Description |
|------|---------|-------------|
| `--server` | `$SQUARED_SERVER_URL` or `localhost:8080` | Store server URL |
| `--token` | `$SQUARED_TOKEN` | Auth token |
| `--package-url` | (empty) | Download URL for the package |

Reads manifest from the ZIP and POSTs to `/api/apps`.

---

### `squared update`

Self-update to the latest version.

```bash
squared update
```

Downloads the latest release from GitHub. Atomic binary replacement (old binary backed up during swap).

!!! note
    Self-update is not supported on Windows. Use the PowerShell install script instead.

---

### `squared version`

Print the CLI version.

```bash
squared version
```

---

## Environment Variables

| Variable | Used By | Description |
|----------|---------|-------------|
| `SQUARED_SERVER_URL` | `publish` | Default store server URL |
| `SQUARED_TOKEN` | `publish` | Authentication token for store |

## Summary

| Command | Arguments | Key Flags |
|---------|-----------|-----------|
| `init` | `<name>` | |
| `setup` | | `--force` |
| `validate` | `[path]` | |
| `package` | `[path]` | `--output` |
| `run` | `[path]` | |
| `publish` | `<sqapp>` | `--server`, `--token`, `--package-url` |
| `update` | | |
| `version` | | |
