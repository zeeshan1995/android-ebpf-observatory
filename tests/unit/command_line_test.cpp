#include "cli/command_line.hpp"

#include <array>
#include <cstdlib>
#include <iostream>
#include <span>
#include <string_view>
#include <variant>

namespace {

auto fail(const std::string_view message) -> int {
    std::cerr << "command_line_test: " << message << '\n';
    return EXIT_FAILURE;
}

} // namespace

auto main() -> int {
    using observatory::cli::InvalidArguments;
    using observatory::cli::ShowHelp;
    using observatory::cli::ShowVersion;

    const std::array<std::string_view, 0> no_arguments{};
    if (!std::holds_alternative<ShowHelp>(observatory::cli::parse_command_line(no_arguments))) {
        return fail("no arguments should show help");
    }

    const std::array<std::string_view, 1> help_arguments{"--help"};
    if (!std::holds_alternative<ShowHelp>(observatory::cli::parse_command_line(help_arguments))) {
        return fail("--help should show help");
    }

    const std::array<std::string_view, 1> version_arguments{"--version"};
    if (!std::holds_alternative<ShowVersion>(
            observatory::cli::parse_command_line(version_arguments))) {
        return fail("--version should show the version");
    }

    const std::array<std::string_view, 1> invalid_arguments{"--invalid"};
    const auto invalid = observatory::cli::parse_command_line(invalid_arguments);
    if (!std::holds_alternative<InvalidArguments>(invalid)) {
        return fail("unknown arguments should be rejected");
    }

    const std::array<std::string_view, 2> excessive_arguments{"--help", "--version"};
    if (!std::holds_alternative<InvalidArguments>(
            observatory::cli::parse_command_line(excessive_arguments))) {
        return fail("multiple arguments should be rejected");
    }

    return EXIT_SUCCESS;
}
