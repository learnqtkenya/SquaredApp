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
add_subdirectory(external/qtkeychain)

add_subdirectory(config)

add_subdirectory(src/sdk/ui)
add_subdirectory(src/sdk/storage)
add_subdirectory(src/sdk/core)
add_subdirectory(src/sdk/network)
add_subdirectory(src/sdk/api)
add_subdirectory(src/core)
add_subdirectory(src)

if(ANDROID)
    set_target_properties(Squared PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android"
    )
    set_property(TARGET Squared PROPERTY QT_ANDROID_TARGET_SDK_VERSION 34)
    set_property(TARGET Squared PROPERTY QT_ANDROID_MIN_SDK_VERSION 26)
endif()

if(NOT ANDROID)
    enable_testing()
    add_subdirectory(tests)
endif()
