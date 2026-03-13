# syntax=docker/dockerfile:1
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Build dependencies for Qt cross-compilation
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    git \
    build-essential \
    cmake \
    ninja-build \
    python3 \
    pkg-config \
    perl \
    bison \
    gperf \
    pigz \
    mold \
    libclang-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libxcb-glx0-dev \
    libxcb-keysyms1-dev \
    libxcb-image0-dev \
    libxcb-shm0-dev \
    libxcb-icccm4-dev \
    libxcb-sync-dev \
    libxcb-xfixes0-dev \
    libxcb-shape0-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-util-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libatspi2.0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    libssl-dev \
    zlib1g-dev \
    libbsd-dev \
    libdbus-1-dev \
    libsecret-1-dev \
    gcc-12-aarch64-linux-gnu \
    g++-12-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    libc6-arm64-cross \
    libc6-dev-arm64-cross \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Extract sysroot and fix symlinks
COPY rasp.tar.gz /build/rasp.tar.gz
RUN mkdir -p sysroot/usr sysroot/opt \
    && tar xfz rasp.tar.gz -C sysroot \
    && rm rasp.tar.gz \
    && wget -q https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py \
    && python3 sysroot-relativelinks.py /build/sysroot \
    && rm sysroot-relativelinks.py

COPY toolchain.cmake /build/

# Qt configuration — modules needed for Squared
ARG QT_VERSION=6.10.2
ARG QT_MAJOR=6.10
ARG QT_MODULES="qtshadertools qtdeclarative qtsvg"

# Download Qt sources
RUN mkdir -p qt6/src && cd qt6/src \
    && for module in qtbase ${QT_MODULES}; do \
        echo "https://download.qt.io/official_releases/qt/${QT_MAJOR}/${QT_VERSION}/submodules/${module}-everywhere-src-${QT_VERSION}.tar.xz"; \
    done | xargs -P 4 -n 1 wget -q

# Build Qt for host (provides moc, rcc, qmlcachegen)
RUN set -e \
    && mkdir -p qt6/host qt6/host-build && cd qt6/host-build \
    && for file in ../src/*.tar.xz; do tar xf "$file"; done \
    && echo "=== Building qtbase for host ===" \
    && cd qtbase-everywhere-src-${QT_VERSION} \
    && cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
        -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX=/build/qt6/host \
        -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=mold" \
        -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=mold" \
    && cmake --build . --parallel $(nproc) \
    && cmake --install . \
    && cd .. \
    && for module in ${QT_MODULES}; do \
        echo "=== Building $module for host ===" \
        && cd ${module}-everywhere-src-${QT_VERSION} \
        && /build/qt6/host/bin/qt-configure-module . \
        && cmake --build . --parallel $(nproc) \
        && cmake --install . \
        && cd ..; \
    done \
    && rm -rf /build/qt6/host-build

# Cross-compile Qt for Raspberry Pi (arm64)
RUN set -e \
    && mkdir -p qt6/pi qt6/pi-build && cd qt6/pi-build \
    && for file in ../src/*.tar.xz; do tar xf "$file"; done \
    && echo "=== Cross-compiling qtbase for Raspberry Pi ===" \
    && cd qtbase-everywhere-src-${QT_VERSION} \
    && cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
        -DINPUT_opengl=es2 \
        -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
        -DQT_HOST_PATH=/build/qt6/host \
        -DCMAKE_STAGING_PREFIX=/build/qt6/pi \
        -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
        -DCMAKE_TOOLCHAIN_FILE=/build/toolchain.cmake \
        -DQT_FEATURE_xcb=ON -DFEATURE_xcb_xlib=ON -DQT_FEATURE_xlib=ON \
    && cmake --build . --parallel $(nproc) \
    && cmake --install . \
    && cd .. \
    && for module in ${QT_MODULES}; do \
        echo "=== Cross-compiling $module for Raspberry Pi ===" \
        && cd ${module}-everywhere-src-${QT_VERSION} \
        && /build/qt6/pi/bin/qt-configure-module . \
        && cmake --build . --parallel $(nproc) \
        && cmake --install . \
        && cd ..; \
    done \
    && rm -rf /build/qt6/pi-build /build/qt6/src

# Package Qt runtime for deployment to Raspberry Pi
RUN tar -I pigz -cf qt-pi-binaries.tar.gz -C /build/qt6/pi .

# --- Application build (layers above are cached between code changes) ---

COPY project /build/project

RUN cd /build/project \
    && /build/qt6/pi/bin/qt-cmake -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD=23 \
        -DCMAKE_INSTALL_PREFIX=/build/install-arm \
    && cmake --build . --parallel $(nproc) \
    && cmake --install .
