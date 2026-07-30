# Architecture

The canonical product architecture and dependency order are defined in
[`../implementation-plan.md`](../implementation-plan.md).

The central rule is:

> Complete and validate the reusable Linux eBPF observability engine before
> building Android-specific enrichment, inference, and clients.

Linux modules emit kernel facts. Android adapters add platform meaning.
Analytics produces evidence-backed inference. Clients remain replaceable.
