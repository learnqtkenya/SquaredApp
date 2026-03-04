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
