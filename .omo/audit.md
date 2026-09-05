# Forge-Standard MCP+OSS Standardization — Gap Audit (Task 1 Inventory)

Generated: 2026-09-05T05:30:00+05:30 IST
Canonical: `SriChandraSekharA/forge-standard` HEAD `09312ed15847449211b4852ec3d4e5822a9e697a` tag `v1.0.0` origin `forge-standard`
Legacies: `SriChandraSekharA/anvil-review-loop` HEAD `685c52c44b9daf4a2a836da60652fae252db1353`, `SriChandraSekharA/qodo-standard-review` HEAD `53319ab35310c3c2fcf0e9345b47dfa6f561c488`
Skills.sh: `https://skills.sh/SriChandraSekharA/forge-standard` → 404 (pending <24h) — verified via curl -sL (NEXT_HTTP_ERROR_FALLBACK;404, body contains "This page could not be found")
Durable notepad: `/var/folders/4l/6c2fc7hj6sn1b4sqf9j_wwkc0000gn/T/ulw-20260905-XXXXXX.md.xxFgv7WX6G` + `.omo/notepad.md`

## Evidence (raw captures — required tools)

### git ls-remote (quoted paths, workdir)

```bash
# canonical
git ls-remote https://github.com/SriChandraSekharA/forge-standard.git
09312ed15847449211b4852ec3d4e5822a9e697a HEAD
09312ed15847449211b4852ec3d4e5822a9e697a refs/heads/main
edef5bc03299fd67d3f1293eeab026636b1783aa refs/tags/v1.0.0
09312ed15847449211b4852ec3d4e5822a9e697a refs/tags/v1.0.0^{}

# legacy anvil
git ls-remote https://github.com/SriChandraSekharA/anvil-review-loop.git
685c52c44b9daf4a2a836da60652fae252db1353 HEAD
685c52c44b9daf4a2a836da60652fae252db1353 refs/heads/main

# legacy qodo
git ls-remote https://github.com/SriChandraSekharA/qodo-standard-review.git
53319ab35310c3c2fcf0e9345b47dfa6f561c488 HEAD
53319ab35310c3c2fcf0e9345b47dfa6f561c488 refs/heads/main
```

### gh repo view (gh api)

```json
// gh api repos/SriChandraSekharA/forge-standard --jq '{name,private,archived,topics,license}'
{"archived":false,"name":"forge-standard","private":false,"visibility":"public","license":null,"topics":["code-quality","code-review","owasp","pr-review","pull-request-review","review-loop","security-review","vulnerability-review"]}
// 8 topics

// gh api repos/SriChandraSekharA/anvil-review-loop
{"archived":false,"name":"anvil-review-loop","private":false,"license":null,"topics":["architecture-review","code-quality-review","code-review","owasp-review","pr-review","review-loop","security-review","vulnerability-review"]}
// 8 topics, public, not archived

// gh api repos/SriChandraSekharA/qodo-standard-review
{"archived":false,"name":"qodo-standard-review","private":false,"license":null,"topics":[]}
// 0 topics, public, not archived

// gh api repos/SriChandraSekharA/forge-standard/license
{"message":"Not Found","status":"404"} // no LICENSE object

// gh api repos/SriChandraSekharA/forge-standard/contents
[".gitignore","AGENTS.md","README.md","SKILL.md","assets","fixture_test.js","package.json","references","scripts","templates"]
// anvil-review-loop/contents: [".gitignore","AGENTS.md","README.md","SKILL.md","fixture_test.js","references","scripts","templates"]
// qodo-standard-review/contents: [".review-memory.json","README.md","SKILL.md","references","scripts"]
```

### curl skills.sh (skills.sh 404 pending)

```bash
curl -s -o /tmp/skills_check.txt -w "%{http_code}" "https://skills.sh/SriChandraSekharA/forge-standard"
# => 308 Redirecting...
curl -sL -w "\nHTTP_CODE:%{http_code}\n" "https://skills.sh/SriChandraSekharA/forge-standard"
# => HTTP_CODE:404 body NEXT_HTTP_ERROR_FALLBACK;404 "This page could not be found"
# Title: srichandrasekhara/forge-standard — Agent skills (og:title) — but page renders 404 shell
```

