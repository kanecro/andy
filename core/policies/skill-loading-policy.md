# Skill Loading Policy

## Principle

Candidate broadly, load narrowly.

- If a skill might apply, include it as a candidate.
- Actually load only the skills needed for the current phase, role, and file scope.
- Avoid making every worker read every skill.

## Phase defaults

| Phase | Skills |
|---|---|
| brainstorm | story-quality-gate, proposal-readiness-check |
| spec | iterative-retrieval, verification-before-completion |
| implement | test-driven-development, iterative-retrieval, verification-before-completion |
| debug | systematic-debugging, verification-before-completion |
| review | iterative-retrieval, verification-before-completion |
| test | verification-before-completion, systematic-debugging on failure |
| compound | verification-before-completion |

## Domain skills

Domain skills should declare:

- phase applicability
- file patterns
- constraints
- design guidance
- full implementation guidance

Load constraints during brainstorming, design guidance during spec, and full skill only during implementation/review when needed.
