# Knowledge Fallback Chain (Stub)

> Full chain logic filled in Task 3. Priority order is authoritative now.

## Fallback Priority

1. `AGENTS.md` — project-specific agent contract at repo root.
2. `CONTRIBUTING.md` — contribution and style guidelines.
3. `.github/copilot-instructions.md` — copilot/assistant instructions.
4. `docs/agents/issue-tracker.md` — issue tracker and workflow docs.
5. Fowler reference note — Martin Fowler's refactoring and architecture
   patterns as generic fallback when no repo doc matches.

## Resolution Rule

Walk the chain top-down; first existing file wins for a given rule domain.
If none exist, apply the Fowler baseline. Cache the resolved source in
`.anvil-review-loop/knowledge.json` for reuse/update on next invocation.

## Status

Stub only — detailed resolver and caching logic lands in Task 3.
