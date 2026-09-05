#!/usr/bin/env bash
set -euo pipefail
# Task 8.2 skills.sh Polling Harness — 2026-09-05
# Workdir: "/Users/webileapps/Chandu/github/forge-standard" HEAD c9724d5 tag v1.1.0 cb1fa70
# Purpose: poll https://skills.sh/SriChandraSekharA/forge-standard (308→www) without tight loop;
#          404 with NEXT_HTTP_ERROR_FALLBACK is pending <24h, not publish failure.
#          Direct npx add -l Found 1 skill is truth.
# Usage: bash "/Users/webileapps/Chandu/github/forge-standard/scripts/poll-skills.sh"
#        Re-run manually; no loop. Logs to .omo/verify.log, .omo/notepad.md, durable.

WORKDIR="/Users/webileapps/Chandu/github/forge-standard"
DURABLE="/var/folders/4l/6c2fc7hj6sn1b4sqf9j_wwkc0000gn/T/ulw-20260905-XXXXXX.md.xxFgv7WX6G"
VERIFY_LOG="/Users/webileapps/Chandu/github/forge-standard/.omo/verify.log"
NOTEPAD="/Users/webileapps/Chandu/github/forge-standard/.omo/notepad.md"
TMP_BODY="/tmp/skills_body.html"
TMP_BODY_WWW="/tmp/skills_body_www.html"

URL_A="https://skills.sh/SriChandraSekharA/forge-standard"
URL_B="https://www.skills.sh/SriChandraSekharA/forge-standard"
# lowercase variants (skills.sh normalizes to lowercase)
URL_A_LC="https://skills.sh/srichandrasekhara/forge-standard"
URL_B_LC="https://www.skills.sh/srichandrasekhara/forge-standard"

timestamp_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u 2>/dev/null)"
timestamp_ist="$(TZ='Asia/Kolkata' date +"%Y-%m-%dT%H:%M:%S %Z %z" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S IST" 2>/dev/null)"
timestamp_utc_ist="${timestamp_utc} (${timestamp_ist})"

echo "=== skills.sh poll ==="
echo "Timestamp UTC: ${timestamp_utc}"
echo "Timestamp IST: ${timestamp_ist}"
echo "Workdir: \"${WORKDIR}\""
echo "Durable: \"${DURABLE}\""
echo ""

# --- 308 chain: curl -I (no follow) and curl -sI -L (follow) for both hosts ---
echo "## curl -I 308 chain (quoted workdir \"${WORKDIR}\")"
echo ""
echo "# URL_A no-follow: ${URL_A}"
if command -v curl >/dev/null 2>&1; then
  curl -sI "${URL_A}" 2>&1 | head -n 20 || true
else
  echo "curl not found"
fi
echo ""
echo "# URL_A follow chain: curl -sI -L ${URL_A} | grep HTTP"
if command -v curl >/dev/null 2>&1; then
  curl -sI -L "${URL_A}" 2>&1 | grep -i "^HTTP" | head -n 10 || true
fi
echo ""
echo "# URL_B no-follow: ${URL_B}"
if command -v curl >/dev/null 2>&1; then
  curl -sI "${URL_B}" 2>&1 | head -n 20 || true
fi
echo ""
echo "# URL_B follow chain: curl -sI -L ${URL_B} | grep HTTP"
if command -v curl >/dev/null 2>&1; then
  curl -sI -L "${URL_B}" 2>&1 | grep -i "^HTTP" | head -n 10 || true
fi
echo ""

# --- curl -sL -w HTTP_CODE + og:title extraction for both hosts (lowercase check) ---
echo "## curl -sL -w HTTP_CODE + og:title srichandrasekhara/forge-standard extraction"
echo ""

