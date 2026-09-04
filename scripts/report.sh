#!/usr/bin/env bash
set -euo pipefail
# report.sh -- ranked report critical->nitpick + review.json (no network)
out_dir=".anvil-review-loop"; mkdir -p "$out_dir"
report_md="$out_dir/report.md"; review_json="$out_dir/review.json"
input_arg=""
while [ $# -gt 0 ]; do
  case "$1" in
    --input) input_arg="${2:-}"; shift 2 ;;
    --format|--output) shift 2 2>/dev/null || shift ;;
    --help|-h) echo "Usage: $0 [--input findings.json]"; exit 0 ;;
    *) shift ;;
  esac
done
src=""
if [ -n "$input_arg" ] && [ -f "$input_arg" ]; then
  src="$input_arg"
elif [ -f "$out_dir/learning.md" ] && [ -s "$out_dir/learning.md" ]; then
  src="$out_dir/learning.md"
else
  latest=$(ls -t "$out_dir"/run-*.log 2>/dev/null | head -1 || true)
  if [ -n "$latest" ] && [ -f "$latest" ]; then src="$latest"
  else src="$out_dir/learning.md"; fi
fi
ts_report="$(date +"%Y-%m-%dT%H:%M:%S+05:30" 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BASE_SHA="$(git rev-parse --verify origin/main 2>/dev/null | head -n1 || true)"
  if [ -z "$BASE_SHA" ]; then BASE_SHA="$(git rev-parse --verify HEAD~1 2>/dev/null | head -n1 || true)"; fi
  if [ -z "$BASE_SHA" ]; then BASE_SHA="HEAD"; fi
  HEAD_SHA="$(git rev-parse --verify HEAD 2>/dev/null | head -n1 || true)"
  if [ -z "$HEAD_SHA" ]; then HEAD_SHA="HEAD"; fi
else
  BASE_SHA="HEAD"
  HEAD_SHA="HEAD"
fi
tmp_findings=$(mktemp); tmp_sorted=$(mktemp); tmp_json=$(mktemp)
trap 'rm -f "$tmp_findings" "$tmp_sorted" "$tmp_json"' EXIT
if echo "$src" | grep -qE "\.json$" 2>/dev/null && [ -f "$src" ]; then
  if command -v jq >/dev/null 2>&1 && jq -e '.findings' "$src" >/dev/null 2>&1; then
    jq -r '.findings[] | "L: \(.file):\(.line) [\(.severity)] \(.reason) -> \(.fix)"' "$src" > "$tmp_findings" 2>/dev/null || true
  fi
  if [ ! -s "$tmp_findings" ]; then
    grep -iE "\[.*(critical|high|medium|low|nitpick).*\]" "$src" 2>/dev/null > "$tmp_findings" || true
  fi
else
  if [ -f "$src" ]; then
    grep -iE "\[.*(critical|high|medium|low|nitpick).*\]" "$src" 2>/dev/null > "$tmp_findings" || true
  fi
fi
: > "$tmp_sorted"
while IFS= read -r line || [ -n "$line" ]; do
  [ -z "$line" ] && continue
  sev=$(echo "$line" | grep -oiE "\[[^]]*/[[:space:]]*(critical|high|medium|low|nitpick)" | grep -oiE "critical|high|medium|low|nitpick" | head -1 | tr '[:upper:]' '[:lower:]' || true)
  if [ -z "$sev" ]; then sev=$(echo "$line" | grep -oiE "critical|high|medium|low|nitpick" | head -1 | tr '[:upper:]' '[:lower:]' || echo "medium"); fi
  case "$sev" in critical) rank=0 ;; high) rank=1 ;; medium) rank=2 ;; low) rank=3 ;; nitpick) rank=4 ;; *) rank=2 ;; esac
  echo "$rank|$line" >> "$tmp_sorted"
