import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
// These unit tests cover the forge_review tool handler per CONTRIBUTING example:
//   bash -n scripts/*.sh
//   npx tsc --noEmit
//   npm test
// Paths are quoted, workdir param is validated and passed via path.resolve + cwd.
// Helpers under test are pure (buildReviewArgs, FORGE_REVIEW_TOOL shape)
// Handler tests mock spawn per javascript-typescript-jest mocking guidelines (vi.mock + Events).
import { buildReviewArgs, FORGE_REVIEW_TOOL, handleForgeReview, resolveRepoRoot, } from "../src/server.js";
// --- mock node:child_process spawn per vitest mocking ---
vi.mock("node:child_process", async () => {
    const actual = await vi.importActual("node:child_process");
    return {
        ...actual,
        spawn: vi.fn(),
    };
});
import { spawn } from "node:child_process";
import { EventEmitter } from "node:events";
import * as fs from "node:fs";
import path from "node:path";
import os from "node:os";
const mockedSpawn = vi.mocked(spawn);
function makeMockChild(opts = {}) {
    const child = new EventEmitter();
    const stdout = new EventEmitter();
    const stderr = new EventEmitter();
    child.stdout = stdout;
    child.stderr = stderr;
    // Emit data/close asynchronously after spawn call so handler's listeners are attached
    setImmediate(() => {
        if (opts.error) {
            child.emit("error", opts.error);
            return;
        }
        if (opts.stdout)
            stdout.emit("data", Buffer.from(opts.stdout));
        if (opts.stderr)
            stderr.emit("data", Buffer.from(opts.stderr));
        child.emit("close", opts.exitCode ?? 0);
    });
    return child;
}
describe("FORGE_REVIEW_TOOL schema", () => {
    it("exposes forge_review with required inputSchema fields including workdir", () => {
        expect(FORGE_REVIEW_TOOL.name).toBe("forge_review");
        expect(FORGE_REVIEW_TOOL.inputSchema.type).toBe("object");
        const props = FORGE_REVIEW_TOOL.inputSchema.properties;
        expect(props).toHaveProperty("mode");
        expect(props).toHaveProperty("range");
        expect(props).toHaveProperty("file");
        expect(props).toHaveProperty("preview");
        expect(props).toHaveProperty("workdir");
        // mode enum covers CONTRIBUTING git diff modes
        const modeProp = props.mode;
        expect(modeProp.enum).toEqual(expect.arrayContaining(["auto", "staged", "range", "file"]));
    });
    it("required is empty (all params optional per mcp.json)", () => {
        expect(FORGE_REVIEW_TOOL.inputSchema.required).toEqual([]);
    });
});
describe("buildReviewArgs", () => {
    it("staged mode maps to --staged", () => {
        expect(buildReviewArgs({ mode: "staged" })).toEqual(["--staged"]);
    });
    it("staged + preview appends --preview", () => {
        expect(buildReviewArgs({ mode: "staged", preview: true })).toEqual(["--staged", "--preview"]);
    });
    it("range mode with range string", () => {
        expect(buildReviewArgs({ mode: "range", range: "HEAD~1..HEAD" })).toEqual([
            "--range",
            "HEAD~1..HEAD",
        ]);
    });
    it("range mode without range yields [] (auto fallback inside review.sh)", () => {
        expect(buildReviewArgs({ mode: "range" })).toEqual([]);
    });
    it("file mode with file path (quote paths)", () => {
        const file = "path/with spaces/file.ts";
        expect(buildReviewArgs({ mode: "file", file })).toEqual(["--file", file]);
    });
    it("file mode without file yields []", () => {
        expect(buildReviewArgs({ mode: "file" })).toEqual([]);
    });
    it("auto mode default yields [] (empty args = auto)", () => {
        expect(buildReviewArgs({})).toEqual([]);
        expect(buildReviewArgs({ mode: "auto" })).toEqual([]);
    });
    it("auto with preview yields --preview", () => {
        expect(buildReviewArgs({ mode: "auto", preview: true })).toEqual(["--preview"]);
    });
    it("auto with bare range shorthand appends --range (CONTRIBUTING range example)", () => {
        expect(buildReviewArgs({ mode: "auto", range: "main...feature" })).toEqual([
            "--range",
            "main...feature",
        ]);
    });
    it("auto range not duplicated when already present", () => {
        expect(buildReviewArgs({ mode: "range", range: "HEAD~1..HEAD" })).toEqual([
            "--range",
            "HEAD~1..HEAD",
        ]);
    });
    it("quotes/special chars in range preserved as single arg (spawn no shell)", () => {
        const range = "origin/main...HEAD";
        const args = buildReviewArgs({ mode: "range", range });
        expect(args[1]).toBe(range);
    });
});
describe("resolveRepoRoot", () => {
    it("resolves to a directory containing scripts/review.sh", () => {
        const root = resolveRepoRoot();
        expect(fs.existsSync(path.join(root, "scripts", "review.sh"))).toBe(true);
    });
});
describe("handleForgeReview (forge_review tool handler) with spawn mocking", () => {
    let tmpDir;
    beforeEach(() => {
        vi.clearAllMocks();
        tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "forge-mcp-"));
    });
    afterEach(() => {
        fs.rmSync(tmpDir, { recursive: true, force: true });
    });
    it("success exitCode 0 returns isError false and includes STDOUT + workdir + args", async () => {
        mockedSpawn.mockImplementation(() => makeMockChild({ stdout: "score: 8\n", exitCode: 0 }));
        const res = await handleForgeReview({ mode: "staged", workdir: tmpDir });
        expect(mockedSpawn).toHaveBeenCalledTimes(1);
        // workdir param is resolved and quoted via path.resolve + cwd param
        const callArgs = mockedSpawn.mock.calls[0];
        expect(callArgs[0]).toBe("bash");
        expect(callArgs[1][0]).toMatch(/review\.sh$/);
        expect(callArgs[1]).toContain("--staged");
        expect(callArgs[2].cwd).toBe(path.resolve(tmpDir));
        expect(res.isError).toBe(false);
        expect(res.content[0].text).toContain("STDOUT:");
        expect(res.content[0].text).toContain("score: 8");
        expect(res.content[0].text).toContain(`workdir: ${path.resolve(tmpDir)}`);
        expect(res.content[0].text).toContain("exitCode: 0");
    });
    it("non-zero exitCode returns isError true and includes stderr", async () => {
        mockedSpawn.mockImplementation(() => makeMockChild({ stderr: "some error", exitCode: 2 }));
        const res = await handleForgeReview({ workdir: tmpDir });
        expect(res.isError).toBe(true);
        expect(res.content[0].text).toContain("STDERR:");
        expect(res.content[0].text).toContain("exitCode: 2");
    });
    it("spawn error emits isError true (child error event)", async () => {
        mockedSpawn.mockImplementation(() => makeMockChild({ error: new Error("spawn ENOENT"), exitCode: 1 }));
        const res = await handleForgeReview({ workdir: tmpDir });
        expect(res.isError).toBe(true);
        expect(res.content[0].text).toContain("spawn ENOENT");
    });
    it("workdir does not exist returns isError true without spawning", async () => {
        const bad = path.join(tmpDir, "nope", "missing");
        const res = await handleForgeReview({ workdir: bad });
        expect(res.isError).toBe(true);
        expect(res.content[0].text).toMatch(/workdir does not exist/);
        expect(mockedSpawn).not.toHaveBeenCalled();
    });
    it("preview flag forwarded as --preview (CONTRIBUTING preview example)", async () => {
        mockedSpawn.mockImplementation(() => makeMockChild({ stdout: "preview diff", exitCode: 0 }));
        const res = await handleForgeReview({ mode: "staged", preview: true, workdir: tmpDir });
        const args = mockedSpawn.mock.calls[0][1];
        expect(args).toContain("--preview");
        expect(res.isError).toBe(false);
    });
    it("range mode with quoted range forwards correctly", async () => {
        mockedSpawn.mockImplementation(() => makeMockChild({ stdout: "ok", exitCode: 0 }));
        const range = "HEAD~1..HEAD";
        await handleForgeReview({ mode: "range", range, workdir: tmpDir });
        const args = mockedSpawn.mock.calls[0][1];
        expect(args).toEqual(expect.arrayContaining(["--range", range]));
    });
    it("file mode with spaces in path forwarded as single arg (quoting)", async () => {
        mockedSpawn.mockImplementation(() => makeMockChild({ stdout: "ok", exitCode: 0 }));
        const file = "path/with spaces/file.ts";
        await handleForgeReview({ mode: "file", file, workdir: tmpDir });
        const args = mockedSpawn.mock.calls[0][1];
        expect(args).toContain("--file");
        const idx = args.indexOf("--file");
        expect(args[idx + 1]).toBe(file);
    });
    it("workdir param uses path.resolve (absolute) and spawn cwd is resolved", async () => {
        mockedSpawn.mockImplementation(() => makeMockChild({ stdout: "ok", exitCode: 0 }));
        // relative workdir resolves against cwd; we pass tmpDir already absolute
        const res = await handleForgeReview({ workdir: tmpDir });
        const cwd = mockedSpawn.mock.calls[0][2].cwd;
        expect(path.isAbsolute(cwd)).toBe(true);
        expect(res.content[0].text).toContain(`workdir: ${path.resolve(tmpDir)}`);
    });
});
//# sourceMappingURL=server.test.js.map