#!/usr/bin/env node
import { spawn } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema, } from "@modelcontextprotocol/sdk/types.js";
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
export function getVersionSync() {
    const candidates = [
        path.resolve(__dirname, "..", "package.json"),
        path.resolve(__dirname, "..", "..", "package.json"),
    ];
    for (const p of candidates) {
        try {
            if (existsSync(p)) {
                const txt = readFileSync(p, "utf-8");
                const j = JSON.parse(txt);
                if (j.version && typeof j.version === "string")
                    return j.version;
            }
        }
        catch {
            // ignore
        }
    }
    return "1.0.0";
}
export const VERSION = getVersionSync();
export const FORGE_REVIEW_TOOL = {
    name: "forge_review",
    description: "Run forge-standard review loop (wraps scripts/review.sh). Supports staged, range, and file modes with ranked report critical->high->medium->low->nitpick. Local only, no network.",
    inputSchema: {
        type: "object",
        properties: {
            mode: {
                type: "string",
                enum: ["auto", "staged", "range", "file"],
                description: "Review mode: staged (git diff --cached), range (commit range), file (single file), auto (staged else BASE...HEAD)",
            },
            range: {
                type: "string",
                description: "Git range for range mode, e.g. HEAD~1..HEAD or main...feature",
            },
            file: {
                type: "string",
                description: "File path for file mode, e.g. path/to/file.ts",
            },
            preview: {
                type: "boolean",
                description: "If true, only preview the diff without running the loop",
            },
            workdir: {
                type: "string",
                description: "Working directory to run review in (defaults to repo root)",
            },
        },
        required: [],
    },
};
export const server = new Server({
    name: "forge-standard",
    version: VERSION,
}, {
    capabilities: {
        tools: {},
    },
});
server.setRequestHandler(ListToolsRequestSchema, async () => {
    return {
        tools: [FORGE_REVIEW_TOOL],
    };
});
export function resolveRepoRoot() {
    // mcp/src/server.ts -> mcp/dist/server.js at runtime; repo root is two levels up from mcp/
    // dist is inside mcp/, so __dirname is mcp/dist, repo root is ../../
    const fromDist = path.resolve(__dirname, "..", "..");
    // Also handle running via tsx from src: __dirname is mcp/src, repo root is ../..
    // Both resolve to same logical root; prefer the one that contains scripts/review.sh
    const candidates = [
        path.resolve(__dirname, "..", ".."),
        path.resolve(__dirname, "..", "..", ".."),
        process.cwd(),
    ];
    for (const c of candidates) {
        if (existsSync(path.join(c, "scripts", "review.sh")))
            return c;
    }
    return fromDist;
}
export function buildReviewArgs(args) {
    const out = [];
    const mode = args.mode ?? "auto";
    if (mode === "staged") {
        out.push("--staged");
    }
    else if (mode === "range") {
        if (args.range && args.range.length > 0) {
            out.push("--range", args.range);
        }
        else {
            // fallback to auto range logic inside review.sh
            // no extra arg means auto
        }
    }
    else if (mode === "file") {
        if (args.file && args.file.length > 0) {
            out.push("--file", args.file);
        }
    }
    else if (mode !== "auto") {
        // unknown mode -> treat as auto
    }
    if (args.preview)
        out.push("--preview");
    // Bare range shorthand: if mode auto but range supplied, treat as range
    if (mode === "auto" && args.range && !out.includes("--range")) {
        out.push("--range", args.range);
    }
    return out;
}
export function runReviewScript(scriptPath, scriptArgs, workdir) {
    return new Promise((resolve) => {
        const child = spawn("bash", [scriptPath, ...scriptArgs], {
            cwd: workdir,
            env: process.env,
            stdio: ["ignore", "pipe", "pipe"],
        });
        let stdout = "";
        let stderr = "";
        child.stdout?.on("data", (d) => {
            stdout += d.toString("utf-8");
        });
        child.stderr?.on("data", (d) => {
            stderr += d.toString("utf-8");
        });
        child.on("error", (err) => {
            resolve({ stdout, stderr: stderr + String(err), exitCode: 1 });
        });
        child.on("close", (code) => {
            resolve({ stdout, stderr, exitCode: code });
        });
    });
}
export async function handleForgeReview(rawArgs) {
    const typed = (rawArgs ?? {});
    const repoRoot = resolveRepoRoot();
    const workdir = typed.workdir ? path.resolve(typed.workdir) : repoRoot;
    // Validate workdir exists and is a directory
    if (!existsSync(workdir)) {
        return {
            content: [
                {
                    type: "text",
                    text: `workdir does not exist: ${workdir}`,
                },
            ],
            isError: true,
        };
    }
    const scriptPath = path.join(repoRoot, "scripts", "review.sh");
    if (!existsSync(scriptPath)) {
        return {
            content: [
                {
                    type: "text",
                    text: `review.sh not found at ${scriptPath} (repoRoot=${repoRoot})`,
                },
            ],
            isError: true,
        };
    }
    const scriptArgs = buildReviewArgs(typed);
    const result = await runReviewScript(scriptPath, scriptArgs, workdir);
    const combined = [
        result.stdout ? `STDOUT:\n${result.stdout}` : "",
        result.stderr ? `STDERR:\n${result.stderr}` : "",
        `exitCode: ${String(result.exitCode)}`,
        `workdir: ${workdir}`,
        `args: ${scriptArgs.join(" ") || "(auto)"}`,
    ]
        .filter(Boolean)
        .join("\n\n");
    // Also surface .forge-standard/run-*.log and review artifacts if present
    let extra = "";
    try {
        const logDir = path.join(workdir, ".forge-standard");
        if (existsSync(logDir)) {
            extra = `\n\nArtifacts in ${logDir} (learning.md, run-*.log, state.json)`;
        }
    }
    catch {
        // ignore
    }
    return {
        content: [
            {
                type: "text",
                text: combined + extra,
            },
        ],
        isError: result.exitCode !== 0,
    };
}
server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;
    if (name !== "forge_review") {
        throw new Error(`Unknown tool: ${name}`);
    }
    return handleForgeReview(args);
});
export async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
}
// Only auto-start when executed directly (not when imported in tests)
const isDirectRun = process.argv[1] != null &&
    (process.argv[1].endsWith("server.js") || process.argv[1].endsWith("server.ts"));
if (isDirectRun) {
    main().catch((err) => {
        console.error("forge-standard MCP server failed to start:", err);
        process.exit(1);
    });
}
//# sourceMappingURL=server.js.map