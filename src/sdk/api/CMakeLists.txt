qt_add_qml_module(SquaredSDK
    URI Squared.SDK
    VERSION 1.0
    STATIC
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Squared/SDK"
    SOURCES
        StorageSingleton.h
        SecureStorageSingleton.h
        SecureStorageReplySingleton.h
        NetworkSingleton.h
        NetworkReplySingleton.h
        AppSingleton.h
)

target_link_libraries(SquaredSDK PRIVATE Qt6::Quick)
