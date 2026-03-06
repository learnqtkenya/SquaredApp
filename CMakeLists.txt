cmake_minimum_required(VERSION 3.21)

project(Squared VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

if(ANDROID)
    find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Network CorePrivate)
else()
    find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 QuickTest Test Network CorePrivate DBus)
endif()
qt_standard_project_setup(REQUIRES 6.5)

# QtKeychain (secure credential storage)
set(BUILD_WITH_QT6 ON CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_TRANSLATIONS OFF CACHE BOOL "" FORCE)
set(BUILD_TEST_APPLICATION OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
add_subdirectory(external/qtkeychain EXCLUDE_FROM_ALL)

add_subdirectory(config)

add_subdirectory(src/sdk/ui)
add_subdirectory(src/sdk/storage)
add_subdirectory(src/sdk/core)
add_subdirectory(src/sdk/network)
add_subdirectory(src/sdk/api)
add_subdirectory(src/core)
add_subdirectory(src)

if(ANDROID)
    # Version code: MAJOR * 10000 + MINOR * 100 + PATCH (e.g., 0.1.0 → 100)
    math(EXPR ANDROID_VERSION_CODE
        "${PROJECT_VERSION_MAJOR} * 10000 + ${PROJECT_VERSION_MINOR} * 100 + ${PROJECT_VERSION_PATCH}")

    set_target_properties(Squared PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android"
        QT_ANDROID_TARGET_SDK_VERSION 34
        QT_ANDROID_MIN_SDK_VERSION 26
        QT_ANDROID_VERSION_NAME "${PROJECT_VERSION}"
        QT_ANDROID_VERSION_CODE "${ANDROID_VERSION_CODE}"
    )
endif()

if(NOT ANDROID)
    enable_testing()
    add_subdirectory(tests)
endif()

# --- CPack packaging ---
set(CPACK_PACKAGE_NAME "squared")
set(CPACK_PACKAGE_VENDOR "Squared")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Squared — QML super app runtime")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")

if(UNIX AND NOT APPLE AND NOT ANDROID)
    # .desktop file and icons
    install(FILES linux/com.squared.app.desktop
        DESTINATION share/applications)
    install(DIRECTORY linux/icons/hicolor
        DESTINATION share/icons)

    # --- DEB ---
    set(CPACK_GENERATOR "DEB;TGZ")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Squared <hello@squared.dev>")
    set(CPACK_DEBIAN_PACKAGE_SECTION "devel")
    set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "https://github.com/learnqtkenya/SquaredApp")
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS OFF)
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libxcb1, libxkbcommon0, libgl1, libegl1, libfontconfig1, libdbus-1-3")
    set(CPACK_DEBIAN_PACKAGE_DESCRIPTION
        "Squared is a runtime and distribution platform for QML applications.\n Discover, install, and run QML apps inside a single host environment.")

    include(CPack)
elseif(WIN32)
    set(CPACK_PACKAGE_NAME "Squared")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "Squared")
    set(CPACK_PACKAGE_EXECUTABLES "Squared;Squared")

    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME "Squared")
    set(CPACK_NSIS_PACKAGE_NAME "Squared")
    set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/assets/icons/squared.ico")
    set(CPACK_NSIS_MUI_UNIICON "${CMAKE_SOURCE_DIR}/assets/icons/squared.ico")
    set(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\Squared.exe")
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
    set(CPACK_NSIS_MODIFY_PATH OFF)

    # Start Menu + Desktop shortcuts
    set(CPACK_NSIS_CREATE_ICONS_EXTRA
        "CreateShortCut '$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\Squared.lnk' '$INSTDIR\\\\bin\\\\Squared.exe'
         CreateShortCut '$DESKTOP\\\\Squared.lnk' '$INSTDIR\\\\bin\\\\Squared.exe'")
    set(CPACK_NSIS_DELETE_ICONS_EXTRA
        "Delete '$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\Squared.lnk'
         Delete '$DESKTOP\\\\Squared.lnk'")

    include(CPack)
endif()
