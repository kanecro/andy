# Workflow: brainstorm

## Goal

Turn an initial idea into a small, testable proposal.

## Inputs

- User goal or topic
- Short command input such as `brainstorm issue #123`
- GitHub issue title/body/labels/comments when issue input is used
- Existing project context if available

## Outputs

- `openspec/changes/<change-name>/proposal.md`

## Steps

1. Ask one question at a time.
2. Prefer concrete choices over open-ended questioning.
3. Apply YAGNI; explicitly list out-of-scope items.
4. Check story quality with INVEST.
5. Ask how each story will be verified.
6. Generate proposal artifact.
7. Ask for user approval before moving to spec.

## Issue-backed brainstorm

When invoked as `brainstorm issue #123` or `brainstorm owner/repo#123`:

1. Follow `core/workflows/command-router.md` to resolve the issue.
2. Summarize the issue as the initial idea, preserving uncertainty instead of inventing requirements.
3. Derive the default change name as `issue-<number>-<short-kebab-title>`.
4. Write the proposal to `./openspec/changes/<change-name>/proposal.md` in the current target project.
5. Include the source issue URL and issue number in Technical Considerations or a short source note.
6. Ask only for missing product intent or verification details that are necessary before a useful proposal can be written.

## Proposal sections

- Intent
- User Stories
- Scope
- Out of Scope
- Technical Considerations
- Open Questions


## Common rules

- Follow `core/policies/escalation-policy.md`.
- Follow `core/policies/verification-policy.md` before claiming completion.
- Keep changes minimal and scoped.
- Write artifacts to the project, not to root ad-hoc notes, unless requested.
