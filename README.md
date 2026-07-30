# Android eBPF Observatory

A Linux-first eBPF observability engine with Android as the first platform
adapter.

The project is developed in two stages:

1. Complete a reusable Linux daemon and CLI for process, CPU, memory,
   filesystem, block IO, and network observability.
2. Add Android package enrichment, Binder, input, graphics, foreground
   inference, and an optional APK client.

See:

- [Implementation plan](docs/implementation-plan.md)
- [Architecture entry point](docs/architecture/README.md)
- [Agentic development workflow](docs/agentic-workflow.md)
- [Build instructions](docs/development/building.md)
- [Learning roadmap](docs/learning-roadmap.md)

## Build

The primary toolchain is Clang/LLVM with ISO C++20 and libbpf:

```sh
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
```
