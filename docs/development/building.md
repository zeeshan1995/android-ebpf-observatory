# Building

## Toolchain

The primary userspace toolchain is:

- Clang/LLVM
- ISO C++20 with compiler extensions disabled
- CMake 3.24 or newer
- Ninja
- libbpf 1.0 or newer
- libelf, zlib, and pkg-config

`bpftool` is intentionally not installed through Ubuntu's virtual
`bpftool` package in CI because the GitHub runner image currently has no
installable binary provider. The first BPF program slice will add a pinned,
reproducible bpftool source or artifact instead of relying on the runner's
kernel-package layout.

The project intentionally requires Clang by default so Linux userspace and
future Android NDK code share the same compiler family. A secondary GCC
portability build may configure with `-DOBSERVATORY_REQUIRE_CLANG=OFF`.

## Configure, Build, and Test

```sh
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
```

Run formatting validation with:

```sh
./scripts/check-format.sh
```

The `ci` preset additionally enables clang-tidy with warnings treated as
errors.

## Current Executable

The initial executable proves the build, dependency, install, and test
pipeline:

```sh
./build/dev/observatory --help
./build/dev/observatory --version
```

Capability discovery and BPF loading are introduced in subsequent vertical
slices rather than hidden behind placeholder abstractions.

## Source Layout

- `src/` contains C++ implementation files.
- C++ headers are colocated with their implementation under `src/`.
- `ebpf/` contains kernel BPF C programs.
- `tests/` mirrors behavior through unit, integration, and workload tests.
