# Squared — cross-platform build targets
#
# Usage:
#   make                  # Build desktop (debug)
#   make release          # Build desktop (release)
#   make test             # Run tests headlessly
#   make install          # Install desktop binary + Qt libs
#   make android          # Build Android APK + AAB (release)
#   make apk              # Build Android APK only
#   make aab              # Build Android AAB only
#   make apk-debug        # Build debug APK (no signing)
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

.PHONY: android apk aab apk-debug android-configure

android-configure:
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
	@echo ""
	@echo "APK: $$(find $(BUILD_ANDROID)/src/android-build -name '*.apk' -path '*/release/*' | head -1)"

aab: android-configure
	cmake --build $(BUILD_ANDROID) --target aab --parallel $(NPROC)
	@echo ""
	@echo "AAB: $$(find $(BUILD_ANDROID)/src/android-build -name '*.aab' -path '*/release/*' | head -1)"

apk-debug:
	$(QT_ANDROID)/bin/qt-cmake \
		-G Ninja \
		-S . \
		-B $(BUILD_ANDROID) \
		-DCMAKE_BUILD_TYPE=Debug \
		-DQT_HOST_PATH=$(QT_DIR) \
		-DANDROID_SDK_ROOT=$(ANDROID_HOME)
	cmake --build $(BUILD_ANDROID) --target apk --parallel $(NPROC)
	@echo ""
	@echo "Debug APK: $$(find $(BUILD_ANDROID)/src/android-build -name '*.apk' -path '*/debug/*' | head -1)"

# ============================================================================
# Utilities
# ============================================================================

.PHONY: clean distclean

clean:
	rm -rf $(BUILD_DIR) $(BUILD_REL_DIR) $(BUILD_ANDROID) $(INSTALL_DIR) $(DIST_DIR)

help:
	@echo "Desktop:"
	@echo "  make              Build debug"
	@echo "  make release      Build release"
	@echo "  make test         Run tests"
	@echo "  make install      Install to $(INSTALL_DIR)/"
	@echo "  make run APP=dir  Run app in dev mode"
	@echo ""
	@echo "Android:"
	@echo "  make android      Build APK + AAB (release)"
	@echo "  make apk          Build APK only"
	@echo "  make aab          Build AAB only"
	@echo "  make apk-debug    Build debug APK"
	@echo ""
	@echo "Other:"
	@echo "  make clean        Remove all build dirs"
	@echo "  make help         Show this help"
	@echo ""
	@echo "Override paths:"
	@echo "  QT_DIR=$(QT_DIR)"
	@echo "  QT_ANDROID=$(QT_ANDROID)"
	@echo "  JAVA_HOME=$(JAVA_HOME)"
