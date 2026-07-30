# Building

## Toolchain

The primary userspace toolchain is:

- Clang/LLVM
- bpftool
- ISO C++20 with compiler extensions disabled
- CMake 3.24 or newer
- Ninja
- libbpf 1.0 or newer
- libelf, zlib, and pkg-config

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
