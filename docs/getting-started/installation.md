# Installation

## Install the CLI

=== "Linux / macOS"

    ```bash
    curl -fsSL https://squared.co.ke/install.sh | sh
    ```

=== "Windows (PowerShell)"

    ```powershell
    irm https://squared.co.ke/install.ps1 | iex
    ```

=== "From source"

    ```bash
    git clone https://github.com/learnqtkenya/SquaredApp.git
    cd SquaredApp/tools/squared-cli
    go build -o squared .
    # Move 'squared' to a directory in your PATH
    ```

    Requires Go 1.25+.

## Set Up the SDK

Run `squared setup` once after installing the CLI:

```bash
squared setup
```

This installs:

- **Squared host app** — pre-built binary for running and previewing apps
- **SDK type stubs** — IDE autocomplete for `Squared.UI` and `Squared.SDK`

Use `--force` to reinstall if needed:

```bash
squared setup --force
```

## IDE Support

The SDK provides autocomplete for:

- **Squared.UI** — 28 themed QML components (`SButton`, `SCard`, `SPage`, etc.) plus `STheme` and `IconCodes`
- **Squared.SDK** — `Storage`, `SecureStorage`, `Network`, and `App` APIs

Projects created with `squared init` include a `CMakeLists.txt` that references the SDK. Run `cmake -B build` in your project to generate type info for qmlls.

Works with any editor that supports Qt's QML Language Server:

- **Qt Creator** — built-in support
- **VS Code** — install the [Qt QML extension](https://marketplace.visualstudio.com/items?itemName=nicemicro.qml-support)
- **Neovim** — configure qmlls as an LSP server

## Prerequisites (Building from Source)

If you want to build the host app from source instead of using `squared setup`:

- **Qt 6.10.2** — set `QT_DIR` or install to `/opt/Qt/6.10.2`
- **CMake 3.21+** and **Ninja**
- **C++20 compiler** (GCC 13+, Clang 16+, MSVC 2022)

```bash
git clone https://github.com/learnqtkenya/SquaredApp.git
cd SquaredApp
cmake -G Ninja -B build -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/gcc_64
cmake --build build
```

## Verify

```bash
squared version
squared validate --help
```