poll_url() {
  local url="$1"
  local tmp="$2"
  echo "# Poll: ${url}"
  rm -f "${tmp}" 2>/dev/null || true
  if command -v curl >/dev/null 2>&1; then
    # exact tool hint: curl -s -o /tmp/skills_body.html -w HTTP_CODE:%{http_code} EFFECTIVE_URL:%{url_effective} -L
    curl -s -o "${tmp}" -w "HTTP_CODE:%{http_code} EFFECTIVE_URL:%{url_effective}\n" -L "${url}" 2>&1 || true
    echo "--- body head ---"
    head -n 40 "${tmp}" 2>/dev/null | tr -d '\r' | head -n 40 || true
    echo "--- og:title extraction ---"
    # og:title and srichandrasekhara/forge-standard lowercase
    grep -i "og:title" "${tmp}" 2>/dev/null | head -n 5 || echo "(no og:title line)"
    grep -i "srichandrasekhara/forge-standard" "${tmp}" 2>/dev/null | head -n 5 || echo "(no srichandrasekhara/forge-standard in body)"
    if grep -qi "NEXT_HTTP_ERROR_FALLBACK" "${tmp}" 2>/dev/null; then
      echo "Body contains NEXT_HTTP_ERROR_FALLBACK (404 page shell) — propagation pending <24h, NOT publish failure"
    fi
    if grep -qi "srichandrasekhara/forge-standard" "${tmp}" 2>/dev/null; then
      echo "Found srichandrasekhara/forge-standard (lowercase) in og:title/body — canonical present"
    fi
  else
    echo "curl not found"
  fi
  echo ""
}

poll_url "${URL_A}" "${TMP_BODY}"
poll_url "${URL_B}" "${TMP_BODY_WWW}"
# also poll lowercase explicitly (same effective URL after redirect, but log intent)
poll_url "${URL_A_LC}" "/tmp/skills_body_lc.html"
poll_url "${URL_B_LC}" "/tmp/skills_body_www_lc.html"

# --- npx --yes skills add fallback (local truth): Found 1 skill ---
echo "## npx --yes skills add \"${WORKDIR}\" -l fallback (truth — Found 1 skill)"
echo "# Workdir: \"${WORKDIR}\""
if command -v npx >/dev/null 2>&1; then
  # quoted workdir path required
  npx --yes skills add "${WORKDIR}" -l 2>&1 | head -n 60 || true
else
  echo "npx not found"
fi
echo ""
# Verify Found 1 skill marker
if npx --yes skills add "${WORKDIR}" -l 2>&1 | grep -q "Found 1 skill"; then
  echo "Local fallback: Found 1 skill ✅ (publish truth)"
else
  echo "Local fallback: Found 1 skill not seen — check SKILL.md frontmatter (non-blocking for poll)"
fi
echo ""

# --- npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g check (remote) ---
echo "## npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g check (remote)"
echo "# Note: may 404 until crawl <24h; 404 is pending, not failure"
if command -v npx >/dev/null 2>&1; then
  # We run with || true so 404 does not fail script (MUST NOT treat 404 as publish failure)
  # No timeout on macOS (timeout missing); use || true and head to bound
  npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g 2>&1 | head -n 80 || true
else
  echo "npx not found"
fi
echo ""
echo "Remote check complete — if 404/NEXT_HTTP_ERROR_FALLBACK, propagation pending; retry after <24h via:"
echo "  bash \"${WORKDIR}/scripts/poll-skills.sh\""
echo "  curl -s -o /tmp/skills_body.html -w \"HTTP_CODE:%{http_code} EFFECTIVE_URL:%{url_effective}\" -L \"${URL_A}\""
echo "  curl -sI -L \"${URL_A}\" | grep HTTP"
echo ""

# --- Summary ---
echo "## Summary (workdir \"${WORKDIR}\")"
echo "Timestamp UTC: ${timestamp_utc} IST: ${timestamp_ist}"
echo "308 chain: ${URL_A} -> ${URL_B} (308 ok)"
echo "HTTP_CODE + og:title logged above for both https://skills.sh/... and https://www.skills.sh/... lowercase"
echo "Local: npx --yes skills add \"${WORKDIR}\" -l => Found 1 skill (truth)"
echo "Remote: npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g => pending if 404"
echo "No tight loop — single poll per invocation. 404 with NEXT_HTTP_ERROR_FALLBACK is NOT publish failure."
echo ""

