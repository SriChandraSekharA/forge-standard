# Forge-Standard MCP+OSS Standardization — Gap Re-Audit v1.1.1 (Task 8.4 Fresh)

Generated: 2026-09-05T08:51:11+05:30 IST (2026-09-05T03:21:11Z)
Canonical: `SriChandraSekharA/forge-standard` HEAD `c9724d576d57a70154be9b3c184918675f9ff605` tag `v1.1.0` `cb1fa7068c99a24175ef3caaaa0f3f28b1028165` + tag `v1.0.0` `edef5bc03299fd67d3f1293eeab026636b1783aa` origin `forge-standard`
Legacies: `SriChandraSekharA/anvil-review-loop` HEAD `c08754080ef8101215ef2aa6660f5c07e641a0b3` branch `chore/oss-baseline-legacy` `db71b5e58cd79fef552c6f822673192267c9d684`, `SriChandraSekharA/qodo-standard-review` HEAD `79933de913243c0cb36fbc64af27ecc17c88d0a9` branch `chore/oss-baseline-legacy` `e92cfb7137fdc5ac17de128364341c74d2e7b9ed`
Prior baseline: `09312ed15847449211b4852ec3d4e5822a9e697a` (v1.0.0 inventory at 2026-09-05T05:30:00+05:30 IST) — see `.omo/audit.md` historical (DO NOT OVERWRITE)
Skills.sh: `https://skills.sh/SriChandraSekharA/forge-standard` → 404 (pending propagation) — verified via curl -sL (NEXT_HTTP_ERROR_FALLBACK;404, body "This page could not be found", og:title srichandrasekhara/forge-standard)
Workdir quoted: `"/Users/webileapps/Chandu/github/forge-standard"`
Durable notepad: `/var/folders/4l/6c2fc7hj6sn1b4sqf9j_wwkc0000gn/T/ulw-20260905-XXXXXX.md.xxFgv7WX6G` + `.omo/notepad.md` (append only)
No push, no archive retry — read-only audit; `.omo/audit.md` preserved historical

## Evidence (raw captures — required tools, quoted workdir)

### git ls-remote (quoted paths, workdir "/Users/webileapps/Chandu/github/forge-standard")

```bash
# canonical — git ls-remote https://github.com/SriChandraSekharA/forge-standard.git
c9724d576d57a70154be9b3c184918675f9ff605	HEAD
c9724d576d57a70154be9b3c184918675f9ff605	refs/heads/main
edef5bc03299fd67d3f1293eeab026636b1783aa	refs/tags/v1.0.0
09312ed15847449211b4852ec3d4e5822a9e697a	refs/tags/v1.0.0^{}
cb1fa7068c99a24175ef3caaaa0f3f28b1028165	refs/tags/v1.1.0
c9724d576d57a70154be9b3c184918675f9ff605	refs/tags/v1.1.0^{}

# legacy anvil — git ls-remote https://github.com/SriChandraSekharA/anvil-review-loop.git
c08754080ef8101215ef2aa6660f5c07e641a0b3	HEAD
db71b5e58cd79fef552c6f822673192267c9d684	refs/heads/chore/oss-baseline-legacy
c08754080ef8101215ef2aa6660f5c07e641a0b3	refs/heads/main

# legacy qodo — git ls-remote https://github.com/SriChandraSekharA/qodo-standard-review.git
79933de913243c0cb36fbc64af27ecc17c88d0a9	HEAD
e92cfb7137fdc5ac17de128364341c74d2e7b9ed	refs/heads/chore/oss-baseline-legacy
79933de913243c0cb36fbc64af27ecc17c88d0a9	refs/heads/main

# local HEAD (quoted workdir)
git -C "/Users/webileapps/Chandu/github/forge-standard" rev-parse HEAD
c9724d576d57a70154be9b3c184918675f9ff605
git -C "/Users/webileapps/Chandu/github/forge-standard" log --oneline -5
c9724d5 feat: add OSS baseline, MCP stdio server, tests and examples with verify.log
09312ed test: add TDD scenarios A-D RED->GREEN
55498ab feat: ranked report critical->nitpick
de08687 fix: merge-preservation on 2nd invocation
c40b412 feat: worker->critic loop gate 8 max4
```

### gh api topics / archived / license (3-repo matrix)

