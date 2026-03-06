qt_add_executable(Squared main.cpp)

set_source_files_properties(../assets/icons/squared-512.png PROPERTIES QT_RESOURCE_ALIAS icons/squared-512.png)
qt_add_resources(Squared "app_icons" FILES ../assets/icons/squared-512.png)

set_source_files_properties(../qml/Main.qml PROPERTIES QT_RESOURCE_ALIAS Main.qml)
set_source_files_properties(../qml/AppShell.qml PROPERTIES QT_RESOURCE_ALIAS AppShell.qml)
set_source_files_properties(../qml/InstalledPage.qml PROPERTIES QT_RESOURCE_ALIAS InstalledPage.qml)
set_source_files_properties(../qml/StorePage.qml PROPERTIES QT_RESOURCE_ALIAS StorePage.qml)
set_source_files_properties(../qml/DevWindow.qml PROPERTIES QT_RESOURCE_ALIAS DevWindow.qml)

qt_add_qml_module(Squared
    URI Squared.Host
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Squared/Host"
    QML_FILES
        ../qml/Main.qml
        ../qml/AppShell.qml
        ../qml/InstalledPage.qml
        ../qml/StorePage.qml
        ../qml/DevWindow.qml
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

# --- Install ---
install(TARGETS Squared
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

qt_generate_deploy_app_script(
    TARGET Squared
    OUTPUT_SCRIPT deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
)
install(SCRIPT ${deploy_script})

# Symlink built binary to ~/.squared/bin/ so `squared run` finds it during development
if(NOT CMAKE_CROSSCOMPILING)
    set(SQUARED_BIN_DIR "$ENV{HOME}/.squared/bin")
    add_custom_command(TARGET Squared POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${SQUARED_BIN_DIR}"
        COMMAND ${CMAKE_COMMAND} -E create_symlink
            "$<TARGET_FILE:Squared>" "${SQUARED_BIN_DIR}/Squared"
        COMMENT "Symlinking Squared binary to ${SQUARED_BIN_DIR}/"
    )
endif()
