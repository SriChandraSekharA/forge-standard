#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-.forge-standard}"
mkdir -p "$target_dir"

script_dir="$(cd "$(dirname "$0")" && pwd)"
resolve_ref() {
  local rel="$1"
  if [ -f "$rel" ]; then echo "$rel"
  elif [ -f "$script_dir/../$rel" ]; then echo "$script_dir/../$rel"
  elif [ -f "/Users/webileapps/Chandu/github/forge-standard/$rel" ]; then echo "/Users/webileapps/Chandu/github/forge-standard/$rel"
  else echo ""; fi
}

state_template="$(resolve_ref "references/state.json.template")"
checklist_ref="$(resolve_ref "references/checklist.md")"
# state.json merge: preserve reviews[] array, jq fallback to cp -n
if [ -f "$target_dir/state.json" ]; then
  if command -v jq >/dev/null 2>&1 && [ -n "$state_template" ] && [ -f "$state_template" ]; then
    tmp_merged="$(mktemp)"
    jq -s '.[0] * {reviews: .[1].reviews} * (if .[1].lastReviewAt != null then {lastReviewAt: .[1].lastReviewAt} else {} end) | .reviews //= []' "$state_template" "$target_dir/state.json" > "$tmp_merged" 2>/dev/null || cp -n "$state_template" "$tmp_merged" 2>/dev/null || true
    if [ -s "$tmp_merged" ] && jq empty "$tmp_merged" 2>/dev/null; then
      mv "$tmp_merged" "$target_dir/state.json"
    else
      rm -f "$tmp_merged"
    fi
  else
    : # jq missing or template missing - cp -n semantics: preserve existing file
  fi
else
  if [ -n "$state_template" ] && [ -f "$state_template" ]; then
    cp "$state_template" "$target_dir/state.json"
  else
    echo '{"initialized":true,"reviews":[],"version":1,"lastReviewAt":null}' > "$target_dir/state.json"
  fi
fi

# checklist.md merge: preserve CUSTOM blocks or lines containing CUSTOM
if [ -f "$target_dir/checklist.md" ]; then
  tmp_custom="$(mktemp)"
  if grep -q "USER CUSTOM START" "$target_dir/checklist.md" 2>/dev/null; then
    sed -n '/USER CUSTOM START/,/USER CUSTOM END/p' "$target_dir/checklist.md" > "$tmp_custom" 2>/dev/null || true
  else
    grep "CUSTOM" "$target_dir/checklist.md" > "$tmp_custom" 2>/dev/null || true
    # diff -u fallback: preserve user lines not in template that contain CUSTOM
    if command -v diff >/dev/null 2>&1 && [ -n "$checklist_ref" ] && [ -f "$checklist_ref" ]; then
      diff -u "$checklist_ref" "$target_dir/checklist.md" 2>/dev/null | grep "^+.*CUSTOM" | sed 's/^+//' >> "$tmp_custom" 2>/dev/null || true
    fi
    sort -u "$tmp_custom" -o "$tmp_custom" 2>/dev/null || true
  fi
  if [ -s "$tmp_custom" ]; then
    # file exists - never cp blindly; ensure CUSTOM preserved
    if ! grep -q "CUSTOM" "$target_dir/checklist.md" 2>/dev/null; then
      cat "$tmp_custom" >> "$target_dir/checklist.md"
    fi
  fi
  rm -f "$tmp_custom"
else
  if [ -n "$checklist_ref" ] && [ -f "$checklist_ref" ]; then
    cp -n "$checklist_ref" "$target_dir/checklist.md" 2>/dev/null || cp "$checklist_ref" "$target_dir/checklist.md"
  fi
fi

# history.md: always overwrite/sync via history.sh
if [ -f "$script_dir/history.sh" ]; then
  bash "$script_dir/history.sh" "$target_dir" 2>/dev/null || echo "no-vcs" > "$target_dir/history.md"
elif [ -f "./scripts/history.sh" ]; then
  bash "./scripts/history.sh" "$target_dir" 2>/dev/null || echo "no-vcs" > "$target_dir/history.md"
else
  echo "no-vcs" > "$target_dir/history.md"
fi

# learning.md: never truncated - append only, create if missing
if [ ! -f "$target_dir/learning.md" ]; then
  touch "$target_dir/learning.md"
fi
echo "merge done"
