# Android Build

Build Squared for Android as an APK or AAB.

## Prerequisites

- **Qt 6.10.2** with Android target (`android_arm64_v8a`)
- **Android SDK** with platform 35+
- **Android NDK r27+**
- **JDK 17** (required by Gradle)
- **CMake 3.21+** and **Ninja**

### Environment Variables

```bash
export JAVA_HOME=/path/to/jdk-17
export ANDROID_HOME=/path/to/android-sdk    # or ANDROID_SDK_ROOT
export ANDROID_NDK_ROOT=$ANDROID_HOME/ndk/27.0.12077973
```

## Build with Make

```bash
make apk              # Release APK (signed)
make aab              # Release AAB (signed)
make apk-debug        # Debug APK (no signing)
make android          # Both APK + AAB
```

## Build with CMake

### Configure

```bash
cmake -G Ninja -B build-android \
    -DCMAKE_PREFIX_PATH=/opt/Qt/6.10.2/android_arm64_v8a \
    -DCMAKE_TOOLCHAIN_FILE=/opt/Qt/6.10.2/android_arm64_v8a/lib/cmake/Qt6/qt.toolchain.cmake \
    -DANDROID_SDK_ROOT=$ANDROID_HOME
```

### Build

```bash
cmake --build build-android
```

### Package APK

```bash
cmake --build build-android --target apk
```

The APK is output to `build-android/src/android-build/Squared.apk`.

## Signing

For release builds, create a keystore:

```bash
keytool -genkey -v -keystore squared.keystore \
    -alias squared -keyalg RSA -keysize 2048 -validity 10000
```

Set environment variables before building:

```bash
export QT_ANDROID_KEYSTORE_PATH=/path/to/squared.keystore
export QT_ANDROID_KEYSTORE_ALIAS=squared
export QT_ANDROID_KEYSTORE_STORE_PASS=yourpassword
export QT_ANDROID_KEYSTORE_KEY_PASS=yourpassword
```

## Standalone Build Script

For CI or one-shot builds:

```bash
tools/build-android.sh
```

This script auto-detects Qt, SDK, and NDK paths and builds both APK and AAB.

## Android-Specific Notes

- The app uses `AndroidManifest.xml` in the `android/` directory
- Internet permission is declared for the store catalog and network SDK
- Qt Activity is the main activity class
- Minimum SDK: 28 (Android 9)
- Target SDK: 35
