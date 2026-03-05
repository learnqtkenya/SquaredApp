qt_add_qml_module(SquaredUI
    URI Squared.UI
    VERSION 1.0
    STATIC
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Squared/UI"
    QML_FILES
        SText.qml
        SIcon.qml
        SButton.qml
        SDivider.qml
        SSpacer.qml
        SCard.qml
        SCardHeader.qml
        SCardBody.qml
        SListItem.qml
        SBadge.qml
        STextField.qml
        SSwitch.qml
        SSearchField.qml
        SProgressBar.qml
        SLoadingSpinner.qml
        SEmptyState.qml
        SPage.qml
        SScrollView.qml
        SMetric.qml
        SToast.qml
        SDialog.qml
        SDropdown.qml
        SCheckbox.qml
        SRadioGroup.qml
        SSlider.qml
        SGrid.qml
        SSection.qml
        SAvatar.qml
    RESOURCES
        fonts/Inter-Variable.ttf
        fonts/MaterialSymbolsOutlined-Variable.ttf
)

set_source_files_properties(STheme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
set_source_files_properties(IconCodes.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
set_source_files_properties(SSize.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_target_qml_sources(SquaredUI
    QML_FILES
        STheme.qml
        IconCodes.qml
        SSize.qml
        ComponentGallery.qml
)

# ComponentGallery launcher executable
qt_add_executable(ComponentGallery gallery_main.cpp)
target_link_libraries(ComponentGallery PRIVATE
    Qt6::Quick
    SquaredUIplugin
)
