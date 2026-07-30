option(OBSERVATORY_REQUIRE_CLANG "Require Clang for the primary build" ON)
option(OBSERVATORY_ENABLE_CLANG_TIDY "Run clang-tidy during compilation" OFF)

function(observatory_configure_project)
    set(CMAKE_CXX_STANDARD 20 PARENT_SCOPE)
    set(CMAKE_CXX_STANDARD_REQUIRED ON PARENT_SCOPE)
    set(CMAKE_CXX_EXTENSIONS OFF PARENT_SCOPE)

    if(OBSERVATORY_REQUIRE_CLANG AND NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        message(FATAL_ERROR
            "Clang is the required primary C++ compiler. "
            "Set OBSERVATORY_REQUIRE_CLANG=OFF only for a portability build."
        )
    endif()
endfunction()

function(observatory_apply_warnings target)
    target_compile_options(${target}
        PRIVATE
            -Wall
            -Wextra
            -Wpedantic
            -Wconversion
            -Wsign-conversion
            -Wshadow
            -Wnon-virtual-dtor
            -Wold-style-cast
            -Woverloaded-virtual
            -Wnull-dereference
            -Wdouble-promotion
            -Wformat=2
    )
endfunction()

function(observatory_apply_static_analysis target)
    if(NOT OBSERVATORY_ENABLE_CLANG_TIDY)
        return()
    endif()

    find_program(CLANG_TIDY_EXECUTABLE NAMES clang-tidy REQUIRED)
    set_target_properties(${target} PROPERTIES
        CXX_CLANG_TIDY "${CLANG_TIDY_EXECUTABLE};--warnings-as-errors=*"
    )
endfunction()
