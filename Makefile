# Squared — cross-platform build targets
#
# Usage:
#   make                  # Build desktop (debug)
#   make release          # Build desktop (release)
#   make test             # Run tests headlessly
#   make install          # Install desktop binary + Qt libs
#   make android          # Build Android APK + AAB (signed)
#   make apk              # Build signed APK only
#   make aab              # Build signed AAB only
#   make apk-debug        # Build debug APK (no signing)
#   make dmg              # Build macOS .dmg disk image
#   make ios              # Build iOS .app (open Xcode for signing)
#   make ipa              # Build signed .ipa for distribution
#   make create-keystore  # Generate Android release keystore
#   make clean            # Remove all build directories
#   make run APP=my-app   # Run app in dev mode
#
# Override paths:
#   make QT_DIR=/path/to/qt
#   make JAVA_HOME=/path/to/jdk android

# --- Qt detection ---
QT_VERSION   ?= 6.10.2

ifeq ($(OS),Windows_NT)
    QT_DIR       ?= C:/Qt/$(QT_VERSION)/msvc2022_64
    QT_ROOT      ?= C:/Qt
    SHELL        := cmd.exe
    NPROC        := $(NUMBER_OF_PROCESSORS)
    PLATFORM     := windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Darwin)
        QT_DIR   ?= $(HOME)/Qt/$(QT_VERSION)/macos
        QT_ROOT  ?= $(HOME)/Qt
        NPROC    := $(shell sysctl -n hw.logicalcpu)
        PLATFORM := macos
    else
        QT_DIR   ?= /opt/Qt/$(QT_VERSION)/gcc_64
        QT_ROOT  ?= /opt/Qt
        NPROC    := $(shell nproc --ignore=2)
        PLATFORM := linux
    endif
endif

# --- Qt-bundled tools (cmake, ninja, cpack) ---
# Qt ships CMake and Ninja under QT_ROOT/Tools/. Use these instead of
# requiring system-installed cmake/ninja.
ifeq ($(UNAME_S),Darwin)
    QT_CMAKE_DIR ?= $(QT_ROOT)/Tools/CMake/CMake.app/Contents/bin
    QT_NINJA_DIR ?= $(QT_ROOT)/Tools/Ninja
else ifeq ($(OS),Windows_NT)
    QT_CMAKE_DIR ?= $(QT_ROOT)/Tools/CMake_64/bin
    QT_NINJA_DIR ?= $(QT_ROOT)/Tools/Ninja
else
    QT_CMAKE_DIR ?= $(QT_ROOT)/Tools/CMake/bin
    QT_NINJA_DIR ?= $(QT_ROOT)/Tools/Ninja
endif

CMAKE := $(QT_CMAKE_DIR)/cmake
CPACK := $(QT_CMAKE_DIR)/cpack
NINJA := $(QT_NINJA_DIR)/ninja

# Also export PATH so child processes (Gradle, qt-cmake) find them
export PATH := $(QT_CMAKE_DIR):$(QT_NINJA_DIR):$(PATH)

# --- Android SDK (override via env) ---
JAVA_HOME        ?= $(HOME)/Android/jdk-17
ANDROID_HOME     ?= $(HOME)/Android/Sdk
ANDROID_NDK_ROOT ?= $(HOME)/Android/android-ndk-r27d
QT_ANDROID       ?= /opt/Qt/$(QT_VERSION)/android_arm64_v8a

# --- iOS SDK (override via env) ---
QT_IOS           ?= $(HOME)/Qt/$(QT_VERSION)/ios

# --- Project version (from CMakeLists.txt project() call) ---
PROJECT_VERSION  := $(shell sed -n 's/^project.*VERSION \([0-9][0-9.]*\).*/\1/p' CMakeLists.txt)

# --- Directories ---
BUILD_DIR        := build
BUILD_REL_DIR    := build-release
BUILD_ANDROID    := build-android
BUILD_IOS        := build-ios
INSTALL_DIR      := install
DIST_DIR         := dist/android

# ============================================================================
# Desktop targets
# ============================================================================

.PHONY: all configure build release test install run clean help

all: build

configure:
	$(CMAKE) -G Ninja -B $(BUILD_DIR) \
		-DCMAKE_MAKE_PROGRAM=$(NINJA) \
		-DCMAKE_PREFIX_PATH=$(QT_DIR) \
		-DCMAKE_BUILD_TYPE=Debug

