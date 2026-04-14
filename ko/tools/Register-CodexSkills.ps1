param(
    [string]$Root = ".",
    [string]$CodexHome,
    [switch]$Force,
    [switch]$ValidateOnly,
    [switch]$AllowTemplateNamespace
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

function New-SkillLink {
    param(
        [string]$Path,
        [string]$Target
    )

    $isWindows = $env:OS -eq "Windows_NT"
    if ($isWindows) {
        try {
            New-Item -ItemType Junction -Path $Path -Target $Target | Out-Null
            return "junction"
        }
        catch {
            New-Item -ItemType SymbolicLink -Path $Path -Target $Target | Out-Null
            return "symlink"
        }
    }

    New-Item -ItemType SymbolicLink -Path $Path -Target $Target | Out-Null
    return "symlink"
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

function Remove-StaleRegistrations {
    param([string]$ManifestDirectory)

    if (-not (Test-Path -LiteralPath $ManifestDirectory)) {
        return
    }

    foreach ($manifestFile in @(Get-ChildItem -Path $ManifestDirectory -File -Filter '*.json')) {
        $manifest = Get-Content -Path $manifestFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not $manifest.repo_root) {
            continue
        }

        if (Test-Path -LiteralPath $manifest.repo_root) {
            continue
        }

        foreach ($skill in @($manifest.skills)) {
            if (-not $skill.destination_path) {
                continue
            }

            $existingEntry = Get-DirectoryEntry -Path $skill.destination_path
            if (-not $existingEntry) {
                continue
            }

            $item = $existingEntry
            $isReparsePoint = ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
            if (-not $isReparsePoint) {
                throw "Stale managed skill destination is no longer a link or junction: $($skill.destination_path)"
            }

            Remove-Item -LiteralPath $skill.destination_path -Force -Recurse
        }

        Remove-Item -LiteralPath $manifestFile.FullName -Force
    }
}

$repoRoot = (Resolve-Path -LiteralPath $Root).Path
$skillsSourceRoot = Join-Path $repoRoot ".agents\skills"
if (-not (Test-Path -LiteralPath $skillsSourceRoot)) {
    throw "Skills source directory not found: $skillsSourceRoot"
}

$metadataValidator = Join-Path $PSScriptRoot "Validate-CodexSkillMetadata.ps1"
if (-not (Test-Path -LiteralPath $metadataValidator)) {
    throw "Skill metadata validator not found: $metadataValidator"
}

& $metadataValidator -Root $repoRoot | Out-Null
if (-not $?) {
    throw "Codex skill metadata validation failed. Fix the skill metadata before registration."
}

$skillDirs = @(Get-ChildItem -Path $skillsSourceRoot -Directory | Sort-Object Name)
if ($skillDirs.Count -eq 0) {
    throw "No skill directories found under $skillsSourceRoot"
}

$templateNamespaceDetected = $false
foreach ($suffix in @('dialogue-start', 'repeat-workflow', 'repeat-workflow-auto')) {
    foreach ($skillDir in $skillDirs) {
        if ($skillDir.Name -eq "dadtpl-$suffix") {
            $templateNamespaceDetected = $true
        }
    }
}

if ($templateNamespaceDetected -and -not $AllowTemplateNamespace) {
    throw "Template skill namespace 'dadtpl-' is still active. Run tools/Set-CodexSkillNamespace.ps1 -Namespace <project-prefix> before registration."
}

$codexHomePath = Get-CodexHomePath -Value $CodexHome
$skillsDestRoot = Join-Path $codexHomePath "skills"
$manifestRoot = Join-Path $skillsDestRoot ".dad-v2-links"

if (-not $ValidateOnly) {
    New-Item -ItemType Directory -Force -Path $skillsDestRoot | Out-Null
    New-Item -ItemType Directory -Force -Path $manifestRoot | Out-Null
    Remove-StaleRegistrations -ManifestDirectory $manifestRoot
}

$repoLeaf = Split-Path -Path $repoRoot -Leaf
$manifestName = "$repoLeaf-$(Get-PathHash -Value $repoRoot).json"
$manifestPath = Join-Path $manifestRoot $manifestName
$existingManifest = $null
if (Test-Path -LiteralPath $manifestPath) {
    $existingManifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
}

$collisions = New-Object System.Collections.Generic.List[string]
$registeredSkills = New-Object System.Collections.Generic.List[object]
$currentSkillNames = @($skillDirs | ForEach-Object { $_.Name })

if ($existingManifest) {
    $staleEntries = @($existingManifest.skills | Where-Object { $_.name -notin $currentSkillNames })
    foreach ($staleEntry in $staleEntries) {
        if (-not $staleEntry.destination_path) {
            continue
        }

        $staleItem = Get-DirectoryEntry -Path $staleEntry.destination_path
        if (-not $staleItem) {
            continue
        }

        $isReparsePoint = ($staleItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
        if (-not $isReparsePoint) {
            throw "Managed stale skill destination is no longer a link or junction: $($staleEntry.destination_path)"
        }

        Remove-Item -LiteralPath $staleEntry.destination_path -Force -Recurse
    }
}

foreach ($skillDir in $skillDirs) {
    $skillName = $skillDir.Name
    $skillDoc = Join-Path $skillDir.FullName "SKILL.md"
    $skillMeta = Join-Path $skillDir.FullName "agents\openai.yaml"
    if (-not (Test-Path -LiteralPath $skillDoc)) {
        throw "Missing SKILL.md for skill '$skillName': $skillDoc"
    }

    if (-not (Test-Path -LiteralPath $skillMeta)) {
        throw "Missing agents/openai.yaml for skill '$skillName': $skillMeta"
    }

    $destinationPath = Join-Path $skillsDestRoot $skillName
    $knownEntry = $null
    if ($existingManifest) {
        $knownEntry = @($existingManifest.skills | Where-Object { $_.name -eq $skillName }) | Select-Object -First 1
    }

    $existingItem = Get-DirectoryEntry -Path $destinationPath
    if ($existingItem) {
        $isReparsePoint = ($existingItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
        $canReuse = $knownEntry -and
            $knownEntry.source_path -eq $skillDir.FullName -and
            $knownEntry.destination_path -eq $destinationPath -and
            $isReparsePoint

        if (-not $canReuse -and -not $Force) {
            $collisions.Add("$skillName -> $destinationPath") | Out-Null
            continue
        }

        if (-not $canReuse -and $Force -and -not $ValidateOnly) {
            Remove-Item -LiteralPath $destinationPath -Force -Recurse
        }
    }

    $linkType = $knownEntry.link_type
    if (-not (Get-DirectoryEntry -Path $destinationPath) -and -not $ValidateOnly) {
        $linkType = New-SkillLink -Path $destinationPath -Target $skillDir.FullName
    }

    $registeredSkills.Add([PSCustomObject]@{
            name = $skillName
            source_path = $skillDir.FullName
            destination_path = $destinationPath
            link_type = $linkType
        }) | Out-Null
}

if ($collisions.Count -gt 0) {
    throw ("Codex skill registration collisions found. Re-run with -Force to replace: " + ($collisions -join ", "))
}

if ($ValidateOnly) {
    Write-Output "Codex skill registration validation passed for $repoRoot"
    foreach ($skill in $registeredSkills) {
        Write-Output "- $($skill.name) -> $($skill.destination_path)"
    }
    return
}

$manifest = [PSCustomObject]@{
    repo_root = $repoRoot
    codex_home = $codexHomePath
    skills_root = $skillsSourceRoot
    registered_at = (Get-Date).ToString("o")
    skills = $registeredSkills
}

$manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Output "Registered Codex Desktop skills under $skillsDestRoot"
foreach ($skill in $registeredSkills) {
    Write-Output "- $($skill.name) -> $($skill.destination_path) [$($skill.link_type)]"
}
Write-Output "Restart Codex Desktop to pick up new skills."
