execute_process(
    COMMAND "${OBSERVATORY_EXECUTABLE}" --invalid
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
)

if(result EQUAL 0)
    message(FATAL_ERROR "Invalid CLI input unexpectedly succeeded")
endif()

string(FIND "${error}" "unknown argument: --invalid" error_position)
if(error_position EQUAL -1)
    message(FATAL_ERROR
        "Invalid CLI input did not produce the expected diagnostic.\n"
        "stdout: ${output}\n"
        "stderr: ${error}"
    )
endif()
