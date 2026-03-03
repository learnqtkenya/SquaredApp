# qml/ — Host App QML Pages

## Overview

Host app UI pages. These are NOT part of the Squared.UI module — they are the host application's own QML files that *use* Squared.UI components.

## Navigation Architecture

```
Main.qml
├── TabBar ("Store" | "Installed")
├── StackView
│   ├── StorePage.qml       ← Store tab default
│   ├── InstalledPage.qml   ← Installed tab default
│   └── AppShell.qml        ← Pushed when launching an app
```

- `StackView` for forward/back navigation (app launch/close)
- `TabBar` for switching between Store and Installed views
- When an app launches, `AppShell` is pushed onto the StackView (tabs hidden)
- Back button in AppShell pops the stack, closes the app via AppRunner

## Pages

### Main.qml (Phase 2 minimal, Phase 3 full)

**Phase 2 (minimal):**
- Simple list of hardcoded local example apps (hello-world, counter, todo)
- Tap to launch into AppShell
- No tabs yet

**Phase 3 (full):**
- TabBar with "Store" and "Installed" tabs
- StackView manages page transitions
- Store tab shows StorePage, Installed tab shows InstalledPage

### AppShell.qml (Phase 2)

Chrome that wraps a running mini app.
- Toolbar at top: back button + app name (from manifest)
- Container `Item` fills remaining space — AppRunner loads the app QML into this
- Back button calls `AppRunner.close()` and pops StackView
- Shows loading indicator while app compiles (Phase 5 polish)
- Shows error state if app fails to load (Phase 5 polish)

### StorePage.qml (Phase 3)

App store browsing page.
- Grid/list of available apps from AppCatalog
- Each tile: icon, name, author, short description, install button
- Install button shows progress during download, changes to "Open" when installed
- Category filter at top
- Pull-to-refresh to refetch catalog

### InstalledPage.qml (Phase 3)

Installed apps grid.
- Grid of installed app tiles from AppRegistry/InstalledAppsModel
- Each tile: icon, name, last used
- Tap to launch
- Long-press for uninstall option

## QML Conventions

- Import Squared.UI: `import Squared.UI 1.0`
- Use SPage as root for full pages
- Use STheme for all visual constants
- Signal handlers: `onClicked: () => { }` (multi-line), `onClicked: doThing()` (single)
- Required properties over context properties where possible
- No JavaScript files — logic inline or in C++
