#!/usr/bin/env node
const input = process.argv.slice(2).join(' ');
let command = input;
try { const parsed = JSON.parse(input); command = parsed.command || input; } catch {}
const blockers = [
  /\brm\s+-rf\s+(\/|~|\.\.?\/?|\*)/,
  /\bgit\s+reset\s+--hard\b/,
  /\bgit\s+push\b.*\s(--force|-f)\b/,
  /\bnpm\s+publish\b/,
  /\bterraform\s+(apply|destroy)\b/,
  /\bgh\s+repo\s+delete\b/
];
for (const re of blockers) {
  if (re.test(command)) {
    console.error(`BLOCKED dangerous command: ${command}`);
    process.exit(2);
  }
}
const serverPatterns = [/\bnpm\s+run\s+dev\b/, /\bnpm\s+start\b/, /\bnpx\s+next\s+dev\b/, /\bnext\s+dev\b/, /\bnext\s+start\b/];
if (serverPatterns.some(re => re.test(command)) && !/\btmux\b|\bnohup\b|\&\s*$/.test(command)) {
  console.error(`WARNING: long-running server command may block the session: ${command}`);
}
process.exit(0);
