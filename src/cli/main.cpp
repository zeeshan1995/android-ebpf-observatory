#include "cli/command_line.hpp"
#include "core/version.hpp"

#include <exception>
#include <iostream>
#include <span>
#include <string_view>
#include <type_traits>
#include <variant>
#include <vector>

namespace {

auto run(const std::span<char* const> raw_arguments) -> int {
    std::vector<std::string_view> arguments;

    if (raw_arguments.size() > 1U) {
        arguments.reserve(raw_arguments.size() - 1U);
    }

    for (const auto* argument : raw_arguments.subspan(1)) {
        arguments.emplace_back(argument);
    }

    const auto command = observatory::cli::parse_command_line(arguments);

    return std::visit(
        [](const auto& selected_command) {
            using CommandType = std::decay_t<decltype(selected_command)>;

            if constexpr (std::is_same_v<CommandType, observatory::cli::ShowHelp>) {
                std::cout << observatory::cli::help_text();
                return 0;
            } else if constexpr (std::is_same_v<CommandType, observatory::cli::ShowVersion>) {
                std::cout << "observatory " << observatory::core::version << '\n';
                return 0;
            } else {
                std::cerr << "observatory: " << selected_command.message << '\n'
                          << "Try 'observatory --help' for usage.\n";
                return 2;
            }
        },
        command);
}

} // namespace

// The C++ runtime defines main's argv parameter as a C array.
// NOLINTNEXTLINE(modernize-avoid-c-arrays)
auto main(const int argument_count, char* argument_values[]) -> int {
    try {
        const auto count = static_cast<std::size_t>(argument_count);
        return run(std::span<char* const>{argument_values, count});
    } catch (const std::exception& error) {
        std::cerr << "observatory: fatal error: " << error.what() << '\n';
        return 1;
    }
}
