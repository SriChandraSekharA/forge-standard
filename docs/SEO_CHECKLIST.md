# SEO Checklist — forge-standard (Task 8.6 Promotion)

Generated: 2026-09-05T09:00:00+05:30 IST (2026-09-05T03:30:00Z)
Workdir quoted: `"/Users/webileapps/Chandu/github/forge-standard"`
Canonical: `SriChandraSekharA/forge-standard` HEAD `c9724d576d57a70154be9b3c184918675f9ff605` tag `v1.1.0`
Skills.sh canonical (lowercase): `https://www.skills.sh/srichandrasekhara/forge-standard` (og:title `srichandrasekhara/forge-standard — Agent skills`)
README: 242 lines | docs/MCP.md: 147 lines | mcp/README.md: 115 lines | .omo/audit-v1.1.1.md: 406 lines | package.json keywords: 19 | assets/badge.svg: 798 B | assets/demo.gif: 69712 B (~68K)

> No push, no `SKILL.md:6` edit in this task — read-only verification + checklist doc.

---

## 1. GitHub Topics SEO (verified `gh api` — 8 topics)

### Current state (2026-09-05T03:29Z probe)

```bash
gh api repos/SriChandraSekharA/forge-standard --jq '{topics,archived,visibility,license}'
# => {"archived":false,"license":{"key":"mit","spdx_id":"MIT"},"topics":["code-quality","code-review","owasp","pr-review","pull-request-review","review-loop","security-review","vulnerability-review"],"visibility":"public"}
gh api repos/SriChandraSekharA/forge-standard --jq '.topics | join(", ")'
# => code-quality, code-review, owasp, pr-review, pull-request-review, review-loop, security-review, vulnerability-review
```

- Count: **8** — matches `.omo/audit-v1.1.1.md` matrix and `09312ed` baseline (same 8, unchanged).
- Expected set: `code-quality`, `code-review`, `owasp`, `pr-review`, `pull-request-review`, `review-loop`, `security-review`, `vulnerability-review` ✅
- Visibility: `public`, `archived:false`, license `MIT` — correct for SEO crawl.
- Legacies unchanged: `anvil-review-loop` 8 topics (`architecture-review` variant), `qodo-standard-review` 0 topics — pending manual archive after skills.sh live.

### Action if drift

```bash
gh api repos/SriChandraSekharA/forge-standard --jq .topics
# if count !=8 or missing keyword:
gh repo edit SriChandraSekharA/forge-standard --add-topic code-quality --add-topic code-review --add-topic owasp --add-topic pr-review --add-topic pull-request-review --add-topic review-loop --add-topic security-review --add-topic vulnerability-review
# verify:
gh api repos/SriChandraSekharA/forge-standard --jq .topics
```

Why 8: GitHub indexes topics for search/discovery; keywords mirror `package.json` keywords for cross-signal (npm + GitHub + skills.sh).

---

## 2. README Badges & Links (242 lines)

### Verified badges at `README.md:3`

```md
[![Skills.sh](https://img.shields.io/badge/skills.sh-forge--standard-blue?logo=data:image/svg+xml;base64)](https://skills.sh) ![npx skills add -l](assets/badge.svg)
```

- Shields.io: `https://img.shields.io/badge/skills.sh-forge--standard-blue` ✅ present (line 3, `grep -n "img.shields.io" README.md` hits 1).
- Local badge: `assets/badge.svg` 798 B, `186x20`, text `skills | forge-standard` (`assets/badge.svg` lines verified) ✅
- `![]()` alt `npx skills add -l` — local proof image, not external.

### Link correctness — canonical case note

- Repo (GitHub): `SriChandraSekharA/forge-standard` (capital S,C,S,A) — used in `README.md:12,18,24`, `SKILL.md:36,41`, `package.json` not containing URL (clean).
- skills.sh detail page: **lowercase** `https://www.skills.sh/srichandrasekhara/forge-standard` — confirmed via `curl -sL` og:title `srichandrasekhara/forge-standard — Agent skills` and canonical `<link rel="canonical" href="https://www.skills.sh/srichandrasekhara/forge-standard">`.
- README current root link `https://skills.sh` (shields parent href) is valid root; detail link should be `https://www.skills.sh/srichandrasekhara/forge-standard` for SEO — document as next patch if adding deep link (do not edit in this 8.6 task).
- `git clone https://github.com/SriChandraSekharA/forge-standard.git` at `README.md:24` ✅ correct case.

