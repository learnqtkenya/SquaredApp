qt_add_library(SquaredCore STATIC
    AppManifest.h AppManifest.cpp
    AppRunner.h AppRunner.cpp
    AppInstaller.h AppInstaller.cpp
    AppCatalog.h AppCatalog.cpp
    PackageDownloader.h PackageDownloader.cpp
    AppRegistry.h AppRegistry.cpp
    ThemeManager.h ThemeManager.cpp
    FileSystemWatcher.h FileSystemWatcher.cpp
)

target_link_libraries(SquaredCore PUBLIC Qt6::Quick Qt6::Qml Qt6::Network)
target_link_libraries(SquaredCore PRIVATE SquaredStorage SquaredCoreSDK SquaredNetwork Qt6::CorePrivate)
target_include_directories(SquaredCore PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
