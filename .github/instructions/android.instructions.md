---
applyTo: "ebpf/platform/android/**,collector/platform/android/**,analytics/platform/android/**"
---

# Android Platform Instructions

- Build Android native userspace code with Android NDK Clang in C++20 mode.
- Do not depend on a standard-library feature until it is supported by the
  project's minimum NDK version.
- Treat UID-to-package mapping as enrichment, not kernel truth.
- Handle Android multi-user UIDs, isolated UIDs, shared UIDs, app zygotes,
  and processes without a resolvable package.
- Keep Binder process dependencies distinct from named-service identity.
- Do not infer input delivery from kernel input occurrence alone.
- Separate application rendering, SurfaceFlinger composition, and display.
- Verify uprobe targets using build IDs, symbols, and ABI compatibility;
  fail closed when they do not match.
- Keep Android framework dependencies out of core Linux modules.
- Label foreground state as an inference with evidence and confidence.
- Use authoritative Android state only as an experiment oracle unless a
  documented product dependency is explicitly approved.