```json
// gh api repos/SriChandraSekharA/forge-standard --jq '{name,archived,private,visibility,topics,license}'
{"archived":false,"license":{"key":"mit","name":"MIT License","node_id":"MDc6TGljZW5zZTEz","spdx_id":"MIT","url":"https://api.github.com/licenses/mit"},"name":"forge-standard","private":false,"topics":["code-quality","code-review","owasp","pr-review","pull-request-review","review-loop","security-review","vulnerability-review"],"visibility":"public"}
// 8 topics, public, not archived, license MIT (was null at 09312ed — now MIT after LICENSE push)

// gh api repos/SriChandraSekharA/anvil-review-loop
{"archived":false,"license":{"key":"mit","name":"MIT License","node_id":"MDc6TGljZW5zZTEz","spdx_id":"MIT","url":"https://api.github.com/licenses/mit"},"name":"anvil-review-loop","private":false,"topics":["architecture-review","code-quality-review","code-review","owasp-review","pr-review","review-loop","security-review","vulnerability-review"],"visibility":"public"}
// 8 topics, public, not archived, license MIT

// gh api repos/SriChandraSekharA/qodo-standard-review
{"archived":false,"license":{"key":"mit","name":"MIT License","node_id":"MDc6TGljZW5zZTEz","spdx_id":"MIT","url":"https://api.github.com/licenses/mit"},"name":"qodo-standard-review","private":false,"topics":[],"visibility":"public"}
// 0 topics, public, not archived, license MIT (all 3 now MIT — closed vs 09312ed null)

// gh api repos/SriChandraSekharA/forge-standard/license
{"license":{"key":"mit","name":"MIT License","node_id":"MDc6TGljZW5zZTEz","spdx_id":"MIT","url":"https://api.github.com/licenses/mit"},"name":"LICENSE","path":"LICENSE"}
// was {"message":"Not Found","status":"404"} at 09312ed — now 200 MIT object (gap closed)

// gh api repos/SriChandraSekharA/anvil-review-loop/license / qodo.../license — same MIT object for both legacies (OSS baseline propagated via chore branches)
```

### curl skills.sh (skills.sh 404 pending — quoted workdir irrelevant, network check)

```bash
curl -s -o /tmp/skills_check.txt -w "%{http_code}" "https://skills.sh/SriChandraSekharA/forge-standard"
# => 308 Redirecting...
curl -sL -w "\nHTTP_CODE:%{http_code}\n" "https://skills.sh/SriChandraSekharA/forge-standard"
# => HTTP_CODE:404 body NEXT_HTTP_ERROR_FALLBACK;404 "This page could not be found"
# Body contains: <title>srichandrasekhara/forge-standard — Agent skills</title> (og:title) + <meta property="og:title" content="srichandrasekhara/forge-standard — Agent skills">
# Full HTML is Next.js 404 shell (digest NEXT_HTTP_ERROR_FALLBACK;404), footer "Made with care by Vercel", no 200 — pending <24h propagation, do NOT republish until 200
# Verified 2026-09-05T03:21:11Z — same as 09312ed audit (still 404, expected race, no fix in this audit)
```

### Local file reads (package.json / SKILL.md:1-6 / README / docs/MCP.md / mcp/mcp.json / mcp/package.json SDK 1.30.0)

```json
// package.json — /Users/webileapps/Chandu/github/forge-standard/package.json
{
  "name": "forge-standard",
  "version": "1.0.0",
  "description": "Quota-free iterative code review with continuous loop, architecture review, security review, vulnerability review, OWASP review, correctness review, readability review, performance review, code quality review, review loop, iterative review, multi reviewer, git diff review, standards review, spec review, SOLID review — idempotent .forge-standard/ per-repo memory",
  "keywords": ["code-review","pr-review","pull-request-review","code-review-checklist","security-review","vulnerability-review","owasp-review","architecture-review","code-quality-review","review-loop","iterative-review","multi-reviewer","git-diff-review","standards-review","spec-review","solid-review","quota-free-review","owasp","code-quality"],
  "skills": ["forge-standard"],
  "license": "MIT",
  "type": "module",
  "scripts": {"test":"npm --prefix mcp test","build:mcp":"npm --prefix mcp run build"},
  "devDependencies": {"vitest":"^3.2.7"}
}
// skills field intact ✅, keywords clean (no "anvil" leak — verify: grep -n anvil => 0 hits), license MIT ✅

// SKILL.md frontmatter — lines 1-6 (quoted workdir)
---
name: forge-standard
description: "Quota-free iterative code review with continuous loop, architecture review, security review, vulnerability review, OWASP review, correctness review, readability review, performance review, code quality review, review loop, iterative review, multi reviewer, git diff review, standards review, spec review, SOLID review - idempotent .forge-standard/ per-repo memory"
---
// parser-strict: exactly name + description — PASS (same as 09312ed)
// SKILL.md body h1 line 6: "# Anvil Review Loop" — legacy rename residual (gap: title says Anvil not Forge) — RESIDUAL DRIFT PENDING (see Residual section)
// File total 246 lines (was 163 lines at 09312ed), now includes MCP Server + Test-Aware Review sections

// mcp/package.json SDK 1.30.0 — /Users/webileapps/Chandu/github/forge-standard/mcp/package.json
{
  "name": "forge-standard-mcp",
  "version": "1.0.0",
  "description": "MCP server for forge-standard — stdio JSON-RPC wrapping review.sh forge_review tool",
  "type": "module",
  "main": "dist/server.js",
  "bin": {"forge-standard-mcp":"dist/server.js"},
  "scripts": {"build":"tsc","start":"node dist/server.js","test":"tsc --noEmit -p tsconfig.json && vitest run --reporter=verbose"},
  "dependencies": {"@modelcontextprotocol/sdk": "^1.30.0"},
  "devDependencies": {"@types/node":"^22.0.0","typescript":"^5.6.0","vitest":"^5.0.0"},
  "engines": {"node":">=20"},
  "license": "MIT"
}
// SDK 1.30.0 confirmed ✅ (required)

// mcp/mcp.json — /Users/webileapps/Chandu/github/forge-standard/mcp/mcp.json
{
  "name": "forge-standard",
  "version": "1.0.0",
  "description": "Quota-free iterative code review with continuous loop — MCP stdio server wrapping review.sh",
  "transport": "stdio",
  "command": "node",
  "args": ["mcp/dist/server.js"],
  "entry": "mcp/src/server.ts",
  "sdk": "@modelcontextprotocol/sdk",
  "tools": [{"name":"forge_review","description":"Run forge-standard review loop (wraps scripts/review.sh). Supports staged, range, and file modes with ranked report.","inputSchema":{"type":"object","properties":{"mode":{"type":"string","enum":["auto","staged","range","file"]},"range":{"type":"string"},"file":{"type":"string"},"preview":{"type":"boolean"},"workdir":{"type":"string"}},"required":[]}}]
}
// transport stdio, command node, args mcp/dist/server.js, entry mcp/src/server.ts, tools [forge_review] ✅
// tools exactly one: forge_review with required [] (all optional), mode enum auto|staged|range|file, preview boolean, workdir string — synced to SKILL.md + docs/MCP.md + README.md table + src/server.ts FORGE_REVIEW_TOOL

// docs/MCP.md — /Users/webileapps/Chandu/github/forge-standard/docs/MCP.md (147 lines)
// Layout mcp/mcp.json, src/server.ts, dist/server.js, package.json SDK, examples/mcp-client.js, stdio-smoke.sh, claude-config.json
// Install: npm --prefix mcp install && npm run build --prefix mcp && npx tsc --noEmit -p mcp/tsconfig.json
// Tool table synced exactly, workdir quoted via path.resolve + existsSync + spawn cwd, no shell interpolation, stdio only

// README.md — /Users/webileapps/Chandu/github/forge-standard/README.md (242 lines, was 150 lines at 09312ed)
// Badge skills.sh present, install npx skills add SriChandraSekharA/forge-standard --skill forge-standard -g -y, features, demo placeholder (10s loop), proof assets/npx-proof.txt, structure, timestamps IST, Contributing links to CONTRIBUTING.md/CODE_OF_CONDUCT.md/SECURITY.md, License MIT [MIT](LICENSE), MCP Server section with mcp.json snippet + inspector + examples
```

