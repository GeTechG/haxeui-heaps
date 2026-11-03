## MODIFIED Requirements

### Requirement: The check proves itself
`.github/scripts/check-commit-kinds-test.sh` SHALL build a throwaway repository with a mixed commit and fail unless the check rejects it; CI runs it before the real check.

#### Scenario: Check that accepts a mixed commit
- **WHEN** a change to `check-commit-kinds.sh` makes it accept a commit that touches both kinds
- **THEN** the self-test fails and the `commit-kinds` CI job fails before the real check runs
