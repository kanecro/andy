# Workflow: review

## Goal

Review implementation against specification, design intent, quality, and risk.

## Inputs

- Delta spec
- Design
- Changed file summary
- Test/static analysis results

## Outputs

- `openspec/changes/<change-name>/reviews/review-summary.md`

## Roles

- spec-compliance-reviewer
- doc-sync-reviewer
- risk-specific reviewers
- review-aggregator

## Steps

1. Run mechanical checks first where possible.
2. Select reviewers based on risk and changed files.
3. Give each reviewer spec/design context.
4. Reviewers produce findings with severity and confidence.
5. Aggregator deduplicates and builds coverage matrix.
6. P1 issues must be fixed or escalated.
7. P2 decisions are presented to user unless clearly in scope.
8. Record review summary.


## Common rules

- Follow `core/policies/escalation-policy.md`.
- Follow `core/policies/verification-policy.md` before claiming completion.
- Keep changes minimal and scoped.
- Write artifacts to the project, not to root ad-hoc notes, unless requested.

