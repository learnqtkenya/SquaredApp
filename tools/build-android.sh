#!/usr/bin/env bash
#
# Android build script for Squared
#
# Usage:
#   ./tools/build-android.sh                    # Build signed APK + AAB (arm64)
#   ./tools/build-android.sh --apk-only         # APK only
#   ./tools/build-android.sh --aab-only         # AAB only
#   ./tools/build-android.sh --debug            # Debug build (no signing)
#   ./tools/build-android.sh --clean            # Clean build directory first
#   ./tools/build-android.sh --create-keystore  # Generate release keystore
#
# Environment variables (override defaults):
#   QT_VERSION       Qt version (default: 6.10.2)
#   QT_DIR           Qt install root (default: /opt/Qt/$QT_VERSION)
#   JAVA_HOME        JDK path
#   ANDROID_HOME     Android SDK path
#   ANDROID_NDK_ROOT Android NDK path

set -euo pipefail

# --- Defaults (override via env vars) ---
QT_VERSION="${QT_VERSION:-6.10.2}"
QT_DIR="${QT_DIR:-/opt/Qt/$QT_VERSION}"
JAVA_HOME="${JAVA_HOME:-/home/user/Android/jdk-17}"
ANDROID_HOME="${ANDROID_HOME:-/home/user/Android/Sdk}"
ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT:-/home/user/Android/android-ndk-r27d}"

export JAVA_HOME ANDROID_HOME ANDROID_NDK_ROOT
# NDK toolchain on PATH so Gradle's strip task can find llvm-strip
NDK_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin"
export PATH="$JAVA_HOME/bin:$NDK_TOOLCHAIN:$ANDROID_HOME/platform-tools:$PATH"

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build-android"
OUTPUT_DIR="$PROJECT_DIR/dist/android"

KEYSTORE_DIR="$HOME/.android-keystore"
KEYSTORE_FILE="$KEYSTORE_DIR/release.keystore"
KEYSTORE_ALIAS="squared-release"

# --- Helpers ---
info()    { printf '\033[0;34m[INFO]\033[0m %s\n' "$1"; }
success() { printf '\033[0;32m[OK]\033[0m   %s\n' "$1"; }
error()   { printf '\033[0;31m[ERR]\033[0m  %s\n' "$1" >&2; exit 1; }
warn()    { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }

# --- Find latest build-tools version ---
build_tools_dir() {
    local latest
    latest="$(ls -v "$ANDROID_HOME/build-tools" | tail -1)"
    echo "$ANDROID_HOME/build-tools/$latest"
}

# --- Keystore creation ---
create_keystore() {
    info "Creating release keystore at $KEYSTORE_FILE"
    mkdir -p "$KEYSTORE_DIR"

    read -rsp "Store password: " store_pw; echo
    read -rsp "Key password (enter = same): " key_pw; echo
    key_pw="${key_pw:-$store_pw}"

    read -rp "Your name: " cn
    read -rp "Organization: " org
    read -rp "Country code (e.g. KE): " country

    keytool -genkeypair \
        -keystore "$KEYSTORE_FILE" \
        -alias "$KEYSTORE_ALIAS" \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -storepass "$store_pw" -keypass "$key_pw" \
        -dname "CN=$cn, O=$org, C=$country"

    # Save credentials (owner-only read)
    cat > "$KEYSTORE_DIR/signing.env" <<EOF
STORE_PASSWORD=$store_pw
KEY_PASSWORD=$key_pw
KEYSTORE_ALIAS=$KEYSTORE_ALIAS
EOF
    chmod 600 "$KEYSTORE_DIR/signing.env" "$KEYSTORE_FILE"
    success "Keystore created. Credentials in $KEYSTORE_DIR/signing.env"
    warn "Back up your keystore — you cannot recover it if lost."
}

# --- Load signing credentials ---
load_signing() {
    if [[ ! -f "$KEYSTORE_FILE" ]]; then
        error "No keystore at $KEYSTORE_FILE. Run: $0 --create-keystore"
    fi
    if [[ ! -f "$KEYSTORE_DIR/signing.env" ]]; then
        error "No signing.env at $KEYSTORE_DIR/signing.env"
    fi
    # shellcheck source=/dev/null
    source "$KEYSTORE_DIR/signing.env"
}

# --- Validate environment ---
check_env() {
    local fail=0
    [[ -d "$QT_DIR/android_arm64_v8a" ]] || { warn "Qt android_arm64_v8a not found at $QT_DIR"; fail=1; }
    [[ -x "$JAVA_HOME/bin/javac" ]]       || { warn "JDK not found at $JAVA_HOME"; fail=1; }
    [[ -d "$ANDROID_HOME" ]]              || { warn "Android SDK not found at $ANDROID_HOME"; fail=1; }
    [[ -d "$ANDROID_NDK_ROOT" ]]          || { warn "Android NDK not found at $ANDROID_NDK_ROOT"; fail=1; }
    [[ $fail -eq 0 ]] || error "Fix the above before building."

    # Gradle expects the NDK inside $ANDROID_HOME/ndk/<version>/ for stripping.
    # If NDK is at a custom path, symlink it so Gradle's strip task works.
    local ndk_ver
    ndk_ver="$(grep 'Pkg.Revision' "$ANDROID_NDK_ROOT/source.properties" | cut -d= -f2 | tr -d ' ')"
    local ndk_link="$ANDROID_HOME/ndk/$ndk_ver"
    if [[ -n "$ndk_ver" && ! -e "$ndk_link" ]]; then
        info "Symlinking NDK into SDK for Gradle strip: $ndk_link"
        mkdir -p "$ANDROID_HOME/ndk"
        ln -sfn "$ANDROID_NDK_ROOT" "$ndk_link"
    fi

    info "Environment:"
    echo "  Qt:   $QT_DIR (v$QT_VERSION)"
    echo "  JDK:  $($JAVA_HOME/bin/javac -version 2>&1)"
    echo "  NDK:  $ANDROID_NDK_ROOT (v${ndk_ver})"
    echo "  SDK:  $ANDROID_HOME (build-tools $(ls -v "$ANDROID_HOME/build-tools" | tail -1))"
}

