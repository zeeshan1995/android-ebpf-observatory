---
applyTo: "src/**"
---

# Userspace Instructions

- Use Clang with ISO C++20 for collector, analytics, storage, daemon, and
  native client code.
- Wrap native resources in focused RAII types and make ownership visible at
  API boundaries.
- Consume canonical versioned events and reject unknown incompatible
  versions explicitly.
- Keep raw events immutable; normalized and derived data must be rebuildable.
- Preserve source module, attachment, timestamp, CPU, and loss metadata.
- Reorder events only within a documented bounded window.
- Separate collection, enrichment, correlation, storage, and presentation.
- Program against narrow interfaces such as `EventSource`, `EventSink`,
  `CapabilityProvider`, and identity resolvers.
- Prefer value-oriented APIs and dependency injection through constructors
  over service locators or global mutable state.
- Bound memory, queues, retries, and storage retention.
- Never convert missing data into success-shaped attribution.
- Make shutdown flush behavior and partial-recording semantics explicit.
