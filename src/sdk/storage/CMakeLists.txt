qt_add_library(SquaredStorage STATIC
    AppStorage.h AppStorage.cpp
    SecureStorage.h SecureStorage.cpp
    SecureStorageReply.h SecureStorageReply.cpp
)

target_link_libraries(SquaredStorage PUBLIC Qt6::Core Qt6::Qml PRIVATE qt6keychain)
target_include_directories(SquaredStorage PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