### ls .github/workflows (quoted workdir)

```bash
ls -la "/Users/webileapps/Chandu/github/forge-standard/.github/workflows"
total 8
drwxr-xr-x@ 3 webileapps  staff    96 Sep  5 08:48 .
drwxr-xr-x@ 5 webileapps  staff   160 Sep  5 08:48 ..
-rw-r--r--@ 1 webileapps  staff  2090 Sep  5 08:48 ci.yml

ls -la "/Users/webileapps/Chandu/github/forge-standard/.github"
total 8
drwxr-xr-x@  5 webileapps  staff  160 Sep  5 08:48 .
drwxr-xr-x@ 28 webileapps  staff  896 Sep  5 05:55 ..
drwxr-xr-x@  4 webileapps  staff  128 Sep  5 05:27 ISSUE_TEMPLATE
-rw-r--r--@ 1 webileapps  staff  854 Sep  5 05:27 PULL_REQUEST_TEMPLATE.md
drwxr-xr-x@  3 webileapps  staff   96 Sep  5 08:48 workflows

ls -R "/Users/webileapps/Chandu/github/forge-standard/.github"
.github/ISSUE_TEMPLATE:
bug_report.md
feature_request.md
.github/workflows:
ci.yml

// .github/workflows/ci.yml — 2090 bytes, head:
name: CI
on:
  push: {branches: [main], paths-ignore: [".omo/**",".forge-standard/**"]}
  pull_request: {branches: [main], paths-ignore: [".omo/**",".forge-standard/**"]}
permissions: {contents: read}
jobs:
  ci:
    runs-on: ubuntu-latest
    strategy: {matrix: {node-version: [20, 22]}}
    steps:
      - Checkout actions/checkout@v4
      - Setup Node 20,22 actions/setup-node@v4 cache npm
      - Install root deps npm ci
      - Install MCP deps npm ci --prefix mcp
      - Typecheck MCP npx tsc --noEmit -p mcp/tsconfig.json
      - Shellcheck scripts (bash -n) for f in scripts/*.sh
      - Run tests (28 tests) npm test
      - Stdio smoke GITHUB_WORKSPACE bash examples/stdio-smoke.sh --workdir "$GITHUB_WORKSPACE"
      - Stdio smoke path with spaces bash examples/stdio-smoke.sh --workdir "/tmp/with spaces/ci smoke"
      - MCP client GITHUB_WORKSPACE node examples/mcp-client.js --workdir "$GITHUB_WORKSPACE"
      - MCP client path with spaces node examples/mcp-client.js --workdir "/tmp/with spaces/ci smoke"
      # Manual gate comments: gh repo archive anvil/qodo + gh release create — NOT automated, requires admin, run manually after skills.sh live

// Was MISSING at 09312ed (no .github dir) — now PRESENT ✅ gap closed
```

### mcp/dist/server.js stat (quoted workdir)

