# Squared

A Qt6/QML super app — a runtime and distribution platform for QML applications. Developers build QML apps, package them as `.sqapp` bundles, publish to the Squared Store, and users discover and run them inside the Squared host app.

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Languages | C++20, QML |
| Qt | 6.10.2 |
| Build | CMake 3.21+ with Ninja |
| UI | Qt Quick, Qt Quick Controls, Qt Quick Layouts |
| Platforms | Desktop Linux, Android (arm64, armv7), Embedded Linux ARM |
| Testing | QTest (C++), QML TestCase (QML) |
| Icons | Material Symbols Outlined (variable font) |
| Fonts | Inter (variable font, bundled) |

## Prerequisites

- **Qt 6.10.2** — installed at `/opt/Qt/6.10.2` (or adjust `CMAKE_PREFIX_PATH`)
- **CMake 3.21+**
- **Ninja** build system
- **C++20** compatible compiler (GCC 11+, Clang 14+)

## Building

### Desktop Linux

```bash
# Configure
cmake -G Ninja -B build -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/gcc_64

# Build
cmake --build build
```

### Android (arm64)

```bash
cmake -G Ninja -B build-android \
  -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/android_arm64_v8a \
  -DCMAKE_TOOLCHAIN_FILE=/opt/Qt/6.10.2/android_arm64_v8a/lib/cmake/Qt6/qt.toolchain.cmake \
  -DANDROID_SDK_ROOT=$ANDROID_SDK_ROOT

cmake --build build-android
```

### Embedded Linux ARM

```bash
cmake -G Ninja -B build-arm \
  -DCMAKE_TOOLCHAIN_FILE=/path/to/arm-toolchain.cmake \
  -DCMAKE_PREFIX_PATH=/path/to/qt-arm-sysroot

cmake --build build-arm
```

## Testing

All tests run headlessly using the offscreen QPA platform.

```bash
# Run all tests
QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure

# Run a single test
QT_QPA_PLATFORM=offscreen ctest --test-dir build -R tst_SButton --output-on-failure

# Verbose output
QT_QPA_PLATFORM=offscreen ctest --test-dir build -V
```

### Current Test Status

29 QML component tests covering all Squared.UI components:

| Component | Test File |
|-----------|-----------|
| STheme | `tests/qml/tst_STheme.qml` |
| SText | `tests/qml/tst_SText.qml` |
| SIcon | `tests/qml/tst_SIcon.qml` |
| SButton | `tests/qml/tst_SButton.qml` |
| SDivider | `tests/qml/tst_SDivider.qml` |
| SSpacer | `tests/qml/tst_SSpacer.qml` |
| SCard | `tests/qml/tst_SCard.qml` |
| SCardHeader | `tests/qml/tst_SCardHeader.qml` |
| SCardBody | `tests/qml/tst_SCardBody.qml` |
| SListItem | `tests/qml/tst_SListItem.qml` |
| SBadge | `tests/qml/tst_SBadge.qml` |
| STextField | `tests/qml/tst_STextField.qml` |
| SSwitch | `tests/qml/tst_SSwitch.qml` |
| SSearchField | `tests/qml/tst_SSearchField.qml` |
| SProgressBar | `tests/qml/tst_SProgressBar.qml` |
| SLoadingSpinner | `tests/qml/tst_SLoadingSpinner.qml` |
| SEmptyState | `tests/qml/tst_SEmptyState.qml` |
| SPage | `tests/qml/tst_SPage.qml` |
| SScrollView | `tests/qml/tst_SScrollView.qml` |
| SMetric | `tests/qml/tst_SMetric.qml` |
| SToast | `tests/qml/tst_SToast.qml` |
| SDialog | `tests/qml/tst_SDialog.qml` |
| SDropdown | `tests/qml/tst_SDropdown.qml` |
| SCheckbox | `tests/qml/tst_SCheckbox.qml` |
| SRadioGroup | `tests/qml/tst_SRadioGroup.qml` |
| SSlider | `tests/qml/tst_SSlider.qml` |
| SGrid | `tests/qml/tst_SGrid.qml` |
| SSection | `tests/qml/tst_SSection.qml` |
| SAvatar | `tests/qml/tst_SAvatar.qml` |