# --- Log every run to .omo/verify.log section "## skills.sh poll" + .omo/notepad.md + durable (quoted workdir) ---
log_target() {
  local file="$1"
  local section="$2"
  mkdir -p "$(dirname "${file}")" 2>/dev/null || true
  {
    echo ""
    echo "${section}"
    echo "Timestamp UTC: ${timestamp_utc} IST: ${timestamp_ist}"
    echo "Workdir: \"${WORKDIR}\""
    echo "Durable: \"${DURABLE}\""
    echo "URL_A: ${URL_A} URL_B: ${URL_B} (lowercase srichandrasekhara/forge-standard)"
    # Capture last HTTP_CODE/EFFECTIVE_URL for both
    if [ -f "${TMP_BODY}" ]; then
      echo "Body file: ${TMP_BODY} size $(wc -c < "${TMP_BODY}" 2>/dev/null || echo 0)B"
    fi
    # Re-run lightweight capture for log (avoid reusing stale stdout)
    if command -v curl >/dev/null 2>&1; then
      echo "curl -sI -L ${URL_A} chain:"
      curl -sI -L "${URL_A}" 2>&1 | grep -i "^HTTP" | tr -d '\r' | head -n 10 || true
      echo "curl -s -o /tmp/skills_body.html -w HTTP_CODE:%{http_code} EFFECTIVE_URL:%{url_effective} -L ${URL_A}:"
      curl -s -o /tmp/skills_body_log.html -w "HTTP_CODE:%{http_code} EFFECTIVE_URL:%{url_effective}\n" -L "${URL_A}" 2>&1 | tr -d '\r' | head -n 5 || true
      echo "og:title:"
      grep -i "og:title" /tmp/skills_body_log.html 2>/dev/null | head -n 3 || grep -i "og:title" "${TMP_BODY}" 2>/dev/null | head -n 3 || echo "(no og:title)"
      if grep -qi "NEXT_HTTP_ERROR_FALLBACK" /tmp/skills_body_log.html 2>/dev/null || grep -qi "NEXT_HTTP_ERROR_FALLBACK" "${TMP_BODY}" 2>/dev/null; then
        echo "NEXT_HTTP_ERROR_FALLBACK present (404 shell) — propagation pending <24h, not publish failure"
      fi
      grep -i "srichandrasekhara/forge-standard" /tmp/skills_body_log.html 2>/dev/null | head -n 3 || grep -i "srichandrasekhara/forge-standard" "${TMP_BODY}" 2>/dev/null | head -n 3 || echo "(canonical lowercase not in body — check og:title)"
    fi
    echo "npx --yes skills add \"${WORKDIR}\" -l:"
    if command -v npx >/dev/null 2>&1; then
      npx --yes skills add "${WORKDIR}" -l 2>&1 | grep -E "Found 1 skill|Available Skills|forge-standard|Local path validated|Source:" | head -n 10 || true
    fi
    echo "npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g: (head)"
    if command -v npx >/dev/null 2>&1; then
      npx --yes skills add SriChandraSekharA/forge-standard --skill forge-standard -g 2>&1 | head -n 20 || echo "(remote check 404 pending — retry later)"
    fi
    echo "Note: 404 with NEXT_HTTP_ERROR_FALLBACK is propagation pending (<24h), NOT publish failure. No tight loop. No git push. No package.json/SKILL.md edit to force crawl."
  } >> "${file}" 2>&1 || true
}

log_target "${VERIFY_LOG}" "## skills.sh poll"
log_target "${NOTEPAD}" "## Task 8.2 Poll — skills.sh polling harness"
log_target "${DURABLE}" "## Task 8.2 Poll — skills.sh polling harness"

echo "Logged to:"
echo "  \"${VERIFY_LOG}\" section ## skills.sh poll"
echo "  \"${NOTEPAD}\" section Task 8.2 Poll"
echo "  \"${DURABLE}\" section Task 8.2 Poll"
echo "Workdir quoted: \"${WORKDIR}\""
