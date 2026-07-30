---
applyTo: "**/*.cc,**/*.cpp,**/*.cxx,**/*.hh,**/*.hpp,**/*.hxx"
---

# Modern C++20 Instructions

- Use Clang/LLVM and ISO C++20 as the primary toolchain.
- Keep code portable between Linux Clang and Android NDK Clang.
- Prefer RAII and the rule of zero for file descriptors, BPF objects,
  links, maps, ring buffers, database handles, threads, and IPC handles.
- Represent ownership explicitly. Use values by default, `std::unique_ptr`
  for exclusive dynamic ownership, and `std::shared_ptr` only for proven
  shared lifetime requirements.
- Use references for required non-owning parameters and pointers only when
  null is a meaningful state. Use `std::span` for contiguous borrowed data.
- Prefer `std::string_view` for borrowed text and `std::string` for owned
  text. Do not retain views beyond the lifetime of their source.
- Use `std::chrono` types for durations and time points; do not pass
  unitless integer time values through C++ APIs.
- Use scoped enums, strong domain types, `std::optional`, and `std::variant`
  to model states explicitly.
- Use concepts where they make template requirements clearer. Avoid
  template abstraction without a concrete reuse case.
- Prefer algorithms and ranges when they are clearer than manual loops.
- Use `std::jthread` and cooperative cancellation for owned worker threads.
- Avoid owning raw pointers, C-style casts, manual `new`/`delete`, variable
  length arrays, GNU-only C++ extensions, and macro-generated C++ APIs.
- Keep kernel/userspace event layouts C-compatible, fixed-width, versioned,
  trivially copyable, and free of standard-library types.
- Do not use a C++23 facility unless the project standard is deliberately
  changed and Android NDK support is verified.
- Follow the project's explicit error model once established; do not mix
  exceptions, status objects, and sentinel values arbitrarily.
