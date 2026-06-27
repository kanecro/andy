#!/usr/bin/env node
const input = process.argv[2] || '{}';
let data;
try { data = JSON.parse(input); } catch { data = { file_path: input }; }
const filePath = data.file_path || data.path || '';
if (!filePath) process.exit(0);
const allowedDirs = ['/docs/', '/openspec/', '/.andy/'];
if (allowedDirs.some(d => filePath.includes(d))) process.exit(0);
const fileName = filePath.split('/').pop() || '';
const isDoc = /\.(md|txt)$/i.test(fileName);
const sourceDirs = ['src','lib','app','components','utils','hooks','types','config','test','tests','__tests__'];
const inSource = filePath.split('/').some(part => sourceDirs.includes(part));
if (isDoc && !inSource) {
  console.error(`BLOCKED: ad-hoc documentation file outside docs/ or openspec/: ${filePath}`);
  process.exit(2);
}
process.exit(0);