build: configure
	$(CMAKE) --build $(BUILD_DIR) --target Squared --parallel $(NPROC)

configure-release:
	$(CMAKE) -G Ninja -B $(BUILD_REL_DIR) \
		-DCMAKE_MAKE_PROGRAM=$(NINJA) \
		-DCMAKE_PREFIX_PATH=$(QT_DIR) \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR)

release: configure-release
	$(CMAKE) --build $(BUILD_REL_DIR) --target Squared --parallel $(NPROC)

CTEST := $(QT_CMAKE_DIR)/ctest

test: build
ifeq ($(OS),Windows_NT)
	$(CTEST) --test-dir $(BUILD_DIR) --output-on-failure
else
	QT_QPA_PLATFORM=offscreen $(CTEST) --test-dir $(BUILD_DIR) --output-on-failure
endif

install: release
	$(CMAKE) --install $(BUILD_REL_DIR)

run: build
ifdef APP
	$(BUILD_DIR)/src/Squared --dev $$(realpath $(APP))
else
	@echo "Usage: make run APP=path/to/app"
	@exit 1
endif

# ============================================================================
# Android targets
# ============================================================================

# Gradle needs these in the environment for compilation and stripping
export JAVA_HOME
export ANDROID_HOME
export ANDROID_NDK_ROOT

# NDK toolchain on PATH so Gradle's strip task can find llvm-strip
NDK_TOOLCHAIN := $(ANDROID_NDK_ROOT)/toolchains/llvm/prebuilt/linux-x86_64/bin
export PATH := $(JAVA_HOME)/bin:$(NDK_TOOLCHAIN):$(PATH)

# Tools and signing
ADB              := $(ANDROID_HOME)/platform-tools/adb
KEYSTORE_DIR     ?= $(HOME)/.android-keystore
KEYSTORE_FILE    := $(KEYSTORE_DIR)/release.keystore
KEYSTORE_ALIAS   := squared-release
ANDROID_BUILD_OUT := $(BUILD_ANDROID)/src/android-build
ANDROID_PKG      := com.squared.app

.PHONY: android apk aab apk-debug android-configure android-clean android-check create-keystore deploy deploy-debug launch logcat

android-check:
	@test -d "$(QT_ANDROID)" || (echo "Error: Qt Android not found at $(QT_ANDROID)" && exit 1)
	@test -x "$(JAVA_HOME)/bin/javac" || (echo "Error: JDK not found at $(JAVA_HOME)" && exit 1)
	@test -d "$(ANDROID_HOME)" || (echo "Error: Android SDK not found at $(ANDROID_HOME)" && exit 1)
	@test -d "$(ANDROID_NDK_ROOT)" || (echo "Error: Android NDK not found at $(ANDROID_NDK_ROOT)" && exit 1)

android-configure: android-check
	$(QT_ANDROID)/bin/qt-cmake \
		-G Ninja \
		-DCMAKE_MAKE_PROGRAM=$(NINJA) \
		-S . \
		-B $(BUILD_ANDROID) \
		-DCMAKE_BUILD_TYPE=MinSizeRel \
		-DQT_HOST_PATH=$(QT_DIR) \
		-DANDROID_SDK_ROOT=$(ANDROID_HOME) \
		-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
		"-DCMAKE_CXX_FLAGS_MINSIZEREL=-Os -ffunction-sections -fdata-sections -DNDEBUG" \
		"-DCMAKE_SHARED_LINKER_FLAGS=-Wl,--gc-sections"
	@# Ensure Gradle can find NDK strip tool
	@NDK_VER=$$(grep 'Pkg.Revision' $(ANDROID_NDK_ROOT)/source.properties | cut -d= -f2 | tr -d ' '); \
	if [ -n "$$NDK_VER" ] && [ ! -e "$(ANDROID_HOME)/ndk/$$NDK_VER" ]; then \
		mkdir -p $(ANDROID_HOME)/ndk; \
		ln -sfn $(ANDROID_NDK_ROOT) $(ANDROID_HOME)/ndk/$$NDK_VER; \
		echo "Symlinked NDK into SDK for Gradle strip"; \
	fi

android: apk aab

