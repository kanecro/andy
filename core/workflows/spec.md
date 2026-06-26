# Workflow: spec

## Goal

Convert an approved proposal into implementation-ready design, delta spec, task list, and traceability.

## Inputs

- `proposal.md`
- Existing specs under `openspec/specs/`
- Codebase patterns
- Relevant official docs/current references if needed
- Compound learnings

## Roles

- codebase-analyzer
- stack-docs-researcher
- web-researcher when current or external information matters
- compound-learnings-researcher
- spec-writer
- spec-validator

## Outputs

- `design.md`
- `tasks.md`
- `specs/<feature>/delta-spec.md`
- `traceability.md`

## Steps

1. Run research roles in parallel when independent.
2. Integrate findings into design.
3. Write behavior-centered delta spec using Given/When/Then.
4. Generate tasks with explicit verification and related requirement IDs.
5. Generate traceability matrix.
6. Run adversarial spec validation.
7. Resolve or escalate gaps.
8. Ask user approval before implementation.


## Common rules

- Follow `core/policies/escalation-policy.md`.
- Follow `core/policies/verification-policy.md` before claiming completion.
- Keep changes minimal and scoped.
- Write artifacts to the project, not to root ad-hoc notes, unless requested.

