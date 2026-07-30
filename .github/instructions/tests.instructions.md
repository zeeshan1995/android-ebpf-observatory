---
applyTo: "tests/**"
---

# Test Instructions

- Use deterministic workloads with explicit expected events and tolerances.
- Test PID reuse, process exit, collector restart, unload/reload, and
  unsupported hooks where relevant.
- Include map exhaustion, transport pressure, event loss, and unknown schema
  tests for infrastructure changes.
- Compare equivalent scheduler, process, Binder, or graphics signals with
  Perfetto when practical.
- Keep device/vendor assumptions in compatibility fixtures, not generic
  assertions.
- Record accuracy, event loss, runtime overhead, and device metadata for
  benchmark tests.
