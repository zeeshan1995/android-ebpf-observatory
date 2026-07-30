#!/bin/sh
set -eu

repo_root=$(git rev-parse --show-toplevel)

set -- "$repo_root/src" "$repo_root/tests"

if [ -d "$repo_root/ebpf" ]; then
    set -- "$@" "$repo_root/ebpf"
fi

find "$@" \
    -type f \
    \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' \) \
    -print0 |
    xargs -0 clang-format --dry-run --Werror