apk: android-configure
	$(CMAKE) --build $(BUILD_ANDROID) --target apk --parallel $(NPROC)
	@mkdir -p $(DIST_DIR)
	@# Sign if keystore exists, otherwise just copy unsigned
	@APK=$$(find $(ANDROID_BUILD_OUT) -name '*.apk' -path '*/release/*' | head -1); \
	if [ -z "$$APK" ]; then echo "Error: APK not found in build output"; exit 1; fi; \
	if [ -f "$(KEYSTORE_FILE)" ] && [ -f "$(KEYSTORE_DIR)/signing.env" ]; then \
		. $(KEYSTORE_DIR)/signing.env; \
		BT=$$(ls -v $(ANDROID_HOME)/build-tools | tail -1); \
		echo "Aligning APK..."; \
		$(ANDROID_HOME)/build-tools/$$BT/zipalign -f -p 4 "$$APK" "$(DIST_DIR)/squared-release.tmp"; \
		echo "Signing APK..."; \
		$(ANDROID_HOME)/build-tools/$$BT/apksigner sign \
			--ks $(KEYSTORE_FILE) --ks-key-alias $(KEYSTORE_ALIAS) \
			--ks-pass "pass:$$STORE_PASSWORD" --key-pass "pass:$$KEY_PASSWORD" \
			--out $(DIST_DIR)/squared-release.apk $(DIST_DIR)/squared-release.tmp; \
		rm -f $(DIST_DIR)/squared-release.tmp; \
		$(ANDROID_HOME)/build-tools/$$BT/apksigner verify --print-certs $(DIST_DIR)/squared-release.apk > /dev/null; \
		echo "Signed APK: $(DIST_DIR)/squared-release.apk ($$(du -h $(DIST_DIR)/squared-release.apk | cut -f1))"; \
	else \
		cp "$$APK" $(DIST_DIR)/squared-unsigned.apk; \
		echo "Unsigned APK: $(DIST_DIR)/squared-unsigned.apk (no keystore — run: make create-keystore)"; \
	fi

aab: android-configure
	$(CMAKE) --build $(BUILD_ANDROID) --target aab --parallel $(NPROC)
	@mkdir -p $(DIST_DIR)
	@AAB=$$(find $(ANDROID_BUILD_OUT) -name '*.aab' -path '*/release/*' | head -1); \
	if [ -z "$$AAB" ]; then echo "Error: AAB not found in build output"; exit 1; fi; \
	if [ -f "$(KEYSTORE_FILE)" ] && [ -f "$(KEYSTORE_DIR)/signing.env" ]; then \
		. $(KEYSTORE_DIR)/signing.env; \
		echo "Signing AAB..."; \
		cp "$$AAB" $(DIST_DIR)/squared-release.aab; \
		jarsigner -keystore $(KEYSTORE_FILE) \
			-storepass "$$STORE_PASSWORD" -keypass "$$KEY_PASSWORD" \
			-sigalg SHA256withRSA -digestalg SHA-256 \
			$(DIST_DIR)/squared-release.aab $(KEYSTORE_ALIAS); \
		jarsigner -verify $(DIST_DIR)/squared-release.aab > /dev/null; \
		echo "Signed AAB: $(DIST_DIR)/squared-release.aab ($$(du -h $(DIST_DIR)/squared-release.aab | cut -f1))"; \
	else \
		cp "$$AAB" $(DIST_DIR)/squared-unsigned.aab; \
		echo "Unsigned AAB: $(DIST_DIR)/squared-unsigned.aab (no keystore — run: make create-keystore)"; \
	fi

apk-debug: android-check
	$(QT_ANDROID)/bin/qt-cmake \
		-G Ninja \
		-DCMAKE_MAKE_PROGRAM=$(NINJA) \
		-S . \
		-B $(BUILD_ANDROID) \
		-DCMAKE_BUILD_TYPE=Debug \
		-DQT_HOST_PATH=$(QT_DIR) \
		-DANDROID_SDK_ROOT=$(ANDROID_HOME)
	$(CMAKE) --build $(BUILD_ANDROID) --target apk --parallel $(NPROC)
	@mkdir -p $(DIST_DIR)
	@APK=$$(find $(ANDROID_BUILD_OUT) -name '*.apk' -path '*/debug/*' | head -1); \
	if [ -n "$$APK" ]; then \
		cp "$$APK" $(DIST_DIR)/squared-debug.apk; \
		echo "Debug APK: $(DIST_DIR)/squared-debug.apk ($$(du -h $(DIST_DIR)/squared-debug.apk | cut -f1))"; \
	fi

