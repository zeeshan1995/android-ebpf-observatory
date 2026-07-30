#!/bin/sh
set -eu

mode=${1:-check}
repo_root=$(git rev-parse --show-toplevel)
staged_files=$(git -C "$repo_root" diff --cached --name-only --diff-filter=ACMR)

if [ -z "$staged_files" ]; then
    if [ "$mode" = "--classify" ]; then
        printf '%s\n' "none"
    fi
    exit 0
fi

has_docs=false
has_implementation=false
requires_docs=false
reasons=""

append_reason() {
    if [ -z "$reasons" ]; then
        reasons=$1
    else
        reasons="$reasons
$1"
    fi
}

while IFS= read -r file; do
    case "$file" in
        docs/*|README.md|*/README.md)
            has_docs=true
            ;;
    esac

    case "$file" in
        ebpf/*|collector/*|analytics/*|storage/*|ui/*|include/*)
            has_implementation=true
            ;;
    esac

    case "$file" in
        include/*|*/api/*|*/contracts/*|*/schema/*|*/schemas/*)
            requires_docs=true
            append_reason "Public API, contract, or schema changed: $file"
            ;;
    esac
done <<EOF
$staged_files
EOF

new_or_deleted_modules=$(
    git -C "$repo_root" diff --cached --name-status --diff-filter=AD |
        awk '$2 ~ /^ebpf\// { print $1 " " $2 }'
)

if [ -n "$new_or_deleted_modules" ]; then
    requires_docs=true
    append_reason "An eBPF module file was added or removed:
$new_or_deleted_modules"
fi

if [ "$has_docs" = true ]; then
    if [ "$mode" = "--classify" ]; then
        printf '%s\n' "documented"
    fi
    exit 0
fi

if [ "$requires_docs" = true ]; then
    if [ "$mode" = "--classify" ]; then
        printf '%s\n' "required"
        exit 0
    fi

    printf '%s\n' "Documentation impact check failed."
    printf '%s\n\n' "$reasons"
    printf '%s\n' "Stage the corresponding documentation under docs/ or a relevant README."
    printf '%s\n' "Document event contracts, hook selection, capabilities, validation, and limitations as applicable."
    exit 1
fi

if [ "$has_implementation" = true ]; then
    if [ "$mode" = "--classify" ]; then
        printf '%s\n' "review"
        exit 0
    fi

    printf '%s\n' "Documentation impact check: implementation changed without documentation."
    printf '%s\n' "No high-impact contract or module change was detected; verify that documentation is genuinely unchanged."
elif [ "$mode" = "--classify" ]; then
    printf '%s\n' "none"
fi
