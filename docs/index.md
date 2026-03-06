# Squared

**A Qt6/QML super app platform.** Build QML apps, package them as `.sqapp` bundles, publish to the Squared Store, and run them inside the Squared host app.

!!! warning
    Squared is a learning/toy project built to explore the super app pattern with Qt. It is not intended for production use.

## What is Squared?

Squared is a runtime and distribution platform for QML applications. Developers build QML mini apps using the Squared SDK, package them into `.sqapp` bundles, and publish them to the Squared Store. Users browse the store, install apps, and run them — all inside a single host application.

The platform targets Qt developers — intermediate to experienced QML developers trained through Squared Academy.

## Architecture

```
Host App (Squared)
├── Store ← browse & install .sqapp packages
├── Home  ← grid of installed apps
└── AppShell ← sandboxed runtime for each mini app
       ├── QQmlContext (isolated)
       ├── Storage API
       ├── SecureStorage API
       ├── Network API
       └── App lifecycle API
```

Each mini app runs in its own `QQmlContext` with sandboxed access to platform APIs. Apps cannot access each other's data or files outside their directory.

## Quick Start

```bash
# Install the CLI
curl -fsSL https://squared.co.ke/install.sh | sh

# Set up SDK + host app
squared setup

# Create your first app
squared init my-app
cd my-app

# Preview with hot reload
squared run
```

## Platforms

| Platform | Build | Package |
|----------|-------|---------|
| Linux    | `make build` | AppImage, DEB |
| macOS    | `make build` | .app bundle |
| Windows  | `make build` | NSIS installer |
| Android  | `make apk` / `make aab` | APK, AAB |

## Tech Stack

- **Language:** C++20, QML
- **Qt version:** 6.10.2
- **Build system:** CMake + Ninja
- **UI framework:** Qt Quick / Qt Quick Controls
- **Icons:** Material Symbols Outlined (variable font)
- **Fonts:** Inter (Regular 400, SemiBold 600)
- **Package format:** `.sqapp` (ZIP with manifest + QML + assets)
- **Store server:** Go + PostgreSQL
- **Developer CLI:** Go

## What's Next?

- [Install the CLI and SDK](getting-started/installation.md)
- [Build your first app](getting-started/first-app.md)
- [Browse the UI components](ui/overview.md)
- [Explore the SDK APIs](sdk/storage.md)
