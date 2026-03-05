#!/bin/sh
# Copies Squared SDK sources into the Go embed directory.
# Run before building the CLI so the SDK is embedded in the binary.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DST_DIR="$SCRIPT_DIR/internal/sdk/files"

# Clean old layout
rm -rf "$DST_DIR/Squared" "$DST_DIR/ui" "$DST_DIR/api" "$DST_DIR/runtime" "$DST_DIR/runner"

# --- Squared.UI (pure QML) ---
UI_SRC="$ROOT_DIR/src/sdk/ui"
UI_DST="$DST_DIR/ui"
mkdir -p "$UI_DST"

cp "$UI_SRC/qmldir" "$UI_DST/qmldir"
for f in "$UI_SRC"/*.qml; do
    base="$(basename "$f")"
    case "$base" in
        ComponentGallery.qml) continue ;;
    esac
    cp "$f" "$UI_DST/$base"
done

# Add SSize singleton to qmldir if missing (added via CMake in host)
if ! grep -q "SSize" "$UI_DST/qmldir"; then
    sed -i '/^singleton IconCodes/a singleton SSize 1.0 SSize.qml' "$UI_DST/qmldir"
fi

# --- Squared.SDK (C++ API types for intellisense) ---
API_SRC="$ROOT_DIR/src/sdk/api"
API_DST="$DST_DIR/api"
mkdir -p "$API_DST"

cp "$API_SRC/CMakeLists.txt" "$API_DST/"
cp "$API_SRC"/*.h "$API_DST/"

# --- Top-level SDK CMakeLists.txt ---
{
    cat << 'CMAKE_HEADER'
# Squared SDK — provides IDE autocomplete for Squared.UI and Squared.SDK
# Included by mini app projects via add_subdirectory().

# Singletons must be declared before qt_add_qml_module processes QML_FILES
set_source_files_properties(ui/STheme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
set_source_files_properties(ui/IconCodes.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
set_source_files_properties(ui/SSize.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(SquaredUI
    URI Squared.UI
    VERSION 1.0
    STATIC
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Squared/UI"
    QML_FILES
CMAKE_HEADER

    for f in "$UI_DST"/*.qml; do
        echo "        ui/$(basename "$f")"
    done

    cat << 'CMAKE_FOOTER'
)

add_subdirectory(api)
CMAKE_FOOTER
} > "$DST_DIR/CMakeLists.txt"

UI_COUNT=$(ls "$UI_DST"/*.qml 2>/dev/null | wc -l)
API_COUNT=$(ls "$API_DST"/*.h 2>/dev/null | wc -l)
echo "Synced $UI_COUNT QML files + $API_COUNT API headers to $DST_DIR"
