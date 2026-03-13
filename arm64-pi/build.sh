#!/bin/bash
set -e

APP_NAME="Squared"
REBUILD_SYSROOT=false

for arg in "$@"; do
    case "$arg" in
        --rebuild-sysroot) REBUILD_SYSROOT=true ;;
        --prune)
            echo "=== Cleaning up Docker artifacts ==="
            docker rm -f tmpsysroot tmpbuild 2>/dev/null || true
            docker image prune -f 2>/dev/null || true
            docker builder prune --filter "until=168h" -f 2>/dev/null || true
            docker system df
            exit 0
            ;;
    esac
done

export DOCKER_BUILDKIT=1

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$SCRIPT_DIR"

# Stage 1: Generate sysroot if missing or forced
if [ ! -f rasp.tar.gz ] || [ "$REBUILD_SYSROOT" = true ]; then
    echo "=== Stage 1: Generating Raspberry Pi sysroot ==="
    docker buildx build --platform linux/arm64 --load -f DockerFileRasp -t raspsysroot .
    docker rm -f tmpsysroot 2>/dev/null || true
    docker create --name tmpsysroot raspsysroot
    docker cp tmpsysroot:/build/rasp.tar.gz .
    docker rm tmpsysroot
    docker rmi raspsysroot 2>/dev/null || true
    echo "=== Sysroot ready (rasp.tar.gz) ==="
else
    echo "=== Stage 1: Skipped (rasp.tar.gz exists, use --rebuild-sysroot to force) ==="
fi

# Prepare project directory for Docker COPY
rm -rf project
mkdir -p project

# Copy application source (excluding build artifacts and deploy dir)
rsync -a \
    --exclude='build*' \
    --exclude='arm64-pi' \
    --exclude='.git' \
    "$PROJECT_DIR/" project/

# Stage 2: Build Qt and application
echo "=== Stage 2: Building $APP_NAME for Raspberry Pi ==="
docker rm -f tmpbuild 2>/dev/null || true
docker build -t squaredcrossbuild .
docker create --name tmpbuild squaredcrossbuild

# Extract install directory (application + Qt runtime bundled)
mkdir -p out
rm -rf out/install-arm
docker cp tmpbuild:/build/install-arm ./out/install-arm

# Extract Qt runtime for first-time Pi setup
if [ ! -f out/qt-pi-binaries.tar.gz ]; then
    echo "=== Extracting Qt runtime ==="
    docker cp tmpbuild:/build/qt-pi-binaries.tar.gz ./out/
fi

docker rm tmpbuild
docker image prune -f 2>/dev/null || true

# Clean up temporary build context
rm -rf project

echo "=== Build complete ==="
echo ""
echo "Deploy to Raspberry Pi:"
echo "  scp -r arm64-pi/out/install-arm/* user@pi:/opt/squared/"
echo ""
echo "First-time Qt runtime setup on Pi:"
echo "  scp arm64-pi/out/qt-pi-binaries.tar.gz user@pi:~/"
echo "  ssh user@pi 'sudo mkdir -p /usr/local/qt6 && sudo tar -xf qt-pi-binaries.tar.gz -C /usr/local/qt6'"
echo ""
echo "Run on Pi:"
echo "  QT_QPA_PLATFORM=eglfs /opt/squared/bin/Squared"
