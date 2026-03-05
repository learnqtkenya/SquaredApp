# Squared

A Qt6/QML super app platform. Build QML apps, package them as `.sqapp` bundles, publish to the Squared Store, and run them inside the Squared host app.

## Prerequisites

- Qt 6.10.2 (`/opt/Qt/6.10.2` or set `CMAKE_PREFIX_PATH`)
- CMake 3.21+, Ninja
- C++20 compiler (GCC 11+, Clang 14+)
- Go 1.25+ (for the developer CLI)
- Android SDK, NDK r27+, JDK 17+ (for Android builds)

## Build

### Desktop (Linux)

```bash
cmake -G Ninja -B build -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/gcc_64
cmake --build build
```

### Android (arm64)

```bash
cmake -G Ninja -B build-android \
  -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/android_arm64_v8a \
  -DCMAKE_TOOLCHAIN_FILE=/opt/Qt/6.10.2/android_arm64_v8a/lib/cmake/Qt6/qt.toolchain.cmake \
  -DANDROID_SDK_ROOT=$ANDROID_SDK_ROOT \
  -DANDROID_NDK_ROOT=$ANDROID_NDK_ROOT \
  -DQT_CHAINLOAD_TOOLCHAIN_FILE=$ANDROID_NDK_ROOT/build/cmake/android.toolchain.cmake
cmake --build build-android
```

Requires Android SDK, NDK r27+, and JDK 17+. Set `ANDROID_SDK_ROOT`, `ANDROID_NDK_ROOT`, and `JAVA_HOME` environment variables.

## Test

```bash
QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure
```

37 tests: 29 QML component tests + 8 C++ tests covering manifest parsing, app runner, storage, installer, catalog, registry, secure storage, and network client.

## Run

```bash
./build/src/Squared
```

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

Downloads the latest binary for your platform. Installs to `~/.local/bin` (Linux/macOS) or `%LOCALAPPDATA%\Squared\bin` (Windows).

### Usage

```bash
squared init my-app           # Scaffold a new app project
squared validate my-app       # Check manifest and file structure
squared package my-app        # Create .sqapp bundle
squared publish app.sqapp     # Publish metadata to store server
squared update                # Update to latest version
squared version               # Print installed version
```

### Build from source

```bash
cd tools/squared-cli && go build -o squared .
```

## Store Server

Go backend with PostgreSQL. Serves the app catalog API.

```bash
cd server && docker compose up
# API: http://localhost:8080
# Endpoints: GET /api/catalog, GET/POST /api/apps, GET /healthz
```

## Project Structure

```
src/
  main.cpp                  Host app entry point
  core/                     AppManifest, AppRunner, AppInstaller, AppCatalog, AppRegistry
  sdk/ui/                   Squared.UI — 28 themed QML components + STheme
  sdk/storage/              AppStorage (key-value) + SecureStorage (keychain/file)
  sdk/network/              NetworkClient (sandboxed HTTP)
  sdk/core/                 SquaredApp (lifecycle + metadata)
qml/                        Host app pages (Main, StorePage, AppShell)
server/                     Go store backend + PostgreSQL migrations
tools/squared-cli/          Developer CLI (Go)
examples/apps/              hello-world, counter, todo, finance, weather
tests/                      QTest (cpp/) + QML TestCase (qml/)
```

## License

All rights reserved.
