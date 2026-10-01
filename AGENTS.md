# haxeui-heaps — agent guide

Independent fork of `haxeui/haxeui-heaps` (Heaps backend of HaxeUI). Its consumers pin it by commit; they do not dictate how it is worked on. This file is the source of truth here.

## Commits
- Every commit is **code** (library sources under `haxe/`, upstream metadata, tests) or **infrastructure** (the paths listed in `.github/infra-paths`: this file, `openspec/`, our CI and scripts). Never both — CI rejects a mixed commit.
- Code commit messages are written as for upstream: `area(scope): imperative summary`, no mention of consumers or their paths.
- An upstream PR is a cherry-pick of one task's code commits; keep them self-contained.
- Changing the list of infrastructure paths is an infrastructure commit.

## Checks
- `bash .github/scripts/check-commit-kinds-test.sh` — self-test of the commit-kind check.
- `bash .github/scripts/check-commit-kinds.sh origin/master..HEAD` — run it on your branch before pushing.
- Build: Haxe 4.3.7 (pinned in `.github/workflows/ci.yml`), with the forks of `haxeui-core` and `heaps` as libraries; the compile command is the `build` job in that workflow. The library has no test suite of its own yet.

## Specs
`openspec/` holds this fork's own specs (`openspec/specs/`). Behaviour or rule changes go through `openspec/changes/`.

## Delivery
Work on a branch, open a PR to `master`; never push to `master` directly.
