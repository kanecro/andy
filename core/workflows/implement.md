# Workflow: implement

## Goal

Implement approved tasks with minimal change and verifiable behavior.

## Inputs

- `design.md`
- `tasks.md`
- `delta-spec.md`
- `traceability.md`

## Roles

- coordinator
- implementer
- build-error-resolver
- spec-compliance-reviewer

## Steps

1. Coordinator reads high-level artifacts and decomposes tasks.
2. Determine parallelizable tasks and assign disjoint write scopes.
3. Each implementer reads relevant artifacts and code context.
4. Each implementer writes a spec interpretation note before coding when behavior is non-trivial.
5. Follow TDD for behavior changes.
6. Update traceability best-effort.
7. Run relevant verification.
8. Run spec compliance review.
9. Summarize changes and evidence.

## Worker handoff template

```markdown
TASK: [task]
ROLE: implementer
READ:
- [artifact paths]
WRITE SCOPE:
- [allowed files/dirs]
DO NOT TOUCH:
- [forbidden files/dirs]
SKILLS:
- test-driven-development
- iterative-retrieval
- verification-before-completion
COMPLETION:
- tests/typecheck/lint evidence
- changed files summary
```


## Common rules

- Follow `core/policies/escalation-policy.md`.
- Follow `core/policies/verification-policy.md` before claiming completion.
- Keep changes minimal and scoped.
- Write artifacts to the project, not to root ad-hoc notes, unless requested.

