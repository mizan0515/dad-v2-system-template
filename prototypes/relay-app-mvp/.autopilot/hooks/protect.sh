#!/usr/bin/env bash
# prototypes/relay-app-mvp/.autopilot/hooks/protect.sh
#
# Pre-commit guard for the relay-app-mvp autopilot's safety surface.
# Scope: only enforces when the commit touches prototypes/relay-app-mvp/**. Commits
# affecting only the rest of the dad-v2-system-template repo are passed through
# unchanged (the root .githooks/pre-commit handles those).
#
# Enforces (no commit-message access — that moves to commit-msg-protect.sh):
#   1. prototypes/relay-app-mvp/.autopilot/PROMPT.md IMMUTABLE blocks cannot be modified.
#   2. Removed IMMUTABLE markers are rejected outright.
#   3. prototypes/relay-app-mvp/.autopilot/MVP-GATES.md must exist with a parseable
#      "Gate count: <N>" line — the halt trigger depends on it.
#   4. prototypes/relay-app-mvp/.autopilot/STATE.md must keep a minimum set of entries
#      under `protected_paths:` (the loop's self-protection list).
#   5. Hard-cap: >20 file deletions per commit is always rejected.
#
# Trailer-dependent gates (IMMUTABLE-ADD for new blocks, cleanup-operator-approved for
# >5/sensitive deletes) run in commit-msg-protect.sh.

set -euo pipefail

PROTO="prototypes/relay-app-mvp"
PROMPT="$PROTO/.autopilot/PROMPT.md"
MVPGATES="$PROTO/.autopilot/MVP-GATES.md"
STATE="$PROTO/.autopilot/STATE.md"

# ---------------------------------------------------------------------------
# Scope gate: only engage when the commit touches the prototype tree.
# ---------------------------------------------------------------------------
staged=$(git diff --cached --name-only)
if ! printf '%s\n' "$staged" | grep -q "^$PROTO/"; then
  exit 0
fi

# ---------------------------------------------------------------------------
# Check 5: hard-cap on bulk deletes (>5 and sensitive-path checks run in
# commit-msg because they need access to the commit message trailers).
# Scope the count to prototype-tree deletions only.
# ---------------------------------------------------------------------------
deleted_count=$(git diff --cached --name-only --diff-filter=D | grep -c "^$PROTO/" || true)

if [ "$deleted_count" -gt 20 ]; then
  echo "protect.sh: commit deletes $deleted_count files under $PROTO/; hard cap is 20 per commit."
  echo "  → reject. Split into multiple cleanup PRs."
  exit 1
fi

# ---------------------------------------------------------------------------
# Check 3 + 4: sentinel files must stay healthy on every prototype-touching commit.
# ---------------------------------------------------------------------------
if [ ! -f "$MVPGATES" ]; then
  echo "protect.sh: $MVPGATES missing. This file is the MVP halt trigger;"
  echo "  losing it disables a safety path. Restore before committing."
  exit 1
fi

if ! grep -qE '^Gate count:[[:space:]]*[0-9]+' "$MVPGATES"; then
  echo "protect.sh: $MVPGATES is missing a parseable 'Gate count: <N>' line."
  echo "  The halt trigger depends on it. Restore."
  exit 1
fi

if [ ! -f "$STATE" ]; then
  echo "protect.sh: $STATE missing. Cannot verify protected_paths."
  exit 1
fi

