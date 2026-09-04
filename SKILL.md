---
name: forge-standard
description: "Quota-free iterative code review with continuous loop, architecture review, security review, vulnerability review, OWASP review, correctness review, readability review, performance review, code quality review, review loop, iterative review, multi reviewer, git diff review, standards review, spec review, SOLID review - idempotent .forge-standard/ per-repo memory"
---

# Anvil Review Loop

Quota-free iterative code review that runs entirely in your repository.

> No external service tokens or paid review credentials required - fully offline capable and quota-free.

## Overview

Anvil Review Loop brings a disciplined, repeatable review pass to every change
without quotas, rate limits, or external dependencies. It operates as a
continuous loop with multiple reviewer perspectives, a ranked report, and
per-repo memory that persists across invocations.

Core principles:

- **Quota-free** - no API keys, no usage caps, no network gate.
- **Loop-gated** - iterates up to 8 cycles, at most 4 auto-fix attempts per cycle.
- **Ranked report** - findings ordered critical -> high -> medium -> low -> nitpick.
- **Idempotent memory** - per-repo `.forge-standard/` is created once and reused.
- **VCS-aware** - works with git, hg, or no VCS (degrades gracefully).

Use this skill when you need a thorough review before merging, when you want
iterative refinement until the gate passes, or when you want a repeatable
checklist that lives with the repo.

## Install

Global install (recommended):

```bash
npx skills add SriChandraSekharA/forge-standard --skill forge-standard -g
```

Local project install:

```bash
npx skills add SriChandraSekharA/forge-standard --skill forge-standard
```

Manual clone:

```bash
git clone https://github.com/SriChandraSekharA/forge-standard.git
```

After install the skill is available as `forge-standard` via `npx skills add -l`.

## Contract

The skill follows a strict idempotent contract anchored at `.forge-standard/`:

1. **First invocation** - `init` creates `.forge-standard/` at the repo root
   with baseline config, checklist snapshot, and knowledge fallback manifest.
2. **Reuse thereafter** - every subsequent invocation reads the existing
   `.forge-standard/` directory, reuses stored state, and updates only what
   changed (findings, iteration counter, timestamps).
3. **Never recreate blindly** - if `.forge-standard/` already exists, scripts
   do not overwrite user customizations; they merge or append.
4. **Per-repo isolation** - each repository owns its own `.forge-standard/`
   directory; no global state leaks between repos.
5. **Deterministic cleanup** - `report` consolidates findings without mutating
   source files; `review` may propose patches but requires explicit apply.

This contract guarantees the loop can be re-entered safely any number of times
without duplicating state or losing prior decisions.

## Prerequisites

- **git** - required for diff-range and staged review modes.
- **bash** - required to run scripts (`bash 4+` recommended, `zsh` also works).
- **jq** - optional but recommended for JSON report shaping and filtering.
  If `jq` is absent, reports fall back to plain text tables.

Verify before use:

```bash
git --version
bash --version
jq --version   # optional
```

## Usage

All scripts live under `scripts/` and are executable from the skill root or
via the installed skill path.

### 1. Initialize

```bash
./scripts/init.sh
```

Creates `.forge-standard/` on first run; on later runs validates and
updates the manifest. Safe to run repeatedly.

### 2. Review

```bash
./scripts/review.sh --staged
./scripts/review.sh --range HEAD~1..HEAD
./scripts/review.sh --range main...feature
./scripts/review.sh --file path/to/file.ts
```

Modes:

- `--staged` - review only staged changes (`git diff --cached`).
- `--range <ref>` - review a commit range or branch diff.
- `--file <path>` - review a single file regardless of VCS state.

Options:

- `--max-iterations 8` - cap loop iterations (default 8, alias loop gate 8).
- `--max-fixes 4` - cap auto-fix attempts per iteration (default 4, alias max4).
- `--severity critical,high` - filter report by severity.

### 3. Report

```bash
./scripts/report.sh
./scripts/report.sh --format json
./scripts/report.sh --format markdown --output review.md
```

