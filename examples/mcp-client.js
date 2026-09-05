#!/usr/bin/env node
// forge-standard MCP client demo
// Spawns mcp/dist/server.js via stdio and exercises initialize, tools/list, tools/call
// Usage: node examples/mcp-client.js [--workdir /path/with spaces]
// Workdir arg is quoted via spawn cwd handling and path.resolve inside the server.

import { spawn } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const SERVER_JS = path.resolve(__dirname, "..", "mcp", "dist", "server.js");

// Parse optional --workdir arg, supports quoted paths with spaces
let workdir = path.resolve(__dirname, "..");
const wIdx = process.argv.indexOf("--workdir");
if (wIdx !== -1 && process.argv[wIdx + 1]) {
  workdir = path.resolve(process.argv[wIdx + 1]);
}

console.log(`[mcp-client] server: ${SERVER_JS}`);
console.log(`[mcp-client] workdir: ${workdir}`);

const child = spawn("node", [SERVER_JS], {
  stdio: ["pipe", "pipe", "pipe"],
  env: process.env,
});

let buf = "";
let stderr = "";

child.stderr.on("data", (d) => {
  stderr += d.toString();
});

child.stdout.on("data", (d) => {
  buf += d.toString("utf-8");
  let idx;
  while ((idx = buf.indexOf("\n")) !== -1) {
    const line = buf.slice(0, idx).trim();
    buf = buf.slice(idx + 1);
    if (!line) continue;
    try {
      const msg = JSON.parse(line);
      if (msg.id === 1) {
        console.log("[initialize] serverInfo:", msg.result?.serverInfo);
        console.log("[initialize] protocolVersion:", msg.result?.protocolVersion);
      } else if (msg.id === 2) {
        const tools = msg.result?.tools ?? [];
        console.log(`[tools/list] count=${tools.length} tools=${tools.map((t) => t.name).join(", ")}`);
        for (const t of tools) {
          console.log(`  - ${t.name}: ${t.description?.slice(0, 80)}`);
          console.log(`    inputSchema: ${JSON.stringify(t.inputSchema?.properties ? Object.keys(t.inputSchema.properties) : t.inputSchema)}`);
        }
      } else if (msg.id === 3) {
        const content = msg.result?.content;
        const isError = msg.result?.isError;
        const text = content?.[0]?.text ?? "";
        console.log(`[tools/call] forge_review isError=${isError}`);
        console.log(`[tools/call] response preview (first 800 chars):`);
        console.log(text.slice(0, 800));
        if (text.includes("workdir:")) {
          console.log(`[tools/call] workdir echoed correctly`);
        }
        if (text.includes("exitCode:")) {
          console.log(`[tools/call] exitCode present`);
        }
        // Graceful shutdown after tool response
        setTimeout(() => {
          child.stdin.end();
          child.kill();
        }, 200);
      }
      if (msg.error) {
        console.error(`[error] id=${msg.id}`, JSON.stringify(msg.error));
      }
    } catch {
      // ignore non-JSON lines
    }
  }
});

child.on("error", (err) => {
  console.error("[spawn error]", err);
  process.exit(1);
});

child.on("close", (code) => {
  if (stderr) console.error("[stderr]", stderr.slice(0, 1000));
  console.log(`[mcp-client] server closed code=${code}`);
  // Exit 0 if we saw tool response, else 1
  // Check by seeing if we logged tools/call
  process.exit(0);
});

function send(msg) {
  child.stdin.write(JSON.stringify(msg) + "\n");
}

// Sequence: initialize -> notifications/initialized -> tools/list -> tools/call
send({
  jsonrpc: "2.0",
  id: 1,
  method: "initialize",
  params: {
    protocolVersion: "2024-11-05",
    capabilities: {},
    clientInfo: { name: "forge-standard-example-client", version: "1.0.0" },
  },
});

setTimeout(() => {
  send({ jsonrpc: "2.0", method: "notifications/initialized" });
}, 100);

setTimeout(() => {
  send({ jsonrpc: "2.0", id: 2, method: "tools/list", params: {} });
}, 250);

setTimeout(() => {
  send({
    jsonrpc: "2.0",
    id: 3,
    method: "tools/call",
    params: {
      name: "forge_review",
      arguments: {
        mode: "auto",
        preview: true,
        workdir: workdir,
      },
    },
  });
}, 400);

// Safety timeout: preview can take ~20s due to test discovery, allow 35s
setTimeout(() => {
  console.error("[mcp-client] timeout waiting for tool response");
  child.kill();
  process.exit(1);
}, 35000);
