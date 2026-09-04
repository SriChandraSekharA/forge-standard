#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-.anvil-review-loop}"
mkdir -p "$target_dir"

script_dir="$(cd "$(dirname "$0")" && pwd)"

# Resolve template/reference paths
resolve_ref() {
  local rel="$1"
  if [ -f "$rel" ]; then
    echo "$rel"
  elif [ -f "$script_dir/../$rel" ]; then
    echo "$script_dir/../$rel"
  elif [ -f "/Users/webileapps/Chandu/github/anvil-review-loop/$rel" ]; then
    echo "/Users/webileapps/Chandu/github/anvil-review-loop/$rel"
  else
    echo ""
  fi
}

state_template="$(resolve_ref "references/state.json.template")"
knowledge_ref="$(resolve_ref "references/knowledge.md")"
checklist_ref="$(resolve_ref "references/checklist.md")"

# state.json: if exists, merge via merge.sh preserving reviews[] else cp template; jq fallback to cp -n
if [ -f "$target_dir/state.json" ]; then
  if [ -f "$script_dir/merge.sh" ]; then
    bash "$script_dir/merge.sh" "$target_dir" 2>/dev/null || true
  elif [ -f "./scripts/merge.sh" ]; then
    bash "./scripts/merge.sh" "$target_dir" 2>/dev/null || true
  elif command -v jq >/dev/null 2>&1 && [ -n "$state_template" ] && [ -f "$state_template" ]; then
    tmp_merged="$(mktemp)"
    jq -s '.[0] * {reviews: .[1].reviews} | .reviews //= []' "$state_template" "$target_dir/state.json" > "$tmp_merged" 2>/dev/null || cp -n "$state_template" "$tmp_merged" 2>/dev/null || true
    if [ -s "$tmp_merged" ] && jq empty "$tmp_merged" 2>/dev/null; then
      mv "$tmp_merged" "$target_dir/state.json"
    else
      rm -f "$tmp_merged"
    fi
  else
    : # jq missing — cp -n semantics preserve
  fi
else
  if [ -n "$state_template" ] && [ -f "$state_template" ]; then
    cp "$state_template" "$target_dir/state.json"
  else
    echo '{"initialized":true,"reviews":[],"version":1}' > "$target_dir/state.json"
  fi
fi

# knowledge.md / history.md / checklist.md: cp -n from references/ if not exists; checklist merge preserves # USER CUSTOM blocks (simple cp -n for now, full merge in Task 6)
if [ ! -f "$target_dir/knowledge.md" ]; then
  if [ -n "$knowledge_ref" ] && [ -f "$knowledge_ref" ]; then
    cp -n "$knowledge_ref" "$target_dir/knowledge.md" 2>/dev/null || cp "$knowledge_ref" "$target_dir/knowledge.md"
  fi
fi

if [ -f "$target_dir/checklist.md" ]; then
  if [ -f "$script_dir/merge.sh" ]; then
    bash "$script_dir/merge.sh" "$target_dir" 2>/dev/null || true
  elif [ -f "./scripts/merge.sh" ]; then
    bash "./scripts/merge.sh" "$target_dir" 2>/dev/null || true
  else
    : # cp -n semantics — preserve CUSTOM blocks, do not cp blindly
  fi
else
  if [ -n "$checklist_ref" ] && [ -f "$checklist_ref" ]; then
    cp -n "$checklist_ref" "$target_dir/checklist.md" 2>/dev/null || cp "$checklist_ref" "$target_dir/checklist.md"
  fi
fi

# history.md always overwrites (sync via history.sh/merge.sh)
if [ -f "$script_dir/merge.sh" ]; then
  bash "$script_dir/merge.sh" "$target_dir" 2>/dev/null || true
elif [ -f "./scripts/merge.sh" ]; then
  bash "./scripts/merge.sh" "$target_dir" 2>/dev/null || true
elif [ -f "$script_dir/history.sh" ]; then
  bash "$script_dir/history.sh" "$target_dir" 2>/dev/null || echo "no-vcs" > "$target_dir/history.md"
elif [ -f "./scripts/history.sh" ]; then
  bash "./scripts/history.sh" "$target_dir" 2>/dev/null || echo "no-vcs" > "$target_dir/history.md"
else
  echo "no-vcs" > "$target_dir/history.md"
fi

# learning.md never truncated — append only
if [ ! -f "$target_dir/learning.md" ]; then
  touch "$target_dir/learning.md"
fi

# call ./scripts/knowledge.sh "$target_dir" and ./scripts/history.sh "$target_dir" if they exist
if [ -f "$script_dir/knowledge.sh" ]; then
  bash "$script_dir/knowledge.sh" "$target_dir" 2>/dev/null || true
elif [ -f "./scripts/knowledge.sh" ]; then
  bash "./scripts/knowledge.sh" "$target_dir" 2>/dev/null || true
fi

if [ -f "$script_dir/history.sh" ]; then
  bash "$script_dir/history.sh" "$target_dir" 2>/dev/null || true
elif [ -f "./scripts/history.sh" ]; then
  bash "./scripts/history.sh" "$target_dir" 2>/dev/null || true
fi

# handle stale .pid: if [ -f "$target_dir/.pid" ]; then if ! kill -0 $(cat "$target_dir/.pid") 2>/dev/null; then rm "$target_dir/.pid"; fi; fi
if [ -f "$target_dir/.pid" ]; then
  pid_val="$(cat "$target_dir/.pid" 2>/dev/null || echo "")"
  if [ -n "$pid_val" ]; then
    if ! kill -0 "$pid_val" 2>/dev/null; then
      rm -f "$target_dir/.pid"
    fi
  else
    rm -f "$target_dir/.pid"
  fi
fi

echo "init done"
