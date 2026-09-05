import { describe, it, expect } from "vitest";
import { spawn, type ChildProcess } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";
import fs from "node:fs";
import os from "node:os";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const SERVER_JS = path.resolve(__dirname, "..", "dist", "server.js");

type RpcResp = { jsonrpc: string; id?: number | string | null; result?: unknown; error?: unknown };

function createHarness() {
  const child: ChildProcess = spawn("node", [SERVER_JS], { stdio: ["pipe", "pipe", "pipe"], env: process.env });
  let buf = ""; let stderr = "";
  const pending = new Map<number | string, (m: RpcResp) => void>();
  child.stderr?.on("data", (d: Buffer) => { stderr += d.toString(); });
  child.stdout?.on("data", (d: Buffer) => {
    buf += d.toString("utf-8");
    let idx: number;
    while ((idx = buf.indexOf("\n")) !== -1) {
      const line = buf.slice(0, idx).trim(); buf = buf.slice(idx + 1);
      if (!line) continue;
      try {
        const msg = JSON.parse(line) as RpcResp;
        if (msg.id != null && pending.has(msg.id as number)) { const cb = pending.get(msg.id as number)!; pending.delete(msg.id as number); cb(msg); }
      } catch { /* ignore */ }
    }
  });
  const send = (m: unknown) => child.stdin?.write(JSON.stringify(m) + "\n");
  const request = <T>(m: unknown, t = 8000) => new Promise<RpcResp & { result: T }>((res, rej) => {
    const id = (m as { id: number }).id;
    const timer = setTimeout(() => { pending.delete(id); rej(new Error(`timeout id=${id} stderr=${stderr.slice(0, 500)}`)); }, t);
    pending.set(id, (r) => { clearTimeout(timer); res(r as RpcResp & { result: T }); });
    send(m);
  });
  const close = () => { child.stdin?.end(); child.kill(); };
  return { send, request, close };
}

async function initialize(h: ReturnType<typeof createHarness>) {
  await h.request({ jsonrpc: "2.0", id: 1, method: "initialize", params: { protocolVersion: "2024-11-05", capabilities: {}, clientInfo: { name: "test", version: "1.0.0" } } });
  h.send({ jsonrpc: "2.0", method: "notifications/initialized" });
  await new Promise((r) => setTimeout(r, 100));
}

describe("stdio JSON-RPC harness (initialize → tools/list → tools/call)", () => {
  it("server.js exists (built artifact)", () => { expect(fs.existsSync(SERVER_JS)).toBe(true); });

  it("initialize handshake returns serverInfo forge-standard", async () => {
    const h = createHarness();
    try {
      const res = await h.request<{ protocolVersion: string; serverInfo: { name: string; version: string } }>({ jsonrpc: "2.0", id: 1, method: "initialize", params: { protocolVersion: "2024-11-05", capabilities: {}, clientInfo: { name: "test", version: "1.0.0" } } });
      expect(res.result.serverInfo.name).toBe("forge-standard");
      expect(res.result.serverInfo.version).toMatch(/\d+\.\d+\.\d+/);
      h.send({ jsonrpc: "2.0", method: "notifications/initialized" });
    } finally { h.close(); }
  });

  it("tools/list count >=1 and includes forge_review (CONTRIBUTING example: npm test must surface tool)", async () => {
    const h = createHarness();
    try {
      await initialize(h);
      const res = await h.request<{ tools: { name: string; description: string; inputSchema: unknown }[] }>({ jsonrpc: "2.0", id: 2, method: "tools/list", params: {} });
      expect(res.result.tools.length).toBeGreaterThanOrEqual(1);
      const forge = res.result.tools.find((t) => t.name === "forge_review");
      expect(forge).toBeDefined();
      expect(forge!.description).toMatch(/review\.sh|forge/i);
      const schema = forge!.inputSchema as { properties: Record<string, unknown> };
      expect(schema.properties).toHaveProperty("workdir");
      expect(schema.properties).toHaveProperty("mode");
    } finally { h.close(); }
  });

  it("tools/call forge_review with preview + workdir returns text content (quote paths, workdir param)", async () => {
    const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "forge-stdio-"));
    const h = createHarness();
    try {
      await initialize(h);
      const res = await h.request<{ content: { type: string; text: string }[] }>(
        { jsonrpc: "2.0", id: 3, method: "tools/call", params: { name: "forge_review", arguments: { mode: "auto", preview: true, workdir: tmpDir } } }, 12000);
      expect(res.result.content[0].type).toBe("text");
      expect(res.result.content[0].text).toContain(`workdir: ${path.resolve(tmpDir)}`);
      expect(res.result.content[0].text).toMatch(/exitCode:/);
    } finally { h.close(); fs.rmSync(tmpDir, { recursive: true, force: true }); }
  });

  it("tools/call unknown tool returns JSON-RPC error", async () => {
    const h = createHarness();
    try {
      await initialize(h);
      const res = await h.request({ jsonrpc: "2.0", id: 5, method: "tools/call", params: { name: "unknown_tool", arguments: {} } });
      expect(res.error ?? res.result).toBeDefined();
      if (res.error) expect(res.error).toBeDefined();
      else expect((res.result as { isError?: boolean }).isError).toBe(true);
    } finally { h.close(); }
  });

  it("workdir with spaces is handled (quote paths)", async () => {
    const base = fs.mkdtempSync(path.join(os.tmpdir(), "forge-stdio-"));
    const spaced = path.join(base, "with spaces"); fs.mkdirSync(spaced);
    const h = createHarness();
    try {
      await initialize(h);
      const res = await h.request<{ content: { type: string; text: string }[] }>(
        { jsonrpc: "2.0", id: 3, method: "tools/call", params: { name: "forge_review", arguments: { mode: "auto", preview: true, workdir: spaced } } }, 12000);
      expect(res.result.content[0].text).toContain(`workdir: ${path.resolve(spaced)}`);
    } finally { h.close(); fs.rmSync(base, { recursive: true, force: true }); }
  });
});