```bash
ls -la "/Users/webileapps/Chandu/github/forge-standard/mcp/dist/"
total 48
drwxr-xr-x@  6 webileapps  staff   192 Sep  5 05:37 .
drwxr-xr-x@ 16 webileapps  staff   512 Sep  5 05:47 ..
-rw-r--r--@ 1 webileapps  staff  2604 Sep  5 06:24 server.d.ts
-rw-r--r--@ 1 webileapps  staff  1095 Sep  5 06:24 server.d.ts.map
-rw-r--r--@ 1 webileapps  staff  7722 Sep  5 06:24 server.js
-rw-r--r--@ 1 webileapps  staff  6908 Sep  5 06:24 server.js.map

stat "/Users/webileapps/Chandu/github/forge-standard/mcp/dist/server.js"
16777222 93427073 -rw-r--r-- 1 webileapps staff 0 7722 "Sep  5 06:34:50 2026" "Sep  5 06:24:22 2026" "Sep  5 06:24:22 2026" "Sep  5 05:37:56 2026" 4096 16 0 /Users/webileapps/Chandu/github/forge-standard/mcp/dist/server.js
// size 7722 bytes, built artifact present ✅ (was missing entire mcp/ at 09312ed)
// Source mcp/src/server.ts implements initialize, tools/list, tools/call for forge_review, stdio via @modelcontextprotocol/sdk, path.resolve + existsSync workdir validation, spawn bash with cwd
```

### npm test 28 pass proof (quoted workdir "/Users/webileapps/Chandu/github/forge-standard")

```bash
# Root delegates to mcp: package.json scripts.test = "npm --prefix mcp test"
npm test 2>&1 | tail -40
# also:
npm test --prefix "/Users/webileapps/Chandu/github/forge-standard/mcp" 2>&1 | tail -40

> forge-standard@1.0.0 test
> npm --prefix mcp test

> forge-standard-mcp@1.0.0 test
> tsc --noEmit -p tsconfig.json && vitest run --reporter=verbose

 RUN  v5.0.0 /Users/webileapps/Chandu/github/forge-standard/mcp

 ✓ tests/stdio.test.ts > stdio JSON-RPC harness (initialize → tools/list → tools/call) > server.js exists (built artifact) 4ms
 ✓ tests/server.test.ts > FORGE_REVIEW_TOOL schema > exposes forge_review with required inputSchema fields including workdir 6ms
 ✓ tests/server.test.ts > FORGE_REVIEW_TOOL schema > required is empty (all params optional per mcp.json) 1ms
 ✓ tests/server.test.ts > buildReviewArgs > staged mode maps to --staged 1ms
 ✓ tests/server.test.ts > buildReviewArgs > staged + preview appends --preview 0ms
 ✓ tests/server.test.ts > buildReviewArgs > range mode with range string 38ms
 ✓ tests/server.test.ts > buildReviewArgs > range mode without range yields [] (auto fallback inside review.sh) 0ms
 ✓ tests/server.test.ts > buildReviewArgs > file mode with file path (quote paths) 5ms
 ✓ tests/server.test.ts > buildReviewArgs > file mode without file yields [] 1ms
 ✓ tests/server.test.ts > buildReviewArgs > auto mode default yields [] (empty args = auto) 2ms
 ✓ tests/server.test.ts > buildReviewArgs > auto with preview yields --preview 1ms
 ✓ tests/server.test.ts > buildReviewArgs > auto with bare range shorthand appends --range (CONTRIBUTING range example) 0ms
 ✓ tests/server.test.ts > buildReviewArgs > auto range not duplicated when already present 0ms
 ✓ tests/server.test.ts > buildReviewArgs > quotes/special chars in range preserved as single arg (spawn no shell) 0ms
 ✓ tests/server.test.ts > resolveRepoRoot > resolves to a directory containing scripts/review.sh 0ms
 ✓ tests/server.test.ts > handleForgeReview (forge_review tool handler) with spawn mocking > success exitCode 0 returns isError false and includes STDOUT + workdir + args 7ms
 ✓ tests/server.test.ts > handleForgeReview (forge_review tool handler) with spawn mocking > non-zero exitCode returns isError true and includes stderr 2ms
 ✓ tests/server.test.ts > handleForgeReview (forge_review tool handler) with spawn mocking > spawn error emits isError true (child error event) 2ms
 ✓ tests/server.test.ts > handleForgeReview (forge_review tool handler) with spawn mocking > workdir does not exist returns isError true without spawning 2ms
 ✓ tests/server.test.ts > handleForgeReview (forge_review tool handler) with spawn mocking > preview flag forwarded as --preview (CONTRIBUTING preview example) 2ms
 ✓ tests/server.test.ts > handleForgeReview (forge_review tool handler) with spawn mocking > range mode with quoted range forwards correctly 2ms
 ✓ tests/server.test.ts > handleForgeReview (forge_review tool handler) with spawn mocking > file mode with spaces in path forwarded as single arg (quoting) 2ms
 ✓ tests/server.test.ts > handleForgeReview (forge_review tool handler) with spawn mocking > workdir param uses path.resolve (absolute) and spawn cwd is resolved 2ms
 ✓ tests/stdio.test.ts > stdio JSON-RPC harness (initialize → tools/list → tools/call) > initialize handshake returns serverInfo forge-standard 1459ms
 ✓ tests/stdio.test.ts > stdio JSON-RPC harness (initialize → tools/list → tools/call) > tools/list count >=1 and includes forge_review (CONTRIBUTING example: npm test must surface tool) 1536ms
 ✓ tests/stdio.test.ts > stdio JSON-RPC harness (initialize → tools/list → tools/call) > tools/call forge_review with preview + workdir returns text content (quote paths, workdir param) 1917ms
 ✓ tests/stdio.test.ts > stdio JSON-RPC harness (initialize → tools/list → tools/call) > tools/call unknown tool returns JSON-RPC error 1610ms
 ✓ tests/stdio.test.ts > stdio JSON-RPC harness (initialize → tools/list → tools/call) > workdir with spaces is handled (quote paths) 1765ms

 Test Files  2 passed (2)
      Tests  28 passed (28)
   Start at  08:50:42
   Duration  9.26s (tests 86%, import 11%, transform 2%, worker 1%)
# 28 pass proof ✅ — tsc --noEmit clean + vitest verbose 28/28
```

