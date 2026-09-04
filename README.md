# anvil-review-loop

Quota-free iterative code review with continuous loop — no tokens, no quotas, no external service dependency.

## Install

```bash
npx skills add SriChandraSekharA/anvil-review-loop --skill anvil-review-loop -g
```

Local install:

```bash
npx skills add SriChandraSekharA/anvil-review-loop --skill anvil-review-loop
```

Manual:

```bash
git clone https://github.com/SriChandraSekharA/anvil-review-loop.git
```

## Features

- **Knowledge fallback chain** — resolves review standards from repo docs in priority order: `AGENTS.md` -> `CONTRIBUTING.md` -> `.github/copilot-instructions.md` -> `docs/agents/issue-tracker.md` -> Fowler reference note.
- **VCS-aware** — detects `git` || `hg` || `none` and degrades gracefully; staged, range, and file modes work across all three.
- **Loop gate 8 max4** — iterates up to 8 cycles, at most 4 auto-fix attempts per cycle; deterministic stop gate prevents infinite loops.
- **Ranked report** — findings ordered `critical -> high -> medium -> low -> nitpick` with file:line, severity, and actionable fix hints.
- **Idempotent memory** — `.anvil-review-loop/` is created on first invocation and reused/updated thereafter; per-repo isolation, never committed.
- **Fully offline** — no API keys, no network calls, no hidden uploads; all analysis runs locally via bash scripts.

## Quick Start

```bash
./scripts/init.sh
./scripts/review.sh --staged
./scripts/review.sh --range HEAD~1..HEAD
./scripts/review.sh --file path/to/file.ts
./scripts/report.sh --format markdown --output review.md
```

## Structure

- `scripts/` — `init.sh`, `review.sh`, `report.sh`
- `references/` — checklist and knowledge fallback docs
- `templates/` — report templates

## License

MIT — see `LICENSE` if present. Free for personal and commercial use.

## Contract

`.anvil-review-loop/` is initialized on first invocation and reused/updated on every later invocation. Do not commit it; it is gitignored by default.
