## Outcome

## Design phase and layer

## Architectural boundaries

- [ ] Linux core remains free of Android dependencies.
- [ ] Kernel facts, platform enrichment, and inference remain distinct.
- [ ] No duplicate kernel attachment was introduced.
- [ ] Unknown and ambiguous states are preserved.

## Capability and compatibility

- Required capabilities:
- Fallback behavior:
- Tested kernels/devices:

## Validation evidence

- Correctness/reference:
- Perfetto comparison:
- Event loss:
- Runtime overhead:
- Resource bounds:

## Event and storage impact

- [ ] Event schema compatibility was considered.
- [ ] Map and queue capacity is documented.
- [ ] Raw events remain sufficient to rebuild derived output.

## Documentation and limitations

- [ ] Documentation was updated for changed behavior, contracts, schemas,
      modules, capabilities, validation, or limitations.
- [ ] If documentation was not changed, the implementation has no
      user-visible, architectural, contract, compatibility, or operational
      impact requiring documentation.
