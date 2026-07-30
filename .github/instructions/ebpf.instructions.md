---
applyTo: "ebpf/**/*.c,ebpf/**/*.h,include/**/*.h"
---

# eBPF Instructions

- Compile kernel BPF C programs with Clang's BPF backend. Do not compile
  BPF programs as C++.
- Prefer CO-RE-compatible types and access patterns when BTF is available.
- Keep verifier control flow simple and loops statically bounded.
- Check every helper and map-operation result when it affects correctness.
- Use fixed-width types in kernel/userspace event contracts.
- Avoid large stack allocations and unbounded event payloads.
- Key process state with PID-reuse-safe identity where possible.
- Use per-CPU aggregation for high-rate counters when exact global ordering
  is unnecessary.
- Document map capacity, eviction behavior, synchronization, and cleanup.
- Emit only data required by the owning module.
- Keep shared event headers valid C and compatible with C++20 userspace.
- Do not parse Android framework semantics in Linux-generic BPF programs.
- Add a capability declaration and fallback order for each attachment.
- Include a deterministic workload and expected reference output.
