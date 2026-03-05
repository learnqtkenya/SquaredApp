# Squared

A Qt6/QML super app platform. Build QML apps, package them as `.sqapp` bundles, publish to the Squared Store, and run them inside the Squared host app.

## Prerequisites

- Qt 6.10.2 (`/opt/Qt/6.10.2` or set `CMAKE_PREFIX_PATH`)
- CMake 3.21+, Ninja
- C++20 compiler (GCC 11+, Clang 14+)
- Go 1.25+ (for the developer CLI)

## Build

```bash
cmake -G Ninja -B build -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/gcc_64
cmake --build build
```

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

```bash
cd tools/squared-cli && go build -o squared .

squared init my-app           # Scaffold a new app project
squared validate my-app       # Check manifest and file structure
squared package my-app        # Create .sqapp bundle
squared publish app.sqapp     # Publish metadata to store server
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
