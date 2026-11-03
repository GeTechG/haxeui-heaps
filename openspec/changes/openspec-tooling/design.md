## Context
OpenSpec 1.16.0 is installed globally on the maintainer's machine, one version for Sprout and every fork. The fork has no OpenSpec skills and no OpenSpec check in CI.

## Decisions
- **Pin as a plain file.** `openspec/cli.pin` holds only the version, so CI and scripts read it with `cat`. CI runs `npm exec --yes --package=@fission-ai/openspec@<pin> -- openspec`; `openspec/check.sh` uses the global `openspec` when its version equals the pin, so a local run needs no download.
- **Two skill directories, not a link.** The generated Claude and Codex skills differ (the Codex ones name `$openspec-…` commands), so `.claude/skills/openspec-*` and `.agents/skills/openspec-*` are both real directories, as `openspec init` writes them, and `openspec update` keeps regenerating them in place.
- **One script for the checks.** The five checks live in `openspec/check.sh`, so a local run and CI are the same command; the job installs nothing but Node.
- **Requirement splits under MODIFIED + ADDED.** Each long requirement keeps its header and every scenario under MODIFIED with its text cut to one behavior; the behaviors cut out become ADDED requirements with their own scenarios. Purposes are edited in the main specs directly, since a delta's Purpose is read only for a new capability.

## Risks / Trade-offs
- CI downloads the CLI on each run (a few seconds); acceptable against an unpinned tool.
