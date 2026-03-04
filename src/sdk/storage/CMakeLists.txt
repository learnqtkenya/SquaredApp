qt_add_library(SquaredStorage STATIC
    AppStorage.h AppStorage.cpp
)

target_link_libraries(SquaredStorage PUBLIC Qt6::Core)
target_include_directories(SquaredStorage PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
