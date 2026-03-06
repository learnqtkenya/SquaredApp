# Component Reference

All 28 Squared.UI components organized by category.

## Text & Icons

### SText

Themed text with variant-based font switching.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | | Text content |
| `variant` | string | `"body"` | `"heading"`, `"subheading"`, `"body"`, `"caption"` |
| `color` | color | `STheme.text` | Text color |

```qml
SText { text: "Title"; variant: "heading" }
SText { text: "Subtitle"; variant: "subheading" }
SText { text: "Body text" }
SText { text: "Small print"; variant: "caption"; color: STheme.textSecondary }
```

### SIcon

Material Symbols icon display.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `icon` | string | | Unicode codepoint from `IconCodes` |
| `size` | int | 24 | Icon size in pixels |
| `color` | color | `STheme.text` | Icon color |

```qml
SIcon { icon: IconCodes.home; size: 28; color: STheme.primary }
```

!!! tip
    `SIcon` sets `Layout.maximumWidth/Height` to its size. To make a larger tap target, wrap it in a `Rectangle`.

---

## Buttons & Inputs

### SButton

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | | Button label |
| `iconSource` | string | `""` | Optional leading icon |
| `style` | string | `"Primary"` | `"Primary"`, `"Secondary"`, `"Ghost"`, `"Danger"` |

| Signal | Description |
|--------|-------------|
| `clicked()` | Fires on tap |

```qml
SButton { text: "Save"; onClicked: save() }
SButton { text: "Delete"; style: "Danger"; iconSource: IconCodes.deleteIcon }
SButton { text: "Cancel"; style: "Ghost" }
SButton { text: "Edit"; style: "Secondary"; iconSource: IconCodes.edit }
```

### STextField

Single-line text input.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | | Current value |
| `placeholderText` | string | | Placeholder |

```qml
STextField {
    placeholderText: "Enter your name"
    onAccepted: console.log(text)
}
```

### SSearchField

Text field with search icon and clear button.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | | Current value |
| `placeholderText` | string | `"Search..."` | Placeholder |

```qml
SSearchField {
    onTextChanged: filterList(text)
}
```

### SSwitch

Toggle switch with animated thumb.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `checked` | bool | `false` | Toggle state |
| `text` | string | `""` | Optional label |

| Signal | Description |
|--------|-------------|
| `toggled()` | Fires when state changes |

```qml
SSwitch { text: "Enable notifications"; onToggled: save(checked) }
```

### SCheckbox

Square checkbox with optional label.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `checked` | bool | `false` | Check state |
| `text` | string | `""` | Optional label |

| Signal | Description |
|--------|-------------|
| `toggled()` | Fires when state changes |

```qml
SCheckbox { text: "Remember me"; onToggled: Storage.set("remember", checked) }
```

### SSlider

Range slider.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `value` | real | | Current value |
| `from` | real | 0 | Minimum |
| `to` | real | 1 | Maximum |
| `stepSize` | real | 0 | Step increment |

```qml
SSlider { from: 0; to: 100; stepSize: 1; onMoved: volume = value }
```

### SDropdown

Themed combobox.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `model` | var | | Array of options |
| `currentIndex` | int | -1 | Selected index |
| `placeholderText` | string | `"Select..."` | Placeholder |

```qml
SDropdown {
    model: ["Small", "Medium", "Large"]
    onActivated: (index) => console.log("Selected:", currentText)
}
```

### SRadioGroup

Exclusive radio button group.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `model` | var | | Array of strings |
| `currentIndex` | int | -1 | Selected index |

| Signal | Description |
|--------|-------------|
| `selected(index)` | Fires when selection changes |

```qml
SRadioGroup {
    model: ["Daily", "Weekly", "Monthly"]
    onSelected: (index) => Storage.set("frequency", index)
}
```

---

## Layout Containers

### SCard

Elevated surface container.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `radius` | int | `STheme.radiusMedium` | Corner radius |

Default content is a `ColumnLayout` — place children directly inside:

```qml
SCard {
    SText { text: "Title"; variant: "subheading" }
    SText { text: "Content goes here" }
    SButton { text: "Action" }
}
```

!!! warning
    Don't nest a `ColumnLayout` inside `SCard` — its content area already is one.

### SCardHeader

Title + optional subtitle for cards.

| Property | Type | Description |
|----------|------|-------------|
| `title` | string | Header title |
| `subtitle` | string | Optional subtitle (hidden if empty) |

