qt_add_executable(tst_appmanifest tst_appmanifest.cpp)
target_link_libraries(tst_appmanifest PRIVATE Qt6::Test SquaredCore)
add_test(NAME tst_appmanifest COMMAND tst_appmanifest)
set_tests_properties(tst_appmanifest PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
)

qt_add_executable(tst_appstorage tst_appstorage.cpp)
target_link_libraries(tst_appstorage PRIVATE Qt6::Test SquaredStorage)
add_test(NAME tst_appstorage COMMAND tst_appstorage)
set_tests_properties(tst_appstorage PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
)

qt_add_executable(tst_apprunner tst_apprunner.cpp)
target_link_libraries(tst_apprunner PRIVATE
    Qt6::Test Qt6::Quick
    SquaredCore SquaredStorage SquaredCoreSDK
)
add_test(NAME tst_apprunner COMMAND tst_apprunner)
set_tests_properties(tst_apprunner PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
)

qt_add_executable(tst_appregistry tst_appregistry.cpp)
target_link_libraries(tst_appregistry PRIVATE Qt6::Test SquaredCore)
add_test(NAME tst_appregistry COMMAND tst_appregistry)
set_tests_properties(tst_appregistry PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
)

qt_add_executable(tst_appinstaller tst_appinstaller.cpp)
target_link_libraries(tst_appinstaller PRIVATE Qt6::Test Qt6::CorePrivate SquaredCore)
add_test(NAME tst_appinstaller COMMAND tst_appinstaller)
set_tests_properties(tst_appinstaller PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
)

qt_add_executable(tst_appcatalog tst_appcatalog.cpp)
target_link_libraries(tst_appcatalog PRIVATE Qt6::Test SquaredCore)
add_test(NAME tst_appcatalog COMMAND tst_appcatalog)
set_tests_properties(tst_appcatalog PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
)

qt_add_executable(tst_securestorage tst_securestorage.cpp)
target_link_libraries(tst_securestorage PRIVATE Qt6::Test SquaredStorage)
add_test(NAME tst_securestorage COMMAND tst_securestorage)
set_tests_properties(tst_securestorage PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
)

qt_add_executable(tst_networkclient tst_networkclient.cpp)
target_link_libraries(tst_networkclient PRIVATE Qt6::Test Qt6::Network SquaredNetwork)
add_test(NAME tst_networkclient COMMAND tst_networkclient)
set_tests_properties(tst_networkclient PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
)
