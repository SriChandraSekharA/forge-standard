# Contributing to forge-standard

Thanks for helping make forge-standard better. This guide explains how to set up the project, propose changes, and get them reviewed.

## Setup

Clone and install the skill locally with npx:

```bash
git clone https://github.com/SriChandraSekharA/forge-standard.git
cd forge-standard
npx --yes skills add . --skill forge-standard -g -y
```

Verify the install:

```bash
npx --yes skills add . -l
# Expected: Source validated, Found 1 skill (forge-standard)
```

Requirements:

- `bash` 4 or newer (`bash --version`)
- `git`
- `jq` recommended for JSON report shaping

## Development Flow

1. Create a branch from `main`:

   ```bash
   git checkout -b feat/your-change
   ```

2. Make focused changes. Keep scripts small and POSIX friendly, preserve the idempotent `.forge-standard/` contract.

3. Validate locally before pushing:

   ```bash
   bash -n scripts/*.sh
   npx tsc --noEmit
   npm test
   ```

   All three should pass with no output or errors.

4. Run the skill loop on a sample diff to confirm behavior:

   ```bash
   ./scripts/init.sh
   ./scripts/review.sh --staged
   ./scripts/report.sh --format markdown --output review.md
   ```

5. Check that `grep forge-standard SKILL.md` still shows the correct frontmatter name:

   ```bash
   grep forge-standard SKILL.md
   ```

## PR Process

- Keep PRs small and focused on one topic.
- Write a clear title and description that explains the why, not just the what.
- Link any related issue in the description (`Closes #123`).
- Ensure CI is green: `bash -n`, type check, and tests.
- Request review and respond to feedback. One approval is enough for merge.
- Do not commit `.forge-standard/` or other generated artifacts. They are gitignored.
- Follow the existing code style. Run shellcheck where available.

## Reporting Issues

Use the issue templates in `.github/ISSUE_TEMPLATE/` for bugs and feature requests. Include steps to reproduce, expected behavior, and environment details.

## Questions

Open a discussion or issue if something is not clear. We aim to answer within a few days.
