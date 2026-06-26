# Escalation Policy

## Must ask the user before proceeding

- Authentication or authorization design/logic changes
- Encryption, key management, PII handling
- Database schema changes or data migrations
- Destructive or irreversible operations
- Production deploy, rollback, infrastructure, CI/CD secrets
- Breaking public API or external contract
- Ambiguous requirement with multiple valid interpretations
- Significant expansion beyond requested scope

## May proceed autonomously

- Local formatting and lint fixes
- Small bug fixes with clear root cause
- Test additions that do not change behavior
- Internal refactors contained within assigned write scope
- Documentation sync required by existing rules

## Escalation format

Ask one concise question. Include:

1. Decision needed
2. Recommended option
3. Tradeoff
4. Consequence of not deciding
