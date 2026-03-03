# tests/ — Testing Standards and Patterns

## Overview

All tests runnable via `ctest`. Headless by default using `QT_QPA_PLATFORM=offscreen`.

## File Organization

```
tests/
├── tst_appmanifest.cpp       # Phase 2
├── tst_apprunner.cpp          # Phase 2
├── tst_appstorage.cpp         # Phase 2
├── tst_appinstaller.cpp       # Phase 3
├── tst_appcatalog.cpp         # Phase 3
├── tst_appregistry.cpp        # Phase 3
└── qml/
    ├── tst_STheme.qml         # Phase 1
    ├── tst_SButton.qml        # Phase 1
    ├── tst_SCard.qml          # Phase 1
    ├── tst_STextField.qml     # Phase 1
    └── tst_S*.qml             # One per Squared.UI component
```

## C++ Tests (QTest)

Pattern for `tst_*.cpp`:

```cpp
#include <QtTest>
#include "AppManifest.h"

class tst_AppManifest : public QObject {
    Q_OBJECT

private slots:
    void initTestCase();          // One-time setup
    void cleanupTestCase();       // One-time teardown
    void init();                  // Per-test setup
    void cleanup();               // Per-test teardown

    void validManifestParses();
    void missingRequiredFieldReturnsNullopt();
    // ...
};
```

### CMake Registration
```cmake
qt_add_executable(tst_appmanifest tst_appmanifest.cpp)
target_link_libraries(tst_appmanifest PRIVATE Qt6::Test SquaredCore)
add_test(NAME tst_appmanifest COMMAND tst_appmanifest)
```

## QML Tests (QML TestCase)

Pattern for `tst_S*.qml`:

```qml
import QtQuick
import QtTest
import Squared.UI 1.0

TestCase {
    name: "SButton"
    when: windowShown

    SButton {
        id: button
        text: "Test"
        style: "Primary"
    }

    function test_instantiation() {
        verify(button !== null)
    }

    function test_textProperty() {
        compare(button.text, "Test")
        button.text = "Changed"
        compare(button.text, "Changed")
    }

    function test_clickSignal() {
        var clicked = false
        button.clicked.connect(function() { clicked = true })
        mouseClick(button)
        verify(clicked)
    }

    function test_themeColors() {
        // Verify STheme values are applied
        compare(button.someColorProperty, STheme.primary)
    }

    function test_disabledState() {
        button.enabled = false
        // Verify visual/behavioral changes
        button.enabled = true
    }
}
```

### QML Test Runner

QML tests need a C++ test runner that loads the QML file:

```cpp
#include <QtQuickTest>
QUICK_TEST_MAIN(tst_SButton)
```

Or use `qmltestrunner` if available. Register via CMake:

```cmake
qt_add_executable(tst_sbutton tst_sbutton_runner.cpp)
target_link_libraries(tst_sbutton PRIVATE Qt6::QuickTest SquaredUI)
set_target_properties(tst_sbutton PROPERTIES
    QT_QML_TEST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/qml"
)
add_test(NAME tst_sbutton COMMAND tst_sbutton)
```

## Running Tests

```bash
# All tests
QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure

# Single test
QT_QPA_PLATFORM=offscreen ./build/tests/tst_appmanifest

# Verbose
QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure -V
```

## Test Coverage by Phase

| Phase | Tests |
|-------|-------|
| 1 | tst_STheme, tst_S* (all 28 components) |
| 2 | tst_appmanifest, tst_apprunner, tst_appstorage |
| 3 | tst_appinstaller, tst_appcatalog, tst_appregistry |
| 4 | CLI tests (pytest in tools/squared-cli/) |
| 5 | Integration tests for first-party apps |
