# ADR Decision — Legacy OSS Baseline / Archive Prep (Task 3)

Status: draft prepared, not executed

## Input Section (Task 3)

## Decision

Prepare legacy repos for eventual archival with OSS baseline parity to canonical `SriChandraSekharA/forge-standard`.

- **Canonical stays:** `SriChandraSekharA/forge-standard` HEAD `09312ed15847449211b4852ec3d4e5822a9e697a`, tag `v1.0.0`, public, not archived, 8 topics. No archive action on canonical.
- **Legacies flagged:** `SriChandraSekharA/anvil-review-loop` HEAD `685c52c44b9daf4a2a836da60652fae252db1353` (8 topics), `SriChandraSekharA/qodo-standard-review` HEAD `53319ab35310c3c2fcf0e9345b47dfa6f561c488` (0 topics), both public, not archived. Same OSS gaps as canonical, see `.omo/audit.md`.

Decision: do not archive yet (Task 9). Prepare draft branches only in `/tmp` clones.

## Legacy Prep Status

| Repo | Clone path | Branch | Commit | Files added | Pushed | Archived |
|------|------------|--------|--------|-------------|--------|----------|
| `SriChandraSekharA/anvil-review-loop` | `/tmp/anvil-review-loop` | `chore/oss-baseline-legacy` | `db71b5e` (parent `685c52c`) | `LICENSE` (MIT 2026 SriChandraSekharA), `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md` (Covenant 2.1), `SECURITY.md`, `ARCHIVED_NOTICE.md` (`MOVED to SriChandraSekharA/forge-standard`), `README.md` banner `> **Archived - moved to forge-standard**`, `README.banner-draft.md` | No | No, draft only |
| `SriChandraSekharA/qodo-standard-review` | `/tmp/qodo-standard-review` | `chore/oss-baseline-legacy` | `e92cfb7` (parent `53319ab`) | Same 7 files as above | No | No, draft only |

## Artifacts (draft only, not pushed)

- `LICENSE`: MIT, `Copyright (c) 2026 SriChandraSekharA`, same as Task 2 baseline.
- `CONTRIBUTING.md`: fork, branch, shellcheck, tests, frontmatter rule, no tokens.
- `CODE_OF_CONDUCT.md`: Contributor Covenant 2.1, report to `chandrashekar.adepalli@kfintech.com`, notes move to forge-standard.
- `SECURITY.md`: canonical `forge-standard` only supported, legacy marked No/Moved, coordinated disclosure, 72h ack.
- `ARCHIVED_NOTICE.md`: banner `# Archived - moved to forge-standard`, blockquote `> **Archived - moved to forge-standard**`, field `MOVED to SriChandraSekharA/forge-standard`, reason consolidation and distinct brand, how to move with `npx skills add SriChandraSekharA/forge-standard`, deferred note for Task 9.
- `README.md`: prepended banner `> **Archived - moved to forge-standard**` plus link to canonical and `ARCHIVED_NOTICE.md`. Original content preserved below banner.
- `README.banner-draft.md`: standalone banner snippet for review.

Clone method: `git clone --depth 1 https://github.com/SriChandraSekharA/<repo>.git /tmp/<repo>` verified HEAD matches audit.
Commit on draft branch only, `origin/main` untouched, `git diff origin/main..HEAD --stat` shows 7 files, 198 insertions.

## MUST NOT DO Compliance

- No `gh repo archive` or `gh repo edit --archived` executed.
- No `git push` to origin from `/tmp` clones.
- No modifications to `SriChandraSekharA/forge-standard` working tree beyond allowed Task 2 OSS baseline and this `.omo/adr-decision.md` (Task 3 input section).
- Draft branches exist only in `/tmp`, not in canonical repo.

## Next Gate (Task 9)

- Re-check `curl -sL https://skills.sh/SriChandraSekharA/forge-standard` for 200 before publish.
- Then push canonical OSS baseline, then archive legacies with same `ARCHIVED_NOTICE.md` content plus `gh repo archive` and topic update.

## Verification

- `git -C /tmp/anvil-review-loop rev-parse HEAD` => `db71b5e58cd79fef552c6f822673192267c9d684` on `chore/oss-baseline-legacy`, `origin/main` still `685c52c44b9daf4a2a836da60652fae252db1353`.
- `git -C /tmp/qodo-standard-review rev-parse HEAD` => `e92cfb7137fdc5ac17de128364341c74d2e7b9ed` on `chore/oss-baseline-legacy`, `origin/main` still `53319ab35310c3c2fcf0e9345b47dfa6f561c488`.
- No pushes, no archive flags, canonical unmodified.

Generated: 2026-09-05 IST.
