---
name: anvil-review-loop
description: "Quota-free iterative code review with continuous loop, architecture review, security review, vulnerability review, OWASP review, correctness review, readability review, performance review, code quality review, review loop, iterative review, multi reviewer, git diff review, standards review, spec review, SOLID review — idempotent .anvil-review-loop/ per-repo memory"
---

# Anvil Review Loop

Quota-free iterative code review that runs entirely in your repository.

> No external service tokens or paid review credentials required — fully offline capable and quota-free.

## Overview

Anvil Review Loop brings a disciplined, repeatable review pass to every change
without quotas, rate limits, or external dependencies. It operates as a
continuous loop with multiple reviewer perspectives, a ranked report, and
per-repo memory that persists across invocations.

Core principles:

- **Quota-free** — no API keys, no usage caps, no network gate.
- **Loop-gated** — iterates up to 8 cycles, at most 4 auto-fix attempts per cycle.
- **Ranked report** — findings ordered critical -> high -> medium -> low -> nitpick.
- **Idempotent memory** — per-repo `.anvil-review-loop/` is created once and reused.
- **VCS-aware** — works with git, hg, or no VCS (degrades gracefully).

Use this skill when you need a thorough review before merging, when you want
iterative refinement until the gate passes, or when you want a repeatable
checklist that lives with the repo.

## Install

Global install (recommended):

```bash
npx skills add SriChandraSekharA/anvil-review-loop --skill anvil-review-loop -g
```

Local project install:

```bash
npx skills add SriChandraSekharA/anvil-review-loop --skill anvil-review-loop
```

Manual clone:

```bash
git clone https://github.com/SriChandraSekharA/anvil-review-loop.git
```

After install the skill is available as `anvil-review-loop` via `npx skills add -l`.

## Contract

The skill follows a strict idempotent contract anchored at `.anvil-review-loop/`:

1. **First invocation** — `init` creates `.anvil-review-loop/` at the repo root
   with baseline config, checklist snapshot, and knowledge fallback manifest.
2. **Reuse thereafter** — every subsequent invocation reads the existing
   `.anvil-review-loop/` directory, reuses stored state, and updates only what
   changed (findings, iteration counter, timestamps).
3. **Never recreate blindly** — if `.anvil-review-loop/` already exists, scripts
   do not overwrite user customizations; they merge or append.
4. **Per-repo isolation** — each repository owns its own `.anvil-review-loop/`
   directory; no global state leaks between repos.
5. **Deterministic cleanup** — `report` consolidates findings without mutating
   source files; `review` may propose patches but requires explicit apply.

This contract guarantees the loop can be re-entered safely any number of times
without duplicating state or losing prior decisions.

## Prerequisites

- **git** — required for diff-range and staged review modes.
- **bash** — required to run scripts (`bash 4+` recommended, `zsh` also works).
- **jq** — optional but recommended for JSON report shaping and filtering.
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

Creates `.anvil-review-loop/` on first run; on later runs validates and
updates the manifest. Safe to run repeatedly.

### 2. Review

```bash
./scripts/review.sh --staged
./scripts/review.sh --range HEAD~1..HEAD
./scripts/review.sh --range main...feature
./scripts/review.sh --file path/to/file.ts
```

Modes:

- `--staged` — review only staged changes (`git diff --cached`).
- `--range <ref>` — review a commit range or branch diff.
- `--file <path>` — review a single file regardless of VCS state.

Options:

- `--max-iterations 8` — cap loop iterations (default 8, alias loop gate 8).
- `--max-fixes 4` — cap auto-fix attempts per iteration (default 4, alias max4).
- `--severity critical,high` — filter report by severity.

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
anvil-review-loop/
  SKILL.md                # this file — frontmatter + contract
  README.md               # install, features, license
  AGENTS.md               # contributor contract for this repo
  .gitignore              # ignores .anvil-review-loop/, logs, caches
  scripts/
    init.sh               # idempotent .anvil-review-loop/ bootstrap
    review.sh             # staged | range | file review loop
    report.sh             # ranked report generator
  references/
    checklist.md          # 5-axis checklist (correctness/readability/arch/security/perf)
    knowledge.md          # fallback chain priority list
  templates/
    report.md             # markdown report template
```

- `scripts/` — bash entry points; keep them POSIX-friendly and shellcheck clean.
- `references/` — authoritative checklists and fallback docs.
- `templates/` — output templates consumed by `report.sh`.
- `.anvil-review-loop/` — per-repo runtime memory (gitignored, never committed).

## Conventions

- Keep reviews deterministic: same input diff produces same ordered findings.
- Write findings as actionable items with file:line, severity, and fix hint.
- Prefer knowledge fallback chain over hard-coded rules when repo docs exist.
- No network calls inside the loop; all analysis is local.
- Respect `.gitignore` and `.anvil-review-loop/` isolation.
