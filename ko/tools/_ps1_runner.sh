#!/usr/bin/env sh
set -eu

script_path=$1
shift

if command -v pwsh >/dev/null 2>&1; then
  runner="pwsh"
elif command -v powershell >/dev/null 2>&1; then
  runner="powershell"
elif command -v powershell.exe >/dev/null 2>&1; then
  runner="powershell.exe"
else
  echo "PowerShell not found. Install PowerShell Core 7.2+ to use tools/*.sh." >&2
  exit 1
fi

exec "$runner" -ExecutionPolicy Bypass -File "$script_path" "$@"
