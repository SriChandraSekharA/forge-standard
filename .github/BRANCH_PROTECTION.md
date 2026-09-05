# Branch Protection — `SriChandraSekharA/forge-standard` `main`

> Workdir: `"/Users/webileapps/Chandu/github/forge-standard"` — HEAD `c9724d5` tag `v1.1.0` `cb1fa70` origin `forge-standard`
> Generated: 2026-09-05T08:55 IST (Task 8.5 Hardening & Branch Protection)
> Scope: manual UI steps only — no `git push --force`, no `mcp/dist` direct edit, all paths quoted.

## Evidence (quoted workdir — read-only verification)

```bash
# gh api repos/SriChandraSekharA/forge-standard --jq '{archived,license,topics}'
gh api repos/SriChandraSekharA/forge-standard --jq '{archived,license:.license.spdx_id,topics:(.topics|length),visibility}'
# => {"archived":false,"license":"MIT","topics":8,"visibility":"public"}
# topics: ["code-quality","code-review","owasp","pr-review","pull-request-review","review-loop","security-review","vulnerability-review"] (8)
# archived:false correct — canonical stays public, not archived
# license MIT correct — gh api repos/SriChandraSekharA/forge-standard/license => {"name":"LICENSE","path":"LICENSE","license":{"key":"mit","spdx_id":"MIT"}}

cat "/Users/webileapps/Chandu/github/forge-standard/LICENSE" | head -5
# => MIT License / Copyright (c) 2026 Chandra Sekhar — PASS (MIT 2026 Chandra Sekhar, no anvil/qodo leak in LICENSE)

# No anvil/qodo leak in publishable surface (exclude .git, node_modules, mcp/dist build artifact, .omo historical, .forge-standard runtime)
grep -ri "qodo" --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.omo --exclude-dir=.forge-standard "/Users/webileapps/Chandu/github/forge-standard" 2>&1 | head
# => 0 hits (outside .omo historical + .forge-standard runtime — package.json keywords clean, SKILL.md frontmatter forge-standard only)

grep -ri "qodo" --exclude-dir=.git --exclude-dir=node_modules "/Users/webileapps/Chandu/github/forge-standard" 2>&1 | grep -v "^.*/.omo/" | grep -v "^.*/.forge-standard/" | head
# => 0 hits on publishable files (hits only in .omo/audit* historical references to legacy SriChandraSekharA/qodo-standard-review — expected, not a leak)
# Same for anvil in package.json: grep -n anvil "/Users/webileapps/Chandu/github/forge-standard/package.json" => 0

# Scripts hardening
for f in "/Users/webileapps/Chandu/github/forge-standard/scripts/"*.sh; do head -n1 "$f"; done
# => all #!/usr/bin/env bash + line2 set -euo pipefail (critic.sh, history.sh, init.sh, knowledge.sh, merge.sh, poll-skills.sh, report.sh, review.sh)
bash -n "/Users/webileapps/Chandu/github/forge-standard/scripts/"*.sh; echo exit:$?
# => exit:0

# Typecheck + tests (quoted workdir, mcp prefix)
npx --prefix "/Users/webileapps/Chandu/github/forge-standard/mcp" tsc --noEmit -p mcp/tsconfig.json; echo exit:$?
# => exit:0 (from mcp dir: npx --prefix mcp tsc --noEmit -p tsconfig.json; from root: npm run build --prefix mcp)
npm --prefix "/Users/webileapps/Chandu/github/forge-standard/mcp" test 2>&1 | tail -5
# => Test Files 2 passed (2) / Tests 28 passed (28) — also npm test at root delegates to mcp (same 28)

# mcp workdir quoting
grep -n "path.resolve.*workdir\|existsSync.*workdir\|spawn.*cwd" "/Users/webileapps/Chandu/github/forge-standard/mcp/src/server.ts"
# => handleForgeReview: const workdir = typed.workdir ? path.resolve(typed.workdir) : repoRoot; if (!existsSync(workdir)) ...; spawn("bash",[scriptPath,...scriptArgs],{cwd: workdir}) — quoted, no shell interpolation
```

## Branch Protection API Probe (read-only — fallback to UI)

```bash
gh api repos/SriChandraSekharA/forge-standard/branches/main/protection 2>&1 | head -5
# => {"message":"Resource not accessible by personal access token","documentation_url":"https://docs.github.com/rest/branches/branch-protection#get-branch-protection","status":"403"}
# gh: Resource not accessible by personal access token (HTTP 403)
# Also seen as 404 when token lacks admin:read — same fallback.
# Meaning: current PAT is read-only for repo metadata (contents:read from ci.yml) and cannot read branch protection — do NOT retry with elevated scope in CI.
# Fallback: configure via UI (Settings > Branches) as owner/admin. PAT alternative below for owner with admin token.
```

## UI Steps (owner/admin — manual, no automation)

> Requires admin on `SriChandraSekharA/forge-standard`. Do not automate via `GITHUB_TOKEN` in CI (ci.yml has `permissions: contents: read` only).

