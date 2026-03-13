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
