#!/usr/bin/env bash
set -euo pipefail

target_dir="${1:-.forge-standard}"
mkdir -p "$target_dir"

ts_hist="$(date +"%Y-%m-%dT%H:%M:%S+05:30" 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")"
header="# History generated $ts_hist IST - git log -30"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tmp_hist="$(mktemp)"
  echo "$header" > "$tmp_hist"
  git log --pretty=format:"%h %s" -30 >> "$tmp_hist" 2>/dev/null || echo "no-vcs" >> "$tmp_hist"
  if [ -s "$tmp_hist" ] && [ -n "$(tail -c1 "$tmp_hist" 2>/dev/null || true)" ]; then
    echo "" >> "$tmp_hist"
  fi
  mv "$tmp_hist" "$target_dir/history.md"
elif hg root >/dev/null 2>&1; then
  tmp_hist="$(mktemp)"
  echo "$header" > "$tmp_hist"
  hg log -l 30 >> "$tmp_hist" 2>/dev/null || echo "no-vcs" >> "$tmp_hist"
  mv "$tmp_hist" "$target_dir/history.md"
else
  echo "$header" > "$target_dir/history.md"
  echo "no-vcs" >> "$target_dir/history.md"
fi