### Install snippets (SEO for npx copy-paste)

```bash
npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g -y  # README:12,18
git clone https://github.com/SriChandraSekharA/forge-standard.git                   # README:24
```

---

## 3. package.json Keywords & Skills Field

```json
// /Users/webileapps/Chandu/github/forge-standard/package.json
{
  "name": "forge-standard",
  "keywords": ["code-review","pr-review","pull-request-review","code-review-checklist","security-review","vulnerability-review","owasp-review","architecture-review","code-quality-review","review-loop","iterative-review","multi-reviewer","git-diff-review","standards-review","spec-review","solid-review","quota-free-review","owasp","code-quality"],
  "skills": ["forge-standard"]
}
```

- Keywords: **19** entries, no `anvil` leak — `grep -i anvil package.json` => **0 hits** ✅ (also `grep -n anvil` => 0, exit 1 from probe).
- Skills field: `["forge-standard"]` at `package.json:26-27` ✅ intact (not polluted by MCP deps — MCP deps isolated to `mcp/package.json`).
- Description mirrors `SKILL.md` frontmatter for npm + skills.sh indexing.

### Leak guard

```bash
grep -i anvil /Users/webileapps/Chandu/github/forge-standard/package.json; echo leak:$?
# => leak:1 (0 hits) ✅
grep -i qodo /Users/webileapps/Chandu/github/forge-standard/package.json; echo leak:$?
# => leak:1 (0 hits) ✅
```

---

## 4. SKILL.md Frontmatter — `forge-standard` (246 lines)

```yaml
---
name: forge-standard
description: "Quota-free iterative code review with continuous loop, architecture review, security review, vulnerability review, OWASP review, correctness review, readability review, performance review, code quality review, review loop, iterative review, multi reviewer, git diff review, standards review, spec review, SOLID review - idempotent .forge-standard/ per-repo memory"
---
```

- Parser-strict: exactly `name` + `description` ✅ (verified `head -5 SKILL.md`).
- Name `forge-standard` ✅ — no `anvil`/`qodo` in frontmatter.
- Body `SKILL.md:6` reads `# Anvil Review Loop` — **residual drift intentionally NOT edited in this task** per `.omo/audit-v1.1.1.md` Residual Gaps and task MUST NOT DO (`No push, no SKILL.md:6 edit`). Tracked for next patch to `# Forge Standard`.

---

## 5. docs/MCP.md Freshness — 147 lines ✅

- Path: `"/Users/webileapps/Chandu/github/forge-standard/docs/MCP.md"` — `wc -l` => **147** ✅ (matches audit-v1.1.1.md evidence).
- Covers: `mcp/mcp.json` manifest (stdio, `forge_review`), `mcp/src/server.ts`, `dist/server.js`, `mcp/package.json` SDK `^1.30.0`, `examples/mcp-client.js` + `stdio-smoke.sh` + `claude-config.json`, install/build/inspector steps, tool table synced to `mcp/mcp.json` + `SKILL.md:202-228` + `README.md:229-236` + `mcp/src/server.ts:FORGE_REVIEW_TOOL`.
- Freshness check: `grep -q "forge_review" docs/MCP.md && grep -q "stdio" docs/MCP.md && echo "fresh"` ✅ — already verified in audit Proof section.

---

## 6. mcp/README.md — 115 lines

- Path: `"/Users/webileapps/Chandu/github/forge-standard/mcp/README.md"` — 115 lines, layout `mcp/package.json`, `tsconfig.json`, `mcp.json`, `src/server.ts`, `dist/server.js` ✅
- Transport `stdio`, tool `forge_review` with `mode|range|file|preview|workdir`, quoted `workdir` via `path.resolve` + `existsSync` + `spawn cwd` — no shell interpolation (see `docs/MCP.md:77` + `mcp/README.md:101`).
- Build: `npm --prefix mcp install && npm run build --prefix mcp && npx tsc --noEmit -p mcp/tsconfig.json` — `mcp/dist/server.js` 7722 B built ✅

---

## 7. Demo GIF — `assets/demo.gif` 68K Placeholder Note

