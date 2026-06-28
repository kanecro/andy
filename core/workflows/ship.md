# Workflow: ship

## Goal

Run the full lifecycle with approval gates.

## Pipeline

```text
brainstorm → approval → spec → approval → implement → review → test → compound
```

## Short command input

When invoked as `ship issue #123`, follow `core/workflows/command-router.md` to resolve the issue, then run the pipeline using that issue as the brainstorm input.

When invoked as `ship <topic>`, use the topic as the brainstorm input.

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
