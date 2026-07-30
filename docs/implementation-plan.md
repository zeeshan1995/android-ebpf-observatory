# Linux-First Implementation Plan

## 1. Strategy

Android eBPF Observatory is built as two products in dependency order:

1. **Linux eBPF Observability Engine**: a complete, independently useful
   privileged Linux application.
2. **Android Observatory**: Android-specific collection, enrichment,
   inference, and UI built on the completed Linux engine.

Android work must not drive abstractions or behavior in the Linux engine.
The Linux engine is completed and validated first because:

- Process, scheduler, memory, network, VFS, and block IO are Linux kernel
  concerns.
- Linux provides a faster development loop and fewer privilege, SELinux,
  vendor-kernel, and deployment constraints.
- Generic modules can be validated against mature Linux tools before
  Android attribution is introduced.
- Android then becomes a real platform adapter instead of being mixed into
  the collection core.

This ordering does not require every future Linux feature to be completed
before Android begins. It requires the version 1 Linux engine defined by
the **Linux Engine Complete Gate** to be complete.

## 2. Product Architecture

```text
                         Optional Clients

             Linux CLI   Android APK   Web UI   Perfetto
                  \          |           |          /
                   +---------+-----------+---------+
                                      |
                           Authenticated Local API
                                      |
+-----------------------------------------------------------------------+
|                    Privileged Native Daemon                           |
|                                                                       |
|  Module Manager   Capability Resolver   Event Router   Health/Loss     |
|         |                  |                 |             |           |
|  Linux Enrichment   Platform Enrichment   Correlation   Storage/API    |
+---------+------------------+-----------------+-------------+-----------+
          |
       libbpf
          |
+---------+-------------------------------------------------------------+
|                         Kernel Programs                               |
|                                                                       |
|  Linux: process, scheduler, memory, filesystem, block IO, network      |
|  Android: Binder, input, graphics, narrowly justified uprobes         |
+-----------------------------------------------------------------------+
```

The daemon is the product boundary. The Linux CLI, Android APK, web UI,
and Perfetto integration are replaceable clients. The APK never owns the
privileged eBPF lifecycle.

## 3. Dependency Direction

```text
clients
   |
API and query contracts
   |
analytics and platform enrichment
   |
canonical events and event routing
   |
collector/module lifecycle
   |
libbpf adapter
   |
BPF programs
```

Dependencies point downward. Lower layers never import clients, Android
framework APIs, storage implementations, or analytics policy.

### Semantic Layers

1. **Kernel facts**
   - Process lifecycle, scheduling, faults, socket, VFS, and block events.
   - Emitted by Linux-generic BPF modules.
2. **Platform enrichment**
   - Android package identity, Binder semantics, rendering context, and
     other platform metadata.
   - Added without rewriting the underlying Linux event.
3. **Inference**
   - Activity scores, timelines, dependency graphs, and platform-state
     hypotheses.
   - Includes evidence, confidence, ambiguity, and data-quality state.

## 4. Core Contracts

The following contracts are established during the Linux phases and remain
stable when Android is added:

- `CapabilityReport`: kernel, BTF, program, map, hook, privilege, and
  fallback availability.
- `ModuleDescriptor`: required capabilities, optional capabilities,
  attachment order, maps, and event types.
- `EventEnvelope`: schema version, event type, monotonic timestamp, CPU,
  source module, attachment identifier, and sequence/loss metadata.
- `ProcessIdentity`: PID, TGID, process start identity, parent, UID, and
  namespace identity.
- `EventSource` and `EventSink`: bounded event transport contracts.
- `ModuleHealth`: load state, attachment choice, verifier failure, map
  pressure, event loss, and backpressure.
- `ClockCalibration`: monotonic-to-wall-clock calibration points.
- `StorageSchema`: versioned raw records, normalized identities and
  resources, migrations, and query compatibility.

Kernel/userspace ABI structures remain C-compatible, fixed-width,
versioned, and trivially copyable. C++ domain models remain separate.
Initial snapshots and other point-in-time inputs required for analysis are
persisted as first-class raw records so replay never rereads live system
state.

## 5. Stage A: Linux eBPF Observability Engine

### Phase L0: Toolchain and Reference Environment

**Purpose:** Establish a reproducible development and validation baseline.

**Deliverables:**

- Clang/LLVM, C++20, libbpf, bpftool, CMake, and test toolchain.
- One primary Linux reference environment and one different kernel.
- Recorded kernel config, BTF, privileges, cgroup mode, and tracefs state.
- Explicit scope decision for kernels without usable BTF. Version 1 may
  require BTF, but must fail clearly rather than imply CO-RE portability.
