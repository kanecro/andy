# Workflow: test

## Goal

Prove the change works at the appropriate verification level.

## Levels

- L1: unit/static/build
- L2: integration/E2E
- L3: acceptance against user stories

## Steps

1. Detect available project commands.
2. Run L1 always when code changed.
3. Run L2 if integration/E2E assets exist or boundary changed.
4. Run L3 if proposal/design acceptance scenarios exist.
5. On failure, use systematic debugging.
6. Do not disable tests to pass.
7. Report command outputs and residual risk.


## Common rules

- Follow `core/policies/escalation-policy.md`.
- Follow `core/policies/verification-policy.md` before claiming completion.
- Keep changes minimal and scoped.
- Write artifacts to the project, not to root ad-hoc notes, unless requested.

