qt_add_executable(Squared main.cpp)

set_source_files_properties(${CMAKE_SOURCE_DIR}/assets/icons/squared-512.png PROPERTIES QT_RESOURCE_ALIAS icons/squared-512.png)
qt_add_resources(Squared "app_icons" FILES ${CMAKE_SOURCE_DIR}/assets/icons/squared-512.png)

set_source_files_properties(${CMAKE_SOURCE_DIR}/qml/Main.qml PROPERTIES QT_RESOURCE_ALIAS Main.qml)
set_source_files_properties(${CMAKE_SOURCE_DIR}/qml/AppShell.qml PROPERTIES QT_RESOURCE_ALIAS AppShell.qml)
set_source_files_properties(${CMAKE_SOURCE_DIR}/qml/InstalledPage.qml PROPERTIES QT_RESOURCE_ALIAS InstalledPage.qml)
set_source_files_properties(${CMAKE_SOURCE_DIR}/qml/StorePage.qml PROPERTIES QT_RESOURCE_ALIAS StorePage.qml)
set_source_files_properties(${CMAKE_SOURCE_DIR}/qml/DevWindow.qml PROPERTIES QT_RESOURCE_ALIAS DevWindow.qml)

qt_add_qml_module(Squared
    URI Squared.Host
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Squared/Host"
    NO_CACHEGEN
    QML_FILES
        ${CMAKE_SOURCE_DIR}/qml/Main.qml
        ${CMAKE_SOURCE_DIR}/qml/AppShell.qml
        ${CMAKE_SOURCE_DIR}/qml/InstalledPage.qml
        ${CMAKE_SOURCE_DIR}/qml/StorePage.qml
        ${CMAKE_SOURCE_DIR}/qml/DevWindow.qml
)

target_link_libraries(Squared PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    SquaredCore
    SquaredStorage
    SquaredCoreSDK
    SquaredNetwork
    SquaredUIplugin
    SquaredSDKplugin
)

target_include_directories(Squared PRIVATE ${CONFIG_INCLUDE_DIR})

# --- Platform icons ---
if(WIN32)
    target_sources(Squared PRIVATE ${CMAKE_SOURCE_DIR}/assets/icons/squared.rc)
elseif(APPLE AND NOT ANDROID AND NOT IOS)
    set_target_properties(Squared PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_ICON_FILE squared.icns
        MACOSX_BUNDLE_BUNDLE_NAME "Squared"
        MACOSX_BUNDLE_GUI_IDENTIFIER "com.squared.app"
        MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
    )
    set(MACOS_ICON "${CMAKE_SOURCE_DIR}/assets/icons/squared.icns")
    set_source_files_properties(${MACOS_ICON} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    target_sources(Squared PRIVATE ${MACOS_ICON})
elseif(IOS)
    set_target_properties(Squared PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_BUNDLE_NAME "Squared"
        MACOSX_BUNDLE_GUI_IDENTIFIER "com.squared.app"
        MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
        XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
        XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "16.0"
        XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
    )
    if(EXISTS "${CMAKE_SOURCE_DIR}/ios/Assets.xcassets")
        target_sources(Squared PRIVATE "${CMAKE_SOURCE_DIR}/ios/Assets.xcassets")
        set_source_files_properties("${CMAKE_SOURCE_DIR}/ios/Assets.xcassets"
            PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    endif()
    set_target_properties(Squared PROPERTIES
        XCODE_ATTRIBUTE_INFOPLIST_KEY_UILaunchScreen_Generation YES
    )
endif()

# --- Android configuration ---
if(ANDROID)
    set_target_properties(Squared PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android"
        QT_ANDROID_TARGET_SDK_VERSION 34
        QT_ANDROID_MIN_SDK_VERSION 26
        QT_ANDROID_VERSION_NAME "${PROJECT_VERSION}"
        QT_ANDROID_VERSION_CODE "${ANDROID_VERSION_CODE}"
    )

    # Copy mipmap icons into android-build/res/
    add_custom_command(TARGET Squared POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_SOURCE_DIR}/android/res"
            "${CMAKE_BINARY_DIR}/src/android-build/res"
        COMMENT "Copying Android resources (icons) to android-build/res/"
    )

    # Bundle OpenSSL libs if found (set up in root CMakeLists.txt)
    if(ANDROID_EXTRA_LIBS)
        set_target_properties(Squared PROPERTIES
            QT_ANDROID_EXTRA_LIBS "${ANDROID_EXTRA_LIBS}"
        )
    endif()
endif()

# --- Desktop install (not applicable for mobile) ---
if(NOT ANDROID AND NOT IOS)
    install(TARGETS Squared
        BUNDLE  DESTINATION .
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    qt_generate_deploy_qml_app_script(
        TARGET Squared
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT ${deploy_script})
endif()
