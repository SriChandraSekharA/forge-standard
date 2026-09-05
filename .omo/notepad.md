# Forge-Standard MCP+OSS Notepad — Durable

Started: 2026-09-05T05:30:00+05:30 IST
Canonical: `SriChandraSekharA/forge-standard` HEAD `09312ed15847449211b4852ec3d4e5822a9e697a` tag `v1.0.0` (8 topics, public, not archived)
Durable: `/var/folders/4l/6c2fc7hj6sn1b4sqf9j_wwkc0000gn/T/ulw-20260905-XXXXXX.md.xxFgv7WX6G` (also this file at `.omo/notepad.md`)
Audit: `.omo/audit.md` (3-repo matrix, evidence captures, gap lists)

## Plan (exhaustive, atomic — Task 1 done, Tasks 2+ gated)

- Task 1 (this turn): Inventory & Gap Audit — capture `git ls-remote` + `gh api` + `curl skills.sh` + file reads, write `.omo/audit.md` matrix, init `.omo/notepad.md`, fix leaked `anvil` keyword. DO NOT create OSS files / scaffold mcp / archive / push.
- Task 2 (next): Re-check `skills.sh` `SriChandraSekharA/forge-standard` 404→200 propagation (`curl -sL`), then scaffold OSS files (LICENSE MIT, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md, .github/workflows) from approved templates only.
- Task 3: Scaffold `mcp/` per MCP+OSS spec (mcp.json + server) — do not invent schema, read spec first.
- Task 4: Re-run audit to confirm gaps closed, then `git push` + publish; archive legacies only after canonical is live and user confirms.

## Scenarios (Task 1 contract)

| # | Check | Pass condition |
|---|-------|----------------|
| S1 | `git ls-remote` for both legacies captured | HEADs 685c52c / 53319ab in `.omo/audit.md` |
| S2 | `gh api` repo view for all 3 captured | topics/archived/license null in audit |
| S3 | `curl skills.sh` 404 verified | HTTP 404 with NEXT_HTTP_ERROR_FALLBACK in audit |
| S4 | `package.json` skills field + SKILL.md frontmatter read | `"skills":["forge-standard"]`, frontmatter `name: forge-standard` in audit |
| S5 | Matrix covers 10 cols per repo | archived/topics/HEAD SHA/LICENSE/CONTRIBUTING/CODE_OF_CONDUCT/SECURITY/mcp/skills.sh in `.omo/audit.md` |
| S6 | Leaked keyword removed | `grep anvil package.json` → 0 hits |

## Now

Task 1 audit written — awaiting user to confirm Task 2 gate (skills.sh propagation).

## Todo

- [x] Task 1 audit (this turn)
- [ ] Task 2: OSS scaffold (gated on skills.sh 200)
- [ ] Task 3: mcp scaffold
- [ ] Task 4: re-audit + push + archive legacies

## Findings (non-obvious, with refs)

- `forge-standard/package.json:23` pre-fix had `anvil` keyword leak — removed; `owasp` duplicate remains but intentional (file:line `package.json:18` now `owasp` once).
- `SKILL.md:6` title is `# Anvil Review Loop` while frontmatter `name: forge-standard` — rename residual to fix in Task 2 (audit notes gap).
- `forge-standard` has 0 OSS compliance files locally: LICENSE, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md, .github/, mcp/ all missing (verified `ls -la` + `gh api .../contents` + `gh api .../license` 404).
- `gh api repos/SriChandraSekharA/forge-standard` license field is `null` — GitHub will populate after LICENSE file push.
- `curl -sL https://skills.sh/SriChandraSekharA/forge-standard` returns 404 shell with correct og:title but NEXT_HTTP_ERROR_FALLBACK — pending <24h is expected race, not a publish error.
- Legacies: `anvil-review-loop` 8 topics not archived HEAD 685c52c, `qodo-standard-review` 0 topics not archived HEAD 53319ab — both left untouched per MUST NOT DO.
- Previous durable notepad at `/var/folders/.../ulw-20260905-XXXXXX.md.xxFgv7WX6G` contained Wave0/Wave1 qodo deletion audit (1985 lines) — Task 1 audit appends new section below without overwriting history.

## Learnings

- `gh api repos/.../license` 404 is the canonical check for missing LICENSE (not just file existence).
- `git ls-remote` is the only reliable HEAD check for remotes without cloning (used for both legacies).
- `skills.sh` 404 behind 308 redirect — must use `curl -sL` not bare `curl`.

## Audit Summary (from .omo/audit.md)

- Canonical forge-standard: public not archived, 8 topics, HEAD 09312ed tag v1.0.0, LICENSE/CONTRIBUTING/CODE_OF_CONDUCT/SECURITY/.github/mcp all missing, skills.sh 404 pending, package.json `anvil` leak fixed, SKILL.md title drift noted.
- anvil-review-loop: public not archived, 8 topics, HEAD 685c52c, same OSS gaps, legacy `.anvil-review-loop/` naming — archive candidate gated.
- qodo-standard-review: public not archived, 0 topics, HEAD 53319ab, `.review-memory.json` artifact — archive candidate gated; local dir already deleted in Wave1 but remote remains.

---
## Task 1 Audit Append (raw durable — 2026-09-05T05:30 IST)

Evidence: see `.omo/audit.md` for full `git ls-remote`, `gh api`, `curl` captures. Matrix row summary: forge-standard 8 topics not archived missing 6 OSS files + mcp, anvil 8 topics not archived missing same, qodo 0 topics not archived missing same + has .review-memory.json. skills.sh 404. Fix: package.json `anvil` keyword removed (now 0 hits).


---
## Task 4 — ADR-001 MCP Repo Strategy (2026-09-05)

Approved: same-repo `mcp/` inside `SriChandraSekharA/forge-standard` — see `docs/ADR-001-mcp-repo-strategy.md`.

Matrix: 6 criteria weighted 100, scores 1..5, weighted totals A 435 vs B 280. A wins by 155.

Criteria: publish friction (20), skills.sh crawl (15), versioning (20), dep isolation (15), CI duplication (15), UX confusion (15).

Recommendation detail: `mcp/server.ts` stdio via `@modelcontextprotocol/sdk`, manifest `mcp/mcp.json`, single repo single publish. ADR file at `docs/ADR-001-mcp-repo-strategy.md` created via `mkdir -p "docs"` and validated exists.

Fallback note: if same-repo blocked by policy or skills.sh rule, split to `SriChandraSekharA/forge-standard-mcp` with pinned `forge-standard@<tag>` dep, version alignment CI check, and amendment ADR-002 to merge back.

Validation: `ls -ld "docs"`, `ls -l "docs/ADR-001-mcp-repo-strategy.md"`, no `git push` performed, local only as required.

