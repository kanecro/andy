# Context Isolation Policy

## Coordinator responsibilities

- Understand user goal
- Read high-level artifacts
- Decompose tasks
- Assign worker roles and write scopes
- Integrate results
- Run verification
- Escalate user decisions

## Coordinator should avoid

- Reading excessive implementation files when a worker can explore them
- Editing files owned by workers during parallel execution
- Reverting worker changes without reviewing ownership and intent
- Carrying long raw logs in context when a summary artifact can be written

## Worker handoff must include

- Task goal
- Relevant artifacts to read
- Allowed write scope
- Forbidden paths
- Required skills/policies
- Verification command or expected proof
- Output format

## Parallel worker rule

Workers are not alone in the codebase. They must not revert, overwrite, or reformat files outside their assigned ownership. If overlap is required, stop and escalate to coordinator.
