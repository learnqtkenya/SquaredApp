<p align="center">
  <img src="assets/icons/squared-192.png" width="128" height="128" alt="Squared icon">
</p>

<h1 align="center">Squared</h1>

<p align="center">
  A Qt6/QML super app platform. Build QML apps, package them as <code>.sqapp</code> bundles, publish to the Squared Store, and run them inside the Squared host app.
</p>

> [!WARNING]
> Squared is a learning/toy project built to explore the super app pattern with Qt. It is not intended for production use.

## Platforms

| Platform | Build | Package |
|----------|-------|---------|
| Linux    | `make build` | AppImage, DEB |
| macOS    | `make build` | .app bundle |
| Windows  | `make build` | NSIS installer |
| Android  | `make apk` / `make aab` | APK, AAB |

## Prerequisites

- **Qt 6.10.2** — set `QT_DIR` or install to `/opt/Qt/6.10.2`
- **CMake 3.21+** and **Ninja**
- **C++23 compiler** (GCC 13+, Clang 16+, MSVC 2022)
- **Go 1.25+** — for the developer CLI (`tools/squared-cli/`)
- **Android** — SDK, NDK r27+, JDK 17 (see [Android build docs](docs/android-build.md))

## Quick Start

```bash
make              # Build (debug)
make test         # Run tests headlessly
make run APP=examples/apps/hello-world  # Preview an app
```

## Build

All targets are available via `make`. Run `make help` for the full list.

### Desktop

```bash
make                  # Debug build
make release          # Release build
make install          # Install to install/
```

Or directly with CMake:

```bash
cmake -G Ninja -B build -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/gcc_64
cmake --build build
```

### Android

```bash
make apk              # Release APK (signed)
make aab              # Release AAB (signed)
make apk-debug        # Debug APK (no signing)
make android          # Both APK + AAB
```

Requires `JAVA_HOME`, `ANDROID_HOME`, and `ANDROID_NDK_ROOT` environment variables. See [docs/android-build.md](docs/android-build.md) for full setup and the standalone build script at [tools/build-android.sh](tools/build-android.sh).

### Linux Packaging

```bash
make deb              # Build .deb package
make appimage         # Build AppImage (downloads linuxdeploy on first run)
make package-linux    # Build both
```

### Windows Packaging

```bash
make release
cd build-release && cpack -G NSIS
```

Generates an NSIS installer with Start Menu and Desktop shortcuts.

## Test

```bash
make test
# or directly:
QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure
```

38 tests: 30 QML component tests + 8 C++ tests covering manifest parsing, app runner, storage, installer, catalog, registry, secure storage, and network client.

## Developer CLI

The `squared` CLI scaffolds, validates, packages, and publishes apps.

### Install

**Linux / macOS:**

```bash
curl -fsSL https://squared.co.ke/install.sh | sh
```

**Windows (PowerShell):**

```powershell
irm https://squared.co.ke/install.ps1 | iex
```

### Usage

```bash
squared setup                 # Install SDK + host app binary
squared init my-app           # Scaffold a new app project
squared run my-app            # Preview in Squared host app
squared validate my-app       # Check manifest and file structure
squared package my-app        # Create .sqapp bundle
squared publish app.sqapp     # Publish metadata to store server
squared update                # Update to latest version
```

### Setup

Run `squared setup` once to install:
- **Squared host app** — pre-built binary for running and previewing apps
- **SDK type stubs** — IDE intellisense for Squared.UI and Squared.SDK

The SDK gives you autocomplete for:
- **Squared.UI** — 28 themed QML components (SButton, SCard, SPage, etc.) plus STheme and IconCodes singletons
- **Squared.SDK** — Storage, SecureStorage, Network, and App APIs

Projects created with `squared init` include a `CMakeLists.txt` that references the SDK. Run `cmake -B build` in your project to generate type info for qmlls.

Works with any editor that supports Qt's QML Language Server (qmlls):
- **Qt Creator** — built-in support
- **VS Code** — install the [Qt QML](https://marketplace.visualstudio.com/items?itemName=nicemicro.qml-support) extension
- **Neovim** — configure qmlls as an LSP server

### Running Apps

**As a user** — launch the Squared host app to browse the store catalog, install apps, and run them:

```bash
~/.squared/bin/Squared              # Linux
open ~/.squared/bin/Squared.app     # macOS
%LOCALAPPDATA%\Squared\bin\Squared.exe  # Windows
```

**As a developer** — preview your app with hot reload:

```bash
squared run my-app
```

Both modes are served by the same binary. `squared setup` downloads it automatically. Building from source (`make build`) symlinks the binary to `~/.squared/bin/` automatically.

### Build CLI from Source

```bash
cd tools/squared-cli && ./sync-sdk.sh && go build -o squared .
```

## Store Server

Go backend with PostgreSQL. Serves the app catalog API.

```bash
cd server && docker compose up
# API: http://localhost:8080
# Endpoints: GET /api/catalog, GET/POST /api/apps, GET /healthz
```

## Example Apps

12 example apps in [examples/apps/](examples/apps/):

| App | Description |
|-----|-------------|
| hello-world | Minimal starter app |
| counter | State management basics |
| todo | CRUD with local storage |
| finance | Budget tracker with charts |
| weather | API integration (network SDK) |
| markdown-notes | Rich text editing |
| pomodoro-timer | Timer with notifications |
| habit-tracker | Daily habit tracking |
| unit-converter | Unit conversion utility |
| color-picker | HSL/RGB color tool |
| qml-playground | Live QML editor |
| iot-dashboard | Sensor dashboard UI |

## Project Structure

```
src/
  main.cpp                  Host app entry point
  core/                     AppManifest, AppRunner, AppInstaller, AppCatalog, AppRegistry
  sdk/ui/                   Squared.UI — 28 themed QML components + STheme
  sdk/storage/              AppStorage (key-value) + SecureStorage (keychain/file)
  sdk/network/              NetworkClient (sandboxed HTTP)
  sdk/core/                 SquaredApp (lifecycle + metadata)
qml/                        Host app pages (Main, StorePage, InstalledPage, AppShell)
android/                    AndroidManifest.xml and Gradle config
linux/                      .desktop file and hicolor icons
ios/                        Asset catalog (AppIcon)
assets/icons/               Platform icons (.ico, .icns, .png, .rc)
server/                     Go store backend + PostgreSQL migrations
tools/
  squared-cli/              Developer CLI (Go)
  build-android.sh          Standalone Android build script
examples/apps/              12 example apps
tests/                      QTest (cpp/) + QML TestCase (qml/)
Makefile                    Cross-platform build targets
```

## License

[MIT](LICENSE)