# --- Sign APK (apksigner v2/v3/v4) ---
sign_apk() {
    local unsigned="$1" signed="$2"
    local bt
    bt="$(build_tools_dir)"

    info "Aligning APK..."
    "$bt/zipalign" -f -p 4 "$unsigned" "${signed}.tmp"

    info "Signing APK with apksigner (v2/v3)..."
    "$bt/apksigner" sign \
        --ks "$KEYSTORE_FILE" \
        --ks-key-alias "$KEYSTORE_ALIAS" \
        --ks-pass "pass:$STORE_PASSWORD" \
        --key-pass "pass:$KEY_PASSWORD" \
        --out "$signed" \
        "${signed}.tmp"
    rm -f "${signed}.tmp"

    # Verify
    "$bt/apksigner" verify --print-certs "$signed" > /dev/null
    success "APK signed and verified: $(basename "$signed") ($(du -h "$signed" | cut -f1))"
}

# --- Sign AAB (jarsigner — Google Play re-signs with their key) ---
sign_aab() {
    local unsigned="$1" signed="$2"

    info "Signing AAB with jarsigner..."
    cp "$unsigned" "$signed"
    jarsigner \
        -keystore "$KEYSTORE_FILE" \
        -storepass "$STORE_PASSWORD" \
        -keypass "$KEY_PASSWORD" \
        -sigalg SHA256withRSA -digestalg SHA-256 \
        "$signed" "$KEYSTORE_ALIAS"

    jarsigner -verify "$signed" > /dev/null
    success "AAB signed and verified: $(basename "$signed") ($(du -h "$signed" | cut -f1))"
}

# --- Parse arguments ---
BUILD_APK=1
BUILD_AAB=1
BUILD_TYPE="MinSizeRel"
CLEAN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --create-keystore) create_keystore; exit 0 ;;
        --apk-only) BUILD_AAB=0 ;;
        --aab-only) BUILD_APK=0 ;;
        --debug)    BUILD_TYPE="Debug" ;;
        --clean)    CLEAN=1 ;;
        -h|--help)
            head -11 "$0" | tail -9
            exit 0 ;;
        *) error "Unknown option: $1" ;;
    esac
    shift
done

# --- Main build ---
check_env

if [[ $CLEAN -eq 1 ]]; then
    info "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

# Configure with size optimizations
info "Configuring ($BUILD_TYPE, arm64-v8a)..."
"$QT_DIR/android_arm64_v8a/bin/qt-cmake" \
    -G Ninja \
    -S "$PROJECT_DIR" \
    -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DQT_HOST_PATH="$QT_DIR/gcc_64" \
    -DANDROID_SDK_ROOT="$ANDROID_HOME" \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
    -DCMAKE_CXX_FLAGS_MINSIZEREL="-Os -ffunction-sections -fdata-sections -DNDEBUG" \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,--gc-sections" \
    -DCMAKE_SHARED_LINKER_FLAGS="-Wl,--gc-sections"

# Build targets
JOBS="$(nproc --ignore=2)"

if [[ $BUILD_AAB -eq 1 ]]; then
    info "Building AAB..."
    cmake --build "$BUILD_DIR" --target aab --parallel "$JOBS"
fi

if [[ $BUILD_APK -eq 1 ]]; then
    info "Building APK..."
    cmake --build "$BUILD_DIR" --target apk --parallel "$JOBS"
fi

# --- Find outputs ---
find_output() {
    local pattern="$1" dir="$2"
    # Qt places build output under src/android-build/build/outputs/
    find "$BUILD_DIR/src/android-build" -name "$pattern" -path "*/$dir/*" 2>/dev/null | head -1
}

# --- Sign and copy outputs ---
if [[ "$BUILD_TYPE" == "Debug" ]]; then
    info "Debug build — skipping signing"

    apk="$(find_output "*.apk" "debug")"
    if [[ -n "$apk" ]]; then
        cp "$apk" "$OUTPUT_DIR/squared-debug.apk"
        success "Debug APK: $OUTPUT_DIR/squared-debug.apk ($(du -h "$apk" | cut -f1))"
    fi
else
    load_signing

    if [[ $BUILD_AAB -eq 1 ]]; then
        aab="$(find_output "*.aab" "release")"
        if [[ -n "$aab" ]]; then
            sign_aab "$aab" "$OUTPUT_DIR/squared-release.aab"
        else
            warn "AAB not found in build output"
        fi
    fi

    if [[ $BUILD_APK -eq 1 ]]; then
        apk="$(find_output "*.apk" "release")"
        if [[ -n "$apk" ]]; then
            sign_apk "$apk" "$OUTPUT_DIR/squared-release.apk"
        else
            warn "APK not found in build output"
        fi
    fi
fi

echo ""
success "Build complete! Output: $OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR"/*.{apk,aab} 2>/dev/null || true
