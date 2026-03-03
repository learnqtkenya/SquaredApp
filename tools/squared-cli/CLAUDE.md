# tools/squared-cli/ — Phase 4: Developer CLI

## Overview

Python CLI tool for creating, validating, testing, and packaging Squared apps. This is a developer tool, not a shipping product component.

## Implementation

- **Language:** Python 3.10+
- **Entry point:** `squared` (installed via `pip install -e .` or run as `python -m squared_cli`)
- **Dependencies:** minimal — `zipfile` (stdlib), `json` (stdlib), `watchdog` (for file watching in `run`)
- **Structure:**
  ```
  tools/squared-cli/
  ├── CLAUDE.md
  ├── pyproject.toml
  ├── squared_cli/
  │   ├── __init__.py
  │   ├── __main__.py
  │   ├── cli.py              # argparse entry point
  │   ├── init_cmd.py
  │   ├── validate_cmd.py
  │   ├── package_cmd.py
  │   ├── run_cmd.py
  │   └── publish_cmd.py
  └── tests/
      ├── test_init.py
      ├── test_validate.py
      └── test_package.py
  ```

## Commands

### `squared init <name>`
- Creates directory: `<name>/manifest.json`, `<name>/qml/Main.qml`, `<name>/assets/icon.png`
- manifest.json with defaults: `id: "com.developer.<name>"`, `name: "<Name>"`, `version: "1.0.0"`, `entry: "Main.qml"`
- Main.qml template uses `Squared.UI` with `SPage` + `SEmptyState`
- icon.png: placeholder (small colored square or bundled default)
- Output: `"Created <name>. Run 'squared run' to preview."`

### `squared validate [path]`
- Default path: current directory
- Checks:
  - `manifest.json` exists and is valid JSON
  - Required fields present: `id`, `name`, `version`
  - `id` is reverse domain format (`com.author.appname` — at least 2 dot segments)
  - Entry QML file exists at `qml/<entry>` (default `qml/Main.qml`)
  - Icon file exists and is PNG
- Warnings (don't fail):
  - Missing recommended fields: `description`, `author`
  - Total assets > 5MB
- Exit codes: 0 = pass, 1 = errors, 2 = warnings only

### `squared package [path] [--output <file>]`
- Runs `validate` first — fails on errors
- Creates `.sqapp` ZIP containing:
  - `manifest.json` at root
  - `qml/` directory
  - `assets/` directory
- Excludes: `.*`, `__pycache__`, `.git`, `*.pyc`, `build/`
- Default output name: `<id>-<version>.sqapp`
- Prints package size on success

### `squared run [path]`
- Launches app in a minimal Qt host window for preview
- Requires Qt installation accessible (uses the host app binary or a lightweight runner)
- Registers Squared.UI module and SDK singletons
- Watches QML files for changes — hot-reloads via Loader source reassignment
- Prints QML warnings/errors to terminal
- Ctrl+C to exit

### `squared publish <sqapp> [--server <url>]`
- Uploads .sqapp to store backend (Phase 6 — separate repo)
- Auth: API key from `~/.squared/config` (TOML)
- Default server URL from config or `https://store.squared.dev`
- Server validates package and adds to catalog
- Output: `"Published <name> v<version>"`

## Tests

Run with `pytest`:
```bash
cd tools/squared-cli && pytest
```

**test_init.py:**
- `squared init test-app` → directory created with manifest.json and Main.qml
- Generated manifest is valid JSON with required fields
- Generated Main.qml imports Squared.UI

**test_validate.py:**
- Valid app → exit 0
- Missing manifest → exit 1 with error message
- Missing entry QML → exit 1
- Invalid id format → exit 1
- Missing recommended fields → exit 2 (warning)

**test_package.py:**
- Produces valid ZIP containing manifest.json and qml/
- Excludes hidden files and __pycache__
- Invalid app → fails with error
- .sqapp can be installed via AppInstaller (integration test)

## Done Criteria

- All commands work end-to-end
- Full loop: `init` → edit QML → `run` (preview) → `package` → install in host app
- `squared run` launches preview window with Squared.UI components rendering
