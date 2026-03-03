# examples/ — Example Apps and First-Party Apps

## Overview

Example `.sqapp` projects for testing the runtime (Phase 2) and first-party apps that ship with the store (Phase 5).

## Directory Layout

```
examples/
├── CLAUDE.md
└── apps/
    ├── hello-world/            # Phase 2 — minimal test app
    │   ├── manifest.json
    │   ├── qml/
    │   │   └── Main.qml
    │   └── assets/
    │       └── icon.png
    ├── counter/                # Phase 2 — tests Storage
    │   ├── manifest.json
    │   ├── qml/
    │   │   └── Main.qml
    │   └── assets/
    │       └── icon.png
    ├── todo/                   # Phase 2 — tests list + Storage
    │   ├── manifest.json
    │   ├── qml/
    │   │   └── Main.qml
    │   └── assets/
    │       └── icon.png
    └── ...                     # Phase 5 — first-party apps
```

## manifest.json Format

```json
{
    "id": "com.squared.helloworld",
    "name": "Hello World",
    "version": "1.0.0",
    "entry": "Main.qml",
    "icon": "assets/icon.png",
    "author": "Squared Computing",
    "description": "A simple starter app"
}
```

**Required fields:** `id`, `name`, `version`
**Optional fields:** `entry` (default: "Main.qml"), `icon`, `author`, `description`
**id format:** Reverse domain — at least two dot-separated segments (e.g., `com.squared.myapp`)

## .sqapp Package Format

A `.sqapp` is a ZIP file:
```
myapp.sqapp (ZIP):
├── manifest.json
├── qml/
│   ├── Main.qml
│   └── *.qml
└── assets/
    ├── icon.png
    └── *
```

## Phase 2 Example Apps

### hello-world — Minimal test app
```qml
import Squared.UI 1.0

SPage {
    title: "Hello World"
    SEmptyState {
        title: "Hello from Squared"
        description: "This app loaded successfully"
    }
}
```
Tests: loads without errors, displays content, back button returns to list.

### counter — Tests Storage
```qml
import Squared.UI 1.0

SPage {
    title: "Counter"
    property int count: Storage.get("count", 0)
    SCard {
        SMetric { value: count; label: "Count" }
    }
    SButton {
        text: "Increment"
        onClicked: () => { count++; Storage.set("count", count) }
    }
}
```
Tests: increment persists across close/reopen.

### todo — Tests list rendering + Storage
- Add/remove todo items
- Items persisted via Storage across sessions
- Uses SListItem, STextField, SButton, SCard

## Phase 5 First-Party Apps

| App | Purpose | Key Components |
|-----|---------|---------------|
| Hello Squared | Onboarding | SPage, SEmptyState, SButton |
| Unit Converter | Utility | STextField, SDropdown, SCard, SMetric |
| Habit Tracker | Productivity | Storage, SListItem, SSwitch, SBadge |
| Color Picker | Design tool | SSlider, Canvas |
| Markdown Notes | Notes | Storage, STextField (multiline) |
| QML Playground | Dev tool | Dynamic QML compilation |
| Pomodoro Timer | Productivity | Timer, SProgressBar, SButton |
| IoT Dashboard | Reference | SMetric, SGrid, SCard |

Each app:
- Has a complete `manifest.json`
- Uses `Squared.UI` components exclusively (no raw Rectangle/Text for standard UI)
- Is packaged as a tested `.sqapp`
- Source code serves as developer reference

## Rules for Example Apps

- Every app must use `import Squared.UI 1.0` — no raw Qt Quick primitives for standard UI
- All visual constants via STheme
- Apps must work on all target platforms (desktop, Android, embedded ARM)
- No external network access in Phase 2 examples (Storage only)