- File: `"/Users/webileapps/Chandu/github/forge-standard/assets/demo.gif"` — **69712 B (~68 KB)** ✅ (`du -h` 72K due to block size, `wc -c` 69712 exact), `ls -la` 68K.
- Content: 800x400, 7 frames, ~10s, loop 0 — terminal simulation via **Python PIL** (no ffmpeg/convert on host) covering `init.sh -> review.sh --staged -> report.md -> review.json | jq` contract.
- README `README.md:7` disclaimer + `README.md:59` note:

  > "Placeholder terminal simulation via PIL (no ffmpeg/convert on this host); re-record with `script` + `ttygif` for pixel-perfect capture."

  > "Note: This GIF is a generated placeholder via Python PIL (ffmpeg/convert not available on this host). For a real capture: `script -q /tmp/demo.txt` then `ttygif`/`terminalizer` or `ffmpeg -loop 0 -f lavfi -i color=c=black:s=800x400 -t 10` overlay. The file at `assets/demo.gif` satisfies the `10s loop init -> review -> report` contract."

- SEO note: placeholder satisfies `README.md:48` `![Demo](assets/demo.gif)` contract for skills.sh/GH preview; replace with **pixel-perfect `script` + `ttygif` capture** when re-recording host has `ffmpeg`/`ttygif`/`terminalizer` — keep 10s loop, 800x400, `init -> staged -> report.md -> review.json | jq` sequence intact.
- Companion: `assets/npx-proof.txt` 28 lines, 1546 B — raw `npx --yes skills add /path -l` log with ANSI banner (see README:62-83).

### Verify

```bash
ls -lh "/Users/webileapps/Chandu/github/forge-standard/assets/demo.gif"
# => 68K / 69712 B
file "/Users/webileapps/Chandu/github/forge-standard/assets/demo.gif" | head
ls -lh "/Users/webileapps/Chandu/github/forge-standard/assets/badge.svg" "/Users/webileapps/Chandu/github/forge-standard/assets/npx-proof.txt"
```

---

## 8. skills.sh Re-Index Steps — `curl -sL` 404 -> 200

### Current probe (still 404 pending <24h propagation — expected)

```bash
# Step 1 — 308 redirect check (root -> www)
curl -s -o /tmp/skills_check.txt -w "%{http_code}" "https://skills.sh/SriChandraSekharA/forge-standard"
# => 308 Redirecting... (Location: https://www.skills.sh/SriChandraSekharA/forge-standard)

# Step 2 — follow redirect, capture HTTP code (lowercase canonical in HTML)
curl -sL -w "\nHTTP_CODE:%{http_code}\n" "https://skills.sh/SriChandraSekharA/forge-standard"
# => HTTP_CODE:404 body NEXT_HTTP_ERROR_FALLBACK;404 "This page could not be found"
# Body og:title: srichandrasekhara/forge-standard — Agent skills
# Body title:     srichandrasekhara/forge-standard — Agent skills
# Footer: Made with care by Vercel — Next.js 404 shell

# Step 3 — verify headers
curl -sI "https://skills.sh/SriChandraSekharA/forge-standard" | head -20
# => HTTP/2 308 location https://www.skills.sh/SriChandraSekharA/forge-standard

# Step 4 — direct www lowercase probe
curl -sL -w "\nHTTP_CODE:%{http_code}\n" "https://www.skills.sh/srichandrasekhara/forge-standard" | tail -5
# => HTTP_CODE:404 (same, pending)
# When live: HTTP_CODE:200 with skill listing

# Step 5 — poll helper
bash "/Users/webileapps/Chandu/github/forge-standard/scripts/poll-skills.sh"
# loops curl -sL until 200 or timeout
```

Evidence file: `.omo/audit-v1.1.1.md:68-78` captures full `curl -sL` 404 shell (digest `NEXT_HTTP_ERROR_FALLBACK;404`, title `srichandrasekhara/forge-standard`).

### When 200 arrives (re-index complete)

```bash
curl -sL -w "\nHTTP_CODE:%{http_code}\n" "https://www.skills.sh/srichandrasekhara/forge-standard" | grep HTTP_CODE
# => HTTP_CODE:200

# SEO verification on 200 page:
curl -sL "https://www.skills.sh/srichandrasekhara/forge-standard" | grep -i "forge-standard" | head
# should contain: description, keywords, README excerpt, install npx snippet
```

**Do NOT republish** until `HTTP_CODE:200` — propagation is `<24h` per audit. Poll via `scripts/poll-skills.sh` or manual `curl -sL`.

