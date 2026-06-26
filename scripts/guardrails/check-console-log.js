#!/usr/bin/env node
const fs = require('fs');
const input = process.argv[2] || '{}';
let data;
try { data = JSON.parse(input); } catch { data = { file_path: input }; }
const filePath = data.file_path || data.path || '';
if (!/\.(ts|tsx|js|jsx)$/.test(filePath)) process.exit(0);
if (!fs.existsSync(filePath)) process.exit(0);
const lines = fs.readFileSync(filePath, 'utf8').split('\n');
const hits = [];
lines.forEach((line, idx) => {
  if (/console\.log\s*\(/.test(line) && !line.trim().startsWith('//')) hits.push(idx + 1);
});
if (hits.length) {
  console.error(`WARNING: console.log detected in ${filePath}: lines ${hits.join(', ')}`);
}
process.exit(0);
