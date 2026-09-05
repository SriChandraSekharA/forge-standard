# forge-standard

[![Skills.sh](https://img.shields.io/badge/skills.sh-forge--standard-blue?logo=data:image/svg+xml;base64)](https://skills.sh) ![npx skills add -l](assets/badge.svg)

Quota-free iterative code review with continuous loop - no tokens, no quotas, no external service dependency.

> **Demo — 10s loop: `init.sh -> review.sh --staged -> report.md -> review.json | jq`** — see [Demo](#demo) below. Placeholder terminal simulation via PIL (no ffmpeg/convert on this host); re-record with `script` + `ttygif` for pixel-perfect capture.

## Install

```bash
npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g -y
```

Local install:

```bash
npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g -y
```

Manual:

```bash
git clone https://github.com/SriChandraSekharA/forge-standard.git
```

## Features

- **Knowledge fallback chain** - resolves review standards from repo docs in priority order: `AGENTS.md` -> `CONTRIBUTING.md` -> `.github/copilot-instructions.md` -> `docs/agents/issue-tracker.md` -> Fowler reference note.
- **VCS-aware** - detects `git` || `hg` || `none` and degrades gracefully; staged, range, and file modes work across all three.
- **Loop gate 8 max4** - iterates up to 8 cycles, at most 4 auto-fix attempts per cycle; deterministic stop gate prevents infinite loops.
- **Ranked report** - findings ordered `critical -> high -> medium -> low -> nitpick` with file:line, severity, and actionable fix hints.
- **Idempotent memory** - `.forge-standard/` is created on first invocation and reused/updated thereafter; per-repo isolation, never committed.
- **Fully offline** - no API keys, no network calls, no hidden uploads; all analysis runs locally via bash scripts.

## Quick Start

```bash
./scripts/init.sh
./scripts/review.sh --staged
./scripts/review.sh --range HEAD~1..HEAD
./scripts/review.sh --file path/to/file.ts
./scripts/report.sh --format markdown --output review.md
```

## Demo

![Demo](assets/demo.gif)

10s loop — terminal simulation (800x400, 7 frames, ~10s, loop 0):

```bash
bash ./scripts/init.sh
bash ./scripts/review.sh --staged
cat .forge-standard/report.md
cat .forge-standard/review.json | jq
```

> Note: This GIF is a generated placeholder via Python PIL (ffmpeg/convert not available on this host). For a real capture: `script -q /tmp/demo.txt` then `ttygif`/`terminalizer` or `ffmpeg -loop 0 -f lavfi -i color=c=black:s=800x400 -t 10` overlay. The file at `assets/demo.gif` satisfies the `10s loop init -> review -> report` contract.

### Proof

`npx` validation (`npx --yes skills add <path> -l`):

```bash
npx --yes skills add /Users/webileapps/Chandu/github/forge-standard -l
```

Output (captured to `assets/npx-proof.txt`):

```
Source: /Users/webileapps/Chandu/github/forge-standard
Local path validated
Found 1 skill

  Available Skills

    forge-standard

      Quota-free iterative code review with continuous loop, architecture review, security review, vulnerability review, OWASP review, correctness review, readability review, performance review, code quality review, review loop, iterative review, multi reviewer, git diff review, standards review, spec review, SOLID review - idempotent .forge-standard/ per-repo memory

Use --skill <name> to install specific skills
```

Full raw log with ANSI banner in `assets/npx-proof.txt` (28 lines).

## Structure

- `scripts/` - `init.sh`, `review.sh`, `report.sh`
- `references/` - checklist and knowledge fallback docs
- `templates/` - report templates
- `assets/` - `demo.gif` (10s loop), `badge.svg`, `npx-proof.txt`

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
# Forge Standard Review Report

Report generated 2026-09-05T03:45:00+05:30 IST - <BASE_SHA>...<HEAD_SHA>

Generated: 2026-09-05T03:45:00+05:30
```

Behavior: `scripts/init.sh` and `scripts/review.sh` update `lastReviewAt` via `date +"%Y-%m-%dT%H:%M:%S+05:30"` (fallback to UTC `Z` if unavailable) and preserve `.forge-standard/reviews` and any `CUSTOM` / `USER CUSTOM START` blocks via `scripts/merge.sh`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, the npx-based development flow, and the PR process. Quick checks before you open a PR:

```bash
bash -n scripts/*.sh
npx tsc --noEmit
npm test
```

Please also read our [Code of Conduct](CODE_OF_CONDUCT.md) and [Security Policy](SECURITY.md).

## License

[MIT](LICENSE) - Copyright (c) 2026 Chandra Sekhar. Free for personal and commercial use.

## MCP Server

Same-repo MCP server at `mcp/` wrapping `scripts/review.sh` as tool `forge_review` via stdio transport.

### Install

Build once:

```bash
npm --prefix mcp install
npm run build --prefix mcp
```

Configure your MCP client with `mcp.json`:

```json
{
  "mcpServers": {
    "forge-standard": {
      "command": "node",
      "args": ["mcp/dist/server.js"],
      "cwd": "/Users/webileapps/Chandu/github/forge-standard"
    }
  }
}
```

Claude Desktop snippet is at `examples/claude-config.json`. Copy it to your Claude config:

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

Merge the `mcpServers` block, restart Claude, then `forge_review` appears in tools.

### Inspector (npx)

No install needed, use the official inspector:

```bash
npx @modelcontextprotocol/inspector node mcp/dist/server.js
```

Then open `http://localhost:6274`, select Transport `STDIO`, Command `node`, Args `mcp/dist/server.js`, click Connect. `tools/list` should show `forge_review`. Try a call with `{ "mode": "staged", "workdir": "/Users/webileapps/Chandu/github/forge-standard" }`.

CLI probe without UI:

```bash
npx -y @modelcontextprotocol/inspector --cli node mcp/dist/server.js --method tools/list
```

### Examples

Runnable client and smoke test live in `examples/`:

```bash
# Node client demo (initialize -> tools/list -> tools/call with quoted workdir)
node examples/mcp-client.js
node examples/mcp-client.js --workdir "/tmp/with spaces/my repo"

# Bash stdio smoke (piped JSON-RPC, quoted paths)
bash examples/stdio-smoke.sh
bash examples/stdio-smoke.sh --workdir "/tmp/with spaces/my repo"
```

Both quote `workdir` via `path.resolve` and `spawn` cwd, no shell interpolation.

### Tool: forge_review

Wraps `scripts/review.sh`, local only, no network. From `mcp/mcp.json`:

| Field | Type | Description |
|-------|------|-------------|
| `mode` | `"auto" \| "staged" \| "range" \| "file"` | Review mode (default `auto`) |
| `range` | `string` | Git range for `range` mode, e.g. `HEAD~1..HEAD` |
| `file` | `string` | File path for `file` mode |
| `preview` | `boolean` | If true, `--preview` diff only |
| `workdir` | `string` | Working directory (quoted, defaults to repo root) |

See `mcp/README.md` and `docs/MCP.md` for full transport details and `examples/` for runnable demos.

## Contract

`.forge-standard/` is initialized on first invocation and reused/updated on every later invocation. Do not commit it; it is gitignored by default.