1. Open `https://github.com/SriChandraSekharA/forge-standard/settings/branches` (quoted workdir irrelevant — browser step).
2. Click **Add classic branch protection rule** (or **Add rule**).
3. **Branch name pattern:** `main`
4. Check **Require a pull request before merging**
   - Check **Require approvals** — set to `1` (or per team policy)
   - Optionally check **Dismiss stale pull request approvals when new commits are pushed**
   - Optionally check **Require review from Code Owners** if `CODEOWNERS` is added later
5. Check **Require status checks to pass before merging**
   - Check **Require branches to be up to date before merging**
   - In **Status checks** search box, type `ci` — select the `ci` job from `.github/workflows/ci.yml` (matrix `20, 22` reports as `ci (20)` / `ci (22)` or single `ci` depending on `actions/setup-node` matrix naming; select all `ci` variants that appear after one PR runs).
   - Required checks: `ci` (and if split, both `ci (20)` and `ci (22)`). The ci.yml runs: `Typecheck MCP` (`npx tsc --noEmit -p mcp/tsconfig.json`), `Shellcheck scripts` (`bash -n`), `Run tests (28 tests)` (`npm test`), `Stdio smoke` (GITHUB_WORKSPACE + path with spaces), `MCP client` (same).
6. Check **Do not allow bypassing the above settings** (if available — enforces even for admins).
7. Check **Restrict who can push to matching branches** — leave empty or add owner only if needed; primary enforcement is via PR + status checks.
8. **Do not allow force pushes** — check **Do not allow force pushes** (or uncheck **Allow force pushes** — wording varies; ensure force pushes are blocked). Also ensure **Allow deletions** is unchecked.
9. Click **Create** (or **Save changes**).

Verify after first PR:
```bash
# As owner, confirm rule applied (requires admin token for API; UI otherwise):
gh api repos/SriChandraSekharA/forge-standard/branches/main/protection --jq '{required_status_checks, required_pull_request_reviews, allow_force_pushes}' 2>&1 | head -20
# Expect: required_status_checks.contexts contains ci, required_pull_request_reviews.required_approving_review_count >=1, allow_force_pushes.enabled == false
# If 403 again, verify visually in Settings > Branches that the rule shows for main with the checks above.
```

## PAT Alternative (owner with admin token — manual, quoted paths)

> Only run as the repo owner with an admin PAT (not in CI). Current task PAT is read-only — do not retry until owner provides admin scope.

```bash
# Preview what would be set (dry-run — no write if 403):
gh api repos/SriChandraSekharA/forge-standard/branches/main/protection 2>&1 | head

# Apply protection via API (requires admin, quoted workdir shown for parity with server.ts validation):
gh api repos/SriChandraSekharA/forge-standard/branches/main/protection -X PUT \
  -f required_status_checks[strict]=true \
  -f required_status_checks[contexts][]="ci" \
  -f enforce_admins=true \
  -f required_pull_request_reviews[required_approving_review_count]=1 \
  -f required_pull_request_reviews[dismiss_stale_reviews]=true \
  -f restrictions=null \
  -f allow_force_pushes[enabled]=false \
  -f allow_deletions[enabled]=false 2>&1 | head -20

# Legacy API alternative if above contexts key needs array JSON:
gh api repos/SriChandraSekharA/forge-standard/branches/main/protection \
  -X PUT --input <(cat <<'JSON'
{
  "required_status_checks": {"strict": true, "contexts": ["ci"]},
  "enforce_admins": true,
  "required_pull_request_reviews": {"required_approving_review_count": 1, "dismiss_stale_reviews": true},
  "restrictions": null,
  "allow_force_pushes": {"enabled": false},
  "allow_deletions": {"enabled": false}
}
JSON
) 2>&1 | head

# Verify:
gh api repos/SriChandraSekharA/forge-standard/branches/main/protection --jq '{required_status_checks, required_pull_request_reviews, allow_force_pushes, allow_deletions, enforce_admins}' 2>&1
# Fallback to UI if 403: Resource not accessible by personal access token — configure via Settings > Branches as above.
```

## Guardrails

- No `git push --force` executed in this task — protection is read-only probe + UI doc.
- No `mcp/dist/server.js` edited directly — source is `mcp/src/server.ts` with `path.resolve` + `existsSync` + `spawn cwd` quoted (build via `npm run build --prefix mcp`).
- All script invocations quoted: `"/Users/webileapps/Chandu/github/forge-standard/scripts/"*.sh`, `"/Users/webileapps/Chandu/github/forge-standard/mcp"` etc.
- CI remains `permissions: contents: read` — branch protection is manual owner step, not automated.

## Next Verification

After owner applies rule via UI or admin PAT, re-run:

```bash
gh api repos/SriChandraSekharA/forge-standard --jq '{archived,topics: (.topics|length), license: .license.spdx_id}' # archived:false topics:8 license:MIT
gh api repos/SriChandraSekharA/forge-standard/branches/main/protection --jq . 2>&1 | head -40 # 200 with contexts, or 403 fallback
bash -n "/Users/webileapps/Chandu/github/forge-standard/scripts/"*.sh; echo ok
npx --prefix "/Users/webileapps/Chandu/github/forge-standard/mcp" tsc --noEmit -p mcp/tsconfig.json && echo tsc ok
npm test 2>&1 | grep -E "Test Files|Tests"
grep -n "path.resolve.*workdir" "/Users/webileapps/Chandu/github/forge-standard/mcp/src/server.ts"
```
