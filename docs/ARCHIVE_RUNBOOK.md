# Archive Runbook — Manual Admin Closure

> **Scope:** `SriChandraSekharA/forge-standard` (canonical, stays `archived:false`) + legacies `SriChandraSekharA/anvil-review-loop` and `SriChandraSekharA/qodo-standard-review` (to be `archived:true` when owner chooses). All paths quoted; no retry with current token; no `git push --force`.

## Context (Task 8.1 snapshot 2026-09-05)

Canonical workdir: `"/Users/webileapps/Chandu/github/forge-standard"` — HEAD `c9724d5` tag `v1.1.0` (`cb1fa70` tag object) `origin/main` synced. Release `v1.1.0` exists at `https://github.com/SriChandraSekharA/forge-standard/releases/tag/v1.1.0` (verified `gh api repos/SriChandraSekharA/forge-standard/releases/tags/v1.1.0 --jq .tag_name` → `v1.1.0`, `2026-09-05T03:06:48Z` — user says released; confirmed `gh api repos/SriChandraSekharA/forge-standard/releases --jq '.[].tag_name'` → `v1.1.0`).

Legacies at 2026-09-05 — OSS baseline + `ARCHIVED_NOTICE` + banner merged, archive still manual:

| Repo | HEAD (git ls-remote) | archived (gh api) | topics | license |
|------|----------------------|-------------------|--------|---------|
| `forge-standard` | `c9724d5` (main) | `false` | 8 (`code-quality,code-review,owasp,pr-review,pull-request-review,review-loop,security-review,vulnerability-review`) | `mit` |
| `anvil-review-loop` | `c087540` | `false` | 8 (`architecture-review,code-quality-review,code-review,owasp-review,pr-review,review-loop,security-review,vulnerability-review`) | `mit` |
| `qodo-standard-review` | `79933de` | `false` | 0 | `mit` |

Banner verified: `cat "/tmp/anvil-review-loop/README.md" | head -n 3` and `cat "/tmp/qodo-standard-review/README.md" | head -n 3` both start `> **Archived - moved to forge-standard** ... Use SriChandraSekharA/forge-standard instead. See ARCHIVED_NOTICE.md`. Full notice at `cat "/tmp/anvil-review-loop/ARCHIVED_NOTICE.md"` and `cat "/tmp/qodo-standard-review/ARCHIVED_NOTICE.md"` — 43 lines, canonical link + migration steps + draft-defer note (`archived:true` pending Task 9/manual step).

403 history (do **not** retry on current token):

```bash
gh repo archive SriChandraSekharA/anvil-review-loop --yes
# -> GraphQL: Resource not accessible by personal access token (archiveRepository) EXIT:1
gh api repos/SriChandraSekharA/anvil-review-loop -X PATCH -f archived=true
# -> {"message":"Resource not accessible by personal access token","status":"403"} EXIT:1
# token scope read:org,repo — lacks admin. Owner must use UI or admin PAT.
```

## Option A — UI (owner, recommended)

Owner does `Settings → Danger Zone → Archive this repository` per legacy repo. Requires repo admin.

Steps per legacy repo (`SriChandraSekharA/anvil-review-loop`, then if desired `SriChandraSekharA/qodo-standard-review`):

1. Open `https://github.com/SriChandraSekharA/anvil-review-loop/settings` (or `qodo-standard-review/settings`) as the owner account.
2. Scroll to **Danger Zone** → click **Archive this repository**.
3. Read confirmation: repo becomes read-only, issues/PRs closed, no new releases. Check the box `I understand...` and confirm **Archive**.
4. Verify banner shows `This repository has been archived.` on the repo homepage (collapses edit buttons).
5. Repeat for second legacy if chosen. Canonical `forge-standard` stays unarchived — do **not** archive `SriChandraSekharA/forge-standard`.

No `git push --force`, no `gh repo archive` retry with the current `gho_` token. UI archival is idempotent — second click shows `Unarchive`.

## Option B — Admin PAT alternative (owner, CLI)

If owner prefers CLI, use a PAT that has `repo` + `admin:org` (classic) or `Administration: read and write` (fine-grained, repo scope). Do **not** reuse the current `read:org,repo` token that got 403.

```bash
# one-time: create or paste owner admin PAT into gh auth (do not echo token in logs)
# classic PAT needs scopes: repo, admin:org, delete_repo; fine-grained needs Administration RW on the two repos
gh auth login --with-token < /path/to/admin-pat.txt
gh auth status  # confirm active account SriChandraSekharA with admin scope

# then archive (only with this admin PAT)
gh repo archive SriChandraSekharA/anvil-review-loop --yes
gh repo archive SriChandraSekharA/qodo-standard-review --yes   # optional, if chosen

# alternative raw API (equivalent)
gh api repos/SriChandraSekharA/anvil-review-loop -X PATCH -f archived=true
gh api repos/SriChandraSekharA/qodo-standard-review -X PATCH -f archived=true
```

