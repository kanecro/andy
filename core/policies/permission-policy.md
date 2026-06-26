# Permission Policy

## Default deny for dangerous actions

Never run or recommend without explicit user approval:

- `rm -rf` on broad paths
- force push
- hard reset
- deleting branches/remotes/repos
- applying or destroying infrastructure
- publishing packages
- reading secrets or private keys
- modifying `.env` or secret files

## Long-running processes

Do not start a foreground server that blocks the session. Use a background session or ask the user for their preferred process manager.

## Environment restart safety

Before running commands that stop, restart, or replace the environment the agent is running in, determine whether it may end the current session. If it might, warn the user and let them run it manually.
