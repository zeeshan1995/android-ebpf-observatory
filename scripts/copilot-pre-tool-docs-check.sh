#!/bin/sh
set -eu

payload=$(cat)
compact_payload=$(printf '%s' "$payload" | tr '\n' ' ')

if ! printf '%s' "$compact_payload" |
    grep -Eq '"toolName"[[:space:]]*:[[:space:]]*"bash"'; then
    printf '%s\n' '{}'
    exit 0
fi

command_text=$(
    printf '%s' "$compact_payload" |
        sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
)

case "$command_text" in
    *git*commit*)
        ;;
    *)
        printf '%s\n' '{}'
        exit 0
        ;;
esac

repo_root=$(git rev-parse --show-toplevel)
impact=$("$repo_root/scripts/check-docs-impact.sh" --classify)

case "$impact" in
    none|documented)
        printf '%s\n' '{"permissionDecision":"allow"}'
        ;;
    required)
        printf '%s\n' '{"permissionDecision":"deny","permissionDecisionReason":"Documentation is required for the staged public contract, schema, or eBPF module changes. Update and stage the relevant documentation before committing."}'
        ;;
    review)
        case "$command_text" in
            *DOCS_IMPACT_REVIEWED=1*)
                printf '%s\n' '{"permissionDecision":"allow","permissionDecisionReason":"Documentation impact was explicitly reviewed by the agent."}'
                ;;
            *)
                printf '%s\n' '{"permissionDecision":"deny","permissionDecisionReason":"Implementation changes are staged without documentation. Semantically review the staged diff for behavior, architecture, compatibility, operational, privacy, validation, and limitation impacts. Update documentation if needed. If documentation is genuinely unaffected, retry the commit with DOCS_IMPACT_REVIEWED=1 after recording the reasoning in the pull request."}'
                ;;
        esac
        ;;
    *)
        printf '%s\n' '{"permissionDecision":"deny","permissionDecisionReason":"The documentation-impact hook returned an unknown classification and failed closed."}'
        ;;
esac