### Local file reads (package.json / SKILL.md / README / dirs)

```json
// package.json (pre-fix) — /Users/webileapps/Chandu/github/forge-standard/package.json
{
  "name": "forge-standard",
  "version": "1.0.0",
  "skills": ["forge-standard"],  // skills field exists, correctly named
  "keywords": ["code-review",...,"anvil","owasp","code-quality"] // LEAK: "anvil" present — removed in this audit
  "license": "MIT"
}
```

```yaml
// SKILL.md frontmatter — line 1-4
---
name: forge-standard
description: "Quota-free iterative code review with continuous loop, architecture review, security review, vulnerability review, OWASP review, correctness review, readability review, performance review, code quality review, review loop, iterative review, multi reviewer, git diff review, standards review, spec review, SOLID review — idempotent .forge-standard/ per-repo memory"
---
// parser-strict: exactly name + description — PASS
// SKILL.md body h1: "# Anvil Review Loop" — legacy rename residual (gap: title says Anvil not Forge)
```

```
// README.md — 150 lines, badge skills.sh present, install npx skills add SriChandraSekharA/forge-standard, features, demo placeholder
// references/checklist.md exists (29 lines), references/knowledge.md exists (22 lines)
// templates/report.md, worker.prompt.md, critic.prompt.md exist
// .gitignore exists, AGENTS.md exists
```

```
// Local dir existence (2026-09-05):
LICENSE: missing (no file, gh api 404)
CONTRIBUTING.md: missing
CODE_OF_CONDUCT.md: missing
SECURITY.md: missing
.github/: missing
mcp/: missing (no mcp dir, no mcp.json, no server)
```

## 3-Repo Matrix (existence + gap)

