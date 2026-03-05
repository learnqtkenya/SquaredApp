qt_add_library(SquaredNetwork STATIC
    NetworkReply.h NetworkReply.cpp
    NetworkClient.h NetworkClient.cpp
)

target_link_libraries(SquaredNetwork PUBLIC Qt6::Core Qt6::Network Qt6::Qml)
target_include_directories(SquaredNetwork PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