---

## 9. `npx skills add` Validation — `-l` vs `-g`

### Local discovery (reads `package.json` + `SKILL.md` in workdir) — always works

```bash
npx --yes skills add /Users/webileapps/Chandu/github/forge-standard -l
# => Local path validated
# => Found 1 skill
#
#    Available Skills
#      forge-standard
#        Quota-free iterative code review with continuous loop, architecture review, security review, vulnerability review, OWASP review, ...
#    Use --skill <name> to install specific skills
# Raw ANSI log in assets/npx-proof.txt (28 lines, captured via npx --yes skills add /path -l)
```

Probe today:

```bash
npx --yes skills add "/Users/webileapps/Chandu/github/forge-standard" -l 2>&1 | grep -E "Found|forge-standard|Available"
# => Found 1 skill / forge-standard ✅
cat "/Users/webileapps/Chandu/github/forge-standard/assets/npx-proof.txt"
# => shows banner + Found 1 skill block
```

### Global install (requires skills.sh live 200 — will fail with 404 until propagation)

```bash
# Global (-g) — writes to ~/.agents/skills/forge-standard (user-level)
npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g -y
# When 404 pending: errors "Skill not found" or 404 fetch — expected until HTTP_CODE 200
# When live: installs globally, verify with:
npx --yes skills add -l 2>&1 | grep forge-standard  # lists installed
# or
npx skills list 2>&1 | grep forge-standard
ls -la ~/.agents/skills/forge-standard/SKILL.md && head -5 ~/.agents/skills/forge-standard/SKILL.md

# Local project install (-l is list, no -g = project-local under <repo>/.agents or node_modules)
npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -y
# installs to project; verify:
npx --yes skills add -l 2>&1 | grep -A2 "forge-standard"
# difference: -g = global ~/.agents/skills/, no -g = project-local (skills-lock.json tracked)
```

### Flags reference (`npx --yes skills add --help`)

```
Add Options:
  -g, --global           Install globally (user-level) instead of project-level
  -a, --agent <agents>   Specify agents (use '*' for all)
  -s, --skill <skills>   Specify skill names (use '*' for all)
  -l, --list             List available skills without installing
  -y, --yes              Skip confirmation prompts
```

Decision: use `-g -y` for one-user global per `README.md:12` + `SKILL.md:36`; use bare `-y` (no `-g`) for project-local per `SKILL.md:41`.

---

## 10. Skill Search Discovery (skills.sh index + `npx skills find`)

### After skills.sh 200:

```bash
# skills.sh site search (once indexed)
open "https://www.skills.sh/search?q=forge-standard"
open "https://www.skills.sh/search?q=code-review"
# should surface srichandrasekhara/forge-standard in results (topics + keywords + description indexed)

# CLI search (requires registry sync)
npx skills find forge-standard 2>&1 | grep -i forge
npx skills find "code-review" --owner SriChandraSekharA 2>&1 | head -20
# Expected: forge-standard listed with description snippet
```

Currently `npx skills find` will miss until registry re-index — verify after `curl ... HTTP_CODE:200`.

---

## 11. GitHub Topics SEO — Deep Dive

- Topics set via `gh repo edit` or UI Settings > About > Topics — 8 keywords overweight `code-review`, `security-review` etc for GitHub search ranking.
- Mirrors `package.json` keywords + `SKILL.md` description tokens — triple signal (GH + npm + skills.sh).
- No `anvil`/`qodo` leak in topics (verified `gh api ... topics` output above).
- Keep topics lowercase hyphenated per GitHub convention — current set compliant.

---

## 12. docs/MCP Freshness & Cross-Sync Table

| Source | Tool entry | Status |
|--------|------------|--------|
| `mcp/mcp.json` | `forge_review` stdio `node mcp/dist/server.js` | ✅ |
| `mcp/src/server.ts` | `FORGE_REVIEW_TOOL` + `resolveRepoRoot` + `handleForgeReview` quoted workdir | ✅ |
| `docs/MCP.md:69-77` | table `mode|range|file|preview|workdir` | ✅ synced |
| `mcp/README.md:93-99` | same table | ✅ |
| `README.md:229-236` | same table | ✅ |
| `SKILL.md:202-217` | JSON + table verbatim | ✅ |

All tables quote `workdir` via `path.resolve` + `existsSync` + `spawn cwd`, no shell interpolation.

---

