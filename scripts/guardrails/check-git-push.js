#!/usr/bin/env node
const input = process.argv.slice(2).join(' ');
let command = input;
try { const parsed = JSON.parse(input); command = parsed.command || input; } catch {}
if (!/\bgit\s+push\b/.test(command)) process.exit(0);
if (/\bgit\s+push\b.*\s(--force|-f)\b/.test(command)) {
  console.error(`BLOCKED: force push requires explicit user confirmation: ${command}`);
  process.exit(2);
}
console.error('WARNING: git push detected. Ensure review and tests are complete.');
process.exit(0);
