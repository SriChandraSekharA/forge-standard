#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-.anvil-review-loop}"
mkdir -p "$target_dir"

# Resolve script dir for fallback references lookup
script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_ref_knowledge=""
if [ -f "references/knowledge.md" ]; then
  repo_ref_knowledge="references/knowledge.md"
elif [ -f "$script_dir/../references/knowledge.md" ]; then
  repo_ref_knowledge="$script_dir/../references/knowledge.md"
elif [ -f "/Users/webileapps/Chandu/github/anvil-review-loop/references/knowledge.md" ]; then
  repo_ref_knowledge="/Users/webileapps/Chandu/github/anvil-review-loop/references/knowledge.md"
fi

repo_ref_checklist=""
if [ -f "references/checklist.md" ]; then
  repo_ref_checklist="references/checklist.md"
elif [ -f "$script_dir/../references/checklist.md" ]; then
  repo_ref_checklist="$script_dir/../references/checklist.md"
elif [ -f "/Users/webileapps/Chandu/github/anvil-review-loop/references/checklist.md" ]; then
  repo_ref_checklist="/Users/webileapps/Chandu/github/anvil-review-loop/references/checklist.md"
fi

# Fallback priority: AGENTS.md -> CONTRIBUTING.md -> .github/copilot-instructions.md -> docs/agents/issue-tracker.md -> Fowler baseline
if [ -f "AGENTS.md" ]; then
  cp "AGENTS.md" "$target_dir/knowledge.md"
elif [ -f "CONTRIBUTING.md" ]; then
  cp "CONTRIBUTING.md" "$target_dir/knowledge.md"
elif [ -f ".github/copilot-instructions.md" ]; then
  cp ".github/copilot-instructions.md" "$target_dir/knowledge.md"
elif [ -f "docs/agents/issue-tracker.md" ]; then
  cp "docs/agents/issue-tracker.md" "$target_dir/knowledge.md"
else
  if [ -n "$repo_ref_knowledge" ] && [ -f "$repo_ref_knowledge" ]; then
    cat "$repo_ref_knowledge" > "$target_dir/knowledge.md"
  else
    # Inline Fowler fallback when references file not available (e.g. temp fixture)
    cat > "$target_dir/knowledge.md" <<'FOWLER_EOF'
# Knowledge Fallback: Fowler Baseline

No repo doc found. Using Fowler smells baseline.

## Fowler Smells

1. Long Method
2. Large Class
3. Feature Envy
4. Data Clumps
5. Primitive Obsession
6. Long Parameter List
7. Duplicate Code
8. Shotgun Surgery
9. Divergent Change
10. Message Chains
11. Middle Man
12. Inappropriate Intimacy

Fowler
FOWLER_EOF
  fi
fi

# Copy checklist if not already present (merge later, do not overwrite blindly on 2nd invocation)
if [ ! -f "$target_dir/checklist.md" ]; then
  if [ -n "$repo_ref_checklist" ] && [ -f "$repo_ref_checklist" ]; then
    cp "$repo_ref_checklist" "$target_dir/checklist.md"
  fi
fi
