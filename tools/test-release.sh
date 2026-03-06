#!/usr/bin/env bash
# Test the release-host workflow locally.
# Simulates the CI build/install/package steps using the local Qt installation.
#
# Usage: ./tools/test-release.sh [--clean]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$SCRIPT_DIR/build-release"
INSTALL_DIR="$SCRIPT_DIR/install"
QT_PREFIX="${CMAKE_PREFIX_PATH:-/opt/Qt/6.10.2/gcc_64}"
PLATFORM="linux"
ARCH="amd64"

cd "$SCRIPT_DIR"

if [[ "${1:-}" == "--clean" ]]; then
    echo "Cleaning previous release build..."
    rm -rf "$BUILD_DIR" "$INSTALL_DIR"
fi

echo "=== Step 1: Configure ==="
cmake -G Ninja -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QT_PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"

echo ""
echo "=== Step 2: Build ==="
cmake --build "$BUILD_DIR" --target Squared

echo ""
echo "=== Step 3: Install (qt_generate_deploy_app_script) ==="
cmake --install "$BUILD_DIR"

echo ""
echo "=== Step 4: Verify install contents ==="
echo "Install directory:"
ls "$INSTALL_DIR/"
echo ""
echo "Binary:"
ls -lh "$INSTALL_DIR/bin/Squared"
echo ""
echo "Libraries bundled:"
ls "$INSTALL_DIR/lib/" | wc -l
echo "Plugins bundled:"
find "$INSTALL_DIR/plugins/" -name "*.so" | wc -l

echo ""
echo "=== Step 5: Test binary runs ==="
# offscreen plugin isn't bundled (test-only), use xcb for deployed binary
"$INSTALL_DIR/bin/Squared" --version

echo ""
echo "=== Step 6: Package ==="
ARCHIVE="squared-host_${PLATFORM}_${ARCH}.tar.gz"
tar czf "$ARCHIVE" -C "$INSTALL_DIR" .
echo "Created: $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))"

echo ""
echo "=== Step 7: Verify archive ==="
tar tzf "$ARCHIVE" | head -10
echo "..."
echo "Total files: $(tar tzf "$ARCHIVE" | wc -l)"

echo ""
echo "=== All steps passed ==="
echo ""
echo "To release: git tag host-v0.1.0 && git push --tags"
