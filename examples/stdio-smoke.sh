#!/usr/bin/env bash
set -euo pipefail

# forge-standard MCP stdio smoke test
# Pipes JSON-RPC initialize, initialized notification, tools/list, tools/call through mcp/dist/server.js
# Workdir param is quoted and supports paths with spaces.
# Usage: bash examples/stdio-smoke.sh [--workdir "/path/with spaces"]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SERVER_JS="$REPO_ROOT/mcp/dist/server.js"
WORKDIR="$REPO_ROOT"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workdir)
      WORKDIR="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Resolve workdir to absolute path (handles quoted paths with spaces)
WORKDIR="$(cd "$WORKDIR" 2>/dev/null && pwd || echo "$WORKDIR")"

if [[ ! -f "$SERVER_JS" ]]; then
  echo "Building MCP server..." >&2
  npm run build --prefix "$REPO_ROOT/mcp" >&2
fi

if [[ ! -f "$SERVER_JS" ]]; then
  echo "FAIL: server not found at $SERVER_JS" >&2
  exit 1
fi

echo "[stdio-smoke] server: $SERVER_JS" >&2
echo "[stdio-smoke] workdir: $WORKDIR" >&2

TMPDIR_SMOKE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_SMOKE"' EXIT
OUT="$TMPDIR_SMOKE/out.jsonl"
ERR="$TMPDIR_SMOKE/stderr.log"

# Build JSON-RPC sequence: initialize (id 1), initialized notification, tools/list (id 2), tools/call forge_review (id 3)
# The server speaks newline-delimited JSON over stdio.

# Use python3 to build JSON safely with quoted workdir
python3 -c "
import json, sys
workdir = sys.argv[1]
msgs = [
    {'jsonrpc': '2.0', 'id': 1, 'method': 'initialize', 'params': {'protocolVersion': '2024-11-05', 'capabilities': {}, 'clientInfo': {'name': 'stdio-smoke', 'version': '1.0.0'}}},
    {'jsonrpc': '2.0', 'method': 'notifications/initialized'},
    {'jsonrpc': '2.0', 'id': 2, 'method': 'tools/list', 'params': {}},
    {'jsonrpc': '2.0', 'id': 3, 'method': 'tools/call', 'params': {'name': 'forge_review', 'arguments': {'mode': 'auto', 'preview': True, 'workdir': workdir}}},
]
for m in msgs:
    print(json.dumps(m))
" "$WORKDIR" | node "$SERVER_JS" > "$OUT" 2> "$ERR" &

PID=$!

# Wait up to 35s for all 3 responses (id 1,2,3) to appear, preview can take ~20s due to test discovery
for i in $(seq 1 175); do
  if grep -q '\"id\":1' "$OUT" 2>/dev/null && grep -q '\"id\":2' "$OUT" 2>/dev/null && grep -q '\"id\":3' "$OUT" 2>/dev/null; then
    break
  fi
  sleep 0.2
  if ! kill -0 "$PID" 2>/dev/null; then
    break
  fi
done

# Give a moment for buffered output
sleep 0.5
# Terminate server if still running
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

echo "--- Raw output ---" >&2
cat "$OUT" >&2 || true
if [[ -s "$ERR" ]]; then
  echo "--- Stderr ---" >&2
  cat "$ERR" >&2
fi

# Verify initialize response
if ! grep -q '"serverInfo"' "$OUT"; then
  echo "FAIL: missing serverInfo in initialize response" >&2
  exit 1
fi
if ! grep -q '"forge-standard"' "$OUT"; then
  echo "FAIL: serverInfo.name != forge-standard" >&2
  exit 1
fi

# Verify tools/list
if ! grep -q '"forge_review"' "$OUT"; then
  echo "FAIL: tools/list missing forge_review" >&2
  exit 1
fi
if ! grep -q '"workdir"' "$OUT"; then
  echo "FAIL: tools/list inputSchema missing workdir" >&2
  exit 1
fi

# Verify tools/call response contains workdir and exitCode
if ! grep -q 'workdir:' "$OUT"; then
  echo "FAIL: tools/call response missing workdir echo" >&2
  exit 1
fi
if ! grep -q 'exitCode:' "$OUT"; then
  echo "FAIL: tools/call response missing exitCode" >&2
  exit 1
fi

# Check that workdir with spaces would be quoted correctly (if applicable)
# The server uses path.resolve + spawn cwd, so spaces are preserved as single arg
if echo "$WORKDIR" | grep -q " "; then
  if ! grep -q "$WORKDIR" "$OUT"; then
    echo "FAIL: workdir with spaces not echoed" >&2
    exit 1
  fi
fi

echo "PASS: stdio smoke (initialize -> tools/list -> tools/call) with workdir=$WORKDIR" >&2
exit 0