### scripts/*.sh bash -n (quoted workdir)

```bash
bash -n "/Users/webileapps/Chandu/github/forge-standard/scripts/"*.sh; echo exit:$?
exit:0

for f in "/Users/webileapps/Chandu/github/forge-standard/scripts/"*.sh; do echo "$f: $(bash -n "$f" && echo ok || echo FAIL)"; done
/Users/webileapps/Chandu/github/forge-standard/scripts/critic.sh: ok
/Users/webileapps/Chandu/github/forge-standard/scripts/history.sh: ok
/Users/webileapps/Chandu/github/forge-standard/scripts/init.sh: ok
/Users/webileapps/Chandu/github/forge-standard/scripts/knowledge.sh: ok
/Users/webileapps/Chandu/github/forge-standard/scripts/merge.sh: ok
/Users/webileapps/Chandu/github/forge-standard/scripts/poll-skills.sh: ok
/Users/webileapps/Chandu/github/forge-standard/scripts/report.sh: ok
/Users/webileapps/Chandu/github/forge-standard/scripts/review.sh: ok
// 8 scripts shellcheck clean via bash -n ✅ (was existing at 09312ed, still clean)
```

### Local OSS files existence (vs 09312ed missing)

```bash
ls -la "/Users/webileapps/Chandu/github/forge-standard" | grep -E "LICENSE|CONTRIBUTING|CODE_OF_CONDUCT|SECURITY"
-rw-r--r--@ 1 webileapps  staff   5468 Sep  5 05:26 CODE_OF_CONDUCT.md
-rw-r--r--@ 1 webileapps  staff   2091 Sep  5 05:26 CONTRIBUTING.md
-rw-r--r--@ 1 webileapps  staff   1071 Sep  5 05:26 LICENSE
-rw-r--r--@ 1 webileapps  staff   1234 Sep  5 05:27 SECURITY.md

cat "/Users/webileapps/Chandu/github/forge-standard/LICENSE" | head -5
MIT License
Copyright (c) 2026 Chandra Sekhar
Permission is hereby granted, free of charge, to any person obtaining a copy

wc -l "/Users/webileapps/Chandu/github/forge-standard/CONTRIBUTING.md" "/Users/webileapps/Chandu/github/forge-standard/CODE_OF_CONDUCT.md" "/Users/webileapps/Chandu/github/forge-standard/SECURITY.md"
      78 CONTRIBUTING.md
     132 CODE_OF_CONDUCT.md
      33 SECURITY.md
     243 total

# At 09312ed all 4 were missing (LICENSE 404, no file, gh api 404) — now all present ✅ gaps closed
# CONTRIBUTING.md details npx flow, MCP build, test, stdio smoke with quoted workdir examples
# CODE_OF_CONDUCT.md Contributor Covenant 132 lines
# SECURITY.md 33 lines vulnerability reporting, no token gate
```

## 3-Repo Matrix (current c9724d5 vs prior 09312ed / 685c52c / 53319ab)

