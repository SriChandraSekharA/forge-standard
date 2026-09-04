# Review Checklist — 5-Axis (Stub)

> Full content filled in Task 3. This stub establishes the contract.

## Axes

1. **Correctness** — logic, edge cases, error handling, data flow, invariants.
2. **Readability** — naming, structure, comments, consistency, intent clarity.
3. **Architecture** — modularity, dependencies, layering, SOLID, spec alignment.
4. **Security** — input validation, auth, OWASP top 10, secrets, injection.
5. **Performance** — complexity, allocations, I/O, caching, hot-path cost.

## Severity Scale

- **critical** — breaks build, data loss, or exploitable security hole.
- **high** — likely bug or serious design flaw.
- **medium** — improvement with clear benefit, moderate risk.
- **low** — polish, minor style or micro-optimization.
- **nitpick** — subjective preference; safe to defer.

## How to Use

Each finding must cite `file:line`, axis, severity, and fix hint.
Ranked report orders `critical -> high -> medium -> low -> nitpick`.
Gate: loop up to 8 iterations, at most 4 fixes per iteration.

## Status

Stub only — detailed checklist items land in Task 3.