done < "$tmp_findings"
sort -n "$tmp_sorted" -o "$tmp_sorted" 2>/dev/null || true
extract_file() { echo "$1" | grep -oE "L:[[:space:]]*[^[:space:]]+" | sed 's/^L:[[:space:]]*//' | head -1 || echo "diff:1"; }
extract_line() { f=$(extract_file "$1"); echo "$f" | grep -oE ":[0-9]+" | tr -d ':' | tail -1 || echo "1"; }
{
  echo "# Anvil Review Report"
  echo ""
  echo "Report generated $ts_report IST - $BASE_SHA...$HEAD_SHA"
  echo ""
  echo "Generated: $ts_report"
  echo ""
  if [ ! -s "$tmp_sorted" ]; then
    echo "No findings"
    echo ""
    for s in Critical High Medium Low Nitpick; do echo "## $s"; echo ""; echo "No findings"; echo ""; done
  else
    for sec in Critical High Medium Low Nitpick; do
      echo "## $sec"
      echo ""
      sev_low=$(echo "$sec" | tr '[:upper:]' '[:lower:]')
      rank_want=0; case "$sev_low" in critical) rank_want=0 ;; high) rank_want=1 ;; medium) rank_want=2 ;; low) rank_want=3 ;; nitpick) rank_want=4 ;; esac
      matched=$(grep -E "^${rank_want}\|" "$tmp_sorted" 2>/dev/null || true)
      if [ -z "$matched" ]; then echo "No findings"; echo ""; continue; fi
      echo "$matched" | while IFS= read -r ranked || [ -n "$ranked" ]; do
        raw=$(echo "$ranked" | cut -d'|' -f2-)
        file=$(extract_file "$raw"); line=$(extract_line "$raw")
        sev=$(echo "$raw" | grep -oiE "\[[^]]*/[[:space:]]*(critical|high|medium|low|nitpick)" | grep -oiE "critical|high|medium|low|nitpick" | head -1 | tr '[:upper:]' '[:lower:]' || echo "$sev_low")
        reason=$(echo "$raw" | sed -E 's/.*\[[^]]*\][[:space:]]*//' | sed -E 's/[[:space:]]*->[[:space:]]*.*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$reason" ] && reason="issue at $file"
        if ! echo "$reason" | grep -qiE "CWE|OWASP|Fowler"; then case "$sev" in critical) reason="$reason (CWE-89 / OWASP A03: Injection)" ;; high) reason="$reason (CWE-20 / Fowler Long Method)" ;; medium) reason="$reason (Fowler Code Smell)" ;; low) reason="$reason (Fowler Readability)" ;; nitpick) reason="$reason (Fowler Style)" ;; esac; fi
        fix=$(echo "$raw" | sed -n 's/.*->[[:space:]]*//p' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$fix" ] && fix="apply checklist guidance for $sev"
        prompt="Act as a senior reviewer, fix $sev issue at $file: $reason by $fix"
        if echo "$sev" | grep -qi "critical"; then prompt="Act as a senior security engineer, fix $sev at $file: $reason by $fix"; fi
        if echo "$sev" | grep -qi "nitpick"; then prompt="Act as a senior style reviewer, fix $sev at $file: $reason by $fix"; fi
        echo "- **$file | $sev**"; echo "  - reason: $reason"; echo "  - fix: $fix"; echo "  - prompt: $prompt"; echo ""
      done
    done
  fi
} > "$report_md"
: > "$tmp_json"; echo '{"findings":[' > "$tmp_json"
first=1
if [ -s "$tmp_sorted" ]; then
  while IFS= read -r ranked || [ -n "$ranked" ]; do
    raw=$(echo "$ranked" | cut -d'|' -f2-)
    file=$(extract_file "$raw"); line=$(extract_line "$raw")
    sev=$(echo "$raw" | grep -oiE "\[[^]]*/[[:space:]]*(critical|high|medium|low|nitpick)" | grep -oiE "critical|high|medium|low|nitpick" | head -1 | tr '[:upper:]' '[:lower:]' || true)
    if [ -z "$sev" ]; then sev=$(echo "$raw" | grep -oiE "critical|high|medium|low|nitpick" | head -1 | tr '[:upper:]' '[:lower:]' || echo "medium"); fi
    reason=$(echo "$raw" | sed -E 's/.*\[[^]]*\][[:space:]]*//' | sed -E 's/[[:space:]]*->[[:space:]]*.*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$reason" ] && reason="issue at $file"
    if ! echo "$reason" | grep -qiE "CWE|OWASP|Fowler"; then case "$sev" in critical) reason="$reason (CWE-89 / OWASP A03: Injection)" ;; high) reason="$reason (CWE-20 / Fowler Long Method)" ;; medium) reason="$reason (Fowler Code Smell)" ;; low) reason="$reason (Fowler Readability)" ;; nitpick) reason="$reason (Fowler Style)" ;; esac; fi
    fix=$(echo "$raw" | sed -n 's/.*->[[:space:]]*//p' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$fix" ] && fix="apply checklist guidance for $sev"
    prompt="Act as a senior reviewer, fix $sev issue at $file: $reason by $fix"
    if echo "$sev" | grep -qi "critical"; then prompt="Act as a senior security engineer, fix $sev at $file: $reason by $fix"; fi
    if echo "$sev" | grep -qi "nitpick"; then prompt="Act as a senior style reviewer, fix $sev at $file: $reason by $fix"; fi
    esc() { echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr -d '\n' | sed 's/\t/ /g'; }
    f_esc=$(esc "$file"); r_esc=$(esc "$reason"); fix_esc=$(esc "$fix"); p_esc=$(esc "$prompt")
    if [ "$first" -eq 1 ]; then first=0; else echo "," >> "$tmp_json"; fi
    printf '  {"file":"%s","line":"%s","severity":"%s","reason":"%s","fix":"%s","prompt":"%s"}' "$f_esc" "$line" "$sev" "$r_esc" "$fix_esc" "$p_esc" >> "$tmp_json"
  done < "$tmp_sorted"
fi
echo "" >> "$tmp_json"
echo ']}' >> "$tmp_json"
if command -v jq >/dev/null 2>&1; then
  jq empty "$tmp_json" 2>/dev/null && cat "$tmp_json" > "$review_json" || cat "$tmp_json" > "$review_json"
  jq . "$review_json" >/dev/null 2>&1 || true
else cat "$tmp_json" > "$review_json"; fi
echo "report: $report_md"
echo "review: $review_json"
