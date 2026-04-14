param(
    [string]$Root = ".",
    [string]$CodexHome
)

$ErrorActionPreference = "Stop"

function Get-CodexHomePath {
    param([string]$Value)

    if (-not [string]::IsNullOrWhiteSpace($Value)) {
        if (Test-Path -LiteralPath $Value) {
            return (Resolve-Path -LiteralPath $Value).Path
        }

        return [System.IO.Path]::GetFullPath($Value)
    }

    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        if (Test-Path -LiteralPath $env:CODEX_HOME) {
            return (Resolve-Path -LiteralPath $env:CODEX_HOME).Path
        }

        return [System.IO.Path]::GetFullPath($env:CODEX_HOME)
    }

    return (Join-Path $HOME ".codex")
}

function Get-PathHash {
    param([string]$Value)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
        $hash = $sha.ComputeHash($bytes)
        return ([System.BitConverter]::ToString($hash)).Replace("-", "").Substring(0, 8).ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Get-DirectoryEntry {
    param([string]$Path)

    $parent = Split-Path -Path $Path -Parent
    $leaf = Split-Path -Path $Path -Leaf
    if ([string]::IsNullOrWhiteSpace($parent) -or -not (Test-Path -LiteralPath $parent)) {
        return $null
    }

    return @(Get-ChildItem -LiteralPath $parent -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $leaf } | Select-Object -First 1)[0]
}

$repoRoot = (Resolve-Path -LiteralPath $Root).Path
$codexHomePath = Get-CodexHomePath -Value $CodexHome
$skillsDestRoot = Join-Path $codexHomePath "skills"
$manifestRoot = Join-Path $skillsDestRoot ".dad-v2-links"
$repoLeaf = Split-Path -Path $repoRoot -Leaf
$manifestName = "$repoLeaf-$(Get-PathHash -Value $repoRoot).json"
$manifestPath = Join-Path $manifestRoot $manifestName

if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Output "No Codex skill registration manifest found for $repoRoot"
    return
}

$manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

foreach ($skill in @($manifest.skills)) {
    $item = Get-DirectoryEntry -Path $skill.destination_path
    if (-not $item) {
        continue
    }

    $isReparsePoint = ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
    if (-not $isReparsePoint) {
        Write-Warning "Skipping non-link destination: $($skill.destination_path)"
        continue
    }

    Remove-Item -LiteralPath $skill.destination_path -Force -Recurse
    Write-Output "Removed Codex skill link: $($skill.destination_path)"
}

Remove-Item -LiteralPath $manifestPath -Force
Write-Output "Removed Codex skill registration manifest: $manifestPath"
Write-Output "Restart Codex Desktop to drop unloaded skills from the session picker."