## 13. Guardrails — No Push, No SKILL.md:6 Edit

- This checklist is **read-only publish prep** — no `git push`, no `gh repo archive`, no `SKILL.md:6` title fix executed (deferred to next task after skills.sh 200 per `.omo/audit-v1.1.1.md` Next Task Gates).
- `SKILL.md:6` drift `# Anvil Review Loop` remains — tracking issue, not fixed here.

---

## 14. Quick Verification One-Liners (quoted workdir)

```bash
# Topics still 8
gh api repos/SriChandraSekharA/forge-standard --jq .topics | wc -l; gh api repos/SriChandraSekharA/forge-standard --jq .topics

# No anvil leak
grep -i anvil /Users/webileapps/Chandu/github/forge-standard/package.json; echo anvil_exit:$?
grep -i qodo  /Users/webileapps/Chandu/github/forge-standard/package.json; echo qodo_exit:$?

# Badges
grep -n "img.shields.io/badge/skills.sh-forge--standard" /Users/webileapps/Chandu/github/forge-standard/README.md
ls -lh /Users/webileapps/Chandu/github/forge-standard/assets/badge.svg /Users/webileapps/Chandu/github/forge-standard/assets/demo.gif
cat /Users/webileapps/Chandu/github/forge-standard/assets/badge.svg | head -5

# Lines
wc -l /Users/webileapps/Chandu/github/forge-standard/README.md /Users/webileapps/Chandu/github/forge-standard/docs/MCP.md /Users/webileapps/Chandu/github/forge-standard/mcp/README.md
# => 242 147 115

# Frontmatter
head -6 /Users/webileapps/Chandu/github/forge-standard/SKILL.md | cat -A

# npx local proof
npx --yes skills add "/Users/webileapps/Chandu/github/forge-standard" -l 2>&1 | grep -E "Found|forge-standard"
cat /Users/webileapps/Chandu/github/forge-standard/assets/npx-proof.txt | grep -A2 "Found"

# skills.sh poll
curl -sL -w "\nHTTP_CODE:%{http_code}\n" "https://skills.sh/SriChandraSekharA/forge-standard" | tail -5
curl -sL -w "\nHTTP_CODE:%{http_code}\n" "https://www.skills.sh/srichandrasekhara/forge-standard" | tail -5
```

---

## 15. Evidence Files (workdir quoted)

- README: `/Users/webileapps/Chandu/github/forge-standard/README.md` (242 lines)
- package.json: `/Users/webileapps/Chandu/github/forge-standard/package.json` (keywords 19, skills 1, no anvil)
- SKILL.md: `/Users/webileapps/Chandu/github/forge-standard/SKILL.md` (246 lines, frontmatter `forge-standard`)
- docs/MCP.md: `/Users/webileapps/Chandu/github/forge-standard/docs/MCP.md` (147 lines)
- mcp/README.md: `/Users/webileapps/Chandu/github/forge-standard/mcp/README.md` (115 lines)
- .omo/audit-v1.1.1.md: `/Users/webileapps/Chandu/github/forge-standard/.omo/audit-v1.1.1.md` (406 lines)
- assets/badge.svg: `/Users/webileapps/Chandu/github/forge-standard/assets/badge.svg` (798 B)
- assets/demo.gif: `/Users/webileapps/Chandu/github/forge-standard/assets/demo.gif` (69712 B ~68K placeholder)
- assets/npx-proof.txt: `/Users/webileapps/Chandu/github/forge-standard/assets/npx-proof.txt` (28 lines)
- Workdir quoted: `"/Users/webileapps/Chandu/github/forge-standard"`
- Durable: `/var/folders/4l/6c2fc7hj6sn1b4sqf9j_wwkc0000gn/T/ulw-20260905-XXXXXX.md.xxFgv7WX6G` + `.omo/notepad.md`

---

## 16. Next Steps After This Checklist

1. Poll `curl -sL https://www.skills.sh/srichandrasekhara/forge-standard` until `HTTP_CODE:200`.
2. Then `npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g -y` and verify `npx skills list` shows `forge-standard`.
3. Then `npx skills find forge-standard` — should appear in search index within hours of 200.
4. Then patch `SKILL.md:6` title drift `# Anvil Review Loop` → `# Forge Standard` (keep `name: forge-standard`).
5. Re-verify `grep -i anvil package.json` still 0 after title fix.
