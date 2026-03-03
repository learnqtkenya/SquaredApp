# src/sdk/ui/ — Phase 1: Squared.UI Component Library

## Overview

Self-contained QML module (`Squared.UI`) with a themed component set. Independently testable — no runtime, no app loading. This is the foundation every mini app builds on.

## QML Module Registration

- URI: `Squared.UI`
- Version: `1.0`
- Registered via `qt_add_qml_module()` in `CMakeLists.txt`
- All QML files, fonts, and icon font bundled as Qt resources

## Bundled Assets

### Inter Font
- Files: `fonts/Inter-Regular.otf` (400), `fonts/Inter-SemiBold.otf` (600)
- Loaded via `QFontDatabase::addApplicationFont()` in a C++ plugin init or a QML singleton initializer
- STheme font properties reference `"Inter"` family with appropriate weight

### Material Symbols Outlined
- File: `fonts/MaterialSymbolsOutlined.otf`
- SIcon renders icons as `Text` items using this font family
- Icon names map to Unicode codepoints via `IconCodes.qml` (a singleton with readonly properties)
- Example: `IconCodes.home` → `"\ue88a"`, `IconCodes.search` → `"\ue8b6"`
- This approach scales perfectly and avoids bundling hundreds of SVG files

## STheme Singleton

All visual constants. No hardcoded colors/spacing/fonts anywhere in components.

```qml
pragma Singleton
import QtQuick

QtObject {
    // Colors
    readonly property color primary: "#6366F1"
    readonly property color primaryVariant: "#4F46E5"
    readonly property color surface: "#FFFFFF"
    readonly property color surfaceVariant: "#F8FAFC"
    readonly property color background: "#F1F5F9"
    readonly property color text: "#0F172A"
    readonly property color textSecondary: "#64748B"
    readonly property color border: "#E2E8F0"
    readonly property color error: "#EF4444"
    readonly property color success: "#22C55E"

    // Spacing (density-independent pixels)
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 16
    readonly property int spacingLg: 24
    readonly property int spacingXl: 32

    // Border radii
    readonly property int radiusSmall: 6
    readonly property int radiusMedium: 10
    readonly property int radiusLarge: 16

    // Font definitions (use Inter family, loaded from bundled .otf)
    readonly property font heading: Qt.font({family: "Inter", pixelSize: 24, weight: Font.DemiBold})
    readonly property font subheading: Qt.font({family: "Inter", pixelSize: 18, weight: Font.DemiBold})
    readonly property font body: Qt.font({family: "Inter", pixelSize: 14, weight: Font.Normal})
    readonly property font caption: Qt.font({family: "Inter", pixelSize: 12, weight: Font.Normal})
}
```

## Components (implement in this order)

### 1. SText
Themed text with variant property.
- **Properties:** `text: string`, `variant: string` (heading/subheading/body/caption), `color: color` (default: STheme.text)
- Applies font from STheme based on variant

### 2. SIcon
Icon display using Material Symbols font.
- **Properties:** `icon: string` (codepoint from IconCodes), `size: int` (default 24), `color: color` (default: STheme.text)
- Renders as `Text` with `font.family: "Material Symbols Outlined"`

### 3. SButton
Full button with style variants.
- **Properties:** `text: string`, `icon: string` (optional), `style: string` (Primary/Secondary/Ghost/Danger), `enabled: bool`
- **Signals:** `clicked()`
- **States:** default, hover, pressed, disabled — each with distinct colors from STheme

### 4. SDivider
Horizontal line.
- **Properties:** `color: color` (default: STheme.border)
- 1px `Rectangle` with full width

### 5. SSpacer
Configurable empty space.
- **Properties:** `size: int` (default: STheme.spacingMd)
- Empty `Item` with height/width set to size

### 6. SCard
Elevated surface container.
- **Properties:** `radius: int` (default: STheme.radiusMedium)
- Surface background, border, subtle elevation/shadow
- Default content is a `Column` layout

### 7. SCardHeader
Title + optional subtitle inside a card.
- **Properties:** `title: string`, `subtitle: string` (optional)
- Uses SText heading/body variants

### 8. SCardBody
Content area inside a card.
- **Properties:** `default property alias content: column.data`
- Padded Column layout

### 9. SListItem
List row with icon, text, optional trailing content.
- **Properties:** `title: string`, `subtitle: string`, `icon: string`, `trailing: Component`
- **Signals:** `clicked()`

### 10. SBadge
Small colored label.
- **Properties:** `text: string`, `color: color` (default: STheme.primary), `textColor: color`
- Rounded pill shape

### 11. STextField
Styled text input.
- **Properties:** `text: string`, `placeholderText: string`, `enabled: bool`
- **Signals:** `textChanged()`, `accepted()`
- Focus border color change, themed placeholder

### 12. SSwitch
Toggle switch.
- **Properties:** `checked: bool`, `enabled: bool`, `text: string` (optional label)
- **Signals:** `toggled()`
- Animated thumb slide