- Initial capability-report command.
- Deterministic workload harness and reference-tool inventory.

**Exit criteria:**

- A clean checkout builds reproducibly.
- Capability reports are generated on both kernels.
- Unsupported prerequisites produce actionable diagnostics.

### Phase L1: Runtime, Contracts, and Event Pipeline

**Purpose:** Build the reusable foundation before subsystem probes.

**Deliverables:**

- Minimal CO-RE BPF program and generated skeleton.
- RAII wrappers for BPF objects, links, maps, ring buffers, and file
  descriptors.
- Module registration, load, attach, detach, and shutdown lifecycle.
- Capability-driven attachment resolver with no silent fallback.
- Canonical event envelope and schema-version handling.
- Monotonic clock calibration.
- Bounded transport, raw-event storage, and loss/backpressure counters.
- Versioned baseline raw/normalized storage schema, migration mechanism,
  and minimal query contract.
- Structured diagnostics and health query.
- Shared hook ownership and internal event distribution.

**Exit criteria:**

- A versioned event travels from kernel to persistent storage and query
  output.
- Repeated load/unload and daemon restart leak no links or pinned objects.
- Unknown schemas, unsupported hooks, and transport pressure are visible.
- A known-ordering workload validates cross-CPU/cross-module ordering and
  clock-calibration bounds.

### Phase L2: Process Identity and Lifecycle

**Purpose:** Establish attribution identity before collecting resources.

**Preferred hooks:** `sched_process_fork`, `sched_process_exec`,
`sched_process_exit`.

**Deliverables:**

- PID, TGID, parent, UID, command, namespace, and start identity.
- Process tree and thread-versus-process model.
- PID-reuse-safe lifecycle state.
- Startup snapshot reconciled with subsequent lifecycle events.
- Startup snapshot persisted as first-class raw records for replay.
- Exit cleanup distributed to dependent modules.
- CLI process timeline and raw/normalized storage.

**Validation:**

- Controlled fork, clone/thread, exec, daemonize, exit, and rapid PID reuse.
- Comparison with `/proc`, `ps`, and workload-owned ground truth.

**Exit criteria:**

- No stale identity is used after exit or PID reuse.
- Snapshot/event races and unresolved identities are represented explicitly.
- The module loads and emits a smoke-test event on the secondary kernel, or
  reports an expected unsupported capability.

### Phase L3: Scheduler and CPU Accounting

**Purpose:** Attribute CPU execution using the Phase L2 identity model.

**Preferred hooks:** `sched_switch`, `sched_waking`, `sched_wakeup`.

**Deliverables:**

- Runtime by thread, process, UID, CPU, and time window.
- Context switches, wakeups, run-queue delay, migration, and CPU hotplug.
- Per-CPU aggregation where global ordering is unnecessary.
- CPU timeline, top-process query, and scheduler health metrics.

**Validation:**

- Single-thread, multithread, multi-process, affinity, migration, sleep,
  wakeup, and CPU saturation workloads.
- Comparison with `perf`, `/proc`, `pidstat`, and workload timing.

**Exit criteria:**

- Runtime and wakeup metrics meet documented tolerances.
- Process exit, CPU hotplug, and event pressure do not leave stale state.
- The module passes a load-and-emit smoke test on the secondary kernel.

### Phase L4: Memory Activity

**Purpose:** Add memory evidence without claiming information unavailable
from selected kernel hooks.

**Deliverables:**

- Major/minor page fault activity.
- Reclaim, compaction, swap, and OOM events where supported.
- Process/UID attribution when the kernel signal provides it.
- Optional sampled stack traces as a separately gated capability.
- Clear separation between event activity and point-in-time RSS/PSS data.

**Validation:**

- Allocation, file-backed fault, anonymous fault, reclaim pressure, swap,
  and controlled OOM workloads.
- Comparison with `/proc`, `vmstat`, pressure stall information, and
  workload counters.

**Exit criteria:**

- Supported memory events are attributed and bounded.
- Unsupported attribution remains unknown rather than inferred.
- The module passes a load-and-emit smoke test on the secondary kernel.

### Phase L5: Filesystem and VFS

**Purpose:** Observe logical application file activity without presenting
it as physical storage activity.

**Deliverables:**

- Syscall/VFS operation counts, bytes, latency, and process identity.
- Path collection disabled by default; explicit redaction/hashing policy.
- File identity and descriptor-lifetime limitations.

**Validation:**

- Open, read, write, rename, unlink, synchronous, asynchronous, cached, and
  metadata-heavy workloads.
