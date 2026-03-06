# UI Components Overview

Squared.UI is a themed QML component library with 28 components. Import it in any Squared app:

```qml
import Squared.UI
```

All components use the `S` prefix and are styled through the `STheme` singleton.

## STheme

Central theme singleton. All colors, spacing, radii, and fonts come from here.

### Colors

| Property | Light | Dark | Note |
|----------|-------|------|------|
| `primary` | `#6366F1` | `#6366F1` | Accent color (constant) |
| `primaryVariant` | `#4F46E5` | `#4F46E5` | Darker accent (constant) |
| `surface` | `#FFFFFF` | `#1E293B` | Card/container backgrounds |
| `surfaceVariant` | `#F8FAFC` | `#334155` | Subtle surface variation |
| `background` | `#F1F5F9` | `#0F172A` | Page background |
| `text` | `#0F172A` | `#F1F5F9` | Primary text |
| `textSecondary` | `#64748B` | `#94A3B8` | Secondary/muted text |
| `border` | `#E2E8F0` | `#475569` | Borders and dividers |
| `error` | `#EF4444` | `#EF4444` | Error state (constant) |
| `success` | `#22C55E` | `#22C55E` | Success state (constant) |

### Dark Mode

Toggle with `STheme.dark`:

```qml
SSwitch {
    text: "Dark mode"
    checked: STheme.dark
    onToggled: STheme.dark = checked
}
```

The `dark` property is persisted — it survives app restarts.

### Spacing

| Property | Value |
|----------|-------|
| `spacingXs` | 4 |
| `spacingSm` | 8 |
| `spacingMd` | 16 |
| `spacingLg` | 24 |
| `spacingXl` | 32 |

### Border Radii

| Property | Value |
|----------|-------|
| `radiusSmall` | 6 |
| `radiusMedium` | 10 |
| `radiusLarge` | 16 |

### Fonts

| Property | Size | Weight |
|----------|------|--------|
| `heading` | 24px | DemiBold |
| `subheading` | 18px | DemiBold |
| `body` | 14px | Normal |
| `caption` | 12px | Normal |

All fonts use the Inter family.

## IconCodes

Singleton providing Material Symbols icon codepoints. Use with `SIcon`:

```qml
SIcon {
    icon: IconCodes.home
    size: 24
}
```

### Available Icons

**Navigation:** `home`, `arrowBack`, `arrowForward`, `menu`, `close`, `moreVert`, `moreHoriz`, `expandMore`, `expandLess`, `chevronRight`

**Actions:** `search`, `add`, `remove`, `edit`, `deleteIcon`, `check`, `checkCircle`, `refresh`, `settings`, `download`, `upload`, `share`, `copy`, `save`, `swapHoriz`, `swapVert`, `lock`, `lockOpen`

**Content:** `star`, `starOutline`, `favorite`, `favoriteOutline`, `info`, `warning`, `errorIcon`

**Communication:** `notification`, `email`, `chat`

**Media:** `playArrow`, `pause`, `stop`, `skipNext`, `image`

**Device:** `timer`, `storage`, `thermostat`, `battery`, `sensors`, `lightMode`, `darkMode`, `speed`, `waterDrop`

**Social:** `person`, `group`

**Finance:** `wallet`, `trendingUp`, `trendingDown`, `receipt`, `accountBalance`

**Misc:** `category`, `dashboard`, `code`, `palette`, `lightbulb`, `empty`, `apps`, `store`, `checklist`, `description`, `rocketLaunch`

## SSize

Responsive sizing singleton for adaptive layouts.

### Setup

Bind to your window dimensions at the app root:

```qml
Component.onCompleted: {
    SSize.windowWidth = Qt.binding(() => window.width)
    SSize.windowHeight = Qt.binding(() => window.height)
}
```

### Breakpoints

| Property | Value | Description |
|----------|-------|-------------|
| `compact` | 600 | Phones |
| `medium` | 840 | Tablets |
| `expanded` | 1200 | Desktops |

### Helpers

| Property | Type | Description |
|----------|------|-------------|
| `sizeClass` | string | `"compact"`, `"medium"`, or `"expanded"` |
| `isCompact` | bool | True if width < 600 |
| `isMedium` | bool | True if width 600-1199 |
| `isExpanded` | bool | True if width >= 1200 |
| `gridColumns` | int | Responsive column count (4, 6, or width/96) |
| `contentMaxWidth` | int | 1200 (caps ultra-wide) |
| `margins` | int | 16 (compact), 24 (medium), 32 (expanded) |

### Usage

```qml
GridLayout {
    columns: SSize.gridColumns

    // Children adapt to screen size
}
```

## Conventions

- **Always use STheme** for colors, spacing, and radii — never hardcode visual constants
- **Use Layouts** (`ColumnLayout`, `RowLayout`, `GridLayout`) over positioners (`Column`, `Row`, `Grid`)
- **SIcon hit targets:** `SIcon` constrains its max size — wrap in a `Rectangle` for larger click areas
- **SCard content:** SCard's default content is a `ColumnLayout` — place children directly inside, don't nest another `ColumnLayout`