# These paths must remain in STATE.md protected_paths: at all times.
REQUIRED_PROTECTED=(
  "prototypes/relay-app-mvp/RelayApp.sln"
  "prototypes/relay-app-mvp/.autopilot/PROMPT.md"
  "prototypes/relay-app-mvp/.autopilot/hooks/"
  "prototypes/relay-app-mvp/.autopilot/project.ps1"
  "prototypes/relay-app-mvp/.autopilot/project.sh"
  "prototypes/relay-app-mvp/.autopilot/MVP-GATES.md"
  "prototypes/relay-app-mvp/.autopilot/CLEANUP-LOG.md"
  "prototypes/relay-app-mvp/.autopilot/CLEANUP-CANDIDATES.md"
  "PROJECT-RULES.md"
  "CLAUDE.md"
  "AGENTS.md"
  "DIALOGUE-PROTOCOL.md"
  ".githooks/"
  "en/"
  "ko/"
  "tools/"
)
for p in "${REQUIRED_PROTECTED[@]}"; do
  if ! grep -qE "^[[:space:]]*-[[:space:]]*${p//\//\\/}[[:space:]]*$" "$STATE"; then
    echo "protect.sh: STATE.md protected_paths is missing required entry: '$p'"
    echo "  → reject. Restore it before committing."
    exit 1
  fi
done

# ---------------------------------------------------------------------------
# Checks 1 + 2: PROMPT.md IMMUTABLE integrity (skip if PROMPT.md not staged).
# ---------------------------------------------------------------------------
if ! printf '%s\n' "$staged" | grep -qx "$PROMPT"; then
  exit 0
fi

# First-ever commit (no HEAD). Scaffolding pass.
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  exit 0
fi

BLOCKS=(product-directive core-contract boot budget blast-radius halt cleanup-safety mvp-gate exit-contract)

tmp_base=$(mktemp); tmp_head=$(mktemp)
trap 'rm -f "$tmp_base" "$tmp_head"' EXIT

# HEAD may not yet contain the PROMPT (first install) — treat missing as empty.
git show "HEAD:$PROMPT" > "$tmp_base" 2>/dev/null || : > "$tmp_base"
git show ":$PROMPT"     > "$tmp_head"

# Detect removed markers (old IMMUTABLE block deleted). Never allowed.
new_markers=$(grep -oE '\[IMMUTABLE:BEGIN [a-z-]+\]' "$tmp_head" | sort -u || true)
old_markers=$(grep -oE '\[IMMUTABLE:BEGIN [a-z-]+\]' "$tmp_base" | sort -u || true)
removed_markers=$(comm -13 <(printf '%s\n' "$new_markers") <(printf '%s\n' "$old_markers") | sed -E 's/^\[IMMUTABLE:BEGIN ([a-z-]+)\]$/\1/')
if [ -n "$removed_markers" ]; then
  echo "protect.sh: IMMUTABLE block(s) removed from $PROMPT:"
  printf '  %s\n' $removed_markers
  echo "  → reject. IMMUTABLE blocks are append-only and content-locked."
  exit 1
fi

# Check 1: for each named block that exists in HEAD, staged content must match.
for name in "${BLOCKS[@]}"; do
  begin="\[IMMUTABLE:BEGIN $name\]"
  end="\[IMMUTABLE:END $name\]"

  if ! grep -q "$begin" "$tmp_head" || ! grep -q "$end" "$tmp_head"; then
    echo "protect.sh: IMMUTABLE markers for '$name' are missing from $PROMPT"
    echo "  → reject. Restore [IMMUTABLE:BEGIN $name] ... [IMMUTABLE:END $name]."
    exit 1
  fi

  base_block=$(awk "/$begin/,/$end/" "$tmp_base")
  head_block=$(awk "/$begin/,/$end/" "$tmp_head")

  # Bootstrap: block doesn't exist in HEAD. Allowed here; commit-msg-protect.sh
  # enforces the IMMUTABLE-ADD trailer.
  if [ -z "$base_block" ]; then
    continue
  fi

  if [ "$base_block" != "$head_block" ]; then
    echo "protect.sh: IMMUTABLE block '$name' was modified in $PROMPT"
    echo "  → reject. These blocks are self-evolution-immutable."
    echo "  → if you genuinely need to change one, do it in a separate operator"
    echo "    commit with the block content restored and the change in a"
    echo "    dedicated mutable section instead."
    exit 1
  fi
done

exit 0
