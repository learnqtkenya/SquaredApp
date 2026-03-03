# src/ — C++ Source and CMake Conventions

## Module Layout

```
src/
├── main.cpp                    # Application entry point
├── core/                       # Host app logic (AppManifest, AppRunner, AppInstaller, etc.)
└── sdk/                        # QML modules exposed to mini apps
    ├── ui/                     # Squared.UI — component library (Phase 1)
    ├── storage/                # Squared.Storage — sandboxed persistence (Phase 2)
    └── core/                   # Squared.Core — lifecycle + metadata (Phase 2)
```

## C++20 Patterns

- Use `std::optional<T>` for values that may not exist.
- Use `std::expected<T, E>` for operations that can fail with an error description.
- Use structured bindings: `auto [key, value] = pair;`
- Use `auto` when the type is obvious from the right-hand side.
- No exceptions. Error handling via return types only.

## Qt-Specific Conventions

### Memory Management
- QObject-derived classes use Qt parent-child ownership. No smart pointers.
- Non-QObject helper structs can use value semantics or `std::unique_ptr`.
- Explicitly manage lifetime only for objects with no QObject parent (e.g., `QQmlContext` in AppRunner).

### QML Registration
```cpp
// In header — declarative registration
class MyType : public QObject {
    Q_OBJECT
    QML_ELEMENT                    // Registers as "MyType" in QML
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    // ...
};

// For singletons:
class MySingleton : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT
    // ...
};
```

Never use `qmlRegisterType()` — use `QML_ELEMENT` / `QML_SINGLETON` macros exclusively.

### String Literals
```cpp
// Performance-sensitive paths:
auto s = QStringLiteral("hello");
auto s2 = u"hello"_s;

// Regular code — plain string literals are fine:
qWarning() << "Something happened";
```

### Headers
- Forward declare where possible instead of including.
- Mark single-argument constructors `explicit`.
- Keep headers minimal — implementation in `.cpp` files.

## CMake Patterns

### Root CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.21)
project(Squared VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Test)
qt_standard_project_setup(REQUIRES 6.10)

add_subdirectory(src/sdk/ui)
# Future phases add more subdirectories
```

### QML Module Registration
```cmake
qt_add_qml_module(SquaredUI
    URI Squared.UI
    VERSION 1.0
    QML_FILES
        STheme.qml
        SButton.qml
        # ...
    RESOURCES
        fonts/Inter-Regular.otf
        fonts/Inter-SemiBold.otf
        fonts/MaterialSymbolsOutlined.otf
)
```

### Test Registration
```cmake
qt_add_executable(tst_sbutton tst_SButton.cpp)
target_link_libraries(tst_sbutton PRIVATE Qt6::Test Qt6::Quick SquaredUI)
add_test(NAME tst_sbutton COMMAND tst_sbutton)
```

## Build Commands

```bash
cmake -G Ninja -B build -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/gcc_64
cmake --build build
QT_QPA_PLATFORM=offscreen ctest --test-dir build --output-on-failure
```