android-clean:
	rm -rf $(BUILD_ANDROID) $(DIST_DIR)

deploy: apk
	@APK=$$(ls $(DIST_DIR)/squared-release.apk $(DIST_DIR)/squared-unsigned.apk 2>/dev/null | head -1); \
	if [ -z "$$APK" ]; then echo "Error: no APK found in $(DIST_DIR)/"; exit 1; fi; \
	echo "Installing $$APK..."; \
	$(ADB) install -r "$$APK"; \
	echo "Installed. Run: make launch"

deploy-debug: apk-debug
	@echo "Installing debug APK..."
	$(ADB) install -r $(DIST_DIR)/squared-debug.apk
	@echo "Installed. Run: make launch"

launch:
	$(ADB) shell am start -n $(ANDROID_PKG)/org.qtproject.qt.android.bindings.QtActivity

logcat:
	$(ADB) logcat -s "Qt:*" "qtlogging:*" "Squared:*" "AndroidRuntime:E"

create-keystore:
	@mkdir -p $(KEYSTORE_DIR)
	@read -rp "Your name: " CN; \
	read -rp "Organization: " ORG; \
	read -rp "Country code (e.g. KE): " COUNTRY; \
	read -rsp "Store password: " STORE_PW; echo; \
	read -rsp "Key password (enter = same): " KEY_PW; echo; \
	KEY_PW=$${KEY_PW:-$$STORE_PW}; \
	keytool -genkeypair \
		-keystore $(KEYSTORE_FILE) -alias $(KEYSTORE_ALIAS) \
		-keyalg RSA -keysize 2048 -validity 10000 \
		-storepass "$$STORE_PW" -keypass "$$KEY_PW" \
		-dname "CN=$$CN, O=$$ORG, C=$$COUNTRY"; \
	printf 'STORE_PASSWORD=%s\nKEY_PASSWORD=%s\nKEYSTORE_ALIAS=%s\n' \
		"$$STORE_PW" "$$KEY_PW" "$(KEYSTORE_ALIAS)" > $(KEYSTORE_DIR)/signing.env; \
	chmod 600 $(KEYSTORE_FILE) $(KEYSTORE_DIR)/signing.env; \
	echo "Keystore created at $(KEYSTORE_FILE)"; \
	echo "Credentials saved to $(KEYSTORE_DIR)/signing.env"

# ============================================================================
# Linux packaging targets
# ============================================================================

LINUXDEPLOY     := tools/linuxdeploy-x86_64.AppImage
LINUXDEPLOY_URL := https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage

.PHONY: appimage deb package-linux

$(LINUXDEPLOY):
	@echo "Downloading linuxdeploy..."
	@mkdir -p tools
	@curl -sL $(LINUXDEPLOY_URL) -o $@ && chmod +x $@

