#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");

const OFF_VALUES = new Set(["0", "false", "no", "off", "disable", "disabled"]);
const ON_VALUES = new Set(["1", "true", "yes", "on", "enable", "enabled"]);

function usage() {
  console.error("Usage: rezero-bgm <on|off|true|false>");
  process.exitCode = 2;
}

function readConfig(configPath) {
  try {
    const value = JSON.parse(fs.readFileSync(configPath, "utf8"));
    if (value && typeof value === "object" && !Array.isArray(value)) return value;
  } catch {
    // Missing or invalid config starts from an empty object.
  }
  return {};
}

function main() {
  const raw = process.argv[2];
  if (!raw) return usage();

  const normalized = String(raw).trim().toLowerCase();
  let enabled;
  if (ON_VALUES.has(normalized)) enabled = true;
  else if (OFF_VALUES.has(normalized)) enabled = false;
  else return usage();

  const rezeroDir = path.resolve(process.cwd(), ".rezero", "memory");
  const configPath = path.join(rezeroDir, "config.json");
  fs.mkdirSync(rezeroDir, { recursive: true });

  const config = readConfig(configPath);
  config.bgm = enabled;
  fs.writeFileSync(configPath, `${JSON.stringify(config, null, 2)}\n`);

  console.log(`Re:ZERO Return by Death BGM ${enabled ? "enabled" : "disabled"}.`);
  console.log(`Wrote ${path.relative(process.cwd(), configPath) || configPath}`);
}

main();
