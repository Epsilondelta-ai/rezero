#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawn, spawnSync } = require("node:child_process");

const THROTTLE_MS = 8_000;

function readHookInput() {
  try {
    const raw = fs.readFileSync(0, "utf8");
    if (!raw.trim()) return {};
    try {
      return JSON.parse(raw);
    } catch {
      return { raw };
    }
  } catch {
    return {};
  }
}

function getCommand(input) {
  return String(
    input?.tool_input?.command ??
    input?.toolInput?.command ??
    input?.tool?.input?.command ??
    input?.command ??
    input?.raw ??
    "",
  );
}

function isReturnByDeathCommand(command) {
  if (!command) return false;
  return /(?:^|[\n;&|()])\s*git\s+reset\s+--hard\s+HEAD(?:\s|$|[;&|()])/m.test(command);
}

function findProjectRoot(input) {
  const candidates = [
    input?.cwd,
    process.env.CLAUDE_PROJECT_DIR,
    process.env.CODEX_PROJECT_DIR,
    process.env.PWD,
    process.cwd(),
  ].filter(Boolean);

  for (const candidate of candidates) {
    try {
      const resolved = path.resolve(String(candidate));
      if (fs.existsSync(resolved)) return resolved;
    } catch {
      // ignore invalid paths
    }
  }

  return process.cwd();
}

function hasDeathEvidence(projectRoot, command) {
  if (/\.rezero\/memory\/subaru-deaths\.md|\.rezero\\memory\\subaru-deaths\.md/.test(command)) {
    return true;
  }

  const memoryPath = path.join(projectRoot, ".rezero", "memory", "subaru-deaths.md");
  return fs.existsSync(memoryPath);
}

function isTruthy(value) {
  if (value === undefined || value === null) return false;
  const normalized = String(value).trim().toLowerCase();
  return !["", "0", "false", "no", "off"].includes(normalized);
}

function isFalseyOption(value) {
  if (value === false) return true;
  if (value === undefined || value === null) return false;
  const normalized = String(value).trim().toLowerCase();
  return ["0", "false", "no", "off", "disabled"].includes(normalized);
}

function readBgmOption(config) {
  for (const key of ["bgm", "playBgm", "returnByDeathBgm"]) {
    if (Object.prototype.hasOwnProperty.call(config, key)) return config[key];
  }
  return undefined;
}

function isBgmDisabled(projectRoot) {
  if (isTruthy(process.env.REZERO_BGM_DISABLE)) return true;
  if (isFalseyOption(process.env.REZERO_BGM)) return true;

  const configPaths = [
    path.join(projectRoot, ".rezero", "memory", "config.json"),
    path.join(projectRoot, ".rezero", "config.json"),
  ];

  for (const configPath of configPaths) {
    try {
      const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
      const value = readBgmOption(config);
      if (isFalseyOption(value)) return true;
      if (isTruthy(value)) return false;
    } catch {
      // Missing or invalid config does not disable BGM.
    }
  }

  return false;
}

function getPluginRoot() {
  const candidates = [
    process.env.PLUGIN_ROOT,
    process.env.CLAUDE_PLUGIN_ROOT,
    path.resolve(__dirname, ".."),
  ].filter(Boolean);

  for (const candidate of candidates) {
    try {
      const resolved = path.resolve(String(candidate));
      if (fs.existsSync(path.join(resolved, "assets", "bgm.mp3"))) return resolved;
    } catch {
      // ignore invalid paths
    }
  }

  return path.resolve(__dirname, "..");
}

function shellQuote(value) {
  return `'${String(value).replace(/'/g, `'\\''`)}'`;
}

function commandExists(command) {
  const result = process.platform === "win32"
    ? spawnSync("where", [command], { stdio: "ignore" })
    : spawnSync("sh", ["-c", `command -v ${shellQuote(command)} >/dev/null 2>&1`], { stdio: "ignore" });
  return result.status === 0;
}

function choosePlayer(audioPath) {
  if (process.platform === "darwin") {
    if (commandExists("afplay")) return { command: "afplay", args: [audioPath] };
  }

  if (process.platform === "win32") {
    const escaped = audioPath.replace(/'/g, "''");
    return {
      command: "powershell.exe",
      args: [
        "-NoProfile",
        "-WindowStyle",
        "Hidden",
        "-Command",
        `Add-Type -AssemblyName PresentationCore; $m=New-Object System.Windows.Media.MediaPlayer; $m.Open([Uri]'${escaped}'); $m.Play(); Start-Sleep -Seconds 30`,
      ],
    };
  }

  const fallbacks = [
    { command: "mpg123", args: ["-q", audioPath] },
    { command: "mpv", args: ["--no-video", "--really-quiet", audioPath] },
    { command: "ffplay", args: ["-nodisp", "-autoexit", "-loglevel", "quiet", audioPath] },
    { command: "paplay", args: [audioPath] },
  ];

  return fallbacks.find((candidate) => commandExists(candidate.command));
}

function shouldThrottle(dataDir) {
  try {
    fs.mkdirSync(dataDir, { recursive: true });
    const stampPath = path.join(dataDir, "last-bgm-played");
    const now = Date.now();
    const last = Number(fs.readFileSync(stampPath, "utf8"));
    if (Number.isFinite(last) && now - last < THROTTLE_MS) return true;
    fs.writeFileSync(stampPath, String(now));
    return false;
  } catch {
    return false;
  }
}

function debug(message) {
  if (process.env.REZERO_BGM_DEBUG) {
    process.stderr.write(`[rezero-bgm] ${message}\n`);
  }
}

function main() {
  const input = readHookInput();
  const command = getCommand(input);

  if (!isReturnByDeathCommand(command)) {
    debug("not a Return by Death command");
    return;
  }

  const projectRoot = findProjectRoot(input);
  if (isBgmDisabled(projectRoot)) {
    debug("BGM disabled");
    return;
  }

  if (!hasDeathEvidence(projectRoot, command)) {
    debug("death memory missing; skipping to avoid playing on ordinary git reset");
    return;
  }

  const pluginRoot = getPluginRoot();
  const audioPath = path.join(pluginRoot, "assets", "bgm.mp3");
  if (!fs.existsSync(audioPath)) {
    debug(`missing audio: ${audioPath}`);
    return;
  }

  const player = choosePlayer(audioPath);
  if (!player) {
    debug("no supported audio player found");
    return;
  }

  if (process.env.REZERO_BGM_DRY_RUN) {
    debug(`dry run: would start ${player.command}`);
    return;
  }

  const dataDir = process.env.PLUGIN_DATA || process.env.CLAUDE_PLUGIN_DATA || path.join(os.tmpdir(), "rezero-bgm");
  if (shouldThrottle(dataDir)) {
    debug("throttled");
    return;
  }

  try {
    const child = spawn(player.command, player.args, {
      stdio: "ignore",
      detached: true,
      windowsHide: true,
    });
    child.unref();
    debug(`started ${player.command}`);
  } catch (error) {
    debug(`failed to start player: ${error.message}`);
  }
}

main();