### SCardBody

Content area wrapper with default spacing.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `spacing` | int | 8 | Space between children |

### SPage

Full-page background container.

| Property | Type | Description |
|----------|------|-------------|
| `title` | string | Optional page heading |

```qml
SPage {
    title: "Settings"

    SCard { /* ... */ }
    SCard { /* ... */ }
}
```

### SScrollView

Themed scrollable area. Vertical scrollbar appears as needed, horizontal is always off.

```qml
SScrollView {
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        // Long content
    }
}
```

### SSection

Titled section with optional divider.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | string | | Section heading |
| `showDivider` | bool | `true` | Show divider line |

### SGrid

Responsive grid layout. Columns auto-adjust based on parent width (min 150px per column).

```qml
SGrid {
    SCard { /* ... */ }
    SCard { /* ... */ }
    SCard { /* ... */ }
}
```

---

## Display & Status

### SBadge

Small colored label.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | | Badge text |
| `badgeColor` | color | `STheme.primary` | Background |
| `textColor` | color | `STheme.surface` | Text color |

```qml
SBadge { text: "NEW" }
SBadge { text: "Error"; badgeColor: STheme.error }
```

### SDivider

Horizontal 1px line in `STheme.border` color.

```qml
SDivider {}
```

### SSpacer

Empty space item.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | int | `STheme.spacingMd` | Width and height |

### SAvatar

Circular image or initials display.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `source` | url | | Image path (uses initials if empty) |
| `initials` | string | | 1-2 character fallback |
| `size` | int | 40 | Diameter |

```qml
SAvatar { source: "photo.png"; size: 48 }
SAvatar { initials: "JD"; size: 32 }
```

### SMetric

Large value display for dashboards.

| Property | Type | Description |
|----------|------|-------------|
| `value` | var | Display value |
| `label` | string | Description |
| `icon` | string | Optional icon |

```qml
SMetric { value: "98%"; label: "Uptime"; icon: IconCodes.speed }
```

### SProgressBar

Determinate or indeterminate progress bar.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `value` | real | 0 | Progress 0.0 - 1.0 |
| `indeterminate` | bool | `false` | Animate continuously |

```qml
SProgressBar { value: 0.75 }
SProgressBar { indeterminate: true }
```

### SLoadingSpinner

Animated rotating arc.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | int | 32 | Diameter |
| `color` | color | `STheme.primary` | Arc color |
| `running` | bool | `true` | Animation on/off |

```qml
SLoadingSpinner { size: 48 }
```

### SEmptyState

Placeholder for empty content.

| Property | Type | Description |
|----------|------|-------------|
| `icon` | string | Large icon (64px) |
| `title` | string | Heading |
| `description` | string | Body text |
| `actionText` | string | Button label (hidden if empty) |

| Signal | Description |
|--------|-------------|
| `actionClicked()` | Fires when button is tapped |

```qml
SEmptyState {
    icon: IconCodes.empty
    title: "No items"
    description: "Add your first item to get started"
    actionText: "Add Item"
    onActionClicked: createItem()
}
```

---

## Feedback & Overlays

### SToast

Transient notification popup. Place once in your root page:

```qml
SPage {
    title: "My App"
    SToast { id: toast }

    SButton {
        text: "Save"
        onClicked: {
            save()
            toast.show("Saved!", "success")
        }
    }
}
```

| Method | Description |
|--------|-------------|
| `show(message, type)` | Show a toast. Type: `"info"`, `"success"`, `"error"`, `"warning"` |
| `dismiss()` | Remove the oldest toast |

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `duration` | int | 3500 | Auto-dismiss time in ms |

### SDialog

Modal dialog overlay.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | string | | Dialog heading |
| `acceptText` | string | `"OK"` | Confirm button label |
| `rejectText` | string | `"Cancel"` | Cancel button label |
| `showReject` | bool | `true` | Show cancel button |

| Method | Description |
|--------|-------------|
| `open()` | Show the dialog |
| `close()` | Hide the dialog |

| Signal | Description |
|--------|-------------|
| `accepted()` | Fires on confirm |
| `rejected()` | Fires on cancel or overlay click |

```qml
SDialog {
    id: confirmDialog
    title: "Delete item?"
    SText { text: "This action cannot be undone." }
    onAccepted: deleteItem()
}

SButton {
    text: "Delete"
    style: "Danger"
    onClicked: confirmDialog.open()
}
```
