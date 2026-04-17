#!/usr/bin/env bash
# prototypes/relay-app-mvp/.autopilot/hooks/commit-msg-protect.sh
#
# Trailer-dependent enforcement. Runs at commit-msg time where $1 is the authoritative
# commit message file (unlike pre-commit, where .git/COMMIT_EDITMSG is stale under
# `git commit -m ...`).
#
# Scope: only enforces when the commit touches prototypes/relay-app-mvp/**.
#
# Enforces:
#   1. New IMMUTABLE blocks in prototypes/relay-app-mvp/.autopilot/PROMPT.md require
#      'IMMUTABLE-ADD: <name>' trailer.
#   2. Commits with >5 deletes under prototypes/relay-app-mvp/ OR any delete under
#      prototypes/relay-app-mvp/RelayApp.Core|Desktop|CodexProtocol or under the
#      prototype audit docs require 'cleanup-operator-approved: yes' trailer.

set -euo pipefail

msg_file="${1:-}"
if [ -z "$msg_file" ] || [ ! -f "$msg_file" ]; then
  echo "commit-msg-protect: expected commit message file as \$1"
  exit 1
fi
commit_msg=$(cat "$msg_file")

PROTO="prototypes/relay-app-mvp"
PROMPT="$PROTO/.autopilot/PROMPT.md"

# Scope gate: only engage when the commit touches the prototype tree.
staged=$(git diff --cached --name-only)
if ! printf '%s\n' "$staged" | grep -q "^$PROTO/"; then
  exit 0
fi

has_trailer() {
  local key="$1" expected="$2"
  local line
  line=$(printf '%s\n' "$commit_msg" | grep -Ei "^${key}:[[:space:]]*" | head -1 || true)
  [ -z "$line" ] && return 1
  local val
  val=$(printf '%s' "$line" | sed -E "s/^${key}:[[:space:]]*//I")
  if [ "$expected" = "*" ]; then
    [ -n "$val" ]
  else
    [ "${val,,}" = "${expected,,}" ]
  fi
}

# ---------------------------------------------------------------------------
# Bulk-delete / sensitive-path trailer gate (scoped to prototype tree).
# ---------------------------------------------------------------------------
deleted_files=$(git diff --cached --name-only --diff-filter=D | grep "^$PROTO/" || true)
deleted_count=$(printf '%s' "$deleted_files" | grep -c . || true)

if [ "$deleted_count" -gt 5 ]; then
  if ! has_trailer "cleanup-operator-approved" "yes"; then
    echo "commit-msg-protect: commit deletes $deleted_count files under $PROTO/ (>5)."
    echo "  Requires 'cleanup-operator-approved: yes' trailer."
    exit 1
  fi
fi

if [ -n "$deleted_files" ]; then
  sensitive=$(printf '%s\n' "$deleted_files" | grep -E "^$PROTO/(RelayApp\.(Core|Desktop|CodexProtocol|CodexProtocol\.Spike)/|[A-Za-z0-9_.-]+-audit\.md$|phase-[a-z]-[a-z0-9-]+\.md$)" || true)
  if [ -n "$sensitive" ] && ! has_trailer "cleanup-operator-approved" "yes"; then
    echo "commit-msg-protect: commit deletes sensitive file(s) under $PROTO/:"
    printf '  %s\n' $sensitive
    echo "  Requires 'cleanup-operator-approved: yes' trailer."
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# New-IMMUTABLE-marker authorization (only if PROMPT.md was touched).
# ---------------------------------------------------------------------------
if ! printf '%s\n' "$staged" | grep -qx "$PROMPT"; then
  exit 0
fi
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  exit 0
fi

base_markers=$(git show "HEAD:$PROMPT" 2>/dev/null | grep -oE '\[IMMUTABLE:BEGIN [a-z-]+\]' | sort -u || true)
head_markers=$(git show ":$PROMPT" | grep -oE '\[IMMUTABLE:BEGIN [a-z-]+\]' | sort -u)
added_markers=$(comm -23 <(printf '%s\n' "$head_markers") <(printf '%s\n' "$base_markers") \
                  | sed -E 's/^\[IMMUTABLE:BEGIN ([a-z-]+)\]$/\1/' | grep -v '^$' || true)

for name in $added_markers; do
  if ! printf '%s\n' "$commit_msg" | grep -qE "^IMMUTABLE-ADD:[[:space:]]*${name}[[:space:]]*$"; then
    echo "commit-msg-protect: new IMMUTABLE block '$name' introduced without authorization."
    echo "  Commit message must include on its own line: 'IMMUTABLE-ADD: $name'"
    echo "  This prevents self-evolution from granting itself new charter."
    exit 1
  fi
done

exit 0
