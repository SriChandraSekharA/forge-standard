# forge-standard MCP Server

Same-repo MCP server at `mcp/` inside `SriChandraSekharA/forge-standard` per ADR-001.
Stdio transport via `@modelcontextprotocol/sdk`, wrapping the existing skill `scripts/review.sh`
as tool `forge_review`.

## Layout

```
mcp/
  package.json   # name forge-standard-mcp, deps @modelcontextprotocol/sdk
  tsconfig.json
  mcp.json       # manifest: name forge-standard, version from root, stdio, tools [forge_review]
  src/server.ts  # stdio JSON-RPC initialize/tools/list/tools/call
  dist/server.js # built output (gitignored)
```

## Install

Deps are isolated to `mcp/` — root `package.json` keeps `skills: ["forge-standard"]` intact.

```bash
npm install --prefix mcp
# or
npm --prefix mcp install
```

## Build

```bash
npm run build --prefix mcp
# or
npm --prefix mcp run build
# verify no type errors without emitting:
npx tsc --noEmit -p mcp/tsconfig.json
```

## Run (stdio)

```bash
node mcp/dist/server.js
```

The server speaks MCP stdio JSON-RPC:

- `initialize` → returns serverInfo `forge-standard` + capabilities `tools`
- `tools/list` → `[{ name: "forge_review", ... }]`
- `tools/call` with `forge_review` → spawns `bash scripts/review.sh` with quoted paths and `workdir` param

Manual smoke test:

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}' | node mcp/dist/server.js
```

Should return a JSON line with `result.serverInfo.name === "forge-standard"` and protocolVersion.

Tool call example (after initialize + initialized notification):

```bash
# tools/list
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | node mcp/dist/server.js
# tools/call staged
echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"forge_review","arguments":{"mode":"staged","workdir":"/Users/webileapps/Chandu/github/forge-standard"}}}' | node mcp/dist/server.js
```

## Inspector (npx)

Use the official MCP inspector — no install needed:

```bash
npx @modelcontextprotocol/inspector node mcp/dist/server.js
```

Then:

1. Inspector opens `http://localhost:6274`
2. Transport: `STDIO`, Command: `node`, Args: `mcp/dist/server.js`
3. Click Connect → `tools/list` should show `forge_review` → Try `forge_review` with `{ "mode": "staged" }`

Alternative CLI probe without UI:

```bash
npx -y @modelcontextprotocol/inspector --cli node mcp/dist/server.js --method tools/list
```

## Tool: forge_review

Wraps `scripts/review.sh` logic — no hardcoded secrets, no network calls.

Inputs:

| Field | Type | Description |
|-------|------|-------------|
| `mode` | `"auto" \| "staged" \| "range" \| "file"` | Review mode (default `auto`) |
| `range` | `string` | Git range for `range` mode, e.g. `HEAD~1..HEAD` |
| `file` | `string` | File path for `file` mode |
| `preview` | `boolean` | If true, `--preview` diff only |
| `workdir` | `string` | Working directory (quoted, defaults to repo root) |

All paths are quoted and `workdir` is passed as `cwd` to `spawn("bash", [...])` — no shell interpolation.

## Versioning

`mcp/mcp.json` version mirrors root `package.json` version (`1.0.0` today). Bump root version and re-sync `mcp/mcp.json` + `mcp/package.json` together.

## Security

- `bash -n` clean (`bash -n scripts/review.sh` and `bash -n mcp/dist/server.js` not applicable but shell scripts are checked)
- No hardcoded secrets or tokens — stdio only, no auth
- Quoted paths, `workdir` param validated with `existsSync` before spawn

## ADR

See `docs/ADR-001-mcp-repo-strategy.md` for same-repo decision.
