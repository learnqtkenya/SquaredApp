include(${CMAKE_CURRENT_LIST_DIR}/config_utils.cmake)

define_config_option(
    NAME STORE_URL
    TYPE STRING
    DESCRIPTION "Squared Store server URL"
    DEFAULT "https://proms.alwaysdata.net/squared-store"
)

define_config_option(
    NAME EXAMPLES_PATH
    TYPE STRING
    DESCRIPTION "Path to bundled example apps directory"
    DEFAULT "${CMAKE_SOURCE_DIR}/examples/apps"
)
