# anvil-review-loop

Quota-free iterative code review with continuous loop - no tokens, no quotas, no external service dependency.

## Install

```bash
npx --yes skills add SriChandraSekharA/anvil-review-loop --skill anvil-review-loop -g -y
```

Local install:

```bash
npx --yes skills add SriChandraSekharA/anvil-review-loop --skill anvil-review-loop -g -y
```

Manual:

```bash
git clone https://github.com/SriChandraSekharA/anvil-review-loop.git
```

## Features

- **Knowledge fallback chain** - resolves review standards from repo docs in priority order: `AGENTS.md` -> `CONTRIBUTING.md` -> `.github/copilot-instructions.md` -> `docs/agents/issue-tracker.md` -> Fowler reference note.
- **VCS-aware** - detects `git` || `hg` || `none` and degrades gracefully; staged, range, and file modes work across all three.
- **Loop gate 8 max4** - iterates up to 8 cycles, at most 4 auto-fix attempts per cycle; deterministic stop gate prevents infinite loops.
- **Ranked report** - findings ordered `critical -> high -> medium -> low -> nitpick` with file:line, severity, and actionable fix hints.
- **Idempotent memory** - `.anvil-review-loop/` is created on first invocation and reused/updated thereafter; per-repo isolation, never committed.
- **Fully offline** - no API keys, no network calls, no hidden uploads; all analysis runs locally via bash scripts.

## Quick Start

```bash
./scripts/init.sh
./scripts/review.sh --staged
./scripts/review.sh --range HEAD~1..HEAD
./scripts/review.sh --file path/to/file.ts
./scripts/report.sh --format markdown --output review.md
```

## Structure

- `scripts/` - `init.sh`, `review.sh`, `report.sh`
- `references/` - checklist and knowledge fallback docs
- `templates/` - report templates

## Timestamps

All artifacts use ISO8601 with IST offset `+05:30`. Every `init` and `review` invocation refreshes `lastReviewAt` in `state.json` without wiping `CUSTOM` blocks or `reviews`.

- **state.json**

```json
{"lastReviewAt":"2026-09-05T03:45:00+05:30"}
```

Full example after init:

```json
{
  "initialized": true,
  "reviews": [],
  "version": 1,
  "lastReviewAt": "2026-09-05T03:45:00+05:30"
}
```

- **history.md header**

```
# History generated 2026-09-05T03:45:00+05:30 IST - git log -30
abc1234 feat: add login
def5678 fix: handle null
```

- **learning.md iteration line** (appended on each review loop iteration):

```
## 2026-09-05T03:45:00+05:30 Iteration 1 score: 8
## 2026-09-05T03:45:00+05:30 Iteration 2 score: 9
```

`learning.md` is append-only and never truncated on re-init.

- **report.md header**

```
# Anvil Review Report

Report generated 2026-09-05T03:45:00+05:30 IST - <BASE_SHA>...<HEAD_SHA>

Generated: 2026-09-05T03:45:00+05:30
```

Behavior: `scripts/init.sh` and `scripts/review.sh` update `lastReviewAt` via `date +"%Y-%m-%dT%H:%M:%S+05:30"` (fallback to UTC `Z` if unavailable) and preserve `.anvil-review-loop/reviews` and any `CUSTOM` / `USER CUSTOM START` blocks via `scripts/merge.sh`.

## License

MIT - see `LICENSE` if present. Free for personal and commercial use.

## Contract

`.anvil-review-loop/` is initialized on first invocation and reused/updated on every later invocation. Do not commit it; it is gitignored by default.
