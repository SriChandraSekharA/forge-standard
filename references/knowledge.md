# Knowledge Fallback Chain (forge-standard)

> Priority order is authoritative. scripts/knowledge.sh walks top-down, first file that exists wins.

## Fallback Priority

1. `AGENTS.md` : project agent contract at repo root. Highest priority.
2. `CONTRIBUTING.md` : contribution, style, and workflow rules.
3. `.github/copilot-instructions.md` : assistant and copilot instructions.
4. `docs/agents/issue-tracker.md` : issue tracker and process docs.
5. Fowler baseline : Martin Fowler refactoring smells and patterns when no file above exists.

## Resolution Rule

Walk the chain in order 1 to 5. For each path, if the file exists at that location, copy its content to `$target_dir/knowledge.md` and stop. If none exist, write this file plus the Fowler baseline to `$target_dir/knowledge.md`. Cache result under `.forge-standard/knowledge.md` for reuse on next run. The target dir defaults to `.forge-standard` and can be passed as `$1`.

## How scripts/knowledge.sh Picks First Existing

```sh
target_dir=${1:-.forge-standard}
mkdir -p "$target_dir"
if [ -f AGENTS.md ]; then cp AGENTS.md "$target_dir/knowledge.md"
elif [ -f CONTRIBUTING.md ]; then cp CONTRIBUTING.md "$target_dir/knowledge.md"
elif [ -f .github/copilot-instructions.md ]; then cp .github/copilot-instructions.md "$target_dir/knowledge.md"
elif [ -f docs/agents/issue-tracker.md ]; then cp docs/agents/issue-tracker.md "$target_dir/knowledge.md"
else cat references/knowledge.md > "$target_dir/knowledge.md"  # or inline Fowler fallback if references missing
fi
# Also copy checklist if not yet present:
if [ ! -f "$target_dir/checklist.md" ] && [ -f references/checklist.md ]; then cp references/checklist.md "$target_dir/checklist.md"; fi
```

Note: the script also tries `$(dirname "$0")/../references/knowledge.md` and an inline fallback so fixtures in temp dirs still resolve.

## Fowler Smells Baseline (generic fallback, >=10)

When no repo doc matches, apply these smells as review lens:

1. Long Method : method too long, split by intent
2. Large Class : class does too much, split by responsibility
3. Feature Envy : method uses another object more than its own
4. Data Clumps : same group of data items appear together
5. Primitive Obsession : primitives used where small object would help
6. Long Parameter List : too many params, group into object
7. Duplicate Code : same structure in more than one place
8. Shotgun Surgery : one change touches many classes
9. Divergent Change : one class changes for many reasons
10. Message Chains : `a.getB().getC().getD()` chain
11. Middle Man : class delegates most work, adds little value
12. Inappropriate Intimacy : classes know too much about each other

## Cache

Resolved source is cached at `.forge-standard/knowledge.md`. The checklist is cached at `.forge-standard/checklist.md` if not already present. Later runs may merge, not overwrite blindly.

## Status

Authoritative for Task 3 and later.

<!-- docs: knowledge fallback chain priority AGENTS.md > CONTRIBUTING.md > .github/copilot-instructions.md > docs/agents/issue-tracker.md > Fowler baseline - validated wave 3 -->
