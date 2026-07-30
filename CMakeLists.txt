cmake_minimum_required(VERSION 3.24)

project(
    android_ebpf_observatory
    VERSION 0.1.0
    DESCRIPTION "Linux-first eBPF observability engine with Android platform adapters"
    LANGUAGES C CXX
)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(CTest)
include(ProjectOptions)

observatory_configure_project()

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBBPF REQUIRED IMPORTED_TARGET libbpf>=1.0)

configure_file(
    include/observatory/core/version.hpp.in
    generated/observatory/core/version.hpp
    @ONLY
)

add_library(observatory_core STATIC
    src/cli/command_line.cpp
)

target_include_directories(observatory_core
    PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated>"
)

target_compile_features(observatory_core PUBLIC cxx_std_20)
observatory_apply_warnings(observatory_core)
observatory_apply_static_analysis(observatory_core)

add_executable(observatory
    src/cli/main.cpp
)

target_link_libraries(observatory
    PRIVATE
        observatory_core
        PkgConfig::LIBBPF
)

observatory_apply_warnings(observatory)
observatory_apply_static_analysis(observatory)

install(TARGETS observatory RUNTIME DESTINATION bin)

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()
