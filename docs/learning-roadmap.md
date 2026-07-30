# Learning Roadmap

The project is developed alongside *Learning eBPF: Programming the Linux
Kernel for Enhanced Observability, Networking, and Security* by Liz Rice.
The book is a companion resource; project code, tests, experiments, and
documentation are independently authored.

## Study Method

For each implementation phase:

1. Study the relevant kernel and eBPF concepts.
2. Reproduce the concept with a minimal isolated experiment.
3. Record verifier output, map state, emitted events, and failure behavior.
4. Implement the production-oriented project slice.
5. Compare attachment alternatives and measure correctness and overhead.
6. Document what the kernel can prove and what remains unknown.

The objective is not to transcribe examples. It is to use each concept to
build, explain, and validate the observability engine.

## Phase Alignment

| Project phase | Learning focus | Project evidence |
|---|---|---|
| L0 | Toolchain, kernel capabilities, bpftool, BTF | Reproducible build and capability report |
| L1 | Program loading, maps, ring buffers, CO-RE, verifier | Versioned kernel-to-userspace event pipeline |
| L2 | Tracepoints and process lifecycle | PID-reuse-safe process timeline |
| L3 | Scheduler tracing and aggregation | CPU runtime, wakeups, and run-queue delay |
| L4 | Memory-related kernel signals | Fault, reclaim, swap, and OOM activity |
| L5 | Syscalls, VFS, and privacy-aware data collection | Logical file-operation timeline |
| L6 | Block-layer tracing and correlation | Physical IO latency and throughput |
| L7 | Networking program and attachment types | Socket lifecycle and byte accounting |
| L8 | Userspace architecture and observability product design | Daemon, CLI, storage, replay, and health |
| L9 | Portability, security, performance, and failure handling | Compatibility and regression reports |

Android phases apply the same method after the Linux Engine Complete Gate:
start with kernel-visible facts, identify missing platform meaning, and add
the smallest justified Android adapter.

## Learning Artifacts

Each module should eventually include:

- A subsystem overview.
- Hook-selection rationale and alternatives.
- Event and map diagrams.
- Verifier and portability notes.
- A deterministic workload.
- Accuracy, overhead, and event-loss measurements.
- A short conclusion describing what was learned and what remains unknown.