Generates the ranked report ordered critical -> high -> medium -> low -> nitpick.
No tokens, no external calls, no hidden uploads.

## Structure

```
forge-standard/
  SKILL.md                # this file - frontmatter + contract
  README.md               # install, features, license
  AGENTS.md               # contributor contract for this repo
  .gitignore              # ignores .forge-standard/, logs, caches
  scripts/
    init.sh               # idempotent .forge-standard/ bootstrap
    review.sh             # staged | range | file review loop
    report.sh             # ranked report generator
  references/
    checklist.md          # 6-axis checklist (correctness/readability/arch/security/perf/test coverage)
    knowledge.md          # fallback chain priority list
  templates/
    report.md             # markdown report template
    worker.prompt.md      # worker prompt with 6 axes including test quality
    critic.prompt.md      # critic prompt with test-aware scoring
```

- `scripts/` - bash entry points; keep them POSIX-friendly and shellcheck clean.
- `references/` - authoritative checklists and fallback docs.
- `templates/` - output templates consumed by `report.sh`.
- `.forge-standard/` - per-repo runtime memory (gitignored, never committed).

## Test-Aware Review

When the target repo has tests, the review loop includes them automatically. Detection is non-failing and uses guards for `tests/` `testsuite/` `__tests__/` `spec/` directories, glob patterns `**/*.test.*` `**/*.spec.*` via `find . -maxdepth 4 -name "*.test.*"`, and config files `pytest.ini` `vitest.config.*` `jest.config.*` `pyproject.toml` pytest `package.json` script test and `Makefile` test - all with `if [ -f ... ]` or `grep -q` guards and `|| true` so review never blocks if none found.

- If tests are detected, `scripts/review.sh` collects (a) list of test files (capped at 20, `find ... | head -20`) and (b) quick discovery with 30s timeout: `timeout 30 pytest --collect-only 2>&1 | head -30 || timeout 30 npm test -- --listTests 2>&1 | head -20 || true` - failure is graceful and does not fail the review.
- `TEST_CONTEXT` is set to `Tests detected: yes` plus file list and discovery output, persisted to `.forge-standard/test_context.md` and passed to worker/critic prompts.
- Worker and critic include axis 6 (test quality/coverage): missing tests for changed code, brittle mocks, no edge cases, coverage gaps, test deletion to fake green. Prompt section: "If TEST_CONTEXT shows existing tests, review them for coverage gaps, missing edge cases, brittle mocks, and whether changed code lacks tests."
- Checklist `references/checklist.md` has Test Coverage (Axis 6) with items: changed code has tests? edge cases covered? mocks not brittle? no test deletion to fake green? These map to severity medium/high when missing (missing tests for critical code -> high, typo in test -> low).
- Report `scripts/report.sh` maps test findings to severity and ensures fix/prompt suggests test code: e.g. `add test for changed code: tests/test_foo.py covering boundary and failure cases`.

Example state when tests present:

```bash
cat .forge-standard/test_context.md
# Tests detected: yes
# Test files:
# tests/test_foo.py
# tests/test_bar.test.ts
# Discovery:
# tests/test_foo.py::test_boundary
```

Example report snippet mentioning tests:

```
## High

- **src/foo.py | high**
  - reason: missing test coverage for changed code - changed src without test update (Fowler Code Smell)
  - fix: add test for changed code: e.g. tests/test_foo.py covering boundary and failure cases
  - prompt: Act as a senior reviewer, fix high test issue at src/foo.py: missing test coverage ... by add test ...
```

When no tests exist (`Tests detected: no`), the loop skips test checks and does not block - review still passes with exit 0.

## Conventions

- Keep reviews deterministic: same input diff produces same ordered findings.
- Write findings as actionable items with file:line, severity, and fix hint.
- Prefer knowledge fallback chain over hard-coded rules when repo docs exist.
- No network calls inside the loop; all analysis is local.
- Respect `.gitignore` and `.forge-standard/` isolation.
