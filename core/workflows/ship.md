# Workflow: ship

## Goal

Run the full lifecycle with approval gates.

## Pipeline

```text
brainstorm → approval → spec → approval → implement → review → test → compound
```

## Rules

- Do not skip approval after brainstorm/spec.
- Stop after three repeated verification failures and ask user.
- Do not commit or push unless the user asks.
- At the end, present changed files, verification, and next steps.


## Common rules

- Follow `core/policies/escalation-policy.md`.
- Follow `core/policies/verification-policy.md` before claiming completion.
- Keep changes minimal and scoped.
- Write artifacts to the project, not to root ad-hoc notes, unless requested.