| Field | `forge-standard` (canonical) | `anvil-review-loop` (legacy) | `qodo-standard-review` (legacy) |
|---|---|---|---|
| **Visibility / archived** | public, `archived:false` ✅ | public, `archived:false` (not archived) | public, `archived:false` (not archived) |
| **HEAD SHA (ls-remote)** | `09312ed15847449211b4852ec3d4e5822a9e697a` (main, tag v1.0.0 `edef5bc`) | `685c52c44b9daf4a2a836da60652fae252db1353` | `53319ab35310c3c2fcf0e9345b47dfa6f561c488` |
| **Topics count** | 8 (`code-quality`, `code-review`, `owasp`, `pr-review`, `pull-request-review`, `review-loop`, `security-review`, `vulnerability-review`) | 8 (`architecture-review`, `code-quality-review`, `code-review`, `owasp-review`, `pr-review`, `review-loop`, `security-review`, `vulnerability-review`) | 0 (empty) |
| **LICENSE** | missing ❌ (no file, `gh api .../license` 404, `license:null` on repo) | missing (same; file list no LICENSE) | missing (same) |
| **CONTRIBUTING.md** | missing ❌ | missing (not in contents) | missing |
| **CODE_OF_CONDUCT.md** | missing ❌ | missing | missing |
| **SECURITY.md** | missing ❌ | missing | missing |
| **.github/** | missing ❌ (no workflows, no FUNDING, no issue templates) | missing (assuming same; not listed) | missing |
| **mcp presence** | missing ❌ (no `mcp/` dir, no `mcp.json`) | missing | missing (has `.review-memory.json` instead — qodo legacy artifact) |
| **skills.sh status** | 404 pending <24h (`curl -sL` → 404 NEXT_HTTP_ERROR_FALLBACK) — expected race | 404/unknown (not checked; legacy not canonical) | 404/unknown |
| **package.json skills field** | present ✅ (`"skills":["forge-standard"]` at `/Users/webileapps/Chandu/github/forge-standard/package.json:27`) | N/A (no package.json in contents listing) | N/A |
| **SKILL.md frontmatter** | `name: forge-standard` ✅ exact `name+description` only | `name: anvil-review-loop` (legacy name) | `name: qodo-standard-review` (forbidden token legacy) |
| **README.md** | present ✅ 150 lines | present | present |
| **.forge-standard/ vs .anvil/.review-memory** | uses `.forge-standard/` (correct) | uses `.anvil-review-loop/` (legacy) | uses `.review-memory.json` (legacy) |
| **Origin remote (local)** | `https://github.com/SriChandraSekharA/forge-standard.git` (fetch/push) | `https://github.com/SriChandraSekharA/anvil-review-loop.git` (ls-remote) | `https://github.com/SriChandraSekharA/qodo-standard-review.git` |

## Gap Lists (per repo — what MUST be fixed in Tasks 2+ before publish)

### forge-standard (canonical) — gaps to fix, DO NOT FIX NOW per MUST NOT DO
- [ ] `LICENSE` — add MIT LICENSE file (package.json says MIT but no file; gh api 404)
- [ ] `CONTRIBUTING.md` — add contributing guide
- [ ] `CODE_OF_CONDUCT.md` — add CoC (e.g., Contributor Covenant)
- [ ] `SECURITY.md` — add security policy (vulnerability reporting, no token gate)
- [ ] `.github/` — add at minimum `workflows/ci.yml`, `FUNDING.yml` if needed, issue/PR templates (currently zero)
- [ ] `mcp/` — scaffold MCP server per forge-standard MCP+OSS standardization (mcp.json + server entry)
- [ ] `skills.sh` 404 — wait <24h propagation; re-check `curl -sL https://skills.sh/SriChandraSekharA/forge-standard` before publish; do not re-publish until 200
- [ ] `package.json` keyword leak — `anvil` removed in this audit (see Fix below); verify no re-introduction
- [ ] `SKILL.md` title drift — `# Anvil Review Loop` should become `# Forge Standard` (or at least mention forge-standard as primary) to match `name: forge-standard`
- [ ] `README.md` LICENSE note says "MIT - see LICENSE if present" — update once LICENSE added
- [ ] Repo `license` field on GitHub null — will populate after LICENSE push (GitHub detects LICENSE file)
- [ ] No archive action needed (canonical stays public, not archived)

### anvil-review-loop (legacy) — archival candidategaps (MUST NOT archive yet)
- Public, not archived, 8 topics — identical OSS gaps (no LICENSE etc.) but NOT the canonical; Task requires no archive yet
- Gap: should eventually be archived with redirect notice to forge-standard once skills.sh canonical is live
- HEAD 685c52c retained; contains `.anvil-review-loop/` naming — legacy branding

### qodo-standard-review (legacy) — archival candidate
- Public, not archived, 0 topics — weakest signal; `.review-memory.json` artifact confirms qodo token lineage
- Already deleted locally per Wave1 notepad but remote HEAD 53319ab still live (left touched pending user confirm)
- MUST NOT archive/delete remote yet per task; inventory only

## Fix Applied in This Audit (allowed leak fix)

- `package.json` keyword `anvil` removed (line 23 pre-fix → deleted). New keywords list verified below.

```bash
# verification
cat /Users/webileapps/Chandu/github/forge-standard/package.json | grep -n anvil
# => no output (0 hits)
```

## Durable Notepad Pointers

- Durable: `/var/folders/4l/6c2fc7hj6sn1b4sqf9j_wwkc0000gn/T/ulw-20260905-XXXXXX.md.xxFgv7WX6G` — append audit summary section
- Local: `/Users/webileapps/Chandu/github/forge-standard/.omo/notepad.md` — header + audit summary (this audit's companion)

## MUST NOT DO Compliance (no OSS overwrite in this task)

- No `LICENSE`/`CONTRIBUTING`/`CODE_OF_CONDUCT`/`SECURITY` created
- No `mcp/` scaffolded
- No `gh repo archive` or `gh repo edit --archived` executed
- No `git push` executed
- Only `.omo/audit.md` + `.omo/notepad.md` written and `package.json` keyword leak fix

## Next Task Gates (Task 2+)

1. Task 2 waits for skills.sh 404 → 200 propagation check (`curl -I https://skills.sh/SriChandraSekharA/forge-standard`)
2. Then scaffold OSS files (LICENSE MIT, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, .github/workflows) from templates
3. Then scaffold `mcp/` per spec (do not invent schema — read spec first)
4. Then re-run this audit to confirm gaps closed before `git push` + publish