### 13. SSearchField
Text field with search icon and clear button.
- **Properties:** `text: string`, `placeholderText: string` (default: "Search...")
- **Signals:** `textChanged()`, `accepted()`
- Leading SIcon (search), trailing clear button (visible when text not empty)

### 14. SProgressBar
Determinate and indeterminate modes.
- **Properties:** `value: real` (0.0-1.0), `indeterminate: bool`
- STheme.primary for fill color, animated indeterminate mode

### 15. SLoadingSpinner
Animated spinner.
- **Properties:** `size: int` (default: 32), `color: color` (default: STheme.primary), `running: bool`
- Rotation animation when running

### 16. SEmptyState
Empty content placeholder.
- **Properties:** `icon: string`, `title: string`, `description: string`, `actionText: string`
- **Signals:** `actionClicked()`
- Centered layout with SIcon + SText + optional SButton

### 17. SPage
Full page container.
- **Properties:** `title: string`
- Fills parent, STheme.background fill
- Default content column

### 18. SScrollView
Themed scrollable area.
- **Properties:** `default property alias content: flickable.contentItem.data`
- Wraps Flickable with themed scrollbar

### 19. SMetric
Large value display for dashboards.
- **Properties:** `value: var`, `label: string`, `icon: string` (optional)
- Large text for value, caption for label

### 20. SToast
Transient notification popup.
- **Properties:** `text: string`, `duration: int` (default: 3000), `type: string` (info/success/error)
- **Methods:** `show(text, type)`
- Auto-dismiss with fade animation, positioned at bottom

### 21. SDialog
Modal dialog.
- **Properties:** `title: string`, `content: Component`, `visible: bool`
- **Methods:** `open()`, `close()`
- **Signals:** `accepted()`, `rejected()`
- Overlay + centered card with title, content area, action buttons

### 22. SDropdown
Select from a list.
- **Properties:** `model: var`, `currentIndex: int`, `currentText: string`, `placeholderText: string`
- **Signals:** `activated(index)`
- Popup list with themed items

### 23. SCheckbox
Themed checkbox.
- **Properties:** `checked: bool`, `text: string`, `enabled: bool`
- **Signals:** `toggled()`

### 24. SRadioGroup
Group of radio buttons.
- **Properties:** `model: var`, `currentIndex: int`
- **Signals:** `selected(index)`
- Exclusive selection within group

### 25. SSlider
Range slider.
- **Properties:** `value: real`, `from: real`, `to: real`, `stepSize: real`
- **Signals:** `moved()`
- Themed track and handle

### 26. SGrid
Responsive grid layout.
- **Properties:** `columns: int`, `spacing: int` (default: STheme.spacingMd)
- Wraps `Grid` or `GridLayout` with responsive column count

### 27. SSection
Titled group with optional divider.
- **Properties:** `title: string`, `showDivider: bool` (default: true)
- SText heading + SDivider + content column

### 28. SAvatar
Circular image or initials display.
- **Properties:** `source: url` (image), `initials: string`, `size: int` (default: 40)
- Shows image if source set, otherwise colored circle with initials

## ComponentGallery.qml

A scrollable page rendering every component for visual verification. Must:
- Import `Squared.UI 1.0`
- Show each component in a labeled section
- Demonstrate all variants/states (e.g., all SButton styles, SProgressBar both modes)
- Be launchable standalone: `QT_QPA_PLATFORM=xcb ./build/ComponentGallery`

## Test Requirements

Each component gets `tests/qml/tst_S<Component>.qml` using `QtTest`:

**Every component:**
- Instantiates without errors
- Key properties bind and update correctly
- STheme values are applied (colors, spacing, fonts)
- Enabled/disabled states work

**Specific tests:**
- SButton: click signal fires, all 4 styles render differently
- STextField: text input works, accepted signal on Enter
- SSwitch: toggled signal fires, checked property updates
- SDialog: open/close works, accepted/rejected signals
- SToast: show/dismiss works, auto-dismiss after duration
- SSearchField: clear button appears with text, clears on click
- SProgressBar: indeterminate animation runs, determinate shows correct fill
- SDropdown: activated signal with correct index
- SCheckbox: toggled signal, checked state
- SRadioGroup: exclusive selection
- SSlider: value changes on drag, respects from/to/stepSize

## Layout Convention

**Use QML Layouts (`ColumnLayout`, `RowLayout`, `GridLayout`) instead of positioners (`Column`, `Row`, `Grid`).** Layouts provide better responsiveness via `Layout.fillWidth`, `Layout.fillHeight`, and `Layout.preferredWidth`/`Layout.preferredHeight`. Components should use `import QtQuick.Layouts` and structure internal layout with Layout types.

## Done Criteria

- `ctest` passes all QML component tests
- `ComponentGallery.qml` launches and renders every component
- Zero hardcoded colors, fonts, or spacing — everything via STheme
- Material Symbols icons render correctly in SIcon
- Inter font renders correctly in all text
