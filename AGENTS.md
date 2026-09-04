# AGENTS.md - forge-standard

## Purpose

Publishable skill repo delivering quota-free iterative code review with a
continuous loop, ranked reporting, and per-repo memory. No external tokens.

## Skill Contract

- `.forge-standard/` is created on first invocation by `./scripts/init.sh`
  and reused/updated on every later invocation. Never delete blindly.
- Scripts are idempotent and POSIX-friendly: `init.sh`, `review.sh`, `report.sh`.
- Reports are ranked `critical -> high -> medium -> low -> nitpick`.
- VCS mode auto-detects `git` || `hg` || `none`.
- All analysis is local; no network calls in the loop.

## Conventions

- Bash scripts: `set -euo pipefail`, shellcheck clean.
- Frontmatter in `SKILL.md` is exactly `name` + `description` (parser-strict).
- Keep line lengths reasonable; prefer small, focused scripts.
- Do not introduce external service tokens or gated dependencies.
- `references/checklist.md` is the 5-axis truth; `references/knowledge.md`
  is the fallback chain truth.
