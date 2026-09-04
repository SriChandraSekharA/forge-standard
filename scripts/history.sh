#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-.anvil-review-loop}"
mkdir -p "$target_dir"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git log --pretty=format:"%h %s" -30 > "$target_dir/history.md" || echo "no-vcs" > "$target_dir/history.md"
  # Ensure history.md ends with newline so wc -l matches commit count
  if [ -s "$target_dir/history.md" ] && [ -n "$(tail -c1 "$target_dir/history.md" 2>/dev/null || true)" ]; then
    echo "" >> "$target_dir/history.md"
  fi
elif hg root >/dev/null 2>&1; then
  hg log -l 30 > "$target_dir/history.md"
else
  echo "no-vcs" > "$target_dir/history.md"
fi
