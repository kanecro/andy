# Fugu Agent Map

| andy role | Capability profile | Typical use |
|---|---|---|
| coordinator | planning high, code_editing false | decomposition, integration |
| codebase-analyzer | retrieval high | understand existing code |
| spec-writer | requirements high | write artifacts |
| spec-validator | adversarial_review high | find spec gaps |
| implementer | code_editing true, testing high | scoped implementation |
| build-error-resolver | debugging high | repair failures |
| reviewer | critical_review high, code_editing false | review |
| review-aggregator | synthesis high | consolidate findings |

Fugu should choose models according to these capability profiles.
