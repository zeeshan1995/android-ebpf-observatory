add_executable(command_line_test
    unit/command_line_test.cpp
)

target_link_libraries(command_line_test PRIVATE observatory_core)
observatory_apply_warnings(command_line_test)
observatory_apply_static_analysis(command_line_test)

add_test(NAME command_line_unit COMMAND command_line_test)
add_test(NAME cli_help COMMAND observatory --help)
add_test(NAME cli_version COMMAND observatory --version)
add_test(
    NAME cli_invalid
    COMMAND
        ${CMAKE_COMMAND}
        -DOBSERVATORY_EXECUTABLE=$<TARGET_FILE:observatory>
        -P ${CMAKE_CURRENT_SOURCE_DIR}/assert_cli_failure.cmake
)