If this option is not available, fall back to Option A — do not retry `gh api -X PATCH archived=true` on the current non-admin token.

## Verification (quoted workdir paths)

Run all after archival (or to prove still `false` before manual step):

```bash
# 1) canonical stays not archived, 8 topics, MIT — expect archived:false topics 8 license:mit
gh api repos/SriChandraSekharA/forge-standard --jq '{archived,topics,license}'
# -> {"archived":false,"license":{"key":"mit",...},"topics":["code-quality","code-review","owasp","pr-review","pull-request-review","review-loop","security-review","vulnerability-review"]}

# 2) legacies — expect archived:true after owner archives (currently false, pending)
gh api repos/SriChandraSekharA/anvil-review-loop --jq '{archived,topics,license}'
gh api repos/SriChandraSekharA/qodo-standard-review --jq '{archived,topics,license}'

# shorthand archived-only
gh api repos/SriChandraSekharA/forge-standard --jq .archived        # false
gh api repos/SriChandraSekharA/anvil-review-loop --jq .archived    # true after manual
gh api repos/SriChandraSekharA/qodo-standard-review --jq .archived # true after manual (if chosen)

# 3) HEADs (quoted ls-remote) — expect c087540 / 79933de
git ls-remote https://github.com/SriChandraSekharA/anvil-review-loop.git HEAD
# -> c08754080ef8101215ef2aa6660f5c07e641a0b3  HEAD
git ls-remote https://github.com/SriChandraSekharA/qodo-standard-review.git HEAD
# -> 79933de913243c0cb36fbc64af27ecc17c88d0a9  HEAD

# 4) banner + notice (quoted cat)
cat "/tmp/anvil-review-loop/ARCHIVED_NOTICE.md"
cat "/tmp/qodo-standard-review/ARCHIVED_NOTICE.md"
head -n 3 "/tmp/anvil-review-loop/README.md"  # -> > **Archived - moved to forge-standard**
head -n 3 "/tmp/qodo-standard-review/README.md"

# 5) canonical release + tag (quoted workdir)
git -C "/Users/webileapps/Chandu/github/forge-standard" rev-parse HEAD  # c9724d5
git -C "/Users/webileapps/Chandu/github/forge-standard" tag -l -n1      # v1.1.0
gh api repos/SriChandraSekharA/forge-standard/releases/tags/v1.1.0 --jq .tag_name  # v1.1.0

# 6) skills.sh propagation (quoted curl -I — 308→200 when indexed; may be 404→200 propagation delay, not blocking)
curl -I "https://skills.sh/SriChandraSekharA/forge-standard"
curl -I "https://www.skills.sh/SriChandraSekharA/forge-standard"
# expected eventually HTTP/2 200; while stale may show 308 → 307 → 404 (see snapshots above)
```

Legacy `archived:false → true` transition is owner-gated; no automated `gh repo archive` retry is attempted on the current token — this file documents the manual gate.

## Why manual

- Token for Tasks 8–10 has `read:org,repo` only — `gh repo archive` and `PATCH archived=true` return `403 Resource not accessible by personal access token` (GraphQL `archiveRepository`).
- Owner must perform `Settings → Archive` in UI or re-auth `gh` with admin PAT. Current automation stops at `ARCHIVED_NOTICE` + banner merged to `main` (`c087540`, `79933de`).

## Troubleshooting

- `403` on `gh repo archive` → confirms non-admin token; do not retry — use UI or admin PAT per Option B.
- `archived:false` after UI click → hard refresh repo settings, re-run `gh api repos/... --jq .archived`; GraphQL cache may lag seconds.
- `skills.sh` `curl -I` 404 → crawl delay (<24h after `c9724d5` push with 8 topics); re-run `curl -I https://skills.sh/SriChandraSekharA/forge-standard` after a day. Not blocking archive.

## References

- Canonical workdir: `"/Users/webileapps/Chandu/github/forge-standard"` (`docs/`, `scripts/`, `mcp/`, `.omo/`)
- Durable notepad: `/var/folders/4l/6c2fc7hj6sn1b4sqf9j_wwkc0000gn/T/ulw-20260905-XXXXXX.md.xxFgv7WX6G` + `.omo/notepad.md` Task 8.1 section
- This playbook file: `"/Users/webileapps/Chandu/github/forge-standard/docs/ARCHIVE_RUNBOOK.md"`
- Verification: `cat "docs/ARCHIVE_RUNBOOK.md"`, `grep Archive "docs/ARCHIVE_RUNBOOK.md"`, `gh api repos/... --jq .archived` for all 3
