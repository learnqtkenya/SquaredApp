qt_add_executable(Squared main.cpp)

set_source_files_properties(../qml/Main.qml PROPERTIES QT_RESOURCE_ALIAS Main.qml)
set_source_files_properties(../qml/AppShell.qml PROPERTIES QT_RESOURCE_ALIAS AppShell.qml)

qt_add_qml_module(Squared
    URI Squared.Host
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Squared/Host"
    QML_FILES
        ../qml/Main.qml
        ../qml/AppShell.qml
)

target_link_libraries(Squared PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    SquaredCore
    SquaredStorage
    SquaredCoreSDK
    SquaredUIplugin
)

target_compile_definitions(Squared PRIVATE
    EXAMPLES_PATH="${CMAKE_SOURCE_DIR}/examples/apps"
)
