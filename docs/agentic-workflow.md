# Agentic Development Workflow

## Purpose

This workflow coordinates GitHub Copilot CLI and GitHub Copilot coding
agent while preserving architectural boundaries and measurable evidence.

## Unit of Work

An agent task is one coherent vertical slice within one design phase. It
should normally include:

1. Capability and hook research.
2. Bounded kernel or platform instrumentation.
3. Canonical event or enrichment handling.
4. Storage and a minimal query path.
5. A deterministic validation workload.
6. Accuracy, loss, overhead, compatibility, and limitations.

Avoid assigning an entire subsystem or multiple phases as one task.
Phase order and entry/exit gates are defined in
`docs/implementation-plan.md`. Production Android implementation begins
only after the Linux Engine Complete Gate.

## Agent Roles

| Role | Primary responsibility |
|---|---|
| Architecture guardian | Boundaries, contracts, shared hooks, phase alignment |
| eBPF kernel engineer | Linux probes, maps, verifier safety, event plumbing |
| Android platform researcher | Android enrichment and controlled experiments |
| Verification engineer | Workloads, references, Perfetto comparison, measurements |

The implementation owner remains responsible for integrating all evidence;
agent roles do not replace code ownership.

## Task Flow

1. Create an agent-task issue with outcome, scope, layer, capabilities,
   contracts, validation, and completion evidence.
2. Request architecture review when shared contracts, hooks, or layer
   boundaries change.
3. Run independent research and workload preparation in parallel.
4. Implement a small end-to-end slice.
5. Have verification evaluate the result against the declared reference.
6. Open a pull request using the repository template.
7. Merge only when correctness and unsupported behavior are explicit.

## Parallel Work

Safe parallel lanes include:

- Kernel hook research and deterministic workload design.
- Linux-core implementation and Android enrichment research.
- Collector plumbing and storage/query implementation against an agreed
  event contract.
- Documentation and compatibility-matrix updates after behavior is fixed.

Do not parallelize two implementations that independently redefine the
same event schema, shared hook, map ownership, or module contract.

## Pull Request Boundaries

A pull request should target one phase and one coherent result. Split work
when it changes unrelated subsystems, mixes architecture refactoring with
new instrumentation, or combines Linux-core and Android behavior without a
stable contract between them.

## Documentation Impact Gate

Documentation impact has two enforcement layers:

1.  The versioned Git pre-commit hook runs
    `scripts/check-docs-impact.sh` against staged changes.
2.  The repository Copilot `preToolUse` hook intercepts agent attempts to
    run `git commit` and requires semantic review when implementation
    changes have no staged documentation.

The shared classifier applies these rules:

- Changes under `docs/` or a relevant `README.md` satisfy the gate.
- Public API, contract, and schema changes require documentation.
- Added or removed eBPF module files require documentation.
- Other implementation changes without documentation produce a warning so
  a human author must verify that behavior, compatibility, operation, and
  limitations are unchanged.

For Copilot commits, ordinary implementation changes without documentation
are denied on the first attempt. The agent must inspect the staged diff and
either update documentation or retry using:

```sh
DOCS_IMPACT_REVIEWED=1 git commit ...
```

The override is only for changes with no documentation impact. Public
contracts, schemas, and added or removed eBPF modules cannot use it.
The reasoning must be recorded in the pull request.

Install the repository hooks with:

```sh
./scripts/install-git-hooks.sh
```

The hook is a guardrail rather than a substitute for engineering judgment.
Documentation should also be updated whenever observable behavior,
capabilities, validation results, compatibility, privacy, or limitations
change.

## Definition of Done

Work is complete only when:

- Userspace code builds with Clang in ISO C++20 mode.
- C++ resource ownership is explicit and native resources use RAII.
- The declared behavior is observable end to end.
- Unsupported devices or hooks fail explicitly.
- Event and resource bounds are documented.
- Lifecycle cleanup and relevant pressure paths are tested.
- Results are compared with a trusted source when available.
- Accuracy, loss, overhead, compatibility, privacy, and limitations are
  recorded.

## Cloud-Agent Limitation

The cloud agent can compile and test host-side Linux components using the
configured toolchain. Android device validation, vendor-kernel behavior,
root/SELinux constraints, and hardware graphics/input experiments require
an attached development device or a separately configured self-hosted
runner. Cloud-only success must not be presented as device validation.
