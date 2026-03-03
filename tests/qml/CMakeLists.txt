find_package(Qt6 REQUIRED COMPONENTS QuickTest)

# Macro to add a QML test
macro(add_qml_test TEST_NAME)
    qt_add_executable(${TEST_NAME} runner.cpp)
    target_link_libraries(${TEST_NAME} PRIVATE
        Qt6::QuickTest
        Qt6::Quick
        SquaredUIplugin
    )
    target_compile_definitions(${TEST_NAME} PRIVATE
        QUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
        TST_NAME="${TEST_NAME}"
    )
    add_test(NAME ${TEST_NAME} COMMAND ${TEST_NAME}
        -input "${CMAKE_CURRENT_SOURCE_DIR}/${TEST_NAME}.qml"
    )
    set_tests_properties(${TEST_NAME} PROPERTIES
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen"
    )
endmacro()

add_qml_test(tst_STheme)
add_qml_test(tst_SText)
add_qml_test(tst_SIcon)
add_qml_test(tst_SButton)
add_qml_test(tst_SDivider)
add_qml_test(tst_SSpacer)
add_qml_test(tst_SCard)
add_qml_test(tst_SCardHeader)
add_qml_test(tst_SCardBody)
add_qml_test(tst_SListItem)
add_qml_test(tst_SBadge)
add_qml_test(tst_STextField)
add_qml_test(tst_SSwitch)
add_qml_test(tst_SSearchField)
add_qml_test(tst_SProgressBar)
add_qml_test(tst_SLoadingSpinner)
add_qml_test(tst_SEmptyState)
add_qml_test(tst_SPage)
add_qml_test(tst_SScrollView)
add_qml_test(tst_SMetric)
add_qml_test(tst_SToast)
add_qml_test(tst_SDialog)
add_qml_test(tst_SDropdown)
add_qml_test(tst_SCheckbox)
add_qml_test(tst_SRadioGroup)
add_qml_test(tst_SSlider)
add_qml_test(tst_SGrid)
add_qml_test(tst_SSection)
add_qml_test(tst_SAvatar)
