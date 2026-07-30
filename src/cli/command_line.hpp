#pragma once

#include <span>
#include <string>
#include <string_view>
#include <variant>

namespace observatory::cli {

struct ShowHelp {};
struct ShowVersion {};

struct InvalidArguments {
    std::string message;
};

using Command = std::variant<ShowHelp, ShowVersion, InvalidArguments>;

[[nodiscard]] auto parse_command_line(std::span<const std::string_view> arguments) -> Command;
[[nodiscard]] auto help_text() noexcept -> std::string_view;

} // namespace observatory::cli
