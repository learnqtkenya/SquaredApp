cmake_minimum_required(VERSION 3.21)

project(Squared VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 QuickTest Test Network)
if(UNIX AND NOT APPLE)
    find_package(Qt6 REQUIRED COMPONENTS DBus)
endif()

# CorePrivate is needed for QZipReader/QZipWriter in AppInstaller.
# Some Qt distributions (aqtinstall, certain Docker images) don't ship
# Qt6CorePrivateConfig.cmake but DO include the private headers.
# Create a fallback INTERFACE target in that case.
find_package(Qt6 COMPONENTS CorePrivate QUIET)
if(NOT TARGET Qt6::CorePrivate)
    message(STATUS "Qt6CorePrivate cmake config not found — creating fallback target")
    get_target_property(_qt_core_incs Qt6::Core INTERFACE_INCLUDE_DIRECTORIES)
    set(_private_inc "")
    foreach(_inc IN LISTS _qt_core_incs)
        if(_inc MATCHES "include/QtCore$" OR _inc MATCHES "include\\\\QtCore$")
            set(_private_inc "${_inc}/${Qt6_VERSION};${_inc}/${Qt6_VERSION}/QtCore")
            break()
        endif()
    endforeach()
    if(NOT _private_inc)
        # Derive from Qt6_DIR: <prefix>/lib/cmake/Qt6 → <prefix>/include/QtCore/<ver>
        get_filename_component(_qt_prefix "${Qt6_DIR}/../../.." ABSOLUTE)
        set(_private_inc "${_qt_prefix}/include/QtCore/${Qt6_VERSION};${_qt_prefix}/include/QtCore/${Qt6_VERSION}/QtCore")
    endif()
    add_library(Qt6::CorePrivate INTERFACE IMPORTED)
    set_target_properties(Qt6::CorePrivate PROPERTIES
        INTERFACE_LINK_LIBRARIES "Qt6::Core"
        INTERFACE_INCLUDE_DIRECTORIES "${_private_inc}"
    )
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

enable_testing()
add_subdirectory(tests)