## Project Structure

```
squared/
├── CMakeLists.txt              # Root build configuration
├── src/
│   └── sdk/
│       └── ui/                 # Squared.UI QML module
│           ├── CMakeLists.txt  # Module registration (qt_add_qml_module)
│           ├── STheme.qml      # Theme singleton (colors, spacing, radii, fonts)
│           ├── IconCodes.qml   # Material Symbols codepoint mappings
│           ├── S*.qml          # 28 UI components
│           ├── ComponentGallery.qml  # Visual verification app
│           └── fonts/          # Bundled Inter + Material Symbols fonts
├── tests/
│   └── qml/
│       ├── runner.cpp          # Shared test runner (QUICK_TEST_MAIN_WITH_SETUP)
│       ├── CMakeLists.txt      # Test registration
│       └── tst_S*.qml          # 29 QML test files
├── src/core/                   # App runtime (Phase 2-3)
├── src/sdk/storage/            # Sandboxed persistence (Phase 2)
├── src/sdk/core/               # App lifecycle (Phase 2)
├── qml/                        # Host app pages (Phase 2+)
├── tools/squared-cli/          # Developer CLI (Phase 4)
└── examples/apps/              # Example .sqapp projects (Phase 5)
```

## Squared.UI Component Library

The `Squared.UI` module provides 28 themed QML components. All components use `STheme` for visual constants — no hardcoded colors, spacing, or fonts.

### Theme (STheme)

| Category | Properties |
|----------|-----------|
| Colors | `primary`, `primaryVariant`, `surface`, `surfaceVariant`, `background`, `text`, `textSecondary`, `border`, `error`, `success` |
| Spacing | `spacingXs` (4), `spacingSm` (8), `spacingMd` (16), `spacingLg` (24), `spacingXl` (32) |
| Radii | `radiusSmall` (6), `radiusMedium` (10), `radiusLarge` (16) |
| Fonts | `heading` (24px, DemiBold), `subheading` (18px, DemiBold), `body` (14px), `caption` (12px) |

### Components

| Component | Description |
|-----------|-----------|
| SText | Themed text with variant (heading/subheading/body/caption) |
| SIcon | Material Symbols icon display |
| SButton | Styled button (Primary/Secondary/Ghost/Danger) |
| SDivider | Horizontal separator line |
| SSpacer | Configurable empty space |
| SCard | Elevated surface container |
| SCardHeader | Card title + subtitle |
| SCardBody | Card content area |
| SListItem | Icon + title + subtitle + trailing content |
| SBadge | Small colored label |
| STextField | Styled text input |
| SSwitch | Toggle switch |
| SSearchField | Search input with icon and clear button |
| SProgressBar | Determinate and indeterminate progress |
| SLoadingSpinner | Animated spinner |
| SEmptyState | Placeholder with icon, title, description, action |
| SPage | Full page container with background |
| SScrollView | Themed scrollable area |
| SMetric | Large value display for dashboards |
| SToast | Transient notification popup |
| SDialog | Modal dialog with actions |
| SDropdown | Select from a list |
| SCheckbox | Themed checkbox |
| SRadioGroup | Radio button group |
| SSlider | Range slider |
| SGrid | Responsive grid layout |
| SSection | Titled group with divider |
| SAvatar | Circular image or initials |

### Component Gallery

A visual verification app that renders every component on a scrollable page:

```bash
# Build
cmake --build build --target ComponentGallery

# Launch (requires a display — X11 or Wayland)
./build/src/sdk/ui/ComponentGallery
```

## Development Phases

| Phase | Status | Description |
|-------|--------|-----------|
| 1 | Complete | Squared.UI Component Library + STheme |
| 2 | Planned | App Manifest + App Runner + SDK singletons |
| 3 | Planned | App Installer + Store Catalog |
| 4 | Planned | Developer CLI (Python) |
| 5 | Planned | First-Party Apps + Polish |
| 6 | Planned | Store Backend (separate repo) |

## License

All rights reserved.
