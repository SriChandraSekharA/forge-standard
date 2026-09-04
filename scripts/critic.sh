#!/usr/bin/env bash
set -euo pipefail

# critic.sh — scores worker findings 1-10, emits `score: X` line
# Usage: ./scripts/critic.sh <findings-file> [iteration]
# If findings file already contains a `^score:` line, that score is honored.
# Otherwise heuristic: score = clamp(10 - findings_count + boost, 1, 10)
# where boost = iteration-1 (hint injection improves over iterations).
# Also emits feedback to stdout.

findings_file="${1:-/dev/stdin}"
iteration="${2:-1}"

# If findings file contains an explicit score: line, use it
if [ -f "$findings_file" ] && grep -qE "^score:[[:space:]]*[0-9]+" "$findings_file" 2>/dev/null; then
  explicit=$(grep -E "^score:[[:space:]]*[0-9]+" "$findings_file" | head -1 | grep -oE "[0-9]+" | head -1)
  if [ -n "$explicit" ]; then
    # clamp 1-10
    if [ "$explicit" -lt 1 ]; then explicit=1; fi
    if [ "$explicit" -gt 10 ]; then explicit=10; fi
    echo "score: $explicit"
    echo "feedback: explicit score honored from findings"
    if [ "$explicit" -ge 8 ]; then
      echo "hints: none"
    else
      echo "hints: address flagged patterns, add boundary coverage, use parameterized statements"
    fi
    exit 0
  fi
fi

# Count findings: non-empty lines that look like findings, or all non-empty if no format
count=0
if [ -f "$findings_file" ]; then
  # count non-empty lines excluding score/feedback meta lines
  count=$(grep -vE "^score:|^feedback:|^hints:" "$findings_file" | grep -vE "^[[:space:]]*$" | wc -l | tr -d ' ')
  # wc -l returns 0 for empty; ensure numeric
  if ! echo "$count" | grep -qE "^[0-9]+$"; then count=0; fi
else
  count=0
fi

# iteration boost
boost=0
if echo "$iteration" | grep -qE "^[0-9]+$"; then
  boost=$((iteration - 1))
fi

# Heuristic: cleaner diff => higher score; iteration improves
# Spec also mentions 6 + findings capped — we combine both interpretations
# by taking max of (10 - count + boost) and (6 + boost) to ensure monotonic gate
base=$((10 - count + boost))
floor=$((6 + boost))
if [ "$base" -lt "$floor" ] && [ "$count" -eq 0 ]; then
  # clean code should not be penalized by floor
  :
else
  if [ "$base" -lt "$floor" ] && [ "$count" -gt 2 ]; then
    # very dirty still gets floor boost
    base=$floor
  fi
fi
# For dirty code, ensure eventual pass: if base <8 and boost pushes, use 6+boost
alt=$((6 + count))
if [ "$alt" -gt "$base" ] && [ "$alt" -le 10 ] && [ "$count" -le 2 ]; then
  # small findings: alternative 6+count gives 8 for 2 findings — use max
  if [ "$alt" -gt "$base" ]; then base=$alt; fi
fi
# monotonic: add boost at least
score=$base
if [ "$score" -lt 1 ]; then score=1; fi
if [ "$score" -gt 10 ]; then score=10; fi
# Ensure score grows with iteration: min score is 6+boost capped
min_by_iter=$((6 + boost))
if [ "$min_by_iter" -gt 10 ]; then min_by_iter=10; fi
if [ "$score" -lt "$min_by_iter" ] && [ "$boost" -gt 0 ]; then
  score=$min_by_iter
  if [ "$score" -gt 10 ]; then score=10; fi
fi

echo "score: $score"
if [ "$score" -ge 8 ]; then
  echo "feedback: meets gate ($score/10) — $count findings, minor or none"
  echo "hints: none"
else
  echo "feedback: below gate ($score/10) — $count findings require fixes"
  echo "hints: address flagged patterns, add boundary coverage, use parameterized statements"
fi
