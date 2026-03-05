include(${CMAKE_CURRENT_LIST_DIR}/config_definitions.cmake)

configure_file(
    config.h.in
    ${CMAKE_BINARY_DIR}/config/config.h
    @ONLY
)

set(CONFIG_INCLUDE_DIR ${CMAKE_BINARY_DIR}/config CACHE INTERNAL "Path to generated config header")
