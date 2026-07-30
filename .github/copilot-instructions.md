# Repository Instructions

## Mission

Build a reusable Linux eBPF observability core with Android as the first
platform adapter. The project is a learning-oriented reference
implementation, but changes must be designed and validated with a
production mindset.

## Architectural Rules

1. Linux modules emit kernel facts. They must not depend on Android
   headers, framework APIs, package names, Binder, or SurfaceFlinger.
2. Android adapters enrich canonical Linux events with platform meaning.
3. Analytics performs inference and must retain evidence, confidence,
   ambiguity, and data-quality information.
4. Depend on canonical contracts rather than libbpf, Android APIs, or a
   specific storage engine outside their owning layer.
5. Prefer composition and capability-driven module selection over
   platform conditionals in shared code.
6. Do not introduce an abstraction until a real variation or substitution
   requires it.

## Expected Repository Boundaries

- `ebpf/common/`: verifier-safe shared BPF definitions.
- `ebpf/linux/`: platform-neutral process, scheduler, network, VFS, and
  block IO programs.
- `ebpf/platform/android/`: Binder, input, graphics, and Android uprobes.
- `src/collector/`: loading, transport, clocks, schemas, and lifecycle.
- `src/platform/android/`: Android identity and metadata enrichment.
- `src/analytics/`: platform-neutral correlation and Android inference
  adapters.
- `src/storage/`: event sink implementations.
- `src/cli/`: command-line client and commands.
- `include/observatory/`: public C++ interfaces.

## Implementation Rules

- Use Clang/LLVM as the primary compiler toolchain.
- Compile userspace C++ as ISO C++20 with compiler extensions disabled.
- Write modern C++ using RAII, value semantics, the rule of zero, strong
  types, and explicit ownership.
- Do not use owning raw pointers. Prefer stack values and `std::unique_ptr`;
  use `std::shared_ptr` only when ownership is genuinely shared.
- Prefer `std::span`, `std::string_view`, `std::optional`, `std::variant`,
  `std::chrono`, ranges, concepts, and `std::jthread` when they improve
  correctness and remain supported by the Android NDK.
- Avoid manual resource cleanup, C-style casts, macro-based abstractions,
  unnecessary heap allocation, and unchecked narrowing conversions.
- Keep C-compatible event ABI structures separate from C++ domain models.
- Prefer stable tracepoints, then fentry/fexit, then kprobes.
- Probe capabilities before attachment; never silently fall back.
- Keep BPF programs small. Perform heavy correlation in userspace.
- Bound every map, queue, buffer, cache, and retained event collection.
- Use monotonic timestamps and the canonical versioned event envelope.
- Include PID-reuse-safe identity when attributing process activity.
- Preserve unknown, unresolved, shared, and ambiguous attribution states.
- Avoid payload collection. Treat paths, arguments, Binder metadata, and
  input events as sensitive.
- Reuse a shared hook and distribute its events internally instead of
  attaching duplicate programs.
- Surface verifier errors, event loss, map eviction, and backpressure.

## Change Workflow

1. Identify the design phase and owning architectural layer.
2. Read `docs/implementation-plan.md` and the relevant architecture and
   module documentation.
3. Record capability assumptions and expected unsupported behavior.
4. Implement the smallest complete vertical slice: probe, event schema,
   collector handling, storage/query path, and focused tests.
5. Validate against a deterministic workload and a trusted reference,
   using Perfetto where an equivalent signal exists.
6. Report accuracy, loss, overhead, compatibility, and known limitations.

## Quality Gates

- Userspace code must compile with Clang in C++20 mode without relying on
  GNU language extensions.
- New C++ code must be warning-clean under the repository's configured
  Clang warnings.
- Before committing, run the documentation-impact hook against staged
  changes. Public contracts, schemas, and new or removed eBPF modules
  require corresponding documentation.
- When the Copilot `preToolUse` hook requests semantic documentation
  review, inspect the complete staged diff. Retry with
  `DOCS_IMPACT_REVIEWED=1` only when documentation is genuinely unaffected,
  and record the reason in the pull request.
- Do not claim a module is complete because its BPF program loads.
- Tests must cover normal behavior, cleanup, unsupported capabilities, and
  pressure or loss behavior relevant to the change.
- Changes to event structures require schema-version consideration.
- Changes to platform-neutral contracts require an architecture review.
- Android-specific code must remain below Android platform directories.
- Documentation must explain hook selection, alternatives, map design,
  verifier considerations, validation, and limitations.

## Agent Behavior

- Keep tasks scoped to one coherent deliverable and one design phase.
- Complete the Linux Engine Complete Gate before implementing Android
  phases unless the task is research that does not alter production code.
- Parallelize independent research, implementation, and validation work.
- Do not combine unrelated subsystem changes in one pull request.
- State uncertainty explicitly and preserve unsupported states.
- Never weaken validation merely to make a test pass.