- Comparison with workload counters and available VFS tracing tools.

**Exit criteria:**

- Logical IO attribution meets documented tolerances.
- Cached IO is not misrepresented as physical device IO.
- The module passes a load-and-emit smoke test on the secondary kernel.

### Phase L6: Block IO

**Purpose:** Observe physical device requests independently from VFS intent.

**Deliverables:**

- Request issue, queueing, merge, completion, latency, throughput, and
  device identity where supported.
- Page-cache-aware interpretation.
- Separate VFS and block timelines.
- Explicit best-effort correlation with documented limits.

**Validation:**

- Buffered, cached, synchronous, asynchronous, and direct IO workloads.
- Comparison with workload counters, `iostat`, and available block tracing.

**Exit criteria:**

- Logical and physical IO are never presented as the same measurement.
- Device metrics meet documented tolerances.
- VFS-to-block correlation limitations are quantified.
- The module passes a load-and-emit smoke test on the secondary kernel.

### Phase L7: Network

**Purpose:** Observe socket and traffic activity with explicit ownership
limits.

**Attachment order:**

1. Stable networking tracepoints.
2. Cgroup socket/SKB programs when supported.
3. fentry/fexit.
4. Kernel-version-specific kprobes as the final fallback.

**Deliverables:**

- TCP and UDP, IPv4 and IPv6.
- Socket lifecycle, endpoints, state transitions, and byte accounting.
- Process and UID attribution.
- Best-effort connection latency metrics.
- Explicit handling of inherited/shared sockets, namespaces, VPNs, NAT,
  kernel traffic, and process exit.
- Initial socket snapshot persisted as first-class raw records when used.

**Validation:**

- Controlled client/server TCP and UDP workloads, connection churn,
  inherited descriptors, namespace boundaries, and packet loss.
- Comparison with application counters, `ss`, and interface statistics.

**Exit criteria:**

- Byte totals and lifecycle meet documented tolerances.
- Ambiguous ownership is preserved rather than assigned arbitrarily.
- The module passes a load-and-emit smoke test on the secondary kernel.

### Phase L8: Linux Product Integration

**Purpose:** Turn the modules into an independently useful Linux product.

**Deliverables:**

- Privileged daemon and unprivileged CLI client.
- Module enable/disable configuration.
- Process, CPU, memory, IO, and network timelines.
- Cross-stream correlation using canonical process identity.
- Consolidated SQLite implementations of the versioned storage and query
  contracts established in Phase L1.
- Query API, recording sessions, export, and deterministic replay.
- Data-quality view covering capabilities, attachment choices, loss,
  pressure, late events, and unresolved attribution.

**Exit criteria:**

- A user can install, record, query, export, replay, and diagnose a Linux
  session without Android components.
- Derived output is reproducible from the same raw recording.

### Phase L9: Linux Hardening and Compatibility

**Purpose:** Establish the stable foundation Android will consume.

**Deliverables:**

- Compatibility matrix across the declared kernels.
- Map exhaustion, buffer pressure, malformed/unknown event, restart,
  unload/reload, and interrupted-recording tests.
- CPU, memory, storage, and event-loss budgets.
- Packaging and least-privilege capability documentation.
- Baseline security and privacy review.
- Automated regression benchmarks.

**Exit criteria:** Satisfy the Linux Engine Complete Gate.

## 6. Linux Engine Complete Gate

Android implementation begins only after all of the following are true:

1. Process, scheduler/CPU, memory, filesystem, block IO, and network
   modules work end to end on the primary Linux environment.
2. The daemon and CLI operate without Android dependencies.
3. Capability probing and fallback selection are explicit and queryable.
4. Event schemas, process identity, time, loss, and health contracts are
   versioned and documented.
5. Raw recordings deterministically rebuild normalized and derived output.
6. Lifecycle, pressure, restart, and unsupported-capability paths are
   tested.
7. Accuracy, overhead, event loss, resource bounds, privacy, and known
   limitations are measured.
8. A second Linux kernel validates portability assumptions.

The gate protects Android work from becoming a workaround for an unstable
core. Gate changes require an architecture review.

## 7. Stage B: Android Observatory

### Phase A0: Android Feasibility and Deployment

**Deliverables:**

- Rooted, emulator, or userdebug reference environment.
- Secondary device or build with a different kernel/vendor.
- Android capability and SELinux report.
- Privileged daemon deployment and authenticated Binder/AIDL API.
- Perfetto comparison methodology.

**Exit criteria:**

- The unmodified Linux engine modules run where supported.
- Android-specific restrictions and required platform changes are recorded.

### Phase A1: Android Process and Package Enrichment

