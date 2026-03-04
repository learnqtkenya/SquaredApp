qt_add_library(SquaredCoreSDK STATIC
    SquaredApp.h SquaredApp.cpp
)

target_link_libraries(SquaredCoreSDK PUBLIC Qt6::Core)
target_include_directories(SquaredCoreSDK PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
target_compile_definitions(SquaredCoreSDK PRIVATE
    SQUARED_VERSION="${PROJECT_VERSION}"
)
