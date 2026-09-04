# Review Checklist: 6-Axis (forge-standard)

> Ranked report: critical -> high -> medium -> low -> nitpick. Gate 8/10.
> Axes: correctness, readability/arch, security, performance, test coverage (axis 6: missing tests, brittle mocks, edge cases).
> User customizations: wrap additions between `# USER CUSTOM START` and `# USER CUSTOM END` - preserved on merge. Lines containing `CUSTOM` are also preserved via diff fallback (see scripts/merge.sh).

## Axis 1: Correctness

- L: file:line : logic holds for happy and edge paths, null and empty handled.
- L: file:line : error handling returns typed errors, no silent swallow.
- L: file:line : state invariants preserved across call path.
- L: file:line : tests cover boundary, branch, and failure cases.

## Axis 2: Readability and Architecture

- L: file:line : names reveal intent, no abbreviations that hide meaning.
- L: file:line : modules small, single purpose, SOLID layers respected.
- L: file:line : deps point one way, no cycles, spec alignment kept.
- L: file:line : comments explain why, not what; dead code removed.

## Axis 3: Security

- L: file:line : inputs validated, output encoded, no injection.
- L: file:line : auth and authz checked per OWASP Top 10.
- L: file:line : secrets not in code or logs, least privilege kept.
- L: file:line : CWE-20, CWE-79, CWE-89, CWE-287, CWE-798 covered.

## Axis 4: Performance

- L: file:line : algorithm cost stated, avoid O(n^2) on hot path.
- L: file:line : no extra allocs or sync I/O in loops, cache where useful.
- L: file:line : batch I/O, paginate large sets, respect quotas.

## Test Coverage (Axis 6)

> Only enforced when `Tests detected: yes` (see TEST_CONTEXT). When `Tests detected: no`, this section is informational and does not block.

- L: file:line : changed code has tests? Every changed `src/` logic (`*.ts, *.js, *.py`) has a corresponding test update (`*.test.*, *.spec.*, tests/`) - missing -> high (test coverage)
- L: file:line : edge cases covered? Boundary, branch, and failure paths have tests - missing edge case -> medium (coverage gap)
- L: file:line : mocks not brittle? Mocks include assertions for failure paths, not just happy path - brittle mock -> medium
- L: file:line : no test deletion to fake green? No `--- a/.*test` deletions or removed test files to hide failures - deletion -> high
- L: file:line : discovery non-failing? `pytest --collect-only` or `npm test -- --listTests` run with 30s timeout and `|| true` - never block review if discovery fails
- Mapping: missing tests for critical code -> high, coverage gap / brittle mocks -> medium, typo in test -> low, test deletion -> high

Detection guards (non-failing, per `scripts/review.sh` TEST_AWARE block):

- Dirs: `tests/` `testsuite/` `__tests__/` `spec/`
- Globs: `**/*.test.*` `**/*.spec.*` via `find . -maxdepth 4 -name "*.test.*"`
- Configs: `pytest.ini`, `vitest.config.*`, `jest.config.*`, `pyproject.toml` pytest, `package.json` script test, `Makefile` test - all with `[ -f ... ]` or `grep -q` guards and `|| true`

## Axis 6: Scoring and Severity

- Severity: critical breaks build or is exploitable, high is likely bug, medium is useful fix with moderate risk, low is polish, nitpick is style preference.
- Map test findings: missing tests for critical code -> high, coverage gap / brittle mocks -> medium, typo in test -> low, test deletion -> high (see Test Coverage above).
- Score 1-10 per finding, gate 8 to pass. Loop up to 8 iterations, at most 4 fixes each.
- Order findings critical first, then high, medium, low, nitpick.

## BAD / GOOD Pairs

- BAD: `eval(userInput)` : GOOD: `JSON.parse` with schema check. L: file:line
- BAD: `password = "secret"` in source : GOOD: env var or vault lookup. L: file:line
- BAD: 300-line function : GOOD: split by intent, each under 50 lines. L: file:line

## CWE / OWASP Map

- CWE-20 Improper Input Validation -> OWASP A03 Injection
- CWE-79 Cross-site Scripting -> OWASP A03 Injection
- CWE-89 SQL Injection -> OWASP A03 Injection
- CWE-287 Improper Authentication -> OWASP A07 Auth Failures
- CWE-798 Hard-coded Credentials -> OWASP A07 Auth Failures

## Fowler Smells Baseline (count >=10)

- Long Method, Large Class, Feature Envy, Data Clumps, Primitive Obsession, Long Parameter List, Duplicate Code, Shotgun Surgery, Divergent Change, Message Chains, Middle Man, Inappropriate Intimacy. L: file:line for each smell.

## How to Cite

- Format: `L: path/to/file.ts:42 [axis/severity] message -> fix hint`
- Keep each finding terse, one line, with file:line and fix hint.

## User Custom Area - preserved on merge

<!-- Custom entries between markers are never overwritten. See scripts/merge.sh.
     Use: # USER CUSTOM START ... # USER CUSTOM END or any line containing CUSTOM -->
# USER CUSTOM START
# (add custom checklist items here - preserved across init.sh re-runs)
# USER CUSTOM END

<!-- docs: 6-axis checklist - correctness/readability/arch/security/performance/test-coverage - severity critical->nitpick gate 8/10 terse L: pattern -->
