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

# --- CPack / NSIS Installer (Windows) ---
if(WIN32)
    set(CPACK_PACKAGE_NAME "Squared")
    set(CPACK_PACKAGE_VENDOR "Squared")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Squared — QML super app runtime")
    set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "Squared")
    set(CPACK_PACKAGE_EXECUTABLES "Squared;Squared")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")

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
