# Agent Entry Point

All agents working in this repository must follow
`.github/copilot-instructions.md` and the scoped instructions under
`.github/instructions/`.

Use `docs/agentic-workflow.md` for task decomposition, agent roles,
parallel work, pull-request boundaries, and completion criteria.
Use `docs/implementation-plan.md` as the canonical phase order and
architecture plan.

Before implementation:

1. Identify the design phase and architectural layer.
2. Confirm capability assumptions and unsupported behavior.
3. Define the canonical event or enrichment contract.
4. Define a deterministic workload and trusted reference.

Keep Linux kernel facts, Android platform enrichment, and analytics
inference separate.

Use Clang/LLVM as the primary toolchain. Compile userspace code as modern
ISO C++20 and BPF programs as C with Clang's BPF backend.
