#!/usr/bin/env bash
# prototypes/relay-app-mvp/.autopilot/project.sh — bash fallback wrapper (CI/Linux).
# Windows dev flow uses project.ps1.

set -uo pipefail
verb="${1:-help}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/../../.." && pwd)"
proto="prototypes/relay-app-mvp"
cd "$repo_root"

case "$verb" in
  doctor)
    for c in git gh dotnet; do
      command -v "$c" >/dev/null || { echo "missing: $c"; exit 1; }
    done
    [ -f "$proto/RelayApp.sln" ] || { echo "not a relay-app-mvp root: $proto/RelayApp.sln missing"; exit 1; }
    for csproj in RelayApp.Core RelayApp.Desktop RelayApp.CodexProtocol RelayApp.CodexProtocol.Spike; do
      [ -f "$proto/$csproj/$csproj.csproj" ] || { echo "missing $proto/$csproj/$csproj.csproj"; exit 1; }
    done
    remote=$(git remote get-url origin 2>/dev/null || true)
    [ -n "$remote" ] || { echo 'no origin remote'; exit 1; }
    expected="$proto/.autopilot/hooks"
    hp=$(git config --get core.hooksPath 2>/dev/null || true)
    if [ "$hp" != "$expected" ]; then
      echo "WARN: core.hooksPath is '${hp:-<unset>}' (expected $expected). Run: $proto/.autopilot/project.sh install-hooks" >&2
    elif [ ! -x "$expected/pre-commit" ]; then
      echo "WARN: core.hooksPath set, but $expected/pre-commit missing/non-executable." >&2
    elif [ ! -x "$expected/commit-msg" ]; then
      echo "WARN: core.hooksPath set, but $expected/commit-msg missing (trailer gates inactive)." >&2
    fi
    echo "ok (remote $remote)"
    ;;

  test)
    echo "project.sh test: dotnet build $proto/RelayApp.sln -c Release"
    dotnet build "$proto/RelayApp.sln" -c Release --nologo -v minimal
    ;;

  audit)
    echo '=== dotnet outdated ==='
    dotnet list "$proto/RelayApp.sln" package --outdated 2>/dev/null || true
    echo ''
    echo '=== .cs file counts ==='
    for p in RelayApp.Core RelayApp.Desktop RelayApp.CodexProtocol RelayApp.CodexProtocol.Spike; do
      n=$(find "$proto/$p" -name '*.cs' -not -path '*/bin/*' -not -path '*/obj/*' 2>/dev/null | wc -l)
      echo "  $p : $n"
    done
    echo ''
    echo '=== Churn hotspots (30 days) ==='
    git log --since="30.days" --pretty=format: --name-only -- "$proto/RelayApp.Core" "$proto/RelayApp.Desktop" "$proto/RelayApp.CodexProtocol" "$proto/RelayApp.CodexProtocol.Spike" 2>/dev/null \
      | grep -E '\.cs$' | sort | uniq -c | sort -rn | head -10
    ;;

  install-hooks)
    target="$proto/.autopilot/hooks"
    current=$(git config --get core.hooksPath 2>/dev/null || true)
    if [ "$current" = "$target" ]; then
      echo "core.hooksPath already set to $target"
    else
      git config core.hooksPath "$target"
      echo "core.hooksPath set to $target (was: ${current:-<unset>})"
    fi
    for hook in pre-commit commit-msg protect.sh commit-msg-protect.sh; do
      [ -f "$target/$hook" ] || { echo "$target/$hook missing"; exit 1; }
    done
    chmod +x "$target/pre-commit" "$target/commit-msg" "$target/protect.sh" "$target/commit-msg-protect.sh"
    bash "$target/pre-commit"
    echo 'relay-app-mvp autopilot hooks installed and smoke-tested.'
    ;;

  start)
    echo "Paste the contents of $proto/.autopilot/RUN.txt into Claude Code."
    echo "Absolute path:"
    echo "  $repo_root/$proto/.autopilot/RUN.txt"
    ;;

  stop)   touch "$proto/.autopilot/HALT"; echo "HALT created at $proto/.autopilot/HALT." ;;
  resume) rm -f "$proto/.autopilot/HALT"; echo 'HALT removed.' ;;

  help|*)
    cat <<EOF
project.sh — relay-app-mvp autopilot wrapper

Verbs:
  doctor          Fast env check.
  test            dotnet build $proto/RelayApp.sln -c Release.
  audit           Outdated + churn + .cs counts.
  install-hooks   Sets core.hooksPath=$proto/.autopilot/hooks; smoke-tests.
  start           Print path to RUN.txt for pasting into Claude Code.
  stop            touch $proto/.autopilot/HALT.
  resume          Remove $proto/.autopilot/HALT.
EOF
    ;;
esac
