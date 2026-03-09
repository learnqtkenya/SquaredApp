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
    SHELL        := cmd.exe
    NPROC        := $(NUMBER_OF_PROCESSORS)
    PLATFORM     := windows
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Darwin)
        QT_DIR   ?= $(HOME)/Qt/$(QT_VERSION)/macos
        NPROC    := $(shell sysctl -n hw.logicalcpu)
        PLATFORM := macos
    else
        QT_DIR   ?= /opt/Qt/$(QT_VERSION)/gcc_64
        NPROC    := $(shell nproc --ignore=2)
        PLATFORM := linux
    endif
endif

# --- Android SDK (override via env) ---
JAVA_HOME        ?= $(HOME)/Android/jdk-17
ANDROID_HOME     ?= $(HOME)/Android/Sdk
ANDROID_NDK_ROOT ?= $(HOME)/Android/android-ndk-r27d
QT_ANDROID       ?= /opt/Qt/$(QT_VERSION)/android_arm64_v8a

# --- Directories ---
BUILD_DIR        := build
BUILD_REL_DIR    := build-release
BUILD_ANDROID    := build-android
INSTALL_DIR      := install
DIST_DIR         := dist/android

# ============================================================================
# Desktop targets
# ============================================================================

.PHONY: all configure build release test install run clean help

all: build

configure:
	cmake -G Ninja -B $(BUILD_DIR) \
		-DCMAKE_PREFIX_PATH=$(QT_DIR) \
		-DCMAKE_BUILD_TYPE=Debug

build: configure
	cmake --build $(BUILD_DIR) --target Squared --parallel $(NPROC)

configure-release:
	cmake -G Ninja -B $(BUILD_REL_DIR) \
		-DCMAKE_PREFIX_PATH=$(QT_DIR) \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR)

release: configure-release
	cmake --build $(BUILD_REL_DIR) --target Squared --parallel $(NPROC)

test: build
ifeq ($(OS),Windows_NT)
	ctest --test-dir $(BUILD_DIR) --output-on-failure
else
	QT_QPA_PLATFORM=offscreen ctest --test-dir $(BUILD_DIR) --output-on-failure
endif

install: release
	cmake --install $(BUILD_REL_DIR)

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
	cmake --build $(BUILD_ANDROID) --target apk --parallel $(NPROC)
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
	cmake --build $(BUILD_ANDROID) --target aab --parallel $(NPROC)
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
		-S . \
		-B $(BUILD_ANDROID) \
		-DCMAKE_BUILD_TYPE=Debug \
		-DQT_HOST_PATH=$(QT_DIR) \
		-DANDROID_SDK_ROOT=$(ANDROID_HOME)
	cmake --build $(BUILD_ANDROID) --target apk --parallel $(NPROC)
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
	cd $(BUILD_REL_DIR) && cpack -G DEB
	@echo ""
	@echo "DEB: $$(find $(BUILD_REL_DIR) -name '*.deb' | head -1)"

package-linux: deb appimage

# ============================================================================
# Windows packaging targets
# ============================================================================

.PHONY: portable installer package-windows

portable: install
	@echo "Building portable ZIP..."
	cd $(BUILD_REL_DIR) && cpack -G ZIP
	@echo ""
	@echo "ZIP: $$(find $(BUILD_REL_DIR) -name '*.zip' | head -1)"

installer: install
	@echo "Building NSIS installer..."
	cd $(BUILD_REL_DIR) && cpack -G NSIS
	@echo ""
	@echo "Installer: $$(find $(BUILD_REL_DIR) -name '*.exe' | head -1)"

package-windows: portable installer

# ============================================================================
# Utilities
# ============================================================================

.PHONY: clean distclean

clean:
	rm -rf $(BUILD_DIR) $(BUILD_REL_DIR) $(BUILD_ANDROID) $(INSTALL_DIR) $(DIST_DIR) AppDir

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
	@echo "  JAVA_HOME=$(JAVA_HOME)"