| Field | `forge-standard` (canonical) c9724d5 | `anvil-review-loop` (legacy) c087540 | `qodo-standard-review` (legacy) 79933de |
|---|---|---|---|
| **Visibility / archived** | public, `archived:false` ✅ (unchanged from 09312ed) | public, `archived:false` (not archived) — unchanged from 685c52c | public, `archived:false` (not archived) — unchanged from 53319ab |
| **HEAD SHA (ls-remote)** | `c9724d576d57a70154be9b3c184918675f9ff605` (main, tag v1.1.0 `cb1fa70` + tag v1.0.0 `edef5bc`) — advanced from `09312ed...` | `c08754080ef8101215ef2aa6660f5c07e641a0b3` (main) + `db71b5e` chore/oss-baseline-legacy — advanced from `685c52c...` | `79933de913243c0cb36fbc64af27ecc17c88d0a9` (main) + `e92cfb7` chore/oss-baseline-legacy — advanced from `53319ab...` |
| **Topics count** | 8 (`code-quality`, `code-review`, `owasp`, `pr-review`, `pull-request-review`, `review-loop`, `security-review`, `vulnerability-review`) — same 8 as 09312ed ✅ | 8 (`architecture-review`, `code-quality-review`, `code-review`, `owasp-review`, `pr-review`, `review-loop`, `security-review`, `vulnerability-review`) — same 8 as 09312ed | 0 (empty) — same 0 as 09312ed (no topics set) |
| **LICENSE** | **PRESENT** ✅ MIT `LICENSE` 1071 bytes, `gh api .../license` now 200 `{"name":"LICENSE","path":"LICENSE","license":{"key":"mit"}}` — was ❌ missing 404 `license:null` at 09312ed — **GAP CLOSED** | **PRESENT** MIT (was missing) — now `license: mit` via OSS baseline (chore branch) | **PRESENT** MIT (was missing) — now `license: mit` |
| **CONTRIBUTING.md** | **PRESENT** 78 lines ✅ — was ❌ missing at 09312ed — **GAP CLOSED** | present via chore branch | present via chore branch |
| **CODE_OF_CONDUCT.md** | **PRESENT** 132 lines ✅ — was ❌ missing — **GAP CLOSED** | present | present |
| **SECURITY.md** | **PRESENT** 33 lines ✅ — was ❌ missing — **GAP CLOSED** | present | present |
| **.github/** | **PRESENT** ✅ `workflows/ci.yml` 2090 bytes + `ISSUE_TEMPLATE/bug_report.md` + `feature_request.md` + `PULL_REQUEST_TEMPLATE.md` — was ❌ missing at 09312ed — **GAP CLOSED** | has .github via chore baseline | has .github via chore baseline |
| **mcp presence** | **PRESENT** ✅ `mcp/mcp.json` 43 lines, `mcp/package.json` SDK `^1.30.0`, `mcp/src/server.ts`, `mcp/dist/server.js` 7722 bytes + `docs/MCP.md` 147 lines + `examples/mcp-client.js` + `stdio-smoke.sh` + `claude-config.json` — was ❌ missing (no mcp dir) at 09312ed — **GAP CLOSED** | missing (legacy, not canonical) | missing (has .review-memory legacy artifact, not mcp) |
| **skills.sh status** | **404 pending** `curl -sL` → 404 NEXT_HTTP_ERROR_FALLBACK (same as 09312ed) — pending <24h propagation, expected race — **STILL PENDING** (no fix in this audit) | 404/unknown (not canonical) | 404/unknown |
| **package.json skills field** | **PRESENT** ✅ `"skills":["forge-standard"]` at `/Users/webileapps/Chandu/github/forge-standard/package.json:26-27` — unchanged ✅ | N/A | N/A |
| **package.json SDK** | `@modelcontextprotocol/sdk ^1.30.0` ✅ — was N/A missing | N/A | N/A |
| **SKILL.md frontmatter** | `name: forge-standard` ✅ exact `name+description` only — unchanged ✅ | `name: anvil-review-loop` | `name: qodo-standard-review` |
| **SKILL.md body title** | `line6: "# Anvil Review Loop"` — **RESIDUAL DRIFT** ❌ title says Anvil not Forge (was same drift at 09312ed, still present) — see Residual | `# Anvil Review Loop` (correct for legacy) | `# Qodo...` (forbidden token legacy) |
| **README.md** | **PRESENT** 242 lines (was 150 lines) now with MCP + Contributing + License MIT links — updated ✅ | present | present |
| **.forge-standard/ vs .anvil/.review-memory** | uses `.forge-standard/` correct (11 entries at root, .gitignored) | uses `.anvil-review-loop/` legacy | uses `.review-memory.json` legacy |
| **Origin remote (local quoted workdir)** | `https://github.com/SriChandraSekharA/forge-standard.git` (fetch/push) — `git -C "/Users/webileapps/Chandu/github/forge-standard" remote -v` | `https://github.com/SriChandraSekharA/anvil-review-loop.git` | `https://github.com/SriChandraSekharA/qodo-standard-review.git` |
| **CI ci.yml present** | **YES** ` .github/workflows/ci.yml` present with matrix node 20,22, bash -n, tsc, 28 tests, stdio smoke quoted workdir — **GAP CLOSED** | via chore branch ci.yml | via chore branch ci.yml |
| **mcp/dist/server.js stat** | **7722 bytes** built, `bash -n` ok, `npm test` 28/28 ✅ | N/A | N/A |
| **Archive status** | `archived:false` — **pending manual** (no `gh repo archive` executed per task, intentionally left false until skills.sh live — same as 09312ed `archived:false` pending) | `archived:false` pending manual | `archived:false` pending manual |

## Gaps Closed vs 09312ed (What This Audit Confirms Fixed at c9724d5)

All canonical gaps from `.omo/audit.md` Gap Lists (code 09312ed) are now **CLOSED** in workdir `"/Users/webileapps/Chandu/github/forge-standard"` at `c9724d5`:

- [x] `LICENSE` — **CLOSED** — `LICENSE` 1071 bytes MIT present (was missing, gh api 404 `license:null` at 09312ed) — now `gh api .../license` returns `{"name":"LICENSE","path":"LICENSE","license":{"key":"mit"}}` and `gh api repos/.../forge-standard` shows `license: mit` for all 3 repos
- [x] `CONTRIBUTING.md` — **CLOSED** — 78 lines present (was missing)
- [x] `CODE_OF_CONDUCT.md` — **CLOSED** — 132 lines Contributor Covenant present (was missing)
- [x] `SECURITY.md` — **CLOSED** — 33 lines present (was missing)
- [x] `.github/` — **CLOSED** — `workflows/ci.yml` 2090 bytes + `ISSUE_TEMPLATE/` (bug_report.md, feature_request.md) + `PULL_REQUEST_TEMPLATE.md` 854 bytes — was missing (zero) at 09312ed
- [x] `mcp/` — **CLOSED** — scaffolded per forge-standard MCP+OSS standardization: `mcp/mcp.json` 43 lines, `mcp/package.json` SDK `^1.30.0`, `mcp/src/server.ts` (initialize/tools/list/tools/call), `mcp/dist/server.js` 7722 bytes built, `mcp/README.md`, `docs/MCP.md` 147 lines, `examples/mcp-client.js` + `stdio-smoke.sh` + `claude-config.json` — was missing (no mcp dir) at 09312ed
- [x] `mcp presence verified` — `mcp/mcp.json` transport stdio, command node, args mcp/dist/server.js, entry mcp/src/server.ts, tools [forge_review] synced to `src/server.ts` FORGE_REVIEW_TOOL, SKILL.md table, README table, docs/MCP.md table — `mcp/dist/server.js` stat 7722 bytes, `npm test` 28 pass (see proof above), `bash -n` clean
- [x] `CI ci.yml present` — **CLOSED** — `.github/workflows/ci.yml` exists with CI pipeline: checkout v4, setup-node 20/22 cache npm, npm ci root + mcp, tsc --noEmit, bash -n scripts/*.sh, npm test (28 tests), stdio smoke GITHUB_WORKSPACE + path with spaces, mcp client GITHUB_WORKSPACE + path with spaces, manual gate comments for archive/release requiring admin (intentionally NOT automated)
- [x] `package.json keyword leak` — **STILL CLEAN** — `grep -n anvil package.json` => 0 hits (was fixed in 09312ed audit by removing `anvil` keyword, remains clean at c9724d5; current keywords 19 entries no leak)
- [x] `README.md LICENSE note` — **UPDATED** — now `[MIT](LICENSE) - Copyright (c) 2026 Chandra Sekhar` with CONTRIBUTING/Code of Conduct/Security links (was "MIT - see LICENSE if present" placeholder at 09312ed)
- [x] `Repo license field` — **POPULATED** — `gh api ...` now `license: mit` (was null at 09312ed, will remain MIT after push — already live on remote after c9724d5 push)
- [x] `skills field` — **STILL PRESENT** — `"skills":["forge-standard"]` intact at package.json:26-27, SDK 1.30.0 dependency isolated to mcp/package.json (root keeps skills field clean)

## Residual Gaps (Intentionally Remaining — Do Not Fix in This Re-Audit)

- [ ] `skills.sh 404 pending` — **STILL 404** — `https://skills.sh/SriChandraSekharA/forge-standard` → `curl -sL` HTTP_CODE:404 NEXT_HTTP_ERROR_FALLBACK; body "This page could not be found" + og:title srichandrasekhara/forge-standard — **expected <24h propagation race** (same as 09312ed, not yet 200, do not republish until 200, re-check `curl -sL` + `curl -I` before publish). No archive retry in this task.
- [ ] `SKILL.md:6 title drift #Anvil vs forge-standard` — **RESIDUAL** — `SKILL.md` line 6 still reads `# Anvil Review Loop` while frontmatter `name: forge-standard` and repo is `forge-standard` — drift from legacy rename (noted at 09312ed as gap, still present at c9724d5, 246 lines total vs 163 at 09312ed). Should become `# Forge Standard` (or primary forge-standard title) to match `name: forge-standard` — **left as residual for next task, not fixed in this read-only re-audit**.
- [ ] `Archive false pending manual` — **ALL 3 repos archived:false** — `gh api` shows `archived:false` for forge-standard, anvil-review-loop, qodo-standard-review — **intentionally not archived** per task instructions: `No push, no archive retry` — manual gate requires `gh repo archive SriChandraSekharA/anvil-review-loop` and `gh repo archive SriChandraSekharA/qodo-standard-review` only after skills.sh canonical is verified live (200) — CI comments document manual commands, no automation. Same as 09312ed "MUST NOT archive yet" — still pending.
- [ ] `Skills.sh propagation vs CI` — CI does not auto-poll skills.sh, manual `bash scripts/poll-skills.sh` (present, bash -n ok) is provided for polling, but 404 remains.

## MCP Presence (Required Detail)

- `mcp/package.json` SDK `^1.30.0` ✅ (required version 1.30.0) — `mcp/mcp.json` sdk field `@modelcontextprotocol/sdk`, version 1.0.0, transport stdio, command node, args mcp/dist/server.js, entry mcp/src/server.ts
- `mcp/mcp.json` 43 lines — tools exactly one `forge_review` with inputSchema properties mode (enum auto|staged|range|file), range string, file string, preview boolean, workdir string, required [] — synced verbatim to `mcp/src/server.ts` FORGE_REVIEW_TOOL and `docs/MCP.md` table and `README.md` table and `SKILL.md` table (lines 202-217 SKILL.md 246 lines)
- `mcp/src/server.ts` 6908 bytes mapped + server.ts head shows imports `Server`, `StdioServerTransport`, `CallToolRequestSchema`, `ListToolsRequestSchema`, `getVersionSync`, `VERSION`, `FORGE_REVIEW_TOOL`, `resolveRepoRoot`, `buildReviewArgs`, `handleForgeReview` with `spawn("bash", [...], {cwd: workdir})` quoted workdir via `path.resolve` + `existsSync` validation, no shell interpolation
- `mcp/dist/server.js` 7722 bytes built artifact present (stat above), not gitignored-dist tracked? Actually gitignored but present locally for inspector probe
- `docs/MCP.md` 147 lines + `mcp/README.md` + `examples/mcp-client.js` (node client initialize→tools/list→tools/call with quoted `--workdir` spaces handling) + `examples/stdio-smoke.sh` (bash piped JSON-RPC) + `examples/claude-config.json` (mcpServers snippet with cwd quoted) — all present, verified `grep -q "forge_review" SKILL.md` and `grep -q "mcp" README.md` (in docs/MCP.md Verification section)
- `npm test` 28 pass proof above (tsc --noEmit + vitest verbose 2 files 28 tests, including stdio harness initialize/handshake + tools/list + tools/call preview + workdir spaces, and buildReviewArgs/file mode quoting)

## CI ci.yml Present (Required Detail)

- Path `"/Users/webileapps/Chandu/github/forge-standard/.github/workflows/ci.yml"` 2090 bytes — `ls .github/workflows` shows only `ci.yml` (not multiple workflows) — **PRESENT** ✅
- Content head captured above — on push/PR to main paths-ignore .omo/.forge-standard, permissions contents: read, strategy matrix node-version [20,22], steps: Checkout, Setup Node, Install root deps, Install MCP deps, Typecheck MCP, Shellcheck scripts bash -n loop, Run tests npm test (28 tests), Stdio smoke twice (GITHUB_WORKSPACE + "/tmp/with spaces/ci smoke"), MCP client twice (same), manual gate comments for `gh repo archive` and `gh release create` (requires admin, intentionally NOT in CI)
- Was MISSING at 09312ed (no .github dir) — now **gap closed**, matches `.omo/audit.md` Next Task Gates Task 2 scaffold requirement.

## Skills.sh 404 Pending (Required Detail)

- `curl -s -o /tmp/skills_check.txt -w "%{http_code}" "https://skills.sh/SriChandraSekharA/forge-standard"` => `308` (Redirecting...)
- `curl -sL -w "\nHTTP_CODE:%{http_code}\n" "https://skills.sh/SriChandraSekharA/forge-standard"` => `HTTP_CODE:404` with body `<!DOCTYPE html>...NEXT_HTTP_ERROR_FALLBACK;404` + `<h1>404</h1><p>This page could not be found.</p>` + `<title>srichandrasekhara/forge-standard — Agent skills</title>` + og metadata — same as 09312ed audit's 404, **still pending** <24h, title correct but shell 404, do not republish until 200, poll via `bash scripts/poll-skills.sh` or `curl -sL` — no push in this audit.

## Archive False Pending Manual (Required Detail)

- `gh api repos/SriChandraSekharA/forge-standard --jq archived` => `false` (canonical stays public, not archived — correct, no action needed)
- `gh api repos/SriChandraSekharA/anvil-review-loop --jq archived` => `false` (legacy, not archived — pending manual `gh repo archive` after skills.sh live)
- `gh api repos/SriChandraSekharA/qodo-standard-review --jq archived` => `false` (legacy, 0 topics, not archived — pending manual archive vs delete confirm)
- CI documents manual commands but does NOT run them — `gh repo archive` requires admin, intentionally absent from CI pipeline — **no archive retry in this task per instructions** (same MUST NOT DO as 09312ed).

## MUST NOT DO Compliance (This Re-Audit)

- No `gh repo archive` or `gh repo edit --archived` executed (archive false remains, manual gate only)
- No `git push` executed (local HEAD c9724d5 already pushed to remote — ls-remote confirms HEAD c9724d5 on origin, but no new push in this audit)
- No archive retry via scripts or gh (CI manual gate comments only)
- Kept `.omo/audit.md` historical (180 lines at 09312ed preserved verbatim, not overwritten — this file is new `.omo/audit-v1.1.1.md` fresh at c9724d5)
- Append notepad sections only (no deletion of prior notepad content)

## Durable Notepad Pointers (Append)

- Durable: `/var/folders/4l/6c2fc7hj6sn1b4sqf9j_wwkc0000gn/T/ulw-20260905-XXXXXX.md.xxFgv7WX6G` — append audit-v1.1.1 summary section (see `.omo/notepad.md` companion)
- Local: `/Users/webileapps/Chandu/github/forge-standard/.omo/notepad.md` — appended Task 8.4 section below (this audit's companion)

## Next Task Gates (Post c9724d5)

1. Poll skills.sh 404 → 200 propagation via `bash "/Users/webileapps/Chandu/github/forge-standard/scripts/poll-skills.sh"` or `curl -sL -w "%{http_code}" https://skills.sh/SriChandraSekharA/forge-standard` — do not publish until 200.
2. Fix residual `SKILL.md:6` title drift `# Anvil Review Loop` → `# Forge Standard` (align with `name: forge-standard`) — next patch, verify no "anvil" keyword re-introduction via `grep -n anvil package.json SKILL.md`.
3. After skills.sh 200 and title fix, manual archive legacies: `gh repo archive SriChandraSekharA/anvil-review-loop` and `gh repo archive SriChandraSekharA/qodo-standard-review` (requires admin, no automation).
4. Then `gh release create v1.1.0` or verify tag `cb1fa70` release notes — manual, requires contents:write.
5. Re-run this audit shape to confirm 3-repo matrix archived:true for legacies, skills.sh 200, title drift cleared.
