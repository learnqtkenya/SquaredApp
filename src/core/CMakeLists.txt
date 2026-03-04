qt_add_library(SquaredCore STATIC
    AppManifest.h AppManifest.cpp
    AppRunner.h AppRunner.cpp
)

target_link_libraries(SquaredCore PUBLIC Qt6::Quick Qt6::Qml)
target_link_libraries(SquaredCore PRIVATE SquaredStorage SquaredCoreSDK)
target_include_directories(SquaredCore PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
