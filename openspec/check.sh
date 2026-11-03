#!/usr/bin/env bash
# Validates this fork's OpenSpec artifacts with the CLI version pinned in openspec/cli.pin.
# Run from anywhere; exits non-zero and prints ::error:: lines on any failure.
set -euo pipefail
cd "$(dirname "$0")/.."

pin=$(tr -d '[:space:]' < openspec/cli.pin)
if command -v openspec >/dev/null && [ "$(openspec --version 2>/dev/null)" = "$pin" ]; then
  openspec() { command openspec "$@"; }
else
  openspec() { npm exec --yes --package="@fission-ai/openspec@$pin" -- openspec "$@"; }
fi
export OPENSPEC_TELEMETRY=0

fail=0
err() { echo "::error::$*"; fail=1; }

# 1. Strict validation of every spec and active change.
openspec validate --all --strict --no-interactive || err "openspec validate --all --strict failed"

# 2. No main spec keeps the Purpose placeholder that archive writes.
for spec in openspec/specs/*/spec.md; do
  purpose=$(awk '/^## Purpose/{f=1;next} f&&NF{print;exit}' "$spec")
  case "$purpose" in
    "TBD - created by archiving change"*) err "$spec: Purpose is the archive placeholder" ;;
  esac
done

# 3. Every active change was created by the CLI.
for change in openspec/changes/*/; do
  [ "$(basename "$change")" = archive ] && continue
  [ -f "$change.openspec.yaml" ] || err "${change%/}: no .openspec.yaml (create changes with 'openspec new change')"
done

# 4. The generated skills come from the pinned version.
for skill in .claude/skills/openspec-*/SKILL.md .agents/skills/openspec-*/SKILL.md; do
  [ -e "$skill" ] || continue
  gen=$(sed -n 's/^[[:space:]]*generatedBy:[[:space:]]*"\{0,1\}\([^"]*\)"\{0,1\}[[:space:]]*$/\1/p' "$skill" | head -n1)
  [ "$gen" = "$pin" ] || err "$skill: generatedBy '${gen}' differs from openspec/cli.pin '$pin'"
done

# 5. Archived changes have no open task but human ones.
while IFS= read -r hit; do
  err "$hit: open task in an archived change"
done < <(grep -rnE --include=tasks.md '^[[:space:]]*- \[ \]' openspec/changes/archive 2>/dev/null | grep -v '\[human\]' || true)

exit "$fail"
