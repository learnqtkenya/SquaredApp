# Android Build Guide

## Prerequisites

- Qt 6.10.2 for Android (arm64-v8a): `/opt/Qt/6.10.2/android_arm64_v8a/`
- Android SDK with platform API 34
- Android NDK (version compatible with Qt 6.10.2)
- CMake 3.21+ and Ninja

Set environment variables:

```bash
export ANDROID_SDK_ROOT=/path/to/android/sdk
export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/<version>
```

## Configure

```bash
cmake -G Ninja -B build-android \
  -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/android_arm64_v8a \
  -DCMAKE_TOOLCHAIN_FILE=/opt/Qt/6.10.2/android_arm64_v8a/lib/cmake/Qt6/qt.toolchain.cmake \
  -DANDROID_SDK_ROOT=$ANDROID_SDK_ROOT
```

## Build

```bash
cmake --build build-android
```

## Deploy

```bash
cmake --build build-android --target apk
```

The APK will be at `build-android/android-build/Squared.apk`.

Install to a connected device:

```bash
adb install build-android/android-build/Squared.apk
```

## Known Caveats

- **Transparent window**: `window.color: "transparent"` in Main.qml may not behave the same on Android. The home screen launcher effect relies on desktop compositing.
- **QtKeychain**: Uses Android KeyStore on Android for secure credential storage. Requires the app to be signed.
- **Example apps path**: The `EXAMPLES_PATH` compile-time define points to a host filesystem path. On Android, example apps would need to be bundled as Android assets or shipped in the APK's assets directory.
- **Software rendering**: If the device lacks OpenGL ES support, set `QT_QUICK_BACKEND=software` in the environment.

## ARMv7 Build

For older 32-bit ARM devices:

```bash
cmake -G Ninja -B build-android-armv7 \
  -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/android_armv7 \
  -DCMAKE_TOOLCHAIN_FILE=/opt/Qt/6.10.2/android_armv7/lib/cmake/Qt6/qt.toolchain.cmake \
  -DANDROID_SDK_ROOT=$ANDROID_SDK_ROOT
```
