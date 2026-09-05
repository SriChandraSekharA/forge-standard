# ADR-001: MCP Repo Strategy for forge-standard

Date: 2026-09-05
Status: Accepted
Deciders: SriChandraSekharA, forge-standard maintainers
Workdir: `/Users/webileapps/Chandu/github/forge-standard`
Related: `.omo/audit.md`, `.omo/notepad.md`, `package.json`, `SKILL.md`

## Context

forge-standard ships as a publishable skill at `SriChandraSekharA/forge-standard` with a local review loop and file-based skill install via `npx skills add`. The team needs to add Model Context Protocol support without breaking the skill install, adding extra publish steps, or splitting concerns across repos.

Two layouts are on the table:

* **A: Same-repo `mcp/`** inside `SriChandraSekharA/forge-standard` at `mcp/server.ts` (stdio) and `mcp/mcp.json` manifest, using `@modelcontextprotocol/sdk`.
* **B: Separate `forge-standard-mcp`** repo that holds the MCP server on its own.

We compared them on six things that actually matter for this project: publish friction, skills.sh crawl, versioning, dep isolation, CI duplication, and UX confusion.

## Decision

**Use same-repo `mcp/` inside `SriChandraSekharA/forge-standard`.**

* Server entry: `mcp/server.ts` running stdio transport via `@modelcontextprotocol/sdk`.
* Manifest: `mcp/mcp.json` at repo root relative `mcp/mcp.json`, referenced from skill metadata where needed.
* Package and skill stay together so a single publish covers both.

We scored it as the lower-friction and lower-confusion option. If same-repo becomes blocked by policy or tooling, we fall back to a separate `forge-standard-mcp` repo, see fallback note below.

## Weighted Matrix

Scores are 1 to 5, where 5 is best. Weighted score is weight times score. Weights sum to 100.

| # | Criterion | Weight | A: Same-repo `mcp/` | A Weighted | B: Separate `forge-standard-mcp` | B Weighted | Notes |
|---|-----------|--------|---------------------|------------|----------------------------------|------------|-------|
| 1 | Publish friction | 20 | 5 | 100 | 2 | 40 | A needs one tag, one npm/skills publish, one changelog. B needs coordinated releases, two repos to cut, and double the release notes. |
| 2 | skills.sh crawl | 15 | 4 | 60 | 3 | 45 | `skills.sh` already crawls `SriChandraSekharA/forge-standard` for the skill. A stays on that known path, so crawl stays simple. B would need a second crawl entry and a new discovery path to be taught. |
| 3 | Versioning | 20 | 4 | 80 | 3 | 60 | A keeps skill logic, MCP tools, prompts, and checklist in lockstep under one semver. B splits versions, so users can land on mismatched skill + MCP pairs. |
| 4 | Dep isolation | 15 | 3 | 45 | 5 | 75 | B isolates MCP deps cleanly. A shares `package.json` and needs care to keep `@modelcontextprotocol/sdk` and MCP deps out of the skill core, for example via `mcp/package.json` or optional peer handling. |
| 5 | CI duplication | 15 | 5 | 75 | 2 | 30 | A reuses the existing workflows in `.github/workflows`, one matrix, one cache. B duplicates workflows, secrets, and branch protections. |
| 6 | UX confusion | 15 | 5 | 75 | 2 | 30 | A gives one repo, one install, one README. `npx skills add SriChandraSekharA/forge-standard` plus MCP at `mcp/` is easy to explain. B forces users to pick between two repos and two install commands. |
| | **Total** | **100** | | **435** | | **280** | **A wins by 155 points, about 55 percent higher** |

Scoring rationale, short form:

* A gets top marks where it reduces work and confusion, that's publish, CI, and UX. It scores well on versioning and crawl because one repo keeps things in sync and on a single discovery path.
* B's only clear win is dep isolation, since a standalone repo avoids mixing MCP SDK deps with the pure skill dep set. That benefit is real but narrow, and it doesn't offset the extra publish and UX cost for this project.

## Recommendation: Same-Repo `mcp/` Detail

**Layout**

```
forge-standard/
  mcp/
    server.ts      # stdio server, entry for @modelcontextprotocol/sdk
    mcp.json       # MCP manifest, tools and resources declaration
  scripts/         # existing skill scripts, unchanged
  references/      # existing checklists, unchanged
  SKILL.md
  package.json
```

**Runtime**

* `mcp/server.ts` uses stdio transport from `@modelcontextprotocol/sdk`. No HTTP, no extra port, no auth to manage in v1.
* `mcp/mcp.json` declares the server name, version tied to `package.json` version, and the tools exposed. Keep it small and explicit, one file that clients can read without running code.
* The skill and MCP server import shared logic from the same codebase where possible, so review rules and prompts do not drift.

**Publish**

* One command, one repo: bump `package.json` version, tag, push, and `skills.sh` sees the same ref. No second repo to tag.

**Why this is less risky**

* Fewer moving parts, fewer places for a publish to fail part way through, and fewer docs to keep in sync. It also keeps the existing skill install as the primary path, with MCP as an additive capability not a fork.

## Fallback Note

If same-repo is blocked, for example by an org policy that forbids MCP SDK deps in the skill repo, or by a `skills.sh` rule that rejects mixed repos, fall back to a separate `SriChandraSekharA/forge-standard-mcp` repo.

Fallback steps:

1. Create `forge-standard-mcp` from the canonical templates, set `package.json` name to `forge-standard-mcp`, and pin its skill dep to the `forge-standard` release tag it was cut from, for example `forge-standard@1.0.0`.
2. Move only `mcp/server.ts` and `mcp/mcp.json` into the new repo, keep SKILL.md in the original repo, and add a note in both READMEs linking the pair.
3. Add a small CI job in each repo that checks version alignment and fails if the pair drifts by more than a patch.
4. Revisit this ADR and file an amendment ADR-002 recording why the split was needed and how long it should last. Prefer to merge back to same-repo once the blocker clears.

This keeps the cost contained and the pairing explicit if we have to split.

## Consequences

* Positive: one repo to own, one set of OSS files to maintain, one review queue, and one skills.sh crawl path. Changes to review logic and MCP tools ship together.
* Negative: we must handle dep isolation inside one repo. Use a dedicated `mcp/package.json` or careful optional deps so `@modelcontextprotocol/sdk` does not leak into minimal skill installs.
* Neutral: CI stays simple but matrix jobs may need a conditional step that only runs MCP checks when `mcp/` changed.

## Validation

* Dir exists: `"/Users/webileapps/Chandu/github/forge-standard/docs"` via `mkdir -p "/Users/webileapps/Chandu/github/forge-standard/docs"`.
* File written: `"/Users/webileapps/Chandu/github/forge-standard/docs/ADR-001-mcp-repo-strategy.md"` exists and passes basic checks.
* No push performed, this ADR is local only until review, same rule as Task 3 archive prep.
* Approval log touched: `"/Users/webileapps/Chandu/github/forge-standard/.omo/notepad.md"` appended with dated entry, see next section.

## Approval Log Entry

The canonical log at `"/Users/webileapps/Chandu/github/forge-standard/.omo/notepad.md"` was appended on 2026-09-05 with a short entry noting this ADR was accepted as same-repo. That entry is the durable approval record, not just this file.
