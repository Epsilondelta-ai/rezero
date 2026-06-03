import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawn } from "node:child_process";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const pluginRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const playerScript = resolve(pluginRoot, "bin", "rezero-play-bgm.js");

function isReturnByDeathCommand(command: string): boolean {
	return /(?:^|[\n;&|()])\s*git\s+reset\s+--hard\s+HEAD(?:\s|$|[;&|()])/m.test(command);
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return;

		const input = event.input as { command?: unknown };
		const command = typeof input.command === "string" ? input.command : "";
		if (!isReturnByDeathCommand(command)) return;

		try {
			const child = spawn(process.execPath, [playerScript], {
				cwd: ctx.cwd,
				detached: true,
				stdio: ["pipe", "ignore", "ignore"],
				windowsHide: true,
				env: {
					...process.env,
					PLUGIN_ROOT: pluginRoot,
					CLAUDE_PLUGIN_ROOT: pluginRoot,
				},
			});

			child.stdin.end(JSON.stringify({
				cwd: ctx.cwd,
				hook_event_name: "PreToolUse",
				tool_name: "Bash",
				tool_input: { command },
			}));
			child.unref();
		} catch {
			// Audio is best-effort and must never block Return by Death.
		}
	});
}
