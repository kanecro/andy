# Verification Policy

## Iron rule

No completion claim without fresh evidence.

## Before claiming success

1. Identify what proves the claim.
2. Run the relevant command or inspection.
3. Read the output and exit status.
4. Report the evidence.

## Typical verification levels

| Level | Use when | Checks |
|---|---|---|
| L1 Unit | local code change | unit tests, typecheck, lint |
| L2 Integration | module/API boundary | integration/E2E tests |
| L3 Acceptance | user-facing behavior | acceptance scenario from proposal/design |

## If verification cannot be run

Say why, state what was checked instead, and mark residual risk clearly.
