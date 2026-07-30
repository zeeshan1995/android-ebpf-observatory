#include "observatory/cli/command_line.hpp"

#include <string>

namespace observatory::cli {

auto parse_command_line(const std::span<const std::string_view> arguments) -> Command {
    if (arguments.empty()) {
        return ShowHelp{};
    }

    if (arguments.size() > 1U) {
        return InvalidArguments{"expected at most one argument"};
    }

    const auto argument = arguments.front();

    if (argument == "--help" || argument == "-h") {
        return ShowHelp{};
    }

    if (argument == "--version" || argument == "-V") {
        return ShowVersion{};
    }

    return InvalidArguments{"unknown argument: " + std::string{argument}};
}

auto help_text() noexcept -> std::string_view {
    return R"(Usage: observatory [OPTION]

Linux-first eBPF observability engine.

Options:
  -h, --help       Show this help text
  -V, --version    Show the program version
)";
}

} // namespace observatory::cli
