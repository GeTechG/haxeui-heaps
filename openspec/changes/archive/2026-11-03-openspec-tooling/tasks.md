# Tasks

## 1. Pinned CLI and generated skills

- [x] 1.1 Add `.claude/skills/` and `.agents/` to `.github/infra-paths` (own commit); verify: `bash .github/scripts/check-commit-kinds-test.sh` passes.
- [x] 1.2 Add `openspec/cli.pin` with `1.16.0`; verify: `openspec --version` equals the pin.
- [x] 1.3 Generate the ten skills with `openspec init --tools claude,codex --profile custom` at the pinned version and commit them; verify: every `generatedBy` under `.claude/skills/openspec-*` and `.agents/skills/openspec-*` is `1.16.0`.

## 2. Project config rules

- [x] 2.1 Add `rules.specs`, `rules.tasks`, `operations.apply.guidance` and `operations.archive.guidance` to `openspec/config.yaml`, the guidance pointing at AGENTS.md steps; verify: `openspec instructions specs --change openspec-tooling` and `openspec instructions apply --change openspec-tooling` show them without a config warning.

## 3. Main spec defects

- [x] 3.1 Write a real Purpose for `host-image-decode` and `text-font-size` in the main specs; verify: `openspec validate host-image-decode text-font-size --type spec --strict` is clean.
- [x] 3.2 The `commit-kinds`, `pointer-hit-test` and `text-input-pointer` fixes are the deltas of this change; verify after archive: `openspec validate --all --strict` is clean.

## 4. CI validation

- [x] 4.1 Write `openspec/check.sh` running the five checks of `openspec-workflow` with the pinned CLI; verify: it passes on the branch and fails on a scratch copy with a stale `generatedBy`, a `TBD` Purpose, a change without `.openspec.yaml` and an open archived task.
- [x] 4.2 Add an `openspec` job to `.github/workflows/ci.yml` that runs it; verify: the job is green on the branch.

## 5. Documentation

- [x] 5.1 Record in AGENTS.md the pin, how to raise it (global install, pin, regenerated skills in one commit), that changes are created only by `openspec new change`, and the new check; verify: AGENTS.md *Checks* lists `openspec/check.sh`.

## Workflow follow-up

- Archive this change as the last commit of the branch, rebase on `master`, run the checks, cross-review, merge.