appimage: install $(LINUXDEPLOY)
	@echo "Building AppImage..."
	@rm -rf AppDir
	@mkdir -p AppDir/usr
	@cp -r $(INSTALL_DIR)/* AppDir/usr/
	@mkdir -p AppDir/usr/share/applications AppDir/usr/share/icons
	@cp linux/com.squared.app.desktop AppDir/usr/share/applications/
	@cp -r linux/icons/hicolor AppDir/usr/share/icons/
	./$(LINUXDEPLOY) \
		--appdir AppDir \
		--executable AppDir/usr/bin/Squared \
		--desktop-file AppDir/usr/share/applications/com.squared.app.desktop \
		--icon-file linux/icons/hicolor/256x256/apps/com.squared.app.png \
		--output appimage
	@mv Squared-*.AppImage dist/ 2>/dev/null || mv Squared-*.AppImage .
	@rm -rf AppDir
	@echo ""
	@echo "AppImage: $$(ls Squared-*.AppImage dist/Squared-*.AppImage 2>/dev/null | head -1)"

deb: install
	@echo "Building DEB package..."
	cd $(BUILD_REL_DIR) && $(CPACK) -G DEB
	@echo ""
	@echo "DEB: $$(find $(BUILD_REL_DIR) -name '*.deb' | head -1)"

package-linux: deb appimage

# ============================================================================
# Windows packaging targets
# ============================================================================

.PHONY: portable installer package-windows

portable: install
	@echo "Building portable ZIP..."
	cd $(BUILD_REL_DIR) && $(CPACK) -G ZIP
	@echo ""
	@echo "ZIP: $$(find $(BUILD_REL_DIR) -name '*.zip' | head -1)"

installer: install
	@echo "Building NSIS installer..."
	cd $(BUILD_REL_DIR) && $(CPACK) -G NSIS
	@echo ""
	@echo "Installer: $$(find $(BUILD_REL_DIR) -name '*.exe' | head -1)"

package-windows: portable installer

# ============================================================================
# macOS packaging targets
# ============================================================================

MACDEPLOYQT      := $(QT_DIR)/bin/macdeployqt

# Code signing identity for macOS distribution.
# Set to "Developer ID Application: Your Name (TEAMID)" for notarizable builds.
# Defaults to ad-hoc signing (-) for local/dev builds.
CODESIGN_ID      ?= -

.PHONY: dmg package-macos codesign

dmg: install
	@echo "Creating macOS .app bundle..."
	$(MACDEPLOYQT) $(INSTALL_DIR)/Squared.app -qmldir=qml -verbose=1
	@echo "Signing app bundle..."
	@codesign --force --deep --sign "$(CODESIGN_ID)" $(INSTALL_DIR)/Squared.app
	@echo "Creating DMG..."
	@mkdir -p dist/macos
	@hdiutil create -volname "Squared" -srcfolder $(INSTALL_DIR)/Squared.app \
		-ov -format UDZO dist/macos/Squared-$(PROJECT_VERSION).dmg
	@if [ "$(CODESIGN_ID)" != "-" ]; then \
		echo "Signing DMG..."; \
		codesign --force --sign "$(CODESIGN_ID)" dist/macos/Squared-$(PROJECT_VERSION).dmg; \
	fi
	@echo ""
	@echo "DMG: dist/macos/Squared-$(PROJECT_VERSION).dmg"

codesign:
	@echo "Re-signing app bundle..."
	@codesign --force --deep --sign "$(CODESIGN_ID)" $(INSTALL_DIR)/Squared.app
	@codesign --verify --verbose $(INSTALL_DIR)/Squared.app
	@echo "Signed with: $(CODESIGN_ID)"

package-macos: dmg

# ============================================================================
# iOS targets
# ============================================================================

IOS_BUNDLE_ID    ?= com.squared.app
IOS_TEAM_ID      ?= $(DEVELOPMENT_TEAM)

.PHONY: ios-check ios-configure ios ios-sim-configure ios-sim ipa ios-clean

BUILD_IOS_SIM    := build-ios-sim

ios-check:
	@test -d "$(QT_IOS)" || (echo "Error: Qt iOS not found at $(QT_IOS). Install via Qt Maintenance Tool." && exit 1)
	@which xcodebuild > /dev/null 2>&1 || (echo "Error: Xcode command line tools not found" && exit 1)

# --- Device build (requires signing) ---
ios-configure: ios-check
	$(QT_IOS)/bin/qt-cmake \
		-G Xcode \
		-S . \
		-B $(BUILD_IOS) \
		-DCMAKE_BUILD_TYPE=Release \
		-DQT_HOST_PATH=$(QT_DIR) \
		-DCMAKE_OSX_ARCHITECTURES=arm64 \
		$(if $(DEVELOPMENT_TEAM),-DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=$(DEVELOPMENT_TEAM))
	@echo ""
	@echo "Xcode project: $(BUILD_IOS)/Squared.xcodeproj"

ios: ios-configure
	$(CMAKE) --build $(BUILD_IOS) --config Release -- \
		-allowProvisioningUpdates \
		$(if $(DEVELOPMENT_TEAM),DEVELOPMENT_TEAM=$(DEVELOPMENT_TEAM))
	@echo ""
	@echo "iOS app built: $$(find $(BUILD_IOS) -name 'Squared.app' -path '*/Release-*' | head -1)"

