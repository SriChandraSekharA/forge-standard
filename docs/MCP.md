# MCP — forge-standard

Same-repo MCP server wrapping `scripts/review.sh` as tool `forge_review`. Stdio transport via `@modelcontextprotocol/sdk`. Local only, no network calls.

## Layout

```
mcp/
  mcp.json       # manifest: name forge-standard, version 1.0.0, transport stdio, tools [forge_review]
  src/server.ts  # stdio JSON-RPC: initialize, tools/list, tools/call
  dist/server.js # built output
  package.json   # forge-standard-mcp, deps @modelcontextprotocol/sdk
examples/
  mcp-client.js        # runnable node client demo (tools/call with quoted workdir)
  stdio-smoke.sh       # bash smoke: piped JSON-RPC initialize -> list -> call
  claude-config.json   # mcpServers snippet for Claude Desktop
```

## Install

```bash
npm --prefix mcp install
npm run build --prefix mcp
# verify
npx tsc --noEmit -p mcp/tsconfig.json
```

## Configure

`mcp/mcp.json` is the source of truth:

```json
{
  "name": "forge-standard",
  "version": "1.0.0",
  "transport": "stdio",
  "command": "node",
  "args": ["mcp/dist/server.js"],
  "entry": "mcp/src/server.ts",
  "tools": [{ "name": "forge_review", "...": "..." }]
}
```

Client config for Claude Desktop (`examples/claude-config.json`):

```json
{
  "mcpServers": {
    "forge-standard": {
      "command": "node",
      "args": ["mcp/dist/server.js"],
      "cwd": "/Users/webileapps/Chandu/github/forge-standard"
    }
  }
}
```

Merge into:

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

Restart Claude, `forge_review` appears under tools.

## Tool: forge_review

Synced exactly to `mcp/mcp.json` and `mcp/src/server.ts` `FORGE_REVIEW_TOOL`:

| Field | Type | Description |
|-------|------|-------------|
| `mode` | `"auto" \| "staged" \| "range" \| "file"` | Review mode: staged (git diff --cached), range (commit range), file (single file), auto (staged else BASE...HEAD) |
| `range` | `string` | Git range for range mode, e.g. `HEAD~1..HEAD` |
| `file` | `string` | File path for file mode |
| `preview` | `boolean` | If true, `--preview` diff only |
| `workdir` | `string` | Working directory (quoted, defaults to repo root) |

All `required` are `[]`, everything is optional. Paths are quoted via `path.resolve` and passed as `spawn("bash", [scriptPath, ...args], { cwd: workdir })`, no shell interpolation. `workdir` is validated with `existsSync` before spawn.

## Run

Stdio directly:

```bash
node mcp/dist/server.js
```

Initialize:

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}' | node mcp/dist/server.js
```

Tools list:

```bash
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | node mcp/dist/server.js
```

Tool call with quoted workdir:

```bash
echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"forge_review","arguments":{"mode":"staged","workdir":"/Users/webileapps/Chandu/github/forge-standard"}}}' | node mcp/dist/server.js
```

## Inspector (npx)

```bash
npx @modelcontextprotocol/inspector node mcp/dist/server.js
```

Open `http://localhost:6274`, Transport `STDIO`, Command `node`, Args `mcp/dist/server.js`, Connect. `tools/list` should show `forge_review`, try `forge_review` with `{ "mode": "staged" }`.

CLI probe:

```bash
npx -y @modelcontextprotocol/inspector --cli node mcp/dist/server.js --method tools/list
```

## Examples

Both examples quote `workdir` and handle paths with spaces:

```bash
# Node client: initialize -> tools/list -> tools/call
node examples/mcp-client.js
node examples/mcp-client.js --workdir "/tmp/with spaces/repo"

# Bash smoke: piped JSON-RPC
bash examples/stdio-smoke.sh
bash examples/stdio-smoke.sh --workdir "/tmp/with spaces/repo"
```

## Verification

```bash
bash examples/stdio-smoke.sh; echo exit:$?
node examples/mcp-client.js 2>&1 | grep -q "tools/call" && echo "client ok"
grep -q "mcp" README.md && echo "README mentions mcp"
grep -q "forge_review" SKILL.md && echo "SKILL.md synced"
```

## Security

- `bash -n` clean on `scripts/*.sh`
- No hardcoded secrets, stdio only, no auth
- Quoted paths, `workdir` validated before spawn
- No network calls in the loop
