# Fugu Guardrail Map

| Event | Script | Policy |
|---|---|---|
| before writing a file | `scripts/guardrails/check-write-path.js` | no root ad-hoc docs |
| after writing source | `scripts/guardrails/check-console-log.js` | no debug console.log |
| before shell command | `scripts/guardrails/check-command.js` | long-running process + dangerous command policy |
| before push | `scripts/guardrails/check-git-push.js` | git push policy |

If Fugu does not support hook events, run these scripts as preflight checks in workflows or CI.