# --- Simulator build (no signing required) ---
# Use cmake directly with explicit toolchain (not qt-cmake, which forces iphoneos).
ios-sim-configure: ios-check
	$(CMAKE) \
		-G Xcode \
		-S . \
		-B $(BUILD_IOS_SIM) \
		-DCMAKE_TOOLCHAIN_FILE=$(QT_IOS)/lib/cmake/Qt6/qt.toolchain.cmake \
		-DCMAKE_OSX_SYSROOT=iphonesimulator \
		-DCMAKE_OSX_ARCHITECTURES=arm64
	@echo ""
	@echo "Xcode project: $(BUILD_IOS_SIM)/Squared.xcodeproj"

ios-sim: ios-sim-configure
	$(CMAKE) --build $(BUILD_IOS_SIM) --config Debug
	@echo ""
	@echo "Launch: xcrun simctl boot 'iPhone 16' 2>/dev/null; open -a Simulator"
	@echo "Install: xcrun simctl install booted $(BUILD_IOS_SIM)/src/Debug-iphonesimulator/Squared.app"

ipa: ios
	@mkdir -p dist/ios
	@echo "Creating archive..."
	@cd $(BUILD_IOS) && xcodebuild -project Squared.xcodeproj \
		-scheme Squared -configuration Release \
		-archivePath $(CURDIR)/dist/ios/Squared.xcarchive \
		-destination 'generic/platform=iOS' \
		archive -allowProvisioningUpdates
	@echo "Exporting IPA..."
	@xcodebuild -exportArchive \
		-archivePath $(CURDIR)/dist/ios/Squared.xcarchive \
		-exportOptionsPlist ios/ExportOptions.plist \
		-exportPath $(CURDIR)/dist/ios \
		-allowProvisioningUpdates
	@echo ""
	@echo "IPA: $$(ls dist/ios/Squared.ipa 2>/dev/null)"

ios-clean:
	rm -rf $(BUILD_IOS) $(BUILD_IOS_SIM) dist/ios

# ============================================================================
# Utilities
# ============================================================================

.PHONY: clean distclean

clean:
	rm -rf $(BUILD_DIR) $(BUILD_REL_DIR) $(BUILD_ANDROID) $(BUILD_IOS) $(BUILD_IOS_SIM) $(INSTALL_DIR) $(DIST_DIR) dist/macos dist/ios AppDir

help:
	@echo "Desktop:"
	@echo "  make              Build debug"
	@echo "  make release      Build release"
	@echo "  make test         Run tests"
	@echo "  make install      Install to $(INSTALL_DIR)/"
	@echo "  make run APP=dir  Run app in dev mode"
	@echo ""
	@echo "Linux packaging:"
	@echo "  make deb          Build .deb package"
	@echo "  make appimage     Build AppImage"
	@echo "  make package-linux  Build both"
	@echo ""
	@echo "Windows packaging:"
	@echo "  make portable     Build portable ZIP"
	@echo "  make installer    Build NSIS installer"
	@echo "  make package-windows  Build both"
	@echo ""
	@echo "macOS packaging:"
	@echo "  make dmg          Build .dmg (ad-hoc signed)"
	@echo "  make dmg CODESIGN_ID='Developer ID Application: ...'  Signed DMG"
	@echo "  make codesign     Re-sign existing app bundle"
	@echo ""
	@echo "iOS:"
	@echo "  make ios            Build iOS .app for device (needs signing)"
	@echo "  make ios-sim        Build + run in iOS Simulator"
	@echo "  make ipa            Archive + export signed .ipa"
	@echo "  make ios-clean      Remove iOS build + dist"
	@echo ""
	@echo "Android:"
	@echo "  make android        Build signed APK + AAB"
	@echo "  make apk            Build signed APK"
	@echo "  make aab            Build signed AAB"
	@echo "  make apk-debug      Build debug APK (no signing)"
	@echo "  make deploy         Build + install release APK on device"
	@echo "  make deploy-debug   Build + install debug APK on device"
	@echo "  make launch         Start app on connected device"
	@echo "  make logcat         Stream Qt/app logs from device"
	@echo "  make create-keystore  Generate release keystore"
	@echo "  make android-clean  Remove Android build + dist"
	@echo ""
	@echo "Other:"
	@echo "  make clean        Remove all build dirs"
	@echo "  make help         Show this help"
	@echo ""
	@echo "Override paths:"
	@echo "  QT_DIR=$(QT_DIR)"
	@echo "  QT_ANDROID=$(QT_ANDROID)"
	@echo "  QT_IOS=$(QT_IOS)"
	@echo "  JAVA_HOME=$(JAVA_HOME)"