**Deliverables:**

- UID-to-package enrichment separate from `ProcessIdentity`.
- Multi-user, isolated UID, shared UID, app zygote, and unresolved states.
- Android app/process timeline derived from Linux lifecycle and CPU events.

**Exit criteria:**

- Package views do not alter or erase underlying Linux identity.
- Ambiguous mappings remain explicit.

### Phase A2: Binder IPC

**Deliverables:**

- Transaction lifecycle, direction, flags, latency, and correlation.
- Caller/callee process graph.
- Separation of process dependency from named-service dependency.
- Unmatched and ambiguous transaction counters.

**Exit criteria:**

- Controlled synchronous and one-way transactions are reconstructed.
- Results are compared with equivalent Perfetto signals.

### Phase A3: Input Activity

**Deliverables:**

- Privacy-preserving occurrence and timing events.
- Input device/source classification.
- Correlation with scheduler and Binder without claiming delivery.

**Exit criteria:**

- Controlled activity is detected without persisting coordinates, key
  content, or unsupported foreground attribution.

### Phase A4: Graphics and Display Activity

**Deliverables:**

- Capability-dependent rendering timeline.
- Separation of application rendering, composition, and display.
- Generic, Android, and vendor-specific coverage clearly identified.
- Perfetto graphics comparison.

**Exit criteria:**

- The reference workload is correlated on the primary device.
- Unsupported secondary-device signals degrade explicitly.

### Phase A5: Targeted Android Uprobes

**Purpose:** Fill named gaps proven by Phases A1-A4, not explore arbitrary
internal functions.

**Deliverables:**

- Build-ID, symbol, and ABI-verified targets.
- Fail-closed attachment on mismatch.
- Measured benefit over kernel-only evidence.

**Exit criteria:**

- At least one justified signal is stable on declared builds.
- Maintenance and compatibility costs are documented.

### Phase A6: Android Activity and Foreground Inference

**Deliverables:**

- Cross-stream activity model using CPU, Binder, input, graphics, network,
  and IO evidence.
- Evidence and confidence for every state transition.
- Unknown and ambiguous foreground states.
- Comparison against authoritative Android state used only as a test oracle.

**Validation scenarios:**

- Foreground/background transitions.
- Split screen and picture-in-picture.
- Lock screen and screen off.
- Services, media playback, notifications, and background jobs.
- Multi-user and isolated processes.

**Exit criteria:**

- Precision, recall, transition latency, unknown rate, overhead, and
  comparison with Perfetto/Android ground truth are published.

### Phase A7: Android Client

**Deliverables:**

- APK as an unprivileged client of the daemon.
- Timeline, module configuration, health, and recording controls.
- CLI remains fully usable without the APK.

**Exit criteria:**

- The APK contains no privileged BPF loading path.
- Disconnect, daemon restart, permission denial, and version mismatch are
  handled explicitly.

### Phase A8: Android Hardening and Compatibility

**Deliverables:**

- Device/build compatibility matrix.
- SELinux, privilege, reboot, upgrade, and daemon lifecycle tests.
- Android-specific performance and privacy evaluation.
- OEM/system integration guidance.

**Exit criteria:**

- A clean checkout reproduces the declared Android experiments and reports
  on the reference environment.

## 8. Pull Request Sequence

Each pull request should deliver one vertical slice. The initial sequence is:

1. Repository bootstrap, CMake, Clang C++20, libbpf discovery, and CI.
2. Capability report CLI.
3. Canonical event ABI and userspace domain model.
4. Module manager and minimal BPF event pipeline.
5. Raw storage and replay.
6. Process lifecycle vertical slice.
7. Scheduler/CPU vertical slice.
8. Memory vertical slice.
9. VFS vertical slice.
10. Block IO vertical slice.
11. Network lifecycle vertical slice.
12. Linux daemon and CLI integration.
13. Linux hardening and compatibility gate.
14. Android feasibility and deployment bootstrap.

Research and workload preparation may run in parallel, but two pull
requests must not independently redefine the same event contract, storage
schema, hook ownership, map, or module lifecycle.

## 9. Definition of Phase Completion

A phase is complete only when:

- The capability and unsupported behavior are explicit.
- The BPF program, userspace handling, storage/query path, and tests form
  an end-to-end slice.
- Maps, queues, retained data, and event payloads are bounded.
- Lifecycle cleanup and relevant pressure paths are tested.
- A trusted reference or controlled ground truth validates correctness.
- Accuracy, overhead, event loss, compatibility, privacy, and limitations
  are documented.

Loading a BPF program is a milestone inside a phase, not phase completion.
